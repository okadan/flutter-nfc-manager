# nfc_manager

A Flutter plugin for accessing the NFC features on Android and iOS.

## Setup

### Android

* Ensure that `minSdkVersion` is set to 19 or higher.
* Add [android.permission.NFC](https://developer.android.com/reference/android/Manifest.permission.html#NFC) to your `AndroidManifest.xml`.

### iOS

* Ensure that the iOS Deployment Target is set to 13.0 or higher.
* Add [Near Field Communication Tag Reader Session Formats Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_nfc_readersession_formats) to your entitlements.
* Add [NFCReaderUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nfcreaderusagedescription) to your `Info.plist`.
* Add [com.apple.developer.nfc.readersession.iso7816.select-identifiers](https://developer.apple.com/documentation/bundleresources/information_property_list/select-identifiers) to your `Info.plist` as needed.
* Add [com.apple.developer.nfc.readersession.felica.systemcodes](https://developer.apple.com/documentation/bundleresources/information_property_list/systemcodes) to your `Info.plist` if you specify `NfcPollingOption.iso18092` in `startSession`, otherwise an error will occur.

## Usage

### Handling the Session

```dart
import 'package:nfc_manager/nfc_manager.dart';

// Check is NFC is available.
bool isAvailable = await NfcManager.instance.isAvailable();

// Start the session.
NfcManager.instance.startSession(
  pollingOptions: {NfcPollingOption.iso14443}, // You can also specify iso18092 and iso15693.
  onDiscovered: (NfcTag tag) async {
    // Do something with an NfcTag instance...
    print(tag);

    // Stop the session when no longer needed.
    await NfcManager.instance.stopSession();
  },
);
```

### Working with NfcTag

An `NfcTag` instance is typically not used directly. Instead, it's converted into a vendor-specific tag instance by calling a static method `from(tag)`.

```dart
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

final ndef = Ndef.from(tag);

if (ndef == null) {
  print('The tag is not compatible with NDEF.');
  return;
}

// Do something with an Ndef instance...
print(ndef);
```

The following vendor-specific tag classes are available:

#### Android only

* `NfcAAndroid`
* `NfcBAndroid`
* `NfcFAndroid`
* `NfcVAndroid`
* `IsoDepAndroid`
* `MifareClassicAndroid`
* `MifareUltralightAndroid`
* `NfcBarcodeAndroid`
* `NdefAndroid`
* `NdefFormatableAndroid`

#### iOS only

* `FeliCaIos`
* `MiFareIos`
* `Iso15693Ios`
* `Iso7816Ios`
* `NdefIos`

#### Cross-Platform Abstractions (External Packages)

* `Ndef` ([nfc_manager_ndef](https://pub.dev/packages/nfc_manager_ndef))
* `FeliCa` ([nfc_manager_felica](https://pub.dev/packages/nfc_manager_felica))
* and more...

### Android: Suppress the platform default NFC UI when reading a tag

Add these lines to your `MainActivity.kt` class:

```Kotlin
    override fun onResume() {
        super.onResume()

        // prevent default System UI from showing up when reading a tag
        val intent = Intent(context, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE)
        NfcAdapter.getDefaultAdapter(context)
            ?.enableForegroundDispatch(this, pendingIntent, null, null)
    }

    override fun onPause() {
        super.onPause()
        NfcAdapter.getDefaultAdapter(context)?.disableForegroundDispatch(this)
    }
```
