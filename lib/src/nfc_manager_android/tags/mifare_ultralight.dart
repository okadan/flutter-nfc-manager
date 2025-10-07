import 'dart:typed_data';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_android/tags/tag.dart';

/// Provides access to MIFARE Ultralight operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
final class MifareUltralightAndroid {
  const MifareUltralightAndroid._(
    this._handle, {
    required this.tag,
    required this.type,
  });

  final String _handle;

  /// The tag instance backing of this instance.
  final NfcTagAndroid tag;

  // DOC:
  final MifareUltralightTypeAndroid type;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static MifareUltralightAndroid? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.mifareUltralight;
    final atag = NfcTagAndroid.from(tag);
    if (data == null || tech == null || atag == null) return null;
    return MifareUltralightAndroid._(
      data.handle,
      tag: atag,
      type: MifareUltralightTypeAndroid.values.byName(tech.type.name),
    );
  }

  // DOC:
  Future<int> getMaxTransceiveLength() {
    return hostApi.mifareUltralightGetMaxTransceiveLength(handle: _handle);
  }

  // DOC:
  Future<int> getTimeout() {
    return hostApi.mifareUltralightGetTimeout(handle: _handle);
  }

  // DOC:
  Future<void> setTimeout(int timeout) {
    return hostApi.mifareUltralightSetTimeout(
      handle: _handle,
      timeout: timeout,
    );
  }

  // DOC:
  Future<Uint8List> readPages({required int pageOffset}) {
    return hostApi.mifareUltralightReadPages(
      handle: _handle,
      pageOffset: pageOffset,
    );
  }

  // DOC:
  Future<void> writePage({required int pageOffset, required Uint8List data}) {
    return hostApi.mifareUltralightWritePage(
      handle: _handle,
      pageOffset: pageOffset,
      data: data,
    );
  }

  // DOC:
  Future<Uint8List> transceive(Uint8List bytes) {
    return hostApi.mifareUltralightTransceive(handle: _handle, bytes: bytes);
  }
}

// DOC:
enum MifareUltralightTypeAndroid {
  // DOC:
  ultralight,

  // DOC:
  ultralightC,

  // DOC:
  unknown,
}
