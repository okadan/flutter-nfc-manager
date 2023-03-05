import 'package:flutter/foundation.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/src/ndef_platform_android.dart';
import 'package:nfc_manager_ndef/src/ndef_platform_ios.dart';

/// The class providing access to NDEF operations.
///
/// Acquire an instance using [from(NfcTag)].
abstract class Ndef {
  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static Ndef? from(NfcTag tag) {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => NdefPlatformAndroid.from(tag),
      TargetPlatform.iOS => NdefPlatformIos.from(tag),
      _ => null,
    };
  }

  /// Whether the NDEF message can be written to this tag.
  ///
  /// Note that this value is obtained at the tag discovery time and may be
  /// differ from the current state of the tag.
  bool get isWritable;

  /// The maximum NDEF message size in bytes, that can be stored on this tag.
  ///
  /// Note that this value is obtained at the tag discovery time and may be
  /// differ from the current state of the tag.
  int get maxSize;

  /// The NDEF message that was obtained at the tag discovery time.
  ///
  /// Note that this value is obtained at the tag discovery time and may be
  /// differ from the current state of the tag.
  NdefMessage? get cachedMessage;

  /// The additional data that can be obtained from platform-specific APIs.
  ///
  /// Note that this value is obtained at the tag discovery time and may be
  /// differ from the current state of the tag.
  Map<String, dynamic> get additionalData;

  /// Gets the current NDEF message stored on this tag.
  Future<NdefMessage?> read();

  /// Overwrites the NDEF message on this tag.
  Future<void> write({required NdefMessage message});

  /// Makes this tag read-only.
  ///
  /// Note that this is a permanent action that you cannot undo. After locking
  /// the tag, you can no longer write data to it.
  Future<void> writeLock();
}
