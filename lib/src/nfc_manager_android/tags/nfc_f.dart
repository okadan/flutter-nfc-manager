import 'dart:typed_data';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_android/tags/tag.dart';

/// Provides access to NFC-F (JIS 6319-4) operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
final class NfcFAndroid {
  const NfcFAndroid._(
    this._handle, {
    required this.tag,
    required this.manufacturer,
    required this.systemCode,
  });

  final String _handle;

  /// The tag instance backing of this instance.
  final NfcTagAndroid tag;

  // DOC:
  final Uint8List manufacturer;

  // DOC:
  final Uint8List systemCode;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NfcFAndroid? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.nfcF;
    final atag = NfcTagAndroid.from(tag);
    if (data == null || tech == null || atag == null) return null;
    return NfcFAndroid._(
      data.handle,
      tag: atag,
      manufacturer: tech.manufacturer,
      systemCode: tech.systemCode,
    );
  }

  // DOC:
  Future<int> getMaxTransceiveLength() {
    return hostApi.nfcFGetMaxTransceiveLength(handle: _handle);
  }

  // DOC:
  Future<int> getTimeout() {
    return hostApi.nfcFGetTimeout(handle: _handle);
  }

  // DOC:
  Future<void> setTimeout(int timeout) {
    return hostApi.nfcFSetTimeout(handle: _handle, timeout: timeout);
  }

  // DOC:
  Future<Uint8List> transceive(Uint8List bytes) {
    return hostApi.nfcFTransceive(handle: _handle, bytes: bytes);
  }
}
