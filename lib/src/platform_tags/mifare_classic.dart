import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

// MifareClassic
class MifareClassic {
  // MifareClassic
  const MifareClassic({
    @required this.tag,
    @required this.identifier,
    @required this.type,
    @required this.blockCount,
    @required this.sectorCount,
    @required this.size,
    @required this.maxTransceiveLength,
    @required this.timeout,
  });

  // tag
  final NfcTag tag;

  // identifier
  final Uint8List identifier;

  // type: One of TYPE_UNKNOWN, TYPE_CLASSIC, TYPE_PLUS or TYPE_PRO
  final int type;

  // blockCount
  final int blockCount;

  // sectorCount
  final int sectorCount;

  // size: One of SIZE_MINI, SIZE_1K, SIZE_2K, SIZE_4K
  final int size;

  // maxTransceiveLength
  final int maxTransceiveLength;

  // timeout
  final int timeout;

  // MifareClassic.from
  factory MifareClassic.from(NfcTag tag) => $GetMifareClassic(tag);

  // authenticateSectorWithKeyA
  Future<bool> authenticateSectorWithKeyA({
    @required int sectorIndex,
    @required Uint8List key,
  }) async {
    return channel.invokeMethod('MifareClassic#authenticateSectorWithKeyA', {
      'handle': tag.handle,
      'sectorIndex': sectorIndex,
      'key': key,
    });
  }

  // authenticateSectorWithKeyB
  Future<bool> authenticateSectorWithKeyB({
    @required int sectorIndex,
    @required Uint8List key,
  }) async {
    return channel.invokeMethod('MifareClassic#authenticateSectorWithKeyB', {
      'handle': tag.handle,
      'sectorIndex': sectorIndex,
      'key': key,
    });
  }

  // increment
  Future<void> increment({
    @required int blockIndex,
    @required int value,
  }) async {
    return channel.invokeMethod('MifareClassic#increment', {
      'handle': tag.handle,
      'blockIndex': blockIndex,
      'value': value,
    });
  }

  // decrement
  Future<void> decrement({
    @required int blockIndex,
    @required int value,
  }) async {
    return channel.invokeMethod('MifareClassic#decrement', {
      'handle': tag.handle,
      'blockIndex': blockIndex,
      'value': value,
    });
  }

  // readBlock
  Future<Uint8List> readBlock({
    @required int blockIndex,
  }) async {
    return channel.invokeMethod('MifareClassic#readBlock', {
      'handle': tag.handle,
      'blockIndex': blockIndex,
    });
  }

  // writeBlock
  Future<void> writeBlock({
    @required int blockIndex,
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('MifareClassic#writeBlock', {
      'handle': tag.handle,
      'blockIndex': blockIndex,
      'data': data,
    });
  }

  // restore
  Future<void> restore({
    @required int blockIndex,
  }) async {
    return channel.invokeMethod('MifareClassic#restore', {
      'handle': tag.handle,
      'blockIndex': blockIndex,
    });
  }

  // transfer
  Future<void> transfer({
    @required int blockIndex,
  }) async {
    return channel.invokeMethod('MifareClassic#transfer', {
      'handle': tag.handle,
      'blockIndex': blockIndex,
    });
  }

  // transceive
  Future<Uint8List> transceive({
    @required int data,
  }) async {
    return channel.invokeMethod('MifareClassic#transceive', {
      'handle': tag.handle,
      'data': data,
    });
  }
}
