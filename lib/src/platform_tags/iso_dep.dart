import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

// IsoDep
class IsoDep {
  // IsoDep
  const IsoDep({
    @required this.tag,
    @required this.identifier,
    @required this.hiLayerResponse,
    @required this.historicalBytes,
    @required this.isExtendedLengthApduSupported,
    @required this.maxTransceiveLength,
    @required this.timeout,
  });

  // tag
  final NfcTag tag;

  // identifier
  final Uint8List identifier;

  // hiLayerResponse
  final Uint8List hiLayerResponse;

  // historicalBytes
  final Uint8List historicalBytes;

  // isExtendedLengthApduSupported
  final bool isExtendedLengthApduSupported;

  // maxTransceiveLength
  final int maxTransceiveLength;

  // timeout
  final int timeout;

  // IsoDep.from
  factory IsoDep.from(NfcTag tag) => $GetIsoDep(tag);

  // transceive
  Future<Uint8List> transceive({
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('IsoDep#transceive', {
      'handle': tag.handle,
      'data': data,
    });
  }
}
