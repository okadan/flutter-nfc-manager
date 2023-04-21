import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

/// The class providing access to NFC-B (ISO 14443-3B) operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
class NfcBAndroid {
  const NfcBAndroid._(
    this._handle, {
    required this.applicationData,
    required this.protocolInfo,
  });

  final String _handle;

  final Uint8List applicationData;

  final Uint8List protocolInfo;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NfcBAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).nfcB;
    return pigeon == null
        ? null
        : NfcBAndroid._(
            tag.handle,
            applicationData: pigeon.applicationData!,
            protocolInfo: pigeon.protocolInfo!,
          );
  }

  Future<int> getMaxTransceiveLength() {
    return hostApi.nfcBGetMaxTransceiveLength(_handle);
  }

  Future<Uint8List> transceive(Uint8List bytes) {
    return hostApi.nfcBTransceive(_handle, bytes);
  }
}
