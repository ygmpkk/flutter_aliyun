import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Aliyun {
  static const MethodChannel _channel = const MethodChannel('ygmpkk/aliyun');

  static Future setup({
    @required String project,
    @required String logStore,
    @required String accessKeyId,
    @required String accessKeySecret,
    String securityToken = "",
    String endpoint = 'https://cn-hangzhou.log.aliyuncs.com',
    String channel = '',
    String metadataKey = '',
    bool enableLog = false,
  }) async {
    return await _channel.invokeMethod('setup', {
      'project': project,
      'logStore': logStore,
      'accessKeyId': accessKeyId,
      'accessKeySecret': accessKeySecret,
      'securityToken': securityToken,
      'endpoint': endpoint,
      'enableLog': enableLog,
      'channel': channel,
      'metadataKey': metadataKey,
    });
  }

  static Future post({
    @required Map<String, dynamic> data,
    String topic = 'defaultTopic',
  }) async {
    await _channel.invokeMethod('post', {
      'data': data,
      'topic': topic,
    });
  }
}
