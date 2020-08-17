import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../nfc_manager/nfc_ndef.dart';
import '../translator.dart';

/// (Android only) The class provides access to NdefFormatable API for Android.
/// 
/// Acquire `NdefFormatable` instance using `NdefFormatable.from`.
class NdefFormatable {
  /// Constructs an instance with the given values for testing.
  /// 
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `NdefFormatable.from` are valid.
  const NdefFormatable({
    @required NfcTag tag,
    @required this.identifier,
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from Tag#id on Android.
  final Uint8List identifier;

  /// Get an instance of `NdefFormatable` for the given tag.
  ///
  /// Returns null if the tag is not NDEF formatable.
  factory NdefFormatable.from(NfcTag tag) => $GetNdefFormatable(tag);

  /// Format the tag as NDEF, and write the given NDEF message.
  /// 
  /// This uses NdefFormatable#format API on Android.
  Future<void> format(NdefMessage firstMessage) async {
    return channel.invokeMethod('NdefFormatable#format', {
      'handle': _tag.handle,
      'firstMessage': $GetNdefMessageMap(firstMessage),
    });
  }

  /// Format the tag as NDEF, write the given NDEF message, and make read-only.
  /// 
  /// This uses NdefFormatable#formatReadOnly API on Android.
  Future<void> formatReadOnly(NdefMessage firstMessage) async {
    return channel.invokeMethod('NdefFormatable#formatReadOnly', {
      'handle': _tag.handle,
      'firstMessage': $GetNdefMessageMap(firstMessage),
    });
  }
}
