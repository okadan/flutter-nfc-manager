# nfc_manager

A Flutter plugin to use NFC. Supported on both Android and iOS.

## Note

This plugin is still under development.

So please use with caution as there may be potential issues and breaking changes.

Feedback is welcome.

## Setup

### Android Setup

* Add [android.permission.NFC](https://developer.android.com/reference/android/Manifest.permission.html#NFC) to your `AndroidMenifest.xml`.

### iOS Setup

* Add [Near Field Communication Tag Reader Session Formats Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_nfc_readersession_formats) to your entitlements.

* Add [NFCReaderUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nfcreaderusagedescription) to your `Info.plist`.

* If you use `NfcManager#startTagSession` with `NfcTagPollingOption.iso18092`, you must add [com.apple.developer.nfc.readersession.felica.systemcodes](https://developer.apple.com/documentation/bundleresources/information_property_list/systemcodes) to your `Info.plist`.

## Usage

### Reading NDEF

``` dart
NfcManager.instance.startNdefSession(
  alertMessageIOS: '[Any message displayed on the iOS system UI]',
  onNdefDiscovered: (NfcNdef ndef) {
    print(ndef);
  },
);
```

### Writing NDEF

``` dart
NfcManager.instance.startNdefSession(
  alertMessageIOS: '...',
  onNdefDiscovered: (NfcNdef ndef) async {
    if (!ndef.isWritable) {
      print('Tag is not ndef writable.');
      return;
    }

    final NdefMessage message = NdefMessage([
      NdefRecord.createTextRecord('Hello World'),
      NdefRecord.createUriRecord(Uri.parse('https://flutter.dev')),
      NdefRecord.createMimeRecord('plain/text', Uint8List.fromList('Hello World'.codeUnits)),
      NdefRecord.createExternalRecord([domain string], [type string], [data uint8list]),
    ]);

    try {
      await ndef.writeNdef(message);
    } catch (e) {
      // handle error
    }
  },
);
```

### Reading Tag

``` dart
NfcManager.instance.startTagSession(
  alertMessageIOS: '...',
  pollingOpitons: {NfcTagPollingOption.iso14443, NfcTagPollingOption.iso15693, NfcTagPollingOption.iso18092},
  onTagDiscovered: (NfcTag tag) {
    print(tag);
    print(tag.ndef); // You can also read NDEF.
  },
);
```

### Stop Session

``` dart
NfcManager.instance.stopSession(
  alertMessageIOS: [success message string],
  errorMessageIOS: [error message string],
);
```

