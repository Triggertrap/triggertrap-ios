//
//  RemoteOutputServer.h
//  TTLibrary
//
//  Created by Ross Gibson on 19/02/2014.
//  Copyright (c) 2014 Triggertrap Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CocoaAsyncSocket;

@protocol RemoteOutputServerDelegate <NSObject>
@optional
- (void)socketDidReadData;
- (void)socketDidAcceptNewSocket;
- (void)socketDidDisconnect;
- (void)netServiceDidPublish:(NSString *)name;

@end

@interface RemoteOutputServer : NSObject <NSNetServiceDelegate> {
    GCDAsyncSocket *_asyncSocket;
    NSData *_PING;
    NSNetService *_netService; 
    NSData *_CRLF;
    NSMutableDictionary *_hostNames;
    NSMutableArray *_connectedSockets;
}

+ (RemoteOutputServer *)sharedInstance;

@property (assign, nonatomic) id<RemoteOutputServerDelegate> delegate;

@property (strong, nonatomic, readonly) NSString *serviceName;
@property (assign, nonatomic) BOOL running;

#pragma mark - Public

- (void)startService;
- (void)stopService;
- (void)triggerNow;
//- (void)triggerWithPulseDuration:(double)duration;

#pragma mark - Getters

- (NSMutableDictionary *)hostNames;
- (NSMutableArray *)connectedSockets;


#pragma mark - Sockets

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket;
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;

#pragma mark - Scoket Helpers

- (NSString *)parseResponse:(NSData *)data;
#pragma mark - Net Service

- (void)netServiceDidPublish:(NSNetService *)ns;
- (void)netServiceDidStop:(NSNetService *)sender;
- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict;
@end
