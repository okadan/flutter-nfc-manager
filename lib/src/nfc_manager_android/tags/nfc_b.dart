import 'dart:typed_data';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_android/tags/tag.dart';

/// Provides access to NFC-B (ISO 14443-3B) operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
final class NfcBAndroid {
  const NfcBAndroid._(
    this._handle, {
    required this.tag,
    required this.applicationData,
    required this.protocolInfo,
  });

  final String _handle;

  /// The tag instance backing of this instance.
  final NfcTagAndroid tag;

  // DOC:
  final Uint8List applicationData;

  // DOC:
  final Uint8List protocolInfo;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NfcBAndroid? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.nfcB;
    final atag = NfcTagAndroid.from(tag);
    if (data == null || tech == null || atag == null) return null;
    return NfcBAndroid._(
      data.handle,
      tag: atag,
      applicationData: tech.applicationData,
      protocolInfo: tech.protocolInfo,
    );
  }

  // DOC:
  Future<int> getMaxTransceiveLength() {
    return hostApi.nfcBGetMaxTransceiveLength(handle: _handle);
  }

  // DOC:
  Future<Uint8List> transceive(Uint8List bytes) {
    return hostApi.nfcBTransceive(handle: _handle, bytes: bytes);
  }
}
