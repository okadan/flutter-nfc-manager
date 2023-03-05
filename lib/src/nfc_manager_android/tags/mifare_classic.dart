import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

class MifareClassicAndroid {
  const MifareClassicAndroid(this._tag, {
    required this.type,
    required this.blockCount,
    required this.sectorCount,
    required this.size,
  });

  final NfcTag _tag;

  final int type;

  final int blockCount;

  final int sectorCount;

  final int size;

  static MifareClassicAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).mifareClassic;
    return pigeon == null ? null : MifareClassicAndroid(
      tag,
      type: pigeon.type!,
      blockCount: pigeon.blockCount!,
      sectorCount: pigeon.sectorCount!,
      size: pigeon.size!,
    );
  }

  Future<bool> authenticateSectorWithKeyA({
    required int sectorIndex,
    required Uint8List key,
  }) async {
    return hostApi.mifareClassicAuthenticateSectorWithKeyA(_tag.handle, sectorIndex, key);
  }

  Future<bool> authenticateSectorWithKeyB({
    required int sectorIndex,
    required Uint8List key,
  }) async {
    return hostApi.mifareClassicAuthenticateSectorWithKeyB(_tag.handle, sectorIndex, key);
  }

  Future<void> increment({
    required int blockIndex,
    required int value,
  }) async {
    return hostApi.mifareClassicIncrement(_tag.handle, blockIndex, value);
  }

  Future<void> decrement({
    required int blockIndex,
    required int value,
  }) async {
    return hostApi.mifareClassicDecrement(_tag.handle, blockIndex, value);
  }

  Future<Uint8List> readBlock({
    required int blockIndex,
  }) async {
    return hostApi.mifareClassicReadBlock(_tag.handle, blockIndex);
  }

  Future<void> writeBlock({
    required int blockIndex,
    required Uint8List data,
  }) async {
    return hostApi.mifareClassicWriteBlock(_tag.handle, blockIndex, data);
  }

  Future<void> restore({
    required int blockIndex,
  }) async {
    return hostApi.mifareClassicRestore(_tag.handle, blockIndex);
  }

  Future<void> transfer({
    required int blockIndex,
  }) async {
    return hostApi.mifareClassicTransfer(_tag.handle, blockIndex);
  }

  Future<Uint8List> transceive({
    required Uint8List data,
  }) async {
    return hostApi.mifareClassicTransceive(_tag.handle, data);
  }
}
