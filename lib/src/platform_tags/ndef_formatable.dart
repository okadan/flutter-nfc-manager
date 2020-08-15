import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../nfc_manager/nfc_ndef.dart';
import '../translator.dart';

// NdefFormatable
class NdefFormatable {
  // NdefFormatable
  const NdefFormatable({
    @required this.tag,
    @required this.identifier,
  });

  // tag
  final NfcTag tag;

  // identifier
  final Uint8List identifier;

  // NdefFormatable.from
  factory NdefFormatable.from(NfcTag tag) => $GetNdefFormatable(tag);

  // format
  Future<void> format(NdefMessage firstMessage) async {
    return channel.invokeMethod('NdefFormatable#format', {
      'handle': tag.handle,
      'firstMessage': $GetNdefMessageMap(firstMessage),
    });
  }

  // formatReadOnly
  Future<void> formatReadOnly(NdefMessage firstMessage) async {
    return channel.invokeMethod('NdefFormatable#formatReadOnly', {
      'handle': tag.handle,
      'firstMessage': $GetNdefMessageMap(firstMessage),
    });
  }
}
