//
//  RemoteOutputServer.m
//
//  Created by Ross Gibson on 19/02/2014.
//  Copyright (c) 2014 Triggertrap Limited. All rights reserved.
//

#import "RemoteOutputServer.h"
#import "Constants.h"

static const long CONNECT_TAG = 45l;

@implementation RemoteOutputServer

#pragma mark - Lifecycle

static RemoteOutputServer * sharedInstance = nil;

+ (RemoteOutputServer *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[super allocWithZone:nil] init];
        sharedInstance->_PING = [@"BEEP\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        sharedInstance->_CRLF = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        sharedInstance->_hostNames = [NSMutableDictionary new];
    });
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

#pragma mark - Public

- (void)startService {
	// Create our socket.
	// We tell it to invoke our delegate methods on the main thread.
	sharedInstance->_asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:sharedInstance delegateQueue:dispatch_get_main_queue()];
    
    _asyncSocket.IPv4PreferredOverIPv6 = NO;
    
	// Create an array to hold accepted incoming connections.
	sharedInstance->_connectedSockets = [[NSMutableArray alloc] init];
    
	// Now we tell the socket to accept incoming connections.
	// We don't care what port it listens on, so we pass zero for the port number.
	// This allows the operating system to automatically assign us an available port.
	NSError *err = nil;
    
	if ([_asyncSocket acceptOnPort:0 error:&err]) {
		// So what port did the OS give us?
		UInt16 port = [_asyncSocket localPort];
        
		// Create and publish the bonjour service.
		sharedInstance->_netService = [[NSNetService alloc] initWithDomain:@"local."
                                                          type:@"_triggertrap._tcp."
                                                          name:@""
                                                          port:port];
        
		[_netService setDelegate:sharedInstance];
		[_netService publish];
	}
}

- (void)stopService  {
    [_netService stop];
}

- (void)triggerNow {
    
    for (GCDAsyncSocket *sock in _connectedSockets) {
        //NSLog(@"writing data to socket %@", sock.connectedHost);
        [sock writeData:_PING withTimeout:0 tag:0l];
        [sock readDataToData:_CRLF withTimeout:-1 tag:0];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRemoteOuptputServerDidTriggerNotification object:sharedInstance];
}

//- (void)triggerWithPulseDuration:(double)duration {
//    NSLog(@"Duration: %f", duration);
//    
//    for (GCDAsyncSocket *sock in _connectedSockets) {
//        NSString *dString = [NSString stringWithFormat:@"%f\r\n", duration];
//        NSData *data = [dString dataUsingEncoding:NSUTF8StringEncoding];
//        //NSLog(@"writing data to socket %@", sock.connectedHost);
//        [sock writeData:data withTimeout:0 tag:0l];
//        [sock readDataToData:_CRLF withTimeout:-1 tag:0];
//    }
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:kRemoteOuptputServerDidTriggerNotification object:sharedInstance];
//}

#pragma mark - Getters

- (NSString *)serviceName {
    return _netService.name;
}

- (NSMutableDictionary *)hostNames {
    return _hostNames;
}

- (NSMutableArray *)connectedSockets {
    return _connectedSockets;
}

#pragma mark - Sockets

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *command = [sharedInstance parseResponse:data];
    
    if (tag == CONNECT_TAG && sock.connectedHost != nil) {
        [_hostNames setObject:command forKey:sock.connectedHost];
        
        if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(socketDidReadData)]) {
            [sharedInstance.delegate performSelector:@selector(socketDidReadData)];
        }
    }
    [sock readDataToData:_CRLF withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
	// The newSocket automatically inherits its delegate & delegateQueue from its parent.
	[_connectedSockets addObject:newSocket];
    
    if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(socketDidAcceptNewSocket)]) {
        [sharedInstance.delegate performSelector:@selector(socketDidAcceptNewSocket)];
    }
    
    [newSocket readDataToData:_CRLF withTimeout:-1 tag:CONNECT_TAG];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
	[_connectedSockets removeObject:sock];
    
    if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(socketDidDisconnect)]) {
        [sharedInstance.delegate performSelector:@selector(socketDidDisconnect)];
    }
}

#pragma mark - Scoket Helpers

- (NSString *)parseResponse:(NSData *)data {
    NSString *command = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return command;
}

#pragma mark - Net Service

- (void)netServiceDidPublish:(NSNetService *)ns {
    
    _running = YES;
    
    if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(netServiceDidPublish:)]) {
        [sharedInstance.delegate performSelector:@selector(netServiceDidPublish:) withObject:[ns name]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRemoteOutputServerStatusChangedNotification object:nil];
}

- (void)netServiceDidStop:(NSNetService *)sender {
    _netService = nil;
    _running = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRemoteOutputServerStatusChangedNotification object:nil];
    
    for (GCDAsyncSocket *sock in _connectedSockets) {
        [sock disconnect];
    }
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict {
	// Override me to do something here...
	// Note: This method in invoked on our bonjour thread.
    
    _running = NO;
}

@end
