# nfc_manager

A Flutter plugin to manage the NFC features. Supported on both Android and iOS.

## Setup

### Android Setup

* Add [android.permission.NFC](https://developer.android.com/reference/android/Manifest.permission.html#NFC) to your `AndroidMenifest.xml`.

### iOS Setup

* Add [Near Field Communication Tag Reader Session Formats Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_nfc_readersession_formats) to your entitlements.

* Add [NFCReaderUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nfcreaderusagedescription) to your `Info.plist`.

* Add [com.apple.developer.nfc.readersession.felica.systemcodes](https://developer.apple.com/documentation/bundleresources/information_property_list/systemcodes) and [com.apple.developer.nfc.readersession.iso7816.select-identifiers](https://developer.apple.com/documentation/bundleresources/information_property_list/select-identifiers) to your `Info.plist` as needed.

## Usage

### Managing Session

``` dart
// Check availability
bool isAvailable = await NfcManager.instance.isAvailable();

// Start session and register callback.
NfcManager.instance.startTagSession(
  onDiscovered: (NfcTag tag) async {
    // Manipulating tag
  },
);

// Stop session and unregister callback.
NfcManager.instance.stopSession();
```

### Manipulating NDEF

``` dart
// Obtain an Ndef instance from tag
Ndef ndef = Ndef.fromTag(tag);

if (ndef == null) {
  print('Tag is not ndef');
  return;
}

// You can get an NdefMessage instance cached at discovery time
NdefMessage cachedMessage = ndef.cachedMessage;

// Create an NdefMessage instance you want to write.
NdefMessage message = NdefMessage([
  NdefRecord.createText('Hello'),
  NdefRecord.createUri(Uri.parse('https://flutter.dev')),
  NdefRecord.createMime('text/plain', Uint8List.fromList('Hello'.codeUnits)),
  NdefRecord.createExternal('mydomain', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
]);

if (!ndef.isWritable) {
  print('Tag is not ndef writable');
  return;
}

// Write an NdefMessage
try {
  await ndef.write(message);
} catch (e) {
  // handle error
}
```

### Manipulating Platform-Specific-Tag

The following platform-specific-tag classes are available:

**iOS**

* MiFare
* FeliCa
* ISO15693
* ISO7816

**Android**

* NfcA
* NfcB
* NfcF
* NfcV
* IsoDep

**Usage**

``` dart
MiFare miFare = MiFare.fromTag(tag);

if (miFare == null) {
  print('MiFare is not available on this tag');
  return;
}

Uint8List response = await miFare.sendMiFareCommand(...);
```

## Example App

See [this repo](https://github.com/okadan/nfc-manager) which is a Real-World-App demonstrates how to use this plugin.
