import 'dart:typed_data';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_android/tags/tag.dart';

/// Provides access to NFC-V (ISO 15693) operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
final class NfcVAndroid {
  const NfcVAndroid._(
    this._handle, {
    required this.tag,
    required this.dsfId,
    required this.responseFlags,
  });

  final String _handle;

  /// The tag instance backing of this instance.
  final NfcTagAndroid tag;

  // DOC:
  final int dsfId;

  // DOC:
  final int responseFlags;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NfcVAndroid? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.nfcV;
    final atag = NfcTagAndroid.from(tag);
    if (data == null || tech == null || atag == null) return null;
    return NfcVAndroid._(
      data.handle,
      tag: atag,
      dsfId: tech.dsfId,
      responseFlags: tech.responseFlags,
    );
  }

  // DOC:
  Future<int> getMaxTransceiveLength() {
    return hostApi.nfcVGetMaxTransceiveLength(handle: _handle);
  }

  // DOC:
  Future<Uint8List> transceive(Uint8List bytes) {
    return hostApi.nfcVTransceive(handle: _handle, bytes: bytes);
  }
}
