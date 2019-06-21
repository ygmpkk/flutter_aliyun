#import "AliyunPlugin.h"
#import <AliyunLogObjc/AliyunLogObjc.h>

@implementation AliyunPlugin {
  NSString *channel;
  NSString *logStore;
  LogClient *client;
  // NSDictionary *globalLaunchOptions;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"ygmpkk/aliyun"
                                  binaryMessenger:[registrar messenger]];
  AliyunPlugin *instance = [[AliyunPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  // [registrar addApplicationDelegate:instance];
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
  if ([@"setup" isEqualToString:call.method]) {
    [self setup:call result:result];
  } else if ([@"post" isEqualToString:call.method]) {
    [self post:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)setup:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *project = call.arguments[@"project"];
  logStore = call.arguments[@"logStore"];
  NSString *accessKeyId = call.arguments[@"accessKeyId"];
  NSString *accessKeySecret = call.arguments[@"accessKeySecret"];
  NSString *securityToken = call.arguments[@"securityToken"];
  NSString *endpoint = call.arguments[@"endpoint"];

  channel = call.arguments[@"channel"];

  BOOL enableLog = [call.arguments[@"enableLog"] boolValue];
  if (enableLog) {
    NSLog(@"ALI: project => %@", project);
    NSLog(@"ALI: logStore => %@", logStore);
    NSLog(@"ALI: accessKeyId => %@", accessKeyId);
    NSLog(@"ALI: endpoint => %@", endpoint);
    NSLog(@"ALI: channel => %@", channel);
    NSLog(@"ALI: enableLog => %d", enableLog);
  }

  client = [[LogClient alloc] initWithApp:endpoint
                              accessKeyID:accessKeyId
                          accessKeySecret:accessKeySecret
                              projectName:project
                            serializeType:AliSLSJSONSerializer];

  if (securityToken != nil && securityToken != NULL) {
    NSLog(@"ALI: use securityToken");
    [client SetToken:securityToken];
  }

  result(nil);
}

- (void)post:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSDictionary *data = call.arguments[@"data"];
  NSString *topic = call.arguments[@"topic"];

  NSLog(@"ALI post => topic: %@", topic);
  NSLog(@"ALI post => data: %@", data);

  if (channel == nil) {
    channel = @"app_store";
  }

  RawLogGroup *logGroup = [[RawLogGroup alloc] initWithTopic:topic
                                                   andSource:channel];
  RawLog *logInfo = [[RawLog alloc] init];

  for (NSString *key in data) {
    NSString *value = data[key];
    [logInfo PutContent:value withKey:key];
  }

  [logGroup PutLog:logInfo];

  [client PostLog:logGroup
      logStoreName:logStore
              call:^(NSURLResponse *_Nullable response,
                     NSError *_Nullable error) {
                if (error != nil) {
                  NSLog(@"ALI response success: %@",
                        [response debugDescription]);
                } else {
                  NSLog(@"ALI response error: %@", [error debugDescription]);
                }
              }];

  result(nil);
}

@end