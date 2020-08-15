import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

// NfcA
class NfcA {
  // NfcA
  const NfcA({
    @required this.tag,
    @required this.identifier,
    @required this.atqa,
    @required this.sak,
    @required this.maxTransceiveLength,
    @required this.timeout,
  });

  // tag
  final NfcTag tag;

  // identifier
  final Uint8List identifier;

  // atqa
  final Uint8List atqa;

  // sak
  final int sak;

  // maxTransceiveLength
  final int maxTransceiveLength;

  // timeout
  final int timeout;

  // NfcA.from
  factory NfcA.from(NfcTag tag) => $GetNfcA(tag);

  // transceive
  Future<Uint8List> transceive({
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('NfcA#transceive', {
      'handle': tag.handle,
      'data': data,
    });
  }
}
