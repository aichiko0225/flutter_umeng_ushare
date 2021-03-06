#import "FlutterUmengUsharePlugin.h"
#import <UMCommon/UMCommon.h>
#if __has_include(<UMShare/UMShare.h>)
#import <UMShare/UMShare.h>
#endif

@implementation FlutterUmengUsharePlugin
{
    NSString *_bundleId;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_umeng_ushare"
            binaryMessenger:[registrar messenger]];
    FlutterUmengUsharePlugin* instance = [[FlutterUmengUsharePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }

    if ([@"initUMConfigure" isEqualToString:call.method]) {
        NSDictionary *dic = call.arguments[@"appkey"];
        NSString *appkey = dic[@"iosKey"];
        NSString *applicationId = call.arguments[@"applicationId"];
        [self initUMConfigure:appkey withApplicationId:applicationId];
        result(@YES);
        return;
    }

    if ([@"setPlatform" isEqualToString:call.method]) {
        int platformType = ((NSNumber *)call.arguments[@"platform"]).intValue;
        NSString *appId = call.arguments[@"appId"];
        NSString *appSecret = call.arguments[@"appSecret"];
        NSString *universalLink = call.arguments[@"universalLink"];
        [self setPlatform:[self getPlatform:platformType] appId:appId appSecret:appSecret universalLink:universalLink];
        result(@YES);
        return;
    }

    if ([@"shareText" isEqualToString:call.method]) {
            int platformType=((NSNumber*)call.arguments[@"platform"]).intValue;
            NSString *text=call.arguments[@"text"];
            //NSString *desc=call.arguments[@"desc"];
            [self shareText:[self sharePlatform:platformType] withText:text result:result];
        } else if([@"shareImage" isEqualToString:call.method]){
            NSLog(@"flutter_umeng_ushare init shareImage");
            int platformType=((NSNumber*)call.arguments[@"platform"]).intValue;
            NSString *thumb=call.arguments[@"thumb"];
            NSString *image=call.arguments[@"image"];
            [self shareImage:[self sharePlatform:platformType] withImage:image withThumb:thumb result:result];
        } else if([@"shareMedia" isEqualToString:call.method]) {
            NSLog(@"flutter_umeng_ushare shareMedia");
            int platformType=((NSNumber*)call.arguments[@"platform"]).intValue;
            int type=((NSNumber*)call.arguments[@"type"]).intValue;
            NSString *thumb=call.arguments[@"thumb"];
            NSString *title=call.arguments[@"title"];
            NSString *desc=call.arguments[@"desc"];
            NSString *link=call.arguments[@"link"];
            [self shareMedia:[self sharePlatform:platformType] withMediaType:type withTitle:title withDesc:desc withThumb:thumb withLink:link result:result];
        } else if([@"login" isEqualToString:call.method]) {
            int platformType=((NSNumber*)call.arguments[@"platform"]).intValue;
            [self login:[self getPlatform:platformType] result:result];
        } else if([@"shareMiniApp" isEqualToString:call.method]) {
            NSString *username=call.arguments[@"username"];
            NSString *thumb=call.arguments[@"thumb"];
            NSString *title=call.arguments[@"title"];
            NSString *desc=call.arguments[@"desc"];
            NSString *url=call.arguments[@"url"];
            NSString *path=call.arguments[@"path"];
            [self shareMiniApp:username withTitle:title withDesc:desc withThumb:thumb withURL:url withPath:path result:result];
        } else if([@"checkInstall" isEqualToString:call.method]) {
            int platformType=((NSNumber*)call.arguments[@"platform"]).intValue;
            [self checkInstall:[self getPlatform:platformType] result:result];
        } else {
            result(FlutterMethodNotImplemented);
        }
}

- (void)initUMConfigure:(NSString*)appkey withApplicationId:(NSString*)applicationId {
    NSLog(@"flutter_umeng_ushare init umengConfigure");
    [UMConfigure initWithAppkey:appkey channel:@"AppStore"];
    _bundleId = applicationId;
#if DEBUG
    [UMConfigure setLogEnabled:YES];
#endif
}


