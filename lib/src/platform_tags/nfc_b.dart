import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

/// (Android only) The class provides access to NfcB API for Android.
/// 
/// Acquire `NfcB` instance using `NfcB.from`.
class NfcB {
  /// Constructs an instance with the given values for testing.
  /// 
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `NfcB.from` are valid.
  const NfcB({
    @required NfcTag tag,
    @required this.identifier,
    @required this.applicationData,
    @required this.protocolInfo,
    @required this.maxTransceiveLength,
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from Tag#id on Android.
  final Uint8List identifier;

  /// The value from NfcB#applicationData on Android.
  final Uint8List applicationData;

  /// The value from NfcB#protocolInfo on Android.
  final Uint8List protocolInfo;

  /// The value from NfcB#maxTransceiveLength on Android.
  final int maxTransceiveLength;

  /// Get an instance of `NfcB` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NfcB.
  factory NfcB.from(NfcTag tag) => $GetNfcB(tag);

  /// Sends the NfcB command to the tag.
  /// 
  /// This uses NfcB#transceive API on Android.
  Future<Uint8List> transceive({
    @required Uint8List data,
  }) async {
    return channel.invokeMethod('NfcB#transceive', {
      'handle': _tag.handle,
      'data': data,
    });
  }
}
