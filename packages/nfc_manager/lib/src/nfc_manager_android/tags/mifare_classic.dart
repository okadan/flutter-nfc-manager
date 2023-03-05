import 'dart:typed_data';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_android/tags/tag.dart';

/// The class providing access to MIFARE Classic operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
final class MifareClassicAndroid {
  const MifareClassicAndroid._(
    this._handle, {
    required this.tag,
    required this.type,
    required this.blockCount,
    required this.sectorCount,
    required this.size,
  });

  final String _handle;

  /// The tag object backing of this instance.
  final NfcTagAndroid tag;

  // TODO: DOC
  final MifareClassicTypeAndroid type;

  // TODO: DOC
  final int blockCount;

  // TODO: DOC
  final int sectorCount;

  // TODO: DOC
  final int size;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static MifareClassicAndroid? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.mifareClassic;
    final atag = NfcTagAndroid.from(tag);
    if (data == null || tech == null || atag == null) return null;
    return MifareClassicAndroid._(
      data.handle,
      tag: atag,
      type: MifareClassicTypeAndroid.values.byName(tech.type.name),
      blockCount: tech.blockCount,
      sectorCount: tech.sectorCount,
      size: tech.size,
    );
  }

  // TODO: DOC
  Future<bool> authenticateSectorWithKeyA({
    required int sectorIndex,
    required Uint8List key,
  }) {
    return hostApi.mifareClassicAuthenticateSectorWithKeyA(
      handle: _handle,
      sectorIndex: sectorIndex,
      key: key,
    );
  }

  // TODO: DOC
  Future<bool> authenticateSectorWithKeyB({
    required int sectorIndex,
    required Uint8List key,
  }) {
    return hostApi.mifareClassicAuthenticateSectorWithKeyB(
      handle: _handle,
      sectorIndex: sectorIndex,
      key: key,
    );
  }

  // TODO: DOC
  Future<void> increment({required int blockIndex, required int value}) {
    return hostApi.mifareClassicIncrement(
      handle: _handle,
      blockIndex: blockIndex,
      value: value,
    );
  }

  // TODO: DOC
  Future<void> decrement({required int blockIndex, required int value}) {
    return hostApi.mifareClassicDecrement(
      handle: _handle,
      blockIndex: blockIndex,
      value: value,
    );
  }

  // TODO: DOC
  Future<Uint8List> readBlock({required int blockIndex}) {
    return hostApi.mifareClassicReadBlock(
      handle: _handle,
      blockIndex: blockIndex,
    );
  }

  // TODO: DOC
  Future<void> writeBlock({required int blockIndex, required Uint8List data}) {
    return hostApi.mifareClassicWriteBlock(
      handle: _handle,
      blockIndex: blockIndex,
      data: data,
    );
  }

  // TODO: DOC
  Future<void> restore({required int blockIndex}) {
    return hostApi.mifareClassicRestore(
      handle: _handle,
      blockIndex: blockIndex,
    );
  }

  // TODO: DOC
  Future<void> transfer({required int blockIndex}) {
    return hostApi.mifareClassicTransfer(
      handle: _handle,
      blockIndex: blockIndex,
    );
  }

  // TODO: DOC
  Future<Uint8List> transceive(Uint8List bytes) {
    return hostApi.mifareClassicTransceive(handle: _handle, bytes: bytes);
  }
}

// TODO: DOC
enum MifareClassicTypeAndroid {
  // TODO: DOC
  classic,

  // TODO: DOC
  plus,

  // TODO: DOC
  pro,

  // TODO: DOC
  unknown,
}
