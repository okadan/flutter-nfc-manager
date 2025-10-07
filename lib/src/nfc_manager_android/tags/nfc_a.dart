import 'dart:typed_data';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_android/tags/tag.dart';

/// Provides access to NFC-A (ISO 14443-3A) operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
final class NfcAAndroid {
  const NfcAAndroid._(
    this._handle, {
    required this.tag,
    required this.atqa,
    required this.sak,
  });

  final String _handle;

  /// The tag instance backing of this instance.
  final NfcTagAndroid tag;

  // DOC:
  final Uint8List atqa;

  // DOC:
  final int sak;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NfcAAndroid? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.nfcA;
    final atag = NfcTagAndroid.from(tag);
    if (data == null || tech == null || atag == null) return null;
    return NfcAAndroid._(
      data.handle,
      tag: atag,
      atqa: tech.atqa,
      sak: tech.sak,
    );
  }

  // DOC:
  Future<int> getMaxTransceiveLength() {
    return hostApi.nfcAGetMaxTransceiveLength(handle: _handle);
  }

  // DOC:
  Future<int> getTimeout() {
    return hostApi.nfcAGetTimeout(handle: _handle);
  }

  // DOC:
  Future<void> setTimeout(int timeout) {
    return hostApi.nfcASetTimeout(handle: _handle, timeout: timeout);
  }

  // DOC:
  Future<Uint8List> transceive(Uint8List bytes) {
    return hostApi.nfcATransceive(handle: _handle, bytes: bytes);
  }
}
