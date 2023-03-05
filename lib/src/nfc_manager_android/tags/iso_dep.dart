import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

class IsoDepAndroid {
  const IsoDepAndroid(this._tag, {
    required this.hiLayerResponse,
    required this.historicalBytes,
    required this.isExtendedLengthApduSupported,
  });

  final NfcTag _tag;

  final Uint8List? hiLayerResponse;

  final Uint8List? historicalBytes;

  final bool isExtendedLengthApduSupported;

  static IsoDepAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).isoDep;
    return pigeon == null ? null : IsoDepAndroid(
      tag,
      hiLayerResponse: pigeon.hiLayerResponse,
      historicalBytes: pigeon.historicalBytes,
      isExtendedLengthApduSupported: pigeon.isExtendedLengthApduSupported!,
    );
  }

  Future<int> getMaxTransceiveLength() async {
    return hostApi.isoDepGetMaxTransceiveLength(_tag.handle);
  }

  Future<int> getTimeout() async {
    return hostApi.isoDepGetTimeout(_tag.handle);
  }

  Future<void> setTimeout(int timeout) async {
    return hostApi.isoDepSetTimeout(_tag.handle, timeout);
  }

  Future<Uint8List> transceive(Uint8List data) async {
    return hostApi.isoDepTransceive(_tag.handle, data);
  }
}
