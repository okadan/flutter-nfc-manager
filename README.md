# nfc_manager

Flutter plugin for accessing the NFC features on Android and iOS.

Note: This plugin depends on `NFCTagReaderSession` on iOS and `NfcAdapter#enableReaderMode` on Android, so it requires iOS 13.0 or later or Android API level 19 or later.

## Setup

**Android Setup**

* Add [android.permission.NFC](https://developer.android.com/reference/android/Manifest.permission.html#NFC) to your `AndroidMenifest.xml`.

**iOS Setup**

* Add [Near Field Communication Tag Reader Session Formats Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_nfc_readersession_formats) to your entitlements.

* Add [NFCReaderUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nfcreaderusagedescription) to your `Info.plist`.

* Add [com.apple.developer.nfc.readersession.felica.systemcodes](https://developer.apple.com/documentation/bundleresources/information_property_list/systemcodes) and [com.apple.developer.nfc.readersession.iso7816.select-identifiers](https://developer.apple.com/documentation/bundleresources/information_property_list/select-identifiers) to your `Info.plist` as needed.

## Usage

**Handling Session**

```dart
// Check availability
bool isAvailable = await NfcManager.instance.isAvailable();

// Start Session
NfcManager.instance.startSession(onDiscovered(NfcTag tag) async {
  // Handling Tag
});

// Stop Session
NfcManager.instance.stopSession();
```

**Handling Platform Tag**

The following platform-tag-classes are available:

* Ndef
* FeliCa (iOS only)
* Iso7816 (iOS only)
* Iso15693 (iOS only)
* MiFare (iOS only)
* NfcA (Android only)
* NfcB (Android only)
* NfcF (Android only)
* NfcV (Android only)
* IsoDep (Android only)
* MifareClassic (Android only)
* MifareUtralight (Android only)
* NdefFormatable (Android only)

Obtain an instance by calling the factory constructor `from()` on the class. For example:

```dart
Ndef ndef = Ndef.from(tag);

if (ndef == null) {
  print('Tag is not compatible with NDEF');
  return;
}

// Do something with an Ndef instance
```

For more information, please see the [API Doc](https://pub.dev/documentation/nfc_manager/latest/).

## Real-World-App

See [this repo](https://github.com/okadan/flutter-nfc-manager-app) which is a Real-World-App demonstrates how to use this plugin.
