import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

/// The class providing access to NFC-V (ISO 15693) operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
class NfcVAndroid {
  const NfcVAndroid._(
    this._handle, {
    required this.dsfId,
    required this.responseFlags,
  });

  final String _handle;

  final int dsfId;

  final int responseFlags;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NfcVAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).nfcV;
    return pigeon == null
        ? null
        : NfcVAndroid._(
            tag.handle,
            dsfId: pigeon.dsfId!,
            responseFlags: pigeon.responseFlags!,
          );
  }

  Future<int> getMaxTransceiveLength() {
    return hostApi.nfcVGetMaxTransceiveLength(_handle);
  }

  Future<Uint8List> transceive(Uint8List bytes) {
    return hostApi.nfcVTransceive(_handle, bytes);
  }
}
