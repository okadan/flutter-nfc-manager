# nfc_manager

A Flutter plugin to use NFC. Supported on both Android and iOS.

## Setup

### Android Setup

* Add [android.permission.NFC](https://developer.android.com/reference/android/Manifest.permission.html#NFC) to your `AndroidMenifest.xml`.

### iOS Setup

* Add [Near Field Communication Tag Reader Session Formats Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_nfc_readersession_formats) to your entitlements.

* Add [NFCReaderUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nfcreaderusagedescription) to your `Info.plist`.

* If you use `NfcManager#startTagSession` with `NfcTagPollingOption.iso18092`, you must add [com.apple.developer.nfc.readersession.felica.systemcodes](https://developer.apple.com/documentation/bundleresources/information_property_list/systemcodes) to your `Info.plist`.

## Usage

### Starting and Stopping Session

``` dart
// Starting session and register tag discovered callback.
NfcManager.instance.startTagSession(
  alertMessageIOS: '...',
  pollingOptions: {TagPollingOption.iso14443, TagPollingOption.iso18092, TagPollingOption.iso15693},
  onDiscovered: (NfcTag tag) {
    // Manipulating tag
  },
);

// Stoppling session and unregister tag discovered callback.
NfcManager.instance.stopSession(
  alertMessageIOS: '...',
  errorMessageIOS: '...',
);
```

### Manipulating NDEF

``` dart
// Obtain an Ndef instance
Ndef ndef = Ndef.fromTag(tag);

if (ndef == null) {
  print('Tag is not ndef');
  return;
}

// Get an NdefMessage object cached at discovery time
print(ndef.cachedMessage);

if (!ndef.isWritable) {
  print('Tag is not ndef writable');
  return;
}

NdefMessage messageToWrite = NdefMessage([
  NdefRecord.createTextRecord('Hello'),
  NdefRecord.createUriRecord(Uri.parse('https://flutter.dev')),
  NdefRecord.createMimeRecord('text/plain', Uint8List.fromList('Hello'.codeUnits)),
  NdefRecord.createExternalRecord('mydomain', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
]);

// Write an NdefMessage
try {
  await ndef.write(messageToWrite);
} catch (e) {
  // handle error
  return;
}

// Make the tag read-only
try {
  await ndef.writeLock();
} catch (e) {
  // handle error
  return;
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

``` dart
// Obtaing a MiFare instance
MiFare miFare = MiFare.fromTag(tag);

if (miFare == null) {
  print('MiFare is not available on this tag');
  return;
}

Uint8List response = await miFare.sendMiFareCommand(...);
```
