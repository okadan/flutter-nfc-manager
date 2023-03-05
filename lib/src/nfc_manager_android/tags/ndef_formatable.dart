import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_ndef_record/ndef_record.dart';

class NdefFormatableAndroid {
  const NdefFormatableAndroid(this._tag);

  final NfcTag _tag;

  static NdefFormatableAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).ndefFormatable;
    return pigeon == null ? null : NdefFormatableAndroid(tag);
  }

  Future<void> format(NdefMessage firstMessage) async {
    return hostApi.ndefFormatableFormat(_tag.handle, PigeonNdefMessage(
      records: firstMessage.records.map((e) => PigeonNdefRecord(
        tnf: typeNameFormatToPigeon(e.typeNameFormat),
        type: e.type,
        id: e.identifier,
        payload: e.payload,
      )).toList(),
    ));
  }

  Future<void> formatReadOnly(NdefMessage firstMessage) async {
    return hostApi.ndefFormatableFormatReadOnly(_tag.handle, PigeonNdefMessage(
      records: firstMessage.records.map((e) => PigeonNdefRecord(
        tnf: typeNameFormatToPigeon(e.typeNameFormat),
        type: e.type,
        id: e.identifier,
        payload: e.payload,
      )).toList(),
    ));
  }
}
