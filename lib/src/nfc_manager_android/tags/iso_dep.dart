import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

/// The class providing access to ISO-DEP (ISO 14443-4) operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
class IsoDepAndroid {
  const IsoDepAndroid._(
    this._handle, {
    required this.hiLayerResponse,
    required this.historicalBytes,
    required this.isExtendedLengthApduSupported,
  });

  final String _handle;

  final Uint8List? hiLayerResponse;

  final Uint8List? historicalBytes;

  final bool isExtendedLengthApduSupported;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static IsoDepAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).isoDep;
    return pigeon == null
        ? null
        : IsoDepAndroid._(
            tag.handle,
            hiLayerResponse: pigeon.hiLayerResponse,
            historicalBytes: pigeon.historicalBytes,
            isExtendedLengthApduSupported:
                pigeon.isExtendedLengthApduSupported!,
          );
  }

  Future<int> getMaxTransceiveLength() {
    return hostApi.isoDepGetMaxTransceiveLength(_handle);
  }

  Future<int> getTimeout() {
    return hostApi.isoDepGetTimeout(_handle);
  }

  Future<void> setTimeout(int timeout) {
    return hostApi.isoDepSetTimeout(_handle, timeout);
  }

  Future<Uint8List> transceive(Uint8List bytes) {
    return hostApi.isoDepTransceive(_handle, bytes);
  }
}
