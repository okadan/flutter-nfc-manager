import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

/// (Android only) The class provides access to NfcA API for Android.
/// 
/// Acquire `NfcA` instance using `NfcA.from`.
class NfcA {
  /// Constructs an instance with the given values for testing.
  /// 
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `NfcA.from` are valid.
  const NfcA({
    @required NfcTag tag,
    @required this.identifier,
    @required this.atqa,
    @required this.sak,
    @required this.maxTransceiveLength,
    @required this.timeout,
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from Tag#id on Android.
  final Uint8List identifier;

  /// The value from NfcA#atqa on Android.
  final Uint8List atqa;

  /// The value from NfcA#sak on Android.
  final int sak;

  /// The value from NfcA#maxTransceiveLength on Android.
  final int maxTransceiveLength;

  /// The value from NfcA#timeout on Android.
  final int timeout;

  /// Get an instance of `NfcA` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NfcA.
  factory NfcA.from(NfcTag tag) => $GetNfcA(tag);

  /// Sends the NfcA command to the tag.
  /// 
  /// This uses NfcA#transceive API on Android.
  Future<Uint8List> transceive({
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('NfcA#transceive', {
      'handle': _tag.handle,
      'data': data,
    });
  }
}
