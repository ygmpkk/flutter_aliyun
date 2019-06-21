import 'package:flutter/material.dart';
import 'dart:async';

import 'package:aliyun/aliyun.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
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

    await Aliyun.setup(
      project: "YOUR PROJECt",
      logStore: "YOUR LOG STORE",
      accessKeyId: "YOUR ACCESS KEY ID",
      accessKeySecret: "YOUR ACCESS KEY SECRET",
    );

    await Aliyun.post(data: {
      'foo': 'bar',
      'bool': "true",
      "num": "1",
    });

    await Aliyun.post(data: {
      'foo': 'bar2',
      'bool': "true",
      "num": "1",
    });

    await Aliyun.post(data: {
      'foo': 'bar3',
      'bool': "true",
      "num": "1",
    });


    await Aliyun.post(data: {
      'foo': 'bar4',
      'bool': "true",
      "num": "1",
    });

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
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
