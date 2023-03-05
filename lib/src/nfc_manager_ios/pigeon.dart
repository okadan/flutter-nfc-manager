import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/felica.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/iso15693.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/mifare.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/ndef.dart';
import 'package:nfc_manager/src/nfc_manager_ndef_record/ndef_record.dart';

final PigeonHostApi hostApi = PigeonHostApi();

PigeonPollingOption pigeonFromNfcPollingOption(NfcPollingOption value) {
  switch (value) {
    case NfcPollingOption.iso14443: return PigeonPollingOption.iso14443;
    case NfcPollingOption.iso15693: return PigeonPollingOption.iso15693;
    case NfcPollingOption.iso18092: return PigeonPollingOption.iso18092;
  }
}

PigeonFeliCaPollingRequestCode feliCaPollingRequestCodeToPigeon(FeliCaPollingRequestCode value) {
  switch (value) {
    case FeliCaPollingRequestCode.noRequest: return PigeonFeliCaPollingRequestCode.noRequest;
    case FeliCaPollingRequestCode.systemCode: return PigeonFeliCaPollingRequestCode.systemCode;
    case FeliCaPollingRequestCode.communicationPerformance: return PigeonFeliCaPollingRequestCode.communicationPerformance;
  }
}

PigeonFeliCaPollingTimeSlot feliCaPollingTimeSlotToPigeon(FeliCaPollingTimeSlot value) {
  switch (value) {
    case FeliCaPollingTimeSlot.max1: return PigeonFeliCaPollingTimeSlot.max1;
    case FeliCaPollingTimeSlot.max2: return PigeonFeliCaPollingTimeSlot.max2;
    case FeliCaPollingTimeSlot.max4: return PigeonFeliCaPollingTimeSlot.max4;
    case FeliCaPollingTimeSlot.max8: return PigeonFeliCaPollingTimeSlot.max8;
    case FeliCaPollingTimeSlot.max16: return PigeonFeliCaPollingTimeSlot.max16;
  }
}

PigeonIso15693RequestFlag iso15693RequestFlagToPigeon(Iso15693RequestFlag value) {
  switch (value) {
    case Iso15693RequestFlag.address: return PigeonIso15693RequestFlag.address;
    case Iso15693RequestFlag.dualSubCarriers: return PigeonIso15693RequestFlag.dualSubCarriers;
    case Iso15693RequestFlag.highDataRate: return PigeonIso15693RequestFlag.highDataRate;
    case Iso15693RequestFlag.option: return PigeonIso15693RequestFlag.option;
    case Iso15693RequestFlag.protocolExtension: return PigeonIso15693RequestFlag.protocolExtension;
    case Iso15693RequestFlag.select: return PigeonIso15693RequestFlag.select;
  }
}

MiFareFamily miFareFamilyFromPigeon(PigeonMiFareFamily value) {
  switch (value) {
    case PigeonMiFareFamily.unknown: return MiFareFamily.unknown;
    case PigeonMiFareFamily.ultralight: return MiFareFamily.ultralight;
    case PigeonMiFareFamily.plus: return MiFareFamily.plus;
    case PigeonMiFareFamily.desfire: return MiFareFamily.desfire;
  }
}

NdefStatusIOS ndefStatusFromPigeon(PigeonNdefStatus value) {
  switch (value) {
    case PigeonNdefStatus.notSupported: return NdefStatusIOS.notSupported;
    case PigeonNdefStatus.readWrite: return NdefStatusIOS.readWrite;
    case PigeonNdefStatus.readOnly: return NdefStatusIOS.readOnly;
  }
}

PigeonTypeNameFormat typeNameFormatToPigeon(NdefTypeNameFormat value) {
  switch (value) {
    case NdefTypeNameFormat.empty: return PigeonTypeNameFormat.empty;
    case NdefTypeNameFormat.nfcWellknown: return PigeonTypeNameFormat.nfcWellKnown;
    case NdefTypeNameFormat.media: return PigeonTypeNameFormat.media;
    case NdefTypeNameFormat.absoluteUri: return PigeonTypeNameFormat.absoluteUri;
    case NdefTypeNameFormat.external: return PigeonTypeNameFormat.nfcExternal;
    case NdefTypeNameFormat.unknown: return PigeonTypeNameFormat.unknown;
    case NdefTypeNameFormat.unchanged: return PigeonTypeNameFormat.unchanged;
  }
}

NdefTypeNameFormat typeNameFormatFromPigeon(PigeonTypeNameFormat value) {
  switch (value) {
    case PigeonTypeNameFormat.empty: return NdefTypeNameFormat.empty;
    case PigeonTypeNameFormat.nfcWellKnown: return NdefTypeNameFormat.nfcWellknown;
    case PigeonTypeNameFormat.media: return NdefTypeNameFormat.media;
    case PigeonTypeNameFormat.absoluteUri: return NdefTypeNameFormat.absoluteUri;
    case PigeonTypeNameFormat.nfcExternal: return NdefTypeNameFormat.external;
    case PigeonTypeNameFormat.unknown: return NdefTypeNameFormat.unknown;
    case PigeonTypeNameFormat.unchanged: return NdefTypeNameFormat.unchanged;
  }
}