- (void)setPlatform:(UMSocialPlatformType)platform
              appId:(NSString *)appId
          appSecret:(NSString *)appSecret
      universalLink:(NSString *)universalLink {
#if DEBUG
    NSLog(@"flutter_umeng_ushare platformConfig");
#endif
    switch (platform) {
        case UMSocialPlatformType_WechatSession:
            //?????????????????????Universal Links
            [UMSocialGlobal shareInstance].universalLinkDic = @{@(UMSocialPlatformType_WechatSession):universalLink};
            [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:appId appSecret:appSecret redirectURL:@"http://mobile.umeng.com/social"];
            break;
        case UMSocialPlatformType_QQ:
            //??????qq???Universal Links
            [UMSocialGlobal shareInstance].universalLinkDic = @{
                @(UMSocialPlatformType_QQ): universalLink
            };
            [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:appId appSecret:appSecret redirectURL:@"http://mobile.umeng.com/social"];
            break;
        case UMSocialPlatformType_Sina:
            [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:appId appSecret:appSecret redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
            break;
        default:
            break;
    }
}

- (UMSocialPlatformType)sharePlatform:(int)platformType {
    UMSocialPlatformType type = UMSocialPlatformType_Sina;
    switch (platformType) {
        case 0:
            type = UMSocialPlatformType_Sina;//??????
            break;
        case 1:
            type = UMSocialPlatformType_WechatSession;//????????????
            break;
        case 2:
            type = UMSocialPlatformType_WechatTimeLine;//???????????????
            break;
        case 3:
            type = UMSocialPlatformType_WechatFavorite;//????????????
            break;
        case 4:
            type = UMSocialPlatformType_QQ;//QQ
            break;
        case 5:
            type = UMSocialPlatformType_Qzone;//Qzone
            break;
        case 6:
            type = UMSocialPlatformType_Facebook;//Facebook
            break;
        case 7:
            type = UMSocialPlatformType_Twitter;//Twitter
            break;
        default:
            type=UMSocialPlatformType_Sina;
            break;
    }
    return type;
}

- (UMSocialPlatformType)getPlatform:(int)platformType {

    UMSocialPlatformType type = UMSocialPlatformType_Sina;
    switch (platformType) {
        case 0:
            type = UMSocialPlatformType_Sina;//??????
            break;
        case 1:
            type = UMSocialPlatformType_WechatSession;//????????????
            break;
        case 2:
            type = UMSocialPlatformType_QQ;//QQ
            break;
        case 3:
            type = UMSocialPlatformType_Facebook;//Facebook
            break;
        case 4:
            type = UMSocialPlatformType_Twitter;//Twitter
            break;
        case 5:
            type = UMSocialPlatformType_DingDing;//Twitter
            break;
        default:
            type = UMSocialPlatformType_Sina;
            break;
    }
    return type;
}

//????????????
- (void)shareText:(UMSocialPlatformType)platformType
         withText:(NSString *)text
           result:(FlutterResult)result {
    //????????????????????????
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //????????????
    messageObject.text = text;

    dispatch_async(dispatch_get_main_queue(), ^ {
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
            if (error) {
                if (error.code == 2009) {
                    result( @{@"um_status": @"CANCEL"});
                } else {
                    result(@{@"um_status": @"ERROR", @"um_msg": error.userInfo});
                }
            } else {
                result( @{@"um_status": @"SUCCESS"});
            }
        }];
    });
}

//????????????
- (void)shareImage:(UMSocialPlatformType)platformType
         withImage:(NSString *)image
         withThumb:(NSString *)thumb
            result:(FlutterResult)result {
    //????????????????????????
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //????????????????????????
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //shareObject.t

    //?????????????????????????????????????????????
    //shareObject.thumbImage = thumb;
    [shareObject setThumbImage:thumb];
    //shareObject.descr
    [shareObject setShareImage:image];
    //[shareObject sets]
    //??????????????????????????????????????????
    messageObject.shareObject = shareObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
            if (error) {
                if (error.code == 2009) {
                    result( @{@"um_status": @"CANCEL"});
                } else {
                    result(@{@"um_status": @"ERROR", @"um_msg": error.userInfo});
                }
            } else {
                result( @{@"um_status": @"SUCCESS"});
            }
        }];
    });
}
//???????????????

