#import "NfcManagerPlugin.h"
#import <nfc_manager/nfc_manager-Swift.h>

@implementation NfcManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNfcManagerPlugin registerWithRegistrar:registrar];
}
@end
