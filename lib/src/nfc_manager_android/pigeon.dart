import 'package:nfc_manager/nfc_manager_ndef_record.dart';
import 'package:nfc_manager/src/nfc_manager_android/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

final PigeonHostApi hostApi = PigeonHostApi();

PigeonReaderFlag pigeonFromNfcReaderFlagAndroid(NfcReaderFlagAndroid value) {
  switch (value) {
    case NfcReaderFlagAndroid.nfcA: return PigeonReaderFlag.nfcA;
    case NfcReaderFlagAndroid.nfcB: return PigeonReaderFlag.nfcB;
    case NfcReaderFlagAndroid.nfcBarcode: return PigeonReaderFlag.nfcBarcode;
    case NfcReaderFlagAndroid.nfcF: return PigeonReaderFlag.nfcF;
    case NfcReaderFlagAndroid.nfcV: return PigeonReaderFlag.nfcV;
    case NfcReaderFlagAndroid.noPlatformSounds: return PigeonReaderFlag.noPlatformSounds;
    case NfcReaderFlagAndroid.skipNdefCheck: return PigeonReaderFlag.skipNdefCheck;
  }
}

PigeonTypeNameFormat typeNameFormatToPigeon(NdefTypeNameFormat value) {
  switch (value) {
    case NdefTypeNameFormat.empty: return PigeonTypeNameFormat.empty;
    case NdefTypeNameFormat.nfcWellknown: return PigeonTypeNameFormat.wellKnown;
    case NdefTypeNameFormat.media: return PigeonTypeNameFormat.mimeMedia;
    case NdefTypeNameFormat.absoluteUri: return PigeonTypeNameFormat.absoluteUri;
    case NdefTypeNameFormat.external: return PigeonTypeNameFormat.externalType;
    case NdefTypeNameFormat.unknown: return PigeonTypeNameFormat.unknown;
    case NdefTypeNameFormat.unchanged: return PigeonTypeNameFormat.unchanged;
  }
}

NdefTypeNameFormat typeNameFormatFromPigeon(PigeonTypeNameFormat value) {
  switch (value) {
    case  PigeonTypeNameFormat.empty: return NdefTypeNameFormat.empty;
    case  PigeonTypeNameFormat.wellKnown: return NdefTypeNameFormat.nfcWellknown;
    case  PigeonTypeNameFormat.mimeMedia: return NdefTypeNameFormat.media;
    case  PigeonTypeNameFormat.absoluteUri: return NdefTypeNameFormat.absoluteUri;
    case  PigeonTypeNameFormat.externalType: return NdefTypeNameFormat.external;
    case  PigeonTypeNameFormat.unknown: return NdefTypeNameFormat.unknown;
    case  PigeonTypeNameFormat.unchanged: return NdefTypeNameFormat.unchanged;
  }
}
