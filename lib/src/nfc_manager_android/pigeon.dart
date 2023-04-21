import 'package:nfc_manager/src/nfc_manager_android/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_android/tags/mifare_classic.dart';
import 'package:nfc_manager/src/nfc_manager_android/tags/mifare_ultralight.dart';
import 'package:nfc_manager/src/nfc_manager_ndef_record/ndef_record.dart';

final PigeonHostApi hostApi = PigeonHostApi();

String nfcReaderFlagToPigeon(NfcReaderFlagAndroid value) {
  switch (value) {
    case NfcReaderFlagAndroid.nfcA:
      return 'nfcA';
    case NfcReaderFlagAndroid.nfcB:
      return 'nfcB';
    case NfcReaderFlagAndroid.nfcBarcode:
      return 'nfcBarcode';
    case NfcReaderFlagAndroid.nfcF:
      return 'nfcF';
    case NfcReaderFlagAndroid.nfcV:
      return 'nfcV';
    case NfcReaderFlagAndroid.noPlatformSounds:
      return 'noPlatformSounds';
    case NfcReaderFlagAndroid.skipNdefCheck:
      return 'skipNdefCheck';
  }
}

PigeonTypeNameFormat typeNameFormatToPigeon(TypeNameFormat value) {
  switch (value) {
    case TypeNameFormat.empty:
      return PigeonTypeNameFormat.empty;
    case TypeNameFormat.wellKnown:
      return PigeonTypeNameFormat.wellKnown;
    case TypeNameFormat.media:
      return PigeonTypeNameFormat.mimeMedia;
    case TypeNameFormat.absoluteUri:
      return PigeonTypeNameFormat.absoluteUri;
    case TypeNameFormat.external:
      return PigeonTypeNameFormat.externalType;
    case TypeNameFormat.unknown:
      return PigeonTypeNameFormat.unknown;
    case TypeNameFormat.unchanged:
      return PigeonTypeNameFormat.unchanged;
  }
}

TypeNameFormat typeNameFormatFromPigeon(PigeonTypeNameFormat value) {
  switch (value) {
    case PigeonTypeNameFormat.empty:
      return TypeNameFormat.empty;
    case PigeonTypeNameFormat.wellKnown:
      return TypeNameFormat.wellKnown;
    case PigeonTypeNameFormat.mimeMedia:
      return TypeNameFormat.media;
    case PigeonTypeNameFormat.absoluteUri:
      return TypeNameFormat.absoluteUri;
    case PigeonTypeNameFormat.externalType:
      return TypeNameFormat.external;
    case PigeonTypeNameFormat.unknown:
      return TypeNameFormat.unknown;
    case PigeonTypeNameFormat.unchanged:
      return TypeNameFormat.unchanged;
  }
}

MifareClassicTypeAndroid mifareClassicTypeFromPigeon(
    PigeonMifareClassicType value) {
  switch (value) {
    case PigeonMifareClassicType.classic:
      return MifareClassicTypeAndroid.classic;
    case PigeonMifareClassicType.plus:
      return MifareClassicTypeAndroid.plus;
    case PigeonMifareClassicType.pro:
      return MifareClassicTypeAndroid.pro;
    case PigeonMifareClassicType.unknown:
      return MifareClassicTypeAndroid.unknown;
  }
}

MifareUltralightTypeAndroid mifareUltralightTypeFromPigeon(
    PigeonMifareUltralightType value) {
  switch (value) {
    case PigeonMifareUltralightType.ultralight:
      return MifareUltralightTypeAndroid.ultralight;
    case PigeonMifareUltralightType.ultralightC:
      return MifareUltralightTypeAndroid.ultralightC;
    case PigeonMifareUltralightType.unknown:
      return MifareUltralightTypeAndroid.unknown;
  }
}
