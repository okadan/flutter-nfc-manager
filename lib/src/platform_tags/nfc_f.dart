import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

// NfcF
class NfcF {
  // NfcF
  const NfcF({
    @required this.tag,
    @required this.identifier,
    @required this.manufacturer,
    @required this.systemCode,
    @required this.maxTransceiveLength,
    @required this.timeout,
  });

  // tag
  final NfcTag tag;

  // identifier
  final Uint8List identifier;

  // manufacturer
  final Uint8List manufacturer;

  // systemCode
  final Uint8List systemCode;

  // maxTransceiveLength
  final int maxTransceiveLength;

  // timeout
  final int timeout;

  // NfcF.from
  factory NfcF.from(NfcTag tag) => $GetNfcF(tag);

  // transceive
  Future<Uint8List> transceive({
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('NfcF#transceive', {
      'handle': tag.handle,
      'data': data,
    });
  }
}
