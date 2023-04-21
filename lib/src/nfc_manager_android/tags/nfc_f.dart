import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

/// The class providing access to NFC-F (JIS 6319-4) operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
class NfcFAndroid {
  const NfcFAndroid._(
    this._handle, {
    required this.manufacturer,
    required this.systemCode,
  });

  final String _handle;

  final Uint8List manufacturer;

  final Uint8List systemCode;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NfcFAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).nfcF;
    return pigeon == null
        ? null
        : NfcFAndroid._(
            tag.handle,
            manufacturer: pigeon.manufacturer!,
            systemCode: pigeon.systemCode!,
          );
  }

  Future<int> getMaxTransceiveLength() {
    return hostApi.nfcFGetMaxTransceiveLength(_handle);
  }

  Future<int> getTimeout() {
    return hostApi.nfcFGetTimeout(_handle);
  }

  Future<void> setTimeout(int timeout) {
    return hostApi.nfcFSetTimeout(_handle, timeout);
  }

  Future<Uint8List> transceive(Uint8List bytes) {
    return hostApi.nfcFTransceive(_handle, bytes);
  }
}
