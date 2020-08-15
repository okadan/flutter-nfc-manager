import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

// NfcB
class NfcB {
  // NfcB
  const NfcB({
    @required this.tag,
    @required this.identifier,
    @required this.applicationData,
    @required this.protocolInfo,
    @required this.maxTransceiveLength,
  });

  // tag
  final NfcTag tag;

  // identifier
  final Uint8List identifier;

  // applicationdata
  final Uint8List applicationData;

  // protocolInfo
  final Uint8List protocolInfo;

  // maxTransceiveLength
  final int maxTransceiveLength;

  // NfcB.from
  factory NfcB.from(NfcTag tag) => $GetNfcB(tag);

  // transceive
  Future<Uint8List> transceive({
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('NfcB#transceive', {
      'handle': tag.handle,
      'data': data,
    });
  }
}
