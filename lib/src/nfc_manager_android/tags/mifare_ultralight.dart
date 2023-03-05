import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

class MifareUltralightAndroid {
  const MifareUltralightAndroid(this._tag, {
    required this.type,
  });

  final NfcTag _tag;

  final int type;

  static MifareUltralightAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).mifareUltralight;
    return pigeon == null ? null : MifareUltralightAndroid(
      tag,
      type: pigeon.type!,
    );
  }

  Future<int> getMaxTransceiveLength() async {
    return hostApi.mifareUltralightGetMaxTransceiveLength(_tag.handle);
  }

  Future<int> getTimeout() async {
    return hostApi.mifareUltralightGetTimeout(_tag.handle);
  }

  Future<void> setTimeout(int timeout) async {
    return hostApi.mifareUltralightSetTimeout(_tag.handle, timeout);
  }

  Future<Uint8List> readPages({
    required int pageOffset,
  }) async {
    return hostApi.mifareUltralightReadPages(_tag.handle, pageOffset);
  }

  Future<void> writePage({
    required int pageOffset,
    required Uint8List data,
  }) async {
    return hostApi.mifareUltralightWritePage(_tag.handle, pageOffset, data);
  }

  Future<Uint8List> transceive(Uint8List data) async {
    return hostApi.mifareUltralightTransceive(_tag.handle, data);
  }
}
