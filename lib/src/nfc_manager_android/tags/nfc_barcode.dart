import 'dart:typed_data';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_android/tags/tag.dart';

/// Provides access to tags containing just a barcode for Android.
///
/// Acquire an instance using [from(NfcTag)].
final class NfcBarcodeAndroid {
  const NfcBarcodeAndroid._(
    this._handle, {
    required this.tag,
    required this.type,
    required this.barcode,
  });

  // ignore: unused_field
  final String _handle;

  /// The tag instance backing of this instance.
  final NfcTagAndroid tag;

  // DOC:
  final NfcBarcodeTypeAndroid type;

  // DOC:
  final Uint8List barcode;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NfcBarcodeAndroid? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.nfcBarcode;
    final atag = NfcTagAndroid.from(tag);
    if (data == null || tech == null || atag == null) return null;
    return NfcBarcodeAndroid._(
      data.handle,
      tag: atag,
      type: NfcBarcodeTypeAndroid.values.byName(tech.type.name),
      barcode: tech.barcode,
    );
  }
}

// DOC:
enum NfcBarcodeTypeAndroid {
  // DOC:
  kovio,

  // DOC:
  unknown,
}
