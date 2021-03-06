import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_umeng_ushare/flutter_umeng_ushare.dart';
import 'package:flutter_umeng_ushare/types.dart';
import 'package:flutter_umeng_ushare/umeng_api_key.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await UMengShare.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    _initUM();
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin umeng app'),
        ),
        body: Center(
            child: Column(
          children: [
            Text('Running on: $_platformVersion\n'),
            ElevatedButton(
              onPressed: () {
                _initUM();
              },
              child: const Text('初始化'),
            ),
            ElevatedButton(
              onPressed: () {
                _loginForQQ();
              },
              child: const Text('QQ 登录'),
            ),
            ElevatedButton(
              onPressed: () {
                _loginForDingDing();
              },
              child: const Text('钉钉 登录'),
            ),
            ElevatedButton(
              onPressed: () {
                _loginForWechat();
              },
              child: const Text('微信 登录'),
            ),
          ],
        )),
      ),
    );
  }

  _initUM() async {
    UMengShare.initUMConfigure(
        const UMApiKey(
            iosKey: '61b83443e014255fcbb29434',
            androidKey: '59892f08310c9307b60023d0'),
        'com.umeng.soexample');
    UMengShare.setPlatform(UMPlatform.QQ,
        appId: '101830139',
        appSecret: '5d63ae8858f1caab67715ccd6c18d7a5',
        universalLink: 'https://bhb6sl.jgmlink.cn/qq_conn/1112081613');
    UMengShare.setPlatform(UMPlatform.Wechat,
        appId: 'wxdc1e388c3822c80b',
        appSecret: '3baf1193c85774b3fd9d18447d76cab0',
        universalLink: 'https://bhb6sl.jgmlink.cn/qq_conn/1112081613');
  }

  _loginForQQ() async {
    try {
      var resut = await UMengShare.login(UMPlatform.QQ);
      String um_status = resut['um_status'];
      switch (um_status) {
        case 'ERROR':
          debugPrint(resut['um_msg'].toString());
          break;
        case 'CANCEL':
          debugPrint('用户取消');
          break;
        case 'SUCCESS':
          debugPrint("wjj"+resut.toString());
          break;
        default:
          break;
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  _loginForDingDing() async {
    debugPrint('钉钉暂不支持第三方登录');
  }

  _loginForWechat() async {
    try {
      var resut = await UMengShare.login(UMPlatform.Wechat);
      String um_status = resut['um_status'];
      switch (um_status) {
        case 'ERROR':
          debugPrint(resut['um_msg'].toString());
          break;
        case 'CANCEL':
          debugPrint('用户取消');
          break;
        case 'SUCCESS':
          debugPrint("wjj："+resut.toString());
          _deleteOauthForWechat();
          break;
        default:
          break;
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  _deleteOauthForWechat() async {
    try {
      var resut = await UMengShare.deleteOauth(UMPlatform.Wechat);
      String um_status = resut['um_status'];
      switch (um_status) {
        case 'ERROR':
          debugPrint(resut['um_msg'].toString());
          break;
        case 'CANCEL':
          debugPrint('用户取消');
          break;
        case 'SUCCESS':
          debugPrint("wjj："+resut.toString());

          break;
        default:
          break;
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
