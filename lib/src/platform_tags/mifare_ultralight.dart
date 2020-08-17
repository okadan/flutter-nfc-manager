import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

/// (Android only) The class provides access to MifareUltralight API for Android.
/// 
/// Acquire `MifareUltralight` instance using `MifareUltralight.from`.
class MifareUltralight {
  /// Constructs an instance with the given values for testing.
  /// 
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `MifareUltralight.from` are valid.
  const MifareUltralight({
    @required NfcTag tag,
    @required this.identifier,
    @required this.type,
    @required this.maxTransceiveLength,
    @required this.timeout,
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from Tag#id on Android.
  final Uint8List identifier;

  /// The value from MifareUltralight#type on Android.
  final int type;

  /// The value from MifareUltralight#maxTransceiveLength on Android.
  final int maxTransceiveLength;

  /// The value from MifareUltralight#timeout on Android.
  final int timeout;

  /// Get an instance of `MifareUltralight` for the given tag.
  ///
  /// Returns null if the tag is not compatible with MifareUltralight.
  factory MifareUltralight.from(NfcTag tag) => $GetMifareUltralight(tag);

  /// Sends the Read Pages command to the tag.
  /// 
  /// This uses MifareUltralight#readPages API on Android.
  Future<Uint8List> readPages({
    @required int pageOffset,
  }) async {
    return channel.invokeMethod('MifareUltralight#readPages', {
      'handle': _tag.handle,
      'pageOffset': pageOffset,
    });
  }

  /// Sends the Write Page command to the tag.
  /// 
  /// This uses MifareUltralight#writePage API on Android.
  Future<void> writePage({
    @required int pageOffset,
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('MifareUltralight#writePage', {
      'handle': _tag.handle,
      'pageOffset': pageOffset,
      'data': data,
    });
  }

  /// Sends the NfcA command to the tag.
  /// 
  /// This uses MifareUltralight#transceive API on Android.
  /// This is equivalent to obtaining via `NfcA.from` this tag and calling `NfcA#transceive`.
  Future<Uint8List> transceive({
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('MifareUltralight#transceive', {
      'handle': _tag.handle,
      'data': data,
    });
  }
}
