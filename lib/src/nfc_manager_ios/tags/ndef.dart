import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_ndef_record/ndef_record.dart';

class NdefIOS {
  NdefIOS(this._tag, {
    required this.status,
    required this.capacity,
    required this.cachedNdefMessage,
  });

  final NfcTag _tag;

  final NdefStatusIOS status;

  final int capacity;

  final NdefMessage? cachedNdefMessage;

  static NdefIOS? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).ndef;
    return pigeon == null ? null : NdefIOS(
      tag,
      status: ndefStatusFromPigeon(pigeon.status!),
      capacity: pigeon.capacity!,
      cachedNdefMessage: pigeon.cachedNdefMessage == null ? null : NdefMessage(
        records: pigeon.cachedNdefMessage!.records?.map((r) => NdefRecord(
          typeNameFormat: typeNameFormatFromPigeon(r!.typeNameFormat!),
          type: r.type!,
          identifier: r.identifier!,
          payload: r.payload!,
        )).toList() ?? [],
      ),
    );
  }

  Future<QueryNdefStatusResponseIOS> queryNdefStatus() {
    return hostApi.ndefQueryNDEFStatus(_tag.handle)
      .then((value) => QueryNdefStatusResponseIOS(
        status: ndefStatusFromPigeon(value.status!),
        capacity: value.capacity!,
      ));
  }

  Future<NdefMessage?> readNdef() {
    return hostApi.ndefReadNDEF(_tag.handle)
      .then((value) => value == null ? null : NdefMessage(
        records: value.records?.map((r) => NdefRecord(
          typeNameFormat: typeNameFormatFromPigeon(r!.typeNameFormat!),
          type: r.type!,
          identifier: r.identifier!,
          payload: r.payload!,
        )).toList() ?? [],
      ));
  }

  Future<void> writeNdef(NdefMessage message) {
    return hostApi.ndefWriteNDEF(_tag.handle, PigeonNdefMessage(
      records: message.records.map((e) => PigeonNdefPayload(
        typeNameFormat: typeNameFormatToPigeon(e.typeNameFormat),
        type: e.type,
        identifier: e.identifier,
        payload: e.payload,
      )).toList(),
    ));
  }

  Future<void> writeLock() {
    return hostApi.ndefWriteLock(_tag.handle);
  }
}

class QueryNdefStatusResponseIOS {
  const QueryNdefStatusResponseIOS({required this.status, required this.capacity});

  final NdefStatusIOS status;

  final int capacity;
}

enum NdefStatusIOS {
  notSupported,

  readOnly,

  readWrite,
}
