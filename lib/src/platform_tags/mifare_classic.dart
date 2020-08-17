import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

/// (Android only) The class provides access to MifareClassic API for Android.
/// 
/// Acquire `MifareClassic` instance using `MifareClassic.from`.
class MifareClassic {
  /// Constructs an instance with the given values for testing.
  /// 
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `MifareClassic.from` are valid.
  const MifareClassic({
    @required NfcTag tag,
    @required this.identifier,
    @required this.type,
    @required this.blockCount,
    @required this.sectorCount,
    @required this.size,
    @required this.maxTransceiveLength,
    @required this.timeout,
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from Tag#id on Android.
  final Uint8List identifier;

  /// The value from MifareClassic#type on Android.
  final int type;

  /// The value from MifareClassic#blockCount on Android.
  final int blockCount;

  /// The value from MifareClassic#sectorCount on Android.
  final int sectorCount;

  /// The value from MifareClassic#size on Android.
  final int size;

  /// The value from MifareClassic#maxTransceiveLength on Android.
  final int maxTransceiveLength;

  /// The value from MifareClassic#timeout on Android.
  final int timeout;

  /// Get an instance of `MifareClassic` for the given tag.
  ///
  /// Returns null if the tag is not compatible with MifareClassic.
  factory MifareClassic.from(NfcTag tag) => $GetMifareClassic(tag);

  /// Sends the Authenticate Sector With Key A command to the tag.
  /// 
  /// This uses MifareClassic#authenticateSectorWithKeyA API on Android.
  Future<bool> authenticateSectorWithKeyA({
    @required int sectorIndex,
    @required Uint8List key,
  }) async {
    return channel.invokeMethod('MifareClassic#authenticateSectorWithKeyA', {
      'handle': _tag.handle,
      'sectorIndex': sectorIndex,
      'key': key,
    });
  }

  /// Sends the Authenticate Sector With Key B command to the tag.
  /// 
  /// This uses MifareClassic#authenticateSectorWithKeyB API on Android.
  Future<bool> authenticateSectorWithKeyB({
    @required int sectorIndex,
    @required Uint8List key,
  }) async {
    return channel.invokeMethod('MifareClassic#authenticateSectorWithKeyB', {
      'handle': _tag.handle,
      'sectorIndex': sectorIndex,
      'key': key,
    });
  }

  /// Sends the Increment command to the tag.
  /// 
  /// This uses MifareClassic#increment API on Android.
  Future<void> increment({
    @required int blockIndex,
    @required int value,
  }) async {
    return channel.invokeMethod('MifareClassic#increment', {
      'handle': _tag.handle,
      'blockIndex': blockIndex,
      'value': value,
    });
  }

  /// Sends the Decrement command to the tag.
  /// 
  /// This uses MifareClassic#decrement API on Android.
  Future<void> decrement({
    @required int blockIndex,
    @required int value,
  }) async {
    return channel.invokeMethod('MifareClassic#decrement', {
      'handle': _tag.handle,
      'blockIndex': blockIndex,
      'value': value,
    });
  }

  /// Sends the Read Block command to the tag.
  /// 
  /// This uses MifareClassic#readBlock API on Android.
  Future<Uint8List> readBlock({
    @required int blockIndex,
  }) async {
    return channel.invokeMethod('MifareClassic#readBlock', {
      'handle': _tag.handle,
      'blockIndex': blockIndex,
    });
  }

  /// Sends the Write Block command to the tag.
  /// 
  /// This uses MifareClassic#writeBlock API on Android.
  Future<void> writeBlock({
    @required int blockIndex,
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('MifareClassic#writeBlock', {
      'handle': _tag.handle,
      'blockIndex': blockIndex,
      'data': data,
    });
  }

  /// Sends the Restore command to the tag.
  /// 
  /// This uses MifareClassic#restore API on Android.
  Future<void> restore({
    @required int blockIndex,
  }) async {
    return channel.invokeMethod('MifareClassic#restore', {
      'handle': _tag.handle,
      'blockIndex': blockIndex,
    });
  }

  /// Sends the Transfer command to the tag.
  /// 
  /// This uses MifareClassic#transfer API on Android.
  Future<void> transfer({
    @required int blockIndex,
  }) async {
    return channel.invokeMethod('MifareClassic#transfer', {
      'handle': _tag.handle,
      'blockIndex': blockIndex,
    });
  }

  /// Sends the NfcA command to the tag.
  /// 
  /// This uses MifareClassic#transceive API on Android.
  /// This is equivalent to obtaining via `NfcA.from` this tag and calling `NfcA#transceive`.
  Future<Uint8List> transceive({
    @required int data,
  }) async {
    return channel.invokeMethod('MifareClassic#transceive', {
      'handle': _tag.handle,
      'data': data,
    });
  }
}
