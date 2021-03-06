package com.umeng.flutter_umeng_ushare;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.ArrayMap;
import android.widget.Toast;

import com.tencent.tauth.Tencent;
import com.umeng.commonsdk.UMConfigure;
import com.umeng.socialize.PlatformConfig;
import com.umeng.socialize.ShareAction;
import com.umeng.socialize.UMAuthListener;
import com.umeng.socialize.UMShareAPI;
import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.media.UMImage;
import com.umeng.socialize.media.UMMin;
import com.umeng.socialize.media.UMVideo;
import com.umeng.socialize.media.UMWeb;
import com.umeng.socialize.media.UMusic;
import com.umeng.socialize.utils.SocializeUtils;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;


class MainThreadResult implements Result {

    private Result result;
    private Handler handler;

    MainThreadResult(MethodChannel.Result result) {
        this.result = result;
        handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object t_result) {
        handler.post(
                new Runnable() {

                    @Override
                    public void run() {
                        result.success(t_result);
                    }
                });
    }

    @Override
    public void error(final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        result.error(errorCode, errorMessage, errorDetails);
                    }
                });
    }

    @Override
    public void notImplemented() {
        handler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        result.notImplemented();
                    }
                });
    }
}


/**
 * FlutterUmengUsharePlugin
 */
