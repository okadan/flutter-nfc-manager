import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

class NfcBAndroid {
  const NfcBAndroid(this._tag, {
    required this.applicationData,
    required this.protocolInfo,
  });

  final NfcTag _tag;

  final Uint8List applicationData;

  final Uint8List protocolInfo;

  static NfcBAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).nfcB;
    return pigeon == null ? null : NfcBAndroid(
      tag,
      applicationData: pigeon.applicationData!,
      protocolInfo: pigeon.protocolInfo!,
    );
  }

  Future<int> getMaxTransceiveLength() async {
    return hostApi.nfcBGetMaxTransceiveLength(_tag.handle);
  }

  Future<Uint8List> transceive(Uint8List data) async {
    return hostApi.nfcBTransceive(_tag.handle, data);
  }
}
