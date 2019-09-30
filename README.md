# nfc_manager

A Flutter plugin to use NFC. Supported on both Android and iOS.

## Note

This plugin is still under development.

So please use with caution as there may be potential issues and breaking changes.

Feedback is welcome.

## Setup

### Android Setup

* Add permission to your `AndroidMenifest.xml`:

``` xml
<uses-permission android:name="android.permission.NFC" />
```

### iOS Setup

* Add [NFCReaderUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nfcreaderusagedescription) to your `Info.plist`:

``` xml
<key>NFCReaderUsageDescription</key>
<string>[YOUR DESCRIPTION]</string>
```

* Add [Near Field Communication Tag Reader Session Formats Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_nfc_readersession_formats) to your entitlements:

``` xml
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
    <string>NDEF</string>
    <string>TAG</string> <!-- To use `NfcManager#startTagSession` -->
</array>
```

* To use `NfcManager#startTagSession`, add [com.apple.developer.nfc.readersession.iso7816.select-identifiers](https://developer.apple.com/documentation/bundleresources/information_property_list/select-identifiers) and [com.apple.developer.nfc.readersession.felica.systemcodes](https://developer.apple.com/documentation/bundleresources/information_property_list/systemcodes) to your `Info.plist` as you need:

``` xml
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>[AID]</string>
</array>

<key>com.apple.developer.nfc.readersession.felica.systemcodes</key>
<array>
    <string>[SYSTEM CODE]</string>
</array>
```
