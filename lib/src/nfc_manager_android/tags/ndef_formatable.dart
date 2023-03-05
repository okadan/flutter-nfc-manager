import 'package:ndef_record/ndef_record.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_android/tags/tag.dart';

/// The class providing access to NDEF format operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
final class NdefFormatableAndroid {
  const NdefFormatableAndroid._(this._handle, {required this.tag});

  final String _handle;

  /// DOC:
  final NfcTagAndroid tag;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NdefFormatableAndroid? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as PigeonTag?;
    final tech = data?.ndefFormatable;
    final atag = NfcTagAndroid.from(tag);
    if (data == null || tech == null || atag == null) return null;
    return NdefFormatableAndroid._(data.handle, tag: atag);
  }

  /// DOC:
  Future<void> format(NdefMessage firstMessage) {
    return hostApi.ndefFormatableFormat(
        handle: _handle,
        firstMessage: PigeonNdefMessage(
          records: firstMessage.records
              .map((e) => PigeonNdefRecord(
                    tnf: PigeonTypeNameFormat.values.byName(
                      e.typeNameFormat.name,
                    ),
                    type: e.type,
                    id: e.identifier,
                    payload: e.payload,
                  ))
              .toList(),
        ));
  }

  /// DOC:
  Future<void> formatReadOnly(NdefMessage firstMessage) {
    return hostApi.ndefFormatableFormatReadOnly(
        handle: _handle,
        firstMessage: PigeonNdefMessage(
          records: firstMessage.records
              .map((e) => PigeonNdefRecord(
                    tnf: PigeonTypeNameFormat.values.byName(
                      e.typeNameFormat.name,
                    ),
                    type: e.type,
                    id: e.identifier,
                    payload: e.payload,
                  ))
              .toList(),
        ));
  }
}
