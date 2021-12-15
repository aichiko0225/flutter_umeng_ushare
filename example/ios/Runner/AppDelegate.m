#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

#import <UMCommon/UMCommon.h>
#if __has_include(<UMShare/UMShare.h>)
#import <UMShare/UMShare.h>
#endif

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// 支持所有iOS系统
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result =[[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if(!result){
        // 其他如支付等SDK的回调
    }
    return result;
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result =[[UMSocialManager defaultManager] handleOpenURL:url options:options];
    if(!result){
        // 其他如支付等SDK的回调
    }
    return result;
}

-(BOOL)application:(UIApplication*)application handleOpenURL:(NSURL *)url
{
    BOOL result =[[UMSocialManager defaultManager] handleOpenURL:url];
    if(!result){
        // 其他如支付等SDK的回调
    }
    return result;
}


- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    if(![[UMSocialManager defaultManager] handleUniversalLink:userActivity options:nil]){
        // 其他SDK的回调
    }
    return YES;
}

@end
