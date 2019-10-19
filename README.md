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
