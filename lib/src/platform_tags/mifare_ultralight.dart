import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:nfc_manager/src/translator.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';

// MifareUltralight
class MifareUltralight {
  // MifareUltralight
  const MifareUltralight({
    @required this.tag,
    @required this.identifier,
    @required this.type,
    @required this.maxTransceiveLength,
    @required this.timeout,
  });

  // tag
  final NfcTag tag;

  // identifier
  final Uint8List identifier;

  // type: One of TYPE_ULTRALIGHT or TYPE_ULTRALIGHT_C or TYPE_UNKNOWN
  final int type;

  // maxTransceiveLength
  final int maxTransceiveLength;

  // timeout
  final int timeout;

  // MifareUltralight.from
  factory MifareUltralight.from(NfcTag tag) => $GetMifareUltralight(tag);

  // readPages
  Future<Uint8List> readPages({
    @required int pageOffset,
  }) async {
    return channel.invokeMethod('MifareUltralight#readPages', {
      'handle': tag.handle,
      'pageOffset': pageOffset,
    });
  }

  // writePage
  Future<void> writePage({
    @required int pageOffset,
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('MifareUltralight#writePage', {
      'handle': tag.handle,
      'pageOffset': pageOffset,
      'data': data,
    });
  }

  // transceive
  Future<Uint8List> transceive({
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('MifareUltralight#transceive', {
      'handle': tag.handle,
      'data': data,
    });
  }
}
