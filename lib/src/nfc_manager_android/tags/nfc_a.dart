import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

class NfcAAndroid {
  const NfcAAndroid(this._tag, {
    required this.atqa,
    required this.sak,
  });

  final NfcTag _tag;

  final Uint8List atqa;

  final int sak;

  static NfcAAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).nfcA;
    return pigeon == null ? null : NfcAAndroid(
      tag,
      atqa: pigeon.atqa!,
      sak: pigeon.sak!,
    );
  }

  Future<int> getMaxTransceiveLength() async {
    return hostApi.nfcAGetMaxTransceiveLength(_tag.handle);
  }

  Future<int> getTimeout() async {
    return hostApi.nfcAGetTimeout(_tag.handle);
  }

  Future<void> setTimeout(int timeout) async {
    return hostApi.nfcASetTimeout(_tag.handle, timeout);
  }

  Future<Uint8List> transceive(Uint8List data) async {
    return hostApi.nfcATransceive(_tag.handle, data);
  }
}
