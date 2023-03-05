import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

class NfcFAndroid {
  const NfcFAndroid(this._tag, {
    required this.manufacturer,
    required this.systemCode,
  });

  final NfcTag _tag;

  final Uint8List manufacturer;

  final Uint8List systemCode;

  static NfcFAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).nfcF;
    return pigeon == null ? null : NfcFAndroid(
      tag,
      manufacturer: pigeon.manufacturer!,
      systemCode: pigeon.systemCode!,
    );
  }

  Future<int> getMaxTransceiveLength() async {
    return hostApi.nfcFGetMaxTransceiveLength(_tag.handle);
  }

  Future<int> getTimeout() async {
    return hostApi.nfcFGetTimeout(_tag.handle);
  }

  Future<void> setTimeout(int timeout) async {
    return hostApi.nfcFSetTimeout(_tag.handle, timeout);
  }

  Future<Uint8List> transceive(Uint8List data) async {
    return hostApi.nfcFTransceive(_tag.handle, data);
  }
}
