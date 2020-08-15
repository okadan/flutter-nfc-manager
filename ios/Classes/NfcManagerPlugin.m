#import "NfcManagerPlugin.h"
#if __has_include(<nfc_manager/nfc_manager-Swift.h>)
#import <nfc_manager/nfc_manager-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "nfc_manager-Swift.h"
#endif

@implementation NfcManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNfcManagerPlugin registerWithRegistrar:registrar];
}
@end
