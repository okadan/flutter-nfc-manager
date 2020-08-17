import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

/// (Android only) The class provides access to NfcV API for Android.
/// 
/// Acquire `NfcV` instance using `NfcV.from`.
class NfcV {
  /// Constructs an instance with the given values for testing.
  /// 
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `NfcV.from` are valid.
  const NfcV({
    @required NfcTag tag,
    @required this.identifier,
    @required this.dsfId,
    @required this.responseFlags,
    @required this.maxTransceiveLength,
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from Tag#id on Android.
  final Uint8List identifier;

  /// The value from NfcV#dsfId on Android.
  final int dsfId;

  /// The value from NfcV#responseFlags on Android.
  final int responseFlags;

  /// The value from NfcV#maxTransceiveLength on Android.
  final int maxTransceiveLength;

  /// Get an instance of `NfcV` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NfcV.
  factory NfcV.from(NfcTag tag) => $GetNfcV(tag);

  /// Sends the NfcV command to the tag.
  /// 
  /// This uses NfcV#transceive API on Android.
  Future<Uint8List> transceive({
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('NfcV#transceive', {
      'handle': _tag.handle,
      'data': data,
    });
  }
}
