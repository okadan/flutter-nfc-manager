import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

class NfcBarcodeAndroid {
  const NfcBarcodeAndroid(this._tag, {
    required this.type,
    required this.barcode,
  });

  // ignore: unused_field
  final NfcTag _tag;

  final int type;

  final Uint8List barcode;

  static NfcBarcodeAndroid? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).nfcBarcode;
    return pigeon == null ? null : NfcBarcodeAndroid(
      tag,
      type: pigeon.type!,
      barcode: pigeon.barcode!,
    );
  }
}
