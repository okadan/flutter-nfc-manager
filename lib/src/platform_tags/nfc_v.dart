import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

// NfcV
class NfcV {
  // NfcV
  const NfcV({
    @required this.tag,
    @required this.identifier,
    @required this.dsfId,
    @required this.responseFlags,
    @required this.maxTransceiveLength,
  });

  // tag
  final NfcTag tag;

  // identifier
  final Uint8List identifier;

  // dsfId
  final int dsfId;

  // responseFlags
  final int responseFlags;

  // maxTransceiveLength
  final int maxTransceiveLength;

  // NfcV.from
  factory NfcV.from(NfcTag tag) => $GetNfcV(tag);

  // transceive
  Future<Uint8List> transceive({
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('NfcV#transceive', {
      'handle': tag.handle,
      'data': data,
    });
  }
}
