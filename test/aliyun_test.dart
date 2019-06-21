import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aliyun/aliyun.dart';

void main() {
  const MethodChannel channel = MethodChannel('ygmpkk/aliyun');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return true;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('aliyun setup', () async {
    expect(
        await Aliyun.setup(
          project: "",
          logStore: "",
          accessKeyId: "",
          accessKeySecret: "",
        ),
        true);
  });
}
