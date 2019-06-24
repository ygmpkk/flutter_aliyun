#import "AliyunPlugin.h"
#import <aliyun/aliyun-Swift.h>

@implementation AliyunPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftAliyunPlugin registerWithRegistrar:registrar];
}
@end
