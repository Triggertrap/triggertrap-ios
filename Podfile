platform :ios, '10.0'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

def common_pods
    pod 'CTFeedback'
    pod 'GPUImage'
    pod 'Mixpanel'
    pod 'PebbleKit'
    pod 'pop'
    pod 'TTCounterLabel'
end

target 'TriggertrapSLR' do
    common_pods
    pod 'Crashlytics'
    pod 'Fabric'
    pod 'Shimmer'
end
