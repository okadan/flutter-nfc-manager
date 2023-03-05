import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_ndef_record/ndef_record.dart';

class NdefAndroid {
  const NdefAndroid(this._tag, {
    required this.type,
    required this.maxSize,
    required this.canMakeReadOnly,
    required this.isWritable,
    required this.cachedNdefMessage,
  });

  final NfcTag _tag;

  final String type;

  final int maxSize;

  final bool canMakeReadOnly;

  final bool isWritable;

  final NdefMessage? cachedNdefMessage;

  static NdefAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).ndef;
    return pigeon == null ? null : NdefAndroid(
      tag,
      type: pigeon.type!,
      maxSize: pigeon.maxSize!,
      canMakeReadOnly: pigeon.canMakeReadOnly!,
      isWritable: pigeon.isWritable!,
      cachedNdefMessage: pigeon.cachedNdefMessage == null ? null : NdefMessage(
        records: pigeon.cachedNdefMessage!.records?.map((r) => NdefRecord(
          typeNameFormat: typeNameFormatFromPigeon(r!.tnf!),
          type: r.type!,
          identifier: r.id!,
          payload: r.payload!,
        )).toList() ?? [],
      ),
    );
  }

  Future<NdefMessage?> getNdefMessage() {
    return hostApi.ndefGetNdefMessage(_tag.handle)
      .then((value) => value == null ? null : NdefMessage(
        records: value.records?.map((r) => NdefRecord(
          typeNameFormat: typeNameFormatFromPigeon(r!.tnf!),
          type: r.type!,
          identifier: r.id!,
          payload: r.payload!,
        )).toList() ?? [],
      ));
  }

  Future<void> writeNdefMessage(NdefMessage message) {
    return hostApi.ndefWriteNdefMessage(_tag.handle, PigeonNdefMessage(
      records: message.records.map((e) => PigeonNdefRecord(
        tnf: typeNameFormatToPigeon(e.typeNameFormat),
        type: e.type,
        id: e.identifier,
        payload: e.payload,
      )).toList(),
    ));
  }

  Future<void> makeReadOnly() {
    return hostApi.ndefMakeReadOnly(_tag.handle);
  }
}
