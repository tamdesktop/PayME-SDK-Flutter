#import "PaymeSdkFlutterPlugin.h"
#if __has_include(<payme_sdk_flutter/payme_sdk_flutter-Swift.h>)
#import <payme_sdk_flutter/payme_sdk_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "payme_sdk_flutter-Swift.h"
#endif

@implementation PaymeSdkFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPaymeSdkFlutterPlugin registerWithRegistrar:registrar];
}
@end
