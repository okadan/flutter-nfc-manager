import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

class NfcVAndroid {
  const NfcVAndroid(this._tag, {
    required this.dsfId,
    required this.responseFlags,
  });

  final NfcTag _tag;

  final int dsfId;

  final int responseFlags;

  static NfcVAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).nfcV;
    return pigeon == null ? null : NfcVAndroid(
      tag,
      dsfId: pigeon.dsfId!,
      responseFlags: pigeon.responseFlags!,
    );
  }

  Future<int> getMaxTransceiveLength() async {
    return hostApi.nfcVGetMaxTransceiveLength(_tag.handle);
  }

  Future<Uint8List> transceive(Uint8List data) async {
    return hostApi.nfcVTransceive(_tag.handle, data);
  }
}
