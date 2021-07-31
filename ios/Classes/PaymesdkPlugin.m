#import "PaymesdkPlugin.h"
#if __has_include(<paymesdk/paymesdk-Swift.h>)
#import <paymesdk/paymesdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "paymesdk-Swift.h"
#endif

@implementation PaymesdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPaymesdkPlugin registerWithRegistrar:registrar];
}
@end
