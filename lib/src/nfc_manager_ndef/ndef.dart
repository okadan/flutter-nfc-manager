import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ndef/ndef_platform_android.dart';
import 'package:nfc_manager/src/nfc_manager_ndef/ndef_platform_ios.dart';
import 'package:nfc_manager/src/nfc_manager_ndef_record/ndef_record.dart';

/// The class providing access to NDEF operations.
///
/// Acquire an instance using [from(NfcTag)].
abstract class Ndef {
  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static Ndef? from(NfcTag tag) {
    if (defaultTargetPlatform == TargetPlatform.android)
      return NdefPlatformAndroid.from(tag);
    if (defaultTargetPlatform == TargetPlatform.iOS)
      return NdefPlatformIOS.from(tag);
    return null;
  }

  bool get isWritable;

  int get maxSize;

  NdefMessage? get cachedMessage;

  Map<String, dynamic> get additionalData;

  Future<NdefMessage?> read();

  Future<void> write({required NdefMessage message});

  Future<void> writeLock();
}
