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

    UMengShare.initUMConfigure(const UMApiKey(iosKey: '61b83443e014255fcbb29434', androidKey: '61b83403e014255fcbb29404'), 'com.example.flutterUmengUshareExample');
    UMengShare.setPlatform(UMPlatform.QQ, appId: '1112081613', appSecret: '4nbEGzAjsz0b9ioL', universalLink:'https://cc.umeng.com');

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
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(onPressed: (){
                _loginForQQ();
              }, child: Text('QQ 登录'))
            ],
          ) 
        ),
      ),
    );
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

          break;
        default:
        break;
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