public class FlutterUmengUsharePlugin implements FlutterPlugin, MethodCallHandler, ActivityResultListener, RequestPermissionsResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private Handler uiThreadHandler = new Handler(Looper.getMainLooper());

    //android package name;
    private static String applicationId = "";
    private Context applicationContext;

    public FlutterUmengUsharePlugin() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        if (null == applicationContext) {
            applicationContext = flutterPluginBinding.getApplicationContext();
            channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_umeng_ushare");
            channel.setMethodCallHandler(this);
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        }
        if (call.method.equals("initUMConfigure")) {
            Map<String, String> appkey_map = call.argument("appkey");
            String appkey = appkey_map.get("androidKey");
            String applicationId = call.argument("applicationId");
            initUMConfigure(appkey, applicationId);
            result.success(true);
            return;
        }

        if (call.method.equals("setPlatform")) {
            int platform = call.argument("platform");
            String appId = call.argument("appId");
            String appSecret = call.argument("appSecret");
            initPlatformConfig(getPlatForm(platform), appId, appSecret);
            result.success(true);
            return;
        }

        if (call.method.equals("shareText")) {
            int platform = call.argument("platform");
            String text = call.argument("text");
            shareText(sharePlatForm(platform), text, result);
        } else if (call.method.equals("shareImage")) {
            int platform = call.argument("platform");
            String thumb = call.argument("thumb");
            String image = call.argument("image");
            shareImage(sharePlatForm(platform), thumb, image, result);
        } else if (call.method.equals("shareMedia")) {
            int platform = call.argument("platform");
            int type = call.argument("type");
            String title = call.argument("title");
            String desc = call.argument("desc");
            String thumb = call.argument("thumb");
            String link = call.argument("link");
            shareMedia(sharePlatForm(platform), type, title, desc, thumb, link, result);
        } else if (call.method.equals("login")) {
            int platform = call.argument("platform");
            login(getPlatForm(platform), result);
        } else if (call.method.equals("shareMiniApp")) {
            String username = call.argument("username");
            String title = call.argument("title");
            String desc = call.argument("desc");
            String thumb = call.argument("thumb");
            String url = call.argument("url");
            String path = call.argument("path");
            shareMiniApp(username, title, desc, thumb, url, path, result);
        } else if (call.method.equals("checkInstall")) {
            int platform = call.argument("platform");
            boolean flag = UMShareAPI.get(applicationContext).isInstall(getTopActivity(), getPlatForm(platform));
            result.success(flag);
        } else if (call.method.equals("deleteOauth")) {
            int platform = call.argument("platform");
            deleteOauth(getPlatForm(platform), result);
        } else {
            result.notImplemented();
        }
    }


    /**
     * ?????????????????????activity
     */
    public static Activity getTopActivity() {
        try {
            Class activityThreadClass = Class.forName("android.app.ActivityThread");
            Object activityThread = activityThreadClass.getMethod("currentActivityThread").invoke(null);
            Field activitiesField = activityThreadClass.getDeclaredField("mActivities");
            activitiesField.setAccessible(true);
            //16~18 HashMap
            //19~27 ArrayMap
            Map<Object, Object> activities;
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
                activities = (HashMap<Object, Object>) activitiesField.get(activityThread);
            } else {
                activities = (ArrayMap<Object, Object>) activitiesField.get(activityThread);
            }
            if (activities.size() < 1) {
                return null;
            }
            for (Object activityRecord : activities.values()) {
                Class activityRecordClass = activityRecord.getClass();
                Field pausedField = activityRecordClass.getDeclaredField("paused");
                pausedField.setAccessible(true);
                if (!pausedField.getBoolean(activityRecord)) {
                    Field activityField = activityRecordClass.getDeclaredField("activity");
                    activityField.setAccessible(true);
                    Activity activity = (Activity) activityField.get(activityRecord);
                    return activity;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }


    //?????????????????????
    private void initUMConfigure(String appkey, String applicationId) {
        UMConfigure.init(applicationContext, appkey, "umeng_share", UMConfigure.DEVICE_TYPE_PHONE, "");
        FlutterUmengUsharePlugin.applicationId = applicationId;
    }

    //????????????
    private void initPlatformConfig(SHARE_MEDIA platform, String appId, String appSecret) {
        switch (platform) {
            case WEIXIN:
                //????????????
                PlatformConfig.setWeixin(appId, appSecret);
                PlatformConfig.setWXFileProvider(applicationId + ".fileprovider");
                break;
            case QQ:
                //QQ??????
                PlatformConfig.setQQZone(appId, appSecret);
                PlatformConfig.setQQFileProvider(applicationId + ".fileprovider");
                //QQ??????sdk??????
                Tencent.setIsPermissionGranted(true);
                break;
            case WXWORK:
                // ??????????????????
                PlatformConfig.setWXWork("wwac6ffb259ff6f66a", "EU1LRsWC5uWn6KUuYOiWUpkoH45eOA0yH-ngL8579zs", "1000002", "wwauthac6ffb259ff6f66a000002");
                PlatformConfig.setWXWorkFileProvider(applicationId + ".fileprovider");
                break;
            case DINGTALK:
                //????????????
                PlatformConfig.setDing("dingoalmlnohc0wggfedpk");
                break;
            case SINA:
                // ??????????????????
                PlatformConfig.setSinaWeibo("3921700954", "04b48b094faeb16683c32669824ebdad", "http://sns.whalecloud.com");
                PlatformConfig.setSinaFileProvider(applicationId + ".fileprovider");
                break;
            case ALIPAY:
                PlatformConfig.setAlipay("2015111700822536");
                break;
//        // ??????????????????
//        PlatformConfig.setYixin("yxc0614e80c9304c11b0391514d09f13bf");
//        PlatformConfig.setLaiwang("laiwangd497e70d4","d497e70d4c3e4efeab1381476bac4c5e");
//        PlatformConfig.setTwitter("3aIN7fuF685MuZ7jtXkQxalyi","MK6FEYG63eWcpDFgRYw4w9puJhzDl0tyuqWjZ3M7XJuuG7mMbO");
//        PlatformConfig.setPinterest("1439206");
//        PlatformConfig.setKakao("e4f60e065048eb031e235c806b31c70f");
//        PlatformConfig.setVKontakte("5764965","5My6SNliAaLxEm3Lyd9J");
//        PlatformConfig.setDropbox("oz8v5apet3arcdy","h7p2pjbzkkxt02a");
//        PlatformConfig.setYnote("9c82bf470cba7bd2f1819b0ee26f86c6ce670e9b");
            default:
                break;
        }
    }

    private SHARE_MEDIA sharePlatForm(int platform) {
        final SHARE_MEDIA result;
        switch (platform) {
            case 0:
                result = SHARE_MEDIA.SINA;
                break;
            case 1:
                result = SHARE_MEDIA.WEIXIN;
                break;
            case 2:
                result = SHARE_MEDIA.WEIXIN_CIRCLE;
                break;
            case 3:
                result = SHARE_MEDIA.WEIXIN_FAVORITE;
                break;
            case 4:
                result = SHARE_MEDIA.QQ;
                break;
            case 5:
                result = SHARE_MEDIA.QZONE;
                break;
            default:
                result = SHARE_MEDIA.SINA;
                break;

        }
        return result;
    }

    private SHARE_MEDIA getPlatForm(int platform) {
        final SHARE_MEDIA result;
        switch (platform) {
            case 0:
                result = SHARE_MEDIA.SINA;
                break;
            case 1:
                result = SHARE_MEDIA.WEIXIN;
                break;
            case 2:
                result = SHARE_MEDIA.QQ;
                break;
            case 3:
                result = SHARE_MEDIA.FACEBOOK;
                break;
            case 4:
                result = SHARE_MEDIA.TWITTER;
                break;
            case 5:
                result = SHARE_MEDIA.DINGTALK;
                break;
            default:
                result = SHARE_MEDIA.SINA;
                break;
        }

        return result;
    }

    private void shareText(SHARE_MEDIA platform, String text, final Result result) {
        MainThreadResult mainThreadResult = new MainThreadResult(result);

        new ShareAction(getTopActivity()).setPlatform(platform)
                .withText(text)
                .setCallback(new UmengShareActionListener(getTopActivity(), mainThreadResult)).share();
    }

    private void shareImage(SHARE_MEDIA platform, String thumb, String image, final Result result) {
        MainThreadResult mainThreadResult = new MainThreadResult(result);

        final Activity activity = getTopActivity();
        UMImage thumbImage = new UMImage(activity, thumb);
        UMImage sImage = new UMImage(activity, image);
        sImage.setThumb(thumbImage);
        new ShareAction(activity)
                .setPlatform(platform)
                .withMedia(sImage)
                .setCallback(new UmengShareActionListener(activity, mainThreadResult)).share();
    }

    private void shareMedia(SHARE_MEDIA platform, int sharetype, String title, String desc, String thumb, String link, final Result result) {
        MainThreadResult mainThreadResult = new MainThreadResult(result);
        Activity activity = getTopActivity();
        if (sharetype == 0) {
            UMImage thumbImage = new UMImage(activity, thumb);
            UMusic music = new UMusic(link);
            music.setTitle(title);//??????
            music.setThumb(thumbImage);  //?????????
            music.setDescription(desc);//??????
            new ShareAction(activity).setPlatform(platform)
                    .withMedia(music)
                    .setCallback(new UmengShareActionListener(activity, mainThreadResult)).share();
        } else if (sharetype == 1) {
            UMImage thumbImage = new UMImage(activity, thumb);
            UMVideo video = new UMVideo(link);
            video.setTitle(title);//??????
            video.setThumb(thumbImage);  //?????????
            video.setDescription(desc);//??????
            new ShareAction(activity).setPlatform(platform)
                    .withMedia(video)
                    .setCallback(new UmengShareActionListener(activity, mainThreadResult)).share();
        } else if (sharetype == 2) {
            System.out.println("share web url");
            UMImage thumbImage = new UMImage(activity, thumb);
            UMWeb web = new UMWeb(link);
            web.setTitle(title);//??????
            web.setThumb(thumbImage);  //?????????
            web.setDescription(desc);//??????

            new ShareAction(activity).setPlatform(platform)
                    .withMedia(web)
                    .setCallback(new UmengShareActionListener(activity, mainThreadResult)).share();
        } else {
            Map<String, Object> map = new HashMap<>();
            map.put("um_status", "ERROR");
            map.put("um_msg", "INVALID TYPE");
            mainThreadResult.success(map);
        }
    }

    private void shareMiniApp(String username, String title, String desc, String thumb, String url, String path, final Result result) {
        Activity activity = getTopActivity();
        UMMin umMin = new UMMin(url);
        umMin.setThumb(new UMImage(activity, thumb));
        umMin.setTitle(title);
        umMin.setDescription(desc);
        umMin.setPath(path);
        umMin.setUserName(username);
        new ShareAction(activity)
                .withMedia(umMin)
                .setPlatform(SHARE_MEDIA.WEIXIN)
                .setCallback(new UmengShareActionListener(activity, result)).share();
    }

    private void login(SHARE_MEDIA platform, final Result result) {
        MainThreadResult mainThreadResult = new MainThreadResult(result);
        Activity activity = getTopActivity();
        if (activity != null) {
            UMShareAPI.get(activity).getPlatformInfo(activity, platform, new UMAuthListener() {
                @Override
                public void onStart(SHARE_MEDIA share_media) {

                }

                @Override
                public void onComplete(SHARE_MEDIA share_media, int i, Map<String, String> map) {
                    map.put("um_status", "SUCCESS");
                    mainThreadResult.success(map);

                }

                @Override
                public void onError(SHARE_MEDIA share_media, int i, Throwable throwable) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("um_status", "ERROR");
                    map.put("um_msg", throwable.getMessage());
                    mainThreadResult.success(map);
                }

                @Override
                public void onCancel(SHARE_MEDIA share_media, int i) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("um_status", "CANCEL");
                    mainThreadResult.success(map);
                }
            });
        }
    }

    private void deleteOauth(SHARE_MEDIA platform, final Result result) {
        MainThreadResult mainThreadResult = new MainThreadResult(result);
        Activity activity = getTopActivity();
        if (activity != null) {
            UMShareAPI.get(activity).deleteOauth(activity, platform, new UMAuthListener() {
                @Override
                public void onStart(SHARE_MEDIA share_media) {

                }

                @Override
                public void onComplete(SHARE_MEDIA share_media, int i, Map<String, String> map) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("um_status", "SUCCESS");
                    mainThreadResult.success(data);

                }

                @Override
                public void onError(SHARE_MEDIA share_media, int i, Throwable throwable) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("um_status", "ERROR");
                    map.put("um_msg", throwable.getMessage());
                    mainThreadResult.success(map);
                }

                @Override
                public void onCancel(SHARE_MEDIA share_media, int i) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("um_status", "CANCEL");
                    mainThreadResult.success(map);
                }
            });
        }
    }


    @Override
    public boolean onActivityResult(int i, int i1, Intent intent) {
        UMShareAPI.get(getTopActivity()).onActivityResult(i, i1, intent);
        return false;
    }

    @Override
    public boolean onRequestPermissionsResult(int i, String[] strings, int[] ints) {
        return false;
    }
}
