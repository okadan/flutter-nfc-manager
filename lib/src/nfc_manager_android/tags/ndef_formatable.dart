import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_ndef_record/ndef_record.dart';

/// The class providing access to NDEF format operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
class NdefFormatableAndroid {
  const NdefFormatableAndroid._(this._handle);

  final String _handle;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NdefFormatableAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).ndefFormatable;
    return pigeon == null ? null : NdefFormatableAndroid._(tag.handle);
  }

  Future<void> format(NdefMessage firstMessage) {
    return hostApi.ndefFormatableFormat(
        _handle,
        PigeonNdefMessage(
          records: firstMessage.records
              .map((e) => PigeonNdefRecord(
                    tnf: typeNameFormatToPigeon(e.typeNameFormat),
                    type: e.type,
                    id: e.identifier,
                    payload: e.payload,
                  ))
              .toList(),
        ));
  }

  Future<void> formatReadOnly(NdefMessage firstMessage) {
    return hostApi.ndefFormatableFormatReadOnly(
        _handle,
        PigeonNdefMessage(
          records: firstMessage.records
              .map((e) => PigeonNdefRecord(
                    tnf: typeNameFormatToPigeon(e.typeNameFormat),
                    type: e.type,
                    id: e.identifier,
                    payload: e.payload,
                  ))
              .toList(),
        ));
  }
}