- (void)shareMedia:(UMSocialPlatformType)platformType
     withMediaType:(NSInteger) type
         withTitle:(NSString *)title
          withDesc:(NSString *)desc
         withThumb:(NSString *)thumb
          withLink:(NSString *)link
            result:(FlutterResult)result {
    //????????????????????????
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    if(type==0){
        UMShareMusicObject *shareMusicObjet=[UMShareMusicObject shareObjectWithTitle:title descr:desc thumImage:thumb];
        shareMusicObjet.musicUrl=link;
        messageObject.shareObject=shareMusicObjet;
    }else if(type==1){
        UMShareVideoObject *shareVideoObjet=[UMShareVideoObject shareObjectWithTitle:title descr:desc thumImage:thumb];
        shareVideoObjet.videoUrl=link;
        messageObject.shareObject=shareVideoObjet;
    }else if(type==2){
        UMShareWebpageObject *shareWebPageObjet=[UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:thumb];
        shareWebPageObjet.webpageUrl=link;
        messageObject.shareObject=shareWebPageObjet;
    }else{
        result(@{@"um_status": @"INVALID"});
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
            if (error) {
                if(error.code == 2009){
                    result( @{@"um_status": @"CANCEL"});
                }else{
                    result(@{@"um_status": @"ERROR", @"um_msg": error.userInfo});
                }
            }else{
                result( @{@"um_status": @"SUCCESS"});
            }
        }];
    });
}

//???????????????
- (void)shareMiniApp:(NSString *)username withTitle:(NSString *)title withDesc:(NSString *)desc withThumb:(NSString *)thumb withURL:(NSString *)url withPath:(NSString *)path result:(FlutterResult)result
{
    //????????????????????????
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMShareMiniProgramObject *shareObject = [UMShareMiniProgramObject shareObjectWithTitle:title descr:desc thumImage:thumb];
    shareObject.webpageUrl = url;
    shareObject.userName = username;
    shareObject.path = path;
    //shareObject.hdImageData =UIImagePNGRepresentation(thumb);
    //shareObject.hdImageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"]];
    shareObject.miniProgramType = UShareWXMiniProgramTypeRelease;
    messageObject.shareObject = shareObject;

    //??????????????????
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_WechatSession messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {

            if (error) {
                if(error.code == 2009){
                    result( @{@"um_status": @"CANCEL"});
                }else{
                    result(@{@"um_status": @"ERROR", @"um_msg": error.userInfo});
                }
            }else{
                result( @{@"um_status": @"SUCCESS"});
            }
        }];
    });
}

//??????
-(void)login:(UMSocialPlatformType)platformType result:(FlutterResult)result {
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:nil completion:^(id data, NSError *error) {
        if (error) {
            if(error.code == 2009){
                //error.code;
                result( @{@"um_status": @"CANCEL"} );
            }else{
                result(@{@"um_status": @"ERROR", @"um_msg": error.userInfo});
            }
        } else {
            UMSocialUserInfoResponse *resp = data;
            NSDictionary *ret = @{
                @"um_status": @"SUCCESS",
                @"uid": resp.uid,
                @"openid": resp.openid,
                @"accessToken": resp.accessToken,
//                @"expiration": resp.expiration,
                @"name": resp.name,
                @"iconurl": resp.iconurl,
                @"gender": resp.gender,
                @"originalResponse": resp.originalResponse
            };
            result(ret);
        }
    }];
}

//????????????????????????
-(void) checkInstall:(UMSocialPlatformType)platformType result:(FlutterResult)result{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL flag=[[UMSocialManager defaultManager] isInstall:platformType];
        result([NSNumber numberWithBool:flag]);
    });
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // ??????????????????SDK?????????
    }
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // ??????????????????SDK?????????
    }
    return result;
}

@end
