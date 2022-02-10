# 3.1.1

* Upgrade kotlin version.

# 3.1.0

* Fix Null-Safety related issues. The following properties are now nullable.

  * `IsoDep#hiLayerResponse`
  * `IsoDep#historicalBytes`
  * `Iso7816#historicalBytes`
  * `Iso7816#applicationData`
  * `MiFare#historicalBytes`

# 3.0.0+2

* Update doc.

# 3.0.0+1

* Flutter format.

# 3.0.0

* Upgrade to null safety.

# 2.0.3

* Fix type conversion errors in `FeliCa#readWithoutEncryption` and `FeliCa#requestServiceV2`.

# 2.0.2

* Fix a bug in calling `FeliCa.sendFeliCaCommand` method.

# 2.0.1+1

* Update README.

# 2.0.1

* Fix an error when initializing plugin for non-NFC Android devices.

# 2.0.0+2

* Update doc.
* Flutter format.

# 2.0.0+1

* Update doc.

# 2.0.0

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

# 1.3.2+4

* Update README.

# 1.3.2+3

* Update README.

# 1.3.2+2

* Update README.

# 1.3.2+1

* Update README.

# 1.3.2

* Fix crash on Ndef write and writeLock error.

# 1.3.1

* Fix a bug where the error callback was not called.

# 1.3.0

* Add callback to handle error from session.

# 1.2.0

* Make discovered callback async.

# 1.1.0+1

* Update readme.

# 1.1.0

* Add constants.
* Fix misspelled name.
* Fix xcode build warning.
* Increase the Flutter SDK requirement to ^1.10.0.

# 1.0.1

* Fix error on invoking transceive method.

# 1.0.0

* Add platform-specifc-tag operations.
* Remove `NfcSessionType` enum.
* Migrate to pubspec platforms manifest.
* More consistent naming.

# 0.5.1

* Update flutter project files.
* Additional fix for migration to AndroidX.

# 0.5.0

* Migrate to AndroidX.

# 0.4.0+2

* Fix typo on README

# 0.4.0+1

* Update README

# 0.4.0

* Rename `NfcNdef#cachedNdef` to `NfcNdef#cachedMessage`.
* Add `NfcSessionType` enum.
* Add `NfcTagPollingOption` enum.

# 0.3.0

* Add `NdefRecord#createMimeRecord`.
* Add optional parameters `alertMessageIOS` and `errorMessageIOS` displayed in iOS system UI.
* Fix error on deserializing null message on dart side.

# 0.2.0

* Split `startSession` into `startNdefSession` and `startTagSession`.
* Improve doc.

# 0.1.1

* Fix crash on serializing nil message on ios side.
* Add example project.
* Improve doc.

# 0.1.0+2

* Improve doc.

# 0.1.0+1

* Improve doc.

# 0.1.0

* Add iOS 13 features.

# 0.0.1

* Initial release.
