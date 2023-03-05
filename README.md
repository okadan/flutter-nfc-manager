# nfc_manager

A Flutter plugin for accessing the NFC features on Android and iOS.

## Requirements

Android SDK Version >= 19 or iOS >= 13.0.

## Setup

**Android Setup**

* Add [android.permission.NFC](https://developer.android.com/reference/android/Manifest.permission.html#NFC) to your `AndroidManifest.xml`.

**iOS Setup**

* Add [Near Field Communication Tag Reader Session Formats Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_nfc_readersession_formats) to your entitlements.

* Add [NFCReaderUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nfcreaderusagedescription) to your `Info.plist`.

* Add [com.apple.developer.nfc.readersession.iso7816.select-identifiers](https://developer.apple.com/documentation/bundleresources/information_property_list/select-identifiers) to your `Info.plist`. (Optional)

* Add [com.apple.developer.nfc.readersession.felica.systemcodes](https://developer.apple.com/documentation/bundleresources/information_property_list/systemcodes) to your `Info.plist`. (Optional but required if you specify the `NfcPollingOptions.iso18092` to the `pollingOptions`)

## Minimum Usage

```dart
bool isAvailable = await NfcManager.instance.isAvailable();

if (!isAvailable) {
  print("The NFC features may not be supported on this device.");
  return;
}

NfcManager.instance.startSession(
  pollingOptions: ...,
  onDiscovered: (NfcTag tag) async {
    // Do something with an NfcTag instance.

    // Stop the session when the processing is completed.
    NfcManager.instance.stopSession();
  },
);
```

## Handling the NfcTag instance.

NfcTag is typically not used directly, but only to obtain an instance of a specific tag type. This plugin provides the following tag types:

**Android Only**

* `NdefAndroid`
* `NfcAAndroid`
* `NfcBAndroid`
* `NfcFAndroid`
* `NfcVAndroid`
* `IsoDepAndroid`
* `MifareClassicAndroid`
* `MifareUltralightAndroid`
* `NdefFormatableAndroid`
* `NfcBarcodeAndroid`

**iOS Only**

* `NdefIOS`
* `MiFareIOS`
* `FeliCaIOS`
* `Iso15693IOS`
* `Iso7618IOS`

**Abstraction between Android and iOS (sub packages)**

* `Ndef` ([nfc_manager_ndef](https://github.com/okadan/flutter-nfc-manager-ndef))
* `FeliCa` ([nfc_manager_felica](https://github.com/okadan/flutter-nfc-manager-felica))
* Add more in the future...

Use `from(NfcTag)` static method to obtain an instance of a specific tag type. For example, to instantiate the `Ndef`:

```dart
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

Ndef? ndef = Ndef.from(tag);

if (ndef == null) {
  print("The tag is not compatible with an NDEF.");
  return;
}

// Do something with an Ndef instance.
```

See the [example](#) directory or [Real World App](#) for more details.
