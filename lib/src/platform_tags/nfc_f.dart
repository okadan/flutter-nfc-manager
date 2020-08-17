import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

/// (Android only) The class provides access to NfcF API for Android.
/// 
/// Acquire `NfcF` instance using `NfcF.from`.
class NfcF {
  /// Constructs an instance with the given values for testing.
  /// 
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `NfcF.from` are valid.
  const NfcF({
    @required NfcTag tag,
    @required this.identifier,
    @required this.manufacturer,
    @required this.systemCode,
    @required this.maxTransceiveLength,
    @required this.timeout,
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from Tag#id on Android.
  final Uint8List identifier;

  /// The value from NfcF#manufacturer on Android.
  final Uint8List manufacturer;

  /// The value from NfcF#systemCode on Android.
  final Uint8List systemCode;

  /// The value from NfcF#maxTransceiveLength on Android.
  final int maxTransceiveLength;

  /// The value from NfcF#timeout on Android.
  final int timeout;

  /// Get an instance of `NfcF` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NfcF.
  factory NfcF.from(NfcTag tag) => $GetNfcF(tag);

  /// Sends the NfcF command to the tag.
  /// 
  /// This uses NfcF#transceive API on Android.
  Future<Uint8List> transceive({
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('NfcF#transceive', {
      'handle': _tag.handle,
      'data': data,
    });
  }
}
