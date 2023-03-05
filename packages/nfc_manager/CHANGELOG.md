## 4.0.0

**Has many breaking changes.**

* Rename the following:
  * `NfcA` to `NfcAAndroid`
  * `NfcB` to `NfcBAndroid`
  * `NfcF` to `NfcFAndroid`
  * `NfcV` to `NfcVAndroid`
  * `IsoDep` to `IsoDepAndroid`
  * `MifareClassic` to `MifareClassicAndroid`
  * `MifareUltralight` to `MifareUltralightAndroid`
  * `NdefFormatable` to `NdefFormatableAndroid`
  * `MiFare` to `MiFareIos`
  * `FeliCa` to `FeliCaIos`
  * `Iso15693` to `Iso15693Ios`
  * `Iso7816` to `Iso7816Ios`
  * Options for `startSession`:
    * `onError` to `onErrorIos`
    * `invalidateAfterFirstRead` to `invalidateAfterFirstReadIos`
    * `alertMessage` to `alertMessageIos`
  * Options for `stopSession`:
    * `alertMessage` to `alertMessageIos`
    * `errorMessage` to `errorMessageIos`
* Remove the following:
  * `Ndef` (Instead use the [`nfc_manager_ndef`](https://pub.dev/packages/nfc_manager_ndef) package or `NdefAndroid` / `NdefIos`)
  * `timeout` (Instead use the `async getTimeout()` method)
  * `maxTransceiveLength` (Instead use the `async getMaxTransceiveLength()` method)
  * `NfcError` (Instead use the `NfcReaderSessionErrorIos`)
  * `NfcErrorType` (Instead use the `NfcReaderErrorCodeIos`)
* Add the following:
  * `ndef_record.dart` library that provides access to [`ndef_record`](https://pub.dev/packages/ndef_record) package.
  * `nfc_manager_android.dart` library that provides access to Android API.
  * `nfc_manager_ios.dart` library that provides access to iOS API.
  * `async setTimeout()` method.
  * `noPlatformSoundsAndroid` option to `startSession` method.
* Upgrade Flutter.
* Update README.

## 3.5.1

* Make compatible for Kotlin 2.1.0

## 3.5.0

* Upgrade Flutter.
* Fix analyze issues.

## 3.4.0

* Fix iOS background isolate issue.
* Add namespace to Gradle for Android.
* Rebuild projects on Flutter stable channel.

## 3.3.0

* Added `invalidateAfterFirstRead` argument to `startSession`. This enables `restartPolling` on iOS.

## 3.2.0

* Fix build issues.

## 3.1.1

* Upgrade kotlin version.

## 3.1.0

* Fix Null-Safety related issues. The following properties are now nullable.
  * `IsoDep#hiLayerResponse`
  * `IsoDep#historicalBytes`
  * `Iso7816#historicalBytes`
  * `Iso7816#applicationData`
  * `MiFare#historicalBytes`

## 3.0.0+2

* Update doc.

## 3.0.0+1

* Flutter format.

## 3.0.0

* Upgrade to null safety.

## 2.0.3

* Fix type conversion errors in `FeliCa#readWithoutEncryption` and `FeliCa#requestServiceV2`.

## 2.0.2

* Fix a bug in calling `FeliCa.sendFeliCaCommand` method.

## 2.0.1+1

* Update README.

## 2.0.1

* Fix an error when initializing plugin for non-NFC Android devices.

## 2.0.0+2

* Update doc.
* Flutter format.

## 2.0.0+1

* Update doc.

## 2.0.0

**Has many breaking changes.**

* Remove `startNdefSession` and `NdefDiscoveredCallback`.
* Rename `startTagSession` to `startSession`.
* Rename `TagPollingOption` to `NfcPollingOption`.
* Rename `NfcSessionError` to `NfcError`.
* Rename `NfcSessionErrorType` to `NfcErrorType`.
* Rename `TagDiscoveredCallback` to `NfcTagCallback`.
* Rename `NfcSessionErrorCallback` to `NfcErrorCallback`.
* Rename `ISO15693` to `Iso15693`.
* Rename `ISO7816` to `Iso7816`.
* Rename `fromTag` to `from`. (e.g. `MiFare.fromTag(tag)` -> `MiFare.from(tag)`)
* Add `NdefTypeNameFormat` enum.
* Add `NdefFormatable`, `MifareClassic` and `MifareUltralight` classes.
* Add `Ndef#read` method.
* Add command-implementations for `FeliCa` and `Iso15693`.
* Upgrade flutter environment.

## 1.3.2+4

* Update README.

## 1.3.2+3

* Update README.

## 1.3.2+2

* Update README.

## 1.3.2+1

* Update README.

## 1.3.2

* Fix crash on Ndef write and writeLock error.

## 1.3.1

* Fix a bug where the error callback was not called.

## 1.3.0

* Add callback to handle error from session.

## 1.2.0

* Make discovered callback async.

## 1.1.0+1

* Update readme.

## 1.1.0

* Add constants.
* Fix misspelled name.
* Fix xcode build warning.
* Increase the Flutter SDK requirement to ^1.10.0.

## 1.0.1

* Fix error on invoking transceive method.

## 1.0.0

* Add platform-specifc-tag operations.
* Remove `NfcSessionType` enum.
* Migrate to pubspec platforms manifest.
* More consistent naming.

## 0.5.1

* Update flutter project files.
* Additional fix for migration to AndroidX.

## 0.5.0

* Migrate to AndroidX.

## 0.4.0+2

* Fix typo on README

## 0.4.0+1

* Update README

## 0.4.0

* Rename `NfcNdef#cachedNdef` to `NfcNdef#cachedMessage`.
* Add `NfcSessionType` enum.
* Add `NfcTagPollingOption` enum.

## 0.3.0

* Add `NdefRecord#createMimeRecord`.
* Add optional parameters `alertMessageIOS` and `errorMessageIOS` displayed in iOS system UI.
* Fix error on deserializing null message on dart side.

## 0.2.0

* Split `startSession` into `startNdefSession` and `startTagSession`.
* Improve doc.

## 0.1.1

* Fix crash on serializing nil message on ios side.
* Add example project.
* Improve doc.

## 0.1.0+2

* Improve doc.

## 0.1.0+1

* Improve doc.

## 0.1.0

* Add iOS 13 features.

## 0.0.1

* Initial release.
