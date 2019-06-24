#import "AliyunPlugin.h"
@import AliyunLOGiOS;

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

  if ([self isBlankString:channel]) {
    channel = @"app_store";
  }

  BOOL enableLog = [call.arguments[@"enableLog"] boolValue];
  if (enableLog) {
    NSLog(@"ALI: project => %@", project);
    NSLog(@"ALI: logStore => %@", logStore);
    NSLog(@"ALI: accessKeyId => %@", accessKeyId);
    NSLog(@"ALI: endpoint => %@", endpoint);
    NSLog(@"ALI: channel => %@", channel);
    NSLog(@"ALI: enableLog => %d", enableLog);
  }
    

  client = [[ alloc] initWithApp:endpoint
                              accessKeyID:accessKeyId
                          accessKeySecret:accessKeySecret
                              projectName:project
                              serializeType:AliSLSProtobufSerializer];

  if (![self isBlankString:securityToken]) {
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

  RawLogGroup *logGroup = [[RawLogGroup alloc] initWithTopic:topic andSource:channel];
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

- (BOOL)isBlankString:(NSString *)string {
  if (string == nil || string == NULL) {
    return YES;
  }

  if ([string isKindOfClass:[NSNull class]]) {
    return YES;
  }
  if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet
                                                   whitespaceCharacterSet]]
          length] == 0) {
    return YES;
  }
  return NO;
}

@end
