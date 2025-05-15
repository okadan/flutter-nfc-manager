import 'package:ndef_record/ndef_record.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_android/tags/tag.dart';

/// The class providing access to NDEF operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
final class NdefAndroid {
  const NdefAndroid._(
    this._handle, {
    required this.tag,
    required this.type,
    required this.maxSize,
    required this.canMakeReadOnly,
    required this.isWritable,
    required this.cachedNdefMessage,
  });

  final String _handle;

  /// The tag object backing of this instance.
  final NfcTagAndroid tag;

  // TODO: DOC
  final String type;

  // TODO: DOC
  final int maxSize;

  // TODO: DOC
  final bool canMakeReadOnly;

  // TODO: DOC
  final bool isWritable;

  // TODO: DOC
  final NdefMessage? cachedNdefMessage;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NdefAndroid? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.ndef;
    final atag = NfcTagAndroid.from(tag);
    if (data == null || tech == null || atag == null) return null;
    return NdefAndroid._(
      data.handle,
      tag: atag,
      type: tech.type,
      maxSize: tech.maxSize,
      canMakeReadOnly: tech.canMakeReadOnly,
      isWritable: tech.isWritable,
      cachedNdefMessage:
          tech.cachedNdefMessage == null
              ? null
              : NdefMessage(
                records:
                    tech.cachedNdefMessage!.records
                        .map(
                          (r) => NdefRecord(
                            typeNameFormat: TypeNameFormat.values.byName(
                              r.tnf.name,
                            ),
                            type: r.type,
                            identifier: r.id,
                            payload: r.payload,
                          ),
                        )
                        .toList(),
              ),
    );
  }

  // TODO: DOC
  Future<NdefMessage?> getNdefMessage() {
    return hostApi
        .ndefGetNdefMessage(handle: _handle)
        .then(
          (value) =>
              value == null
                  ? null
                  : NdefMessage(
                    records:
                        value.records
                            .map(
                              (r) => NdefRecord(
                                typeNameFormat: TypeNameFormat.values.byName(
                                  r.tnf.name,
                                ),
                                type: r.type,
                                identifier: r.id,
                                payload: r.payload,
                              ),
                            )
                            .toList(),
                  ),
        );
  }

  // TODO: DOC
  Future<void> writeNdefMessage(NdefMessage message) {
    return hostApi.ndefWriteNdefMessage(
      handle: _handle,
      message: NdefMessagePigeon(
        records:
            message.records
                .map(
                  (e) => NdefRecordPigeon(
                    tnf: TypeNameFormatPigeon.values.byName(
                      e.typeNameFormat.name,
                    ),
                    type: e.type,
                    id: e.identifier,
                    payload: e.payload,
                  ),
                )
                .toList(),
      ),
    );
  }

  // TODO: DOC
  Future<void> makeReadOnly() {
    return hostApi.ndefMakeReadOnly(handle: _handle);
  }
}
