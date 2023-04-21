import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/felica.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/iso15693.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/mifare.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/ndef.dart';
import 'package:nfc_manager/src/nfc_manager_ndef_record/ndef_record.dart';

final PigeonHostApi hostApi = PigeonHostApi();

String nfcPollingOptionToPigeon(NfcPollingOption value) {
  switch (value) {
    case NfcPollingOption.iso14443:
      return 'iso14443';
    case NfcPollingOption.iso15693:
      return 'iso15693';
    case NfcPollingOption.iso18092:
      return 'iso18092';
  }
}

PigeonFeliCaPollingRequestCode feliCaPollingRequestCodeToPigeon(
    FeliCaPollingRequestCodeIOS value) {
  switch (value) {
    case FeliCaPollingRequestCodeIOS.noRequest:
      return PigeonFeliCaPollingRequestCode.noRequest;
    case FeliCaPollingRequestCodeIOS.systemCode:
      return PigeonFeliCaPollingRequestCode.systemCode;
    case FeliCaPollingRequestCodeIOS.communicationPerformance:
      return PigeonFeliCaPollingRequestCode.communicationPerformance;
  }
}

PigeonFeliCaPollingTimeSlot feliCaPollingTimeSlotToPigeon(
    FeliCaPollingTimeSlotIOS value) {
  switch (value) {
    case FeliCaPollingTimeSlotIOS.max1:
      return PigeonFeliCaPollingTimeSlot.max1;
    case FeliCaPollingTimeSlotIOS.max2:
      return PigeonFeliCaPollingTimeSlot.max2;
    case FeliCaPollingTimeSlotIOS.max4:
      return PigeonFeliCaPollingTimeSlot.max4;
    case FeliCaPollingTimeSlotIOS.max8:
      return PigeonFeliCaPollingTimeSlot.max8;
    case FeliCaPollingTimeSlotIOS.max16:
      return PigeonFeliCaPollingTimeSlot.max16;
  }
}

String iso15693RequestFlagToPigeon(Iso15693RequestFlagIOS value) {
  switch (value) {
    case Iso15693RequestFlagIOS.address:
      return 'address';
    case Iso15693RequestFlagIOS.dualSubCarriers:
      return 'dualSubCarriers';
    case Iso15693RequestFlagIOS.highDataRate:
      return 'highDataRate';
    case Iso15693RequestFlagIOS.option:
      return 'option';
    case Iso15693RequestFlagIOS.protocolExtension:
      return 'protocolExtension';
    case Iso15693RequestFlagIOS.select:
      return 'select';
  }
}

MiFareFamilyIOS miFareFamilyFromPigeon(PigeonMiFareFamily value) {
  switch (value) {
    case PigeonMiFareFamily.unknown:
      return MiFareFamilyIOS.unknown;
    case PigeonMiFareFamily.ultralight:
      return MiFareFamilyIOS.ultralight;
    case PigeonMiFareFamily.plus:
      return MiFareFamilyIOS.plus;
    case PigeonMiFareFamily.desfire:
      return MiFareFamilyIOS.desfire;
  }
}

NdefStatusIOS ndefStatusFromPigeon(PigeonNdefStatus value) {
  switch (value) {
    case PigeonNdefStatus.notSupported:
      return NdefStatusIOS.notSupported;
    case PigeonNdefStatus.readWrite:
      return NdefStatusIOS.readWrite;
    case PigeonNdefStatus.readOnly:
      return NdefStatusIOS.readOnly;
  }
}

PigeonTypeNameFormat typeNameFormatToPigeon(TypeNameFormat value) {
  switch (value) {
    case TypeNameFormat.empty:
      return PigeonTypeNameFormat.empty;
    case TypeNameFormat.wellKnown:
      return PigeonTypeNameFormat.nfcWellKnown;
    case TypeNameFormat.media:
      return PigeonTypeNameFormat.media;
    case TypeNameFormat.absoluteUri:
      return PigeonTypeNameFormat.absoluteUri;
    case TypeNameFormat.external:
      return PigeonTypeNameFormat.nfcExternal;
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
    case PigeonTypeNameFormat.nfcWellKnown:
      return TypeNameFormat.wellKnown;
    case PigeonTypeNameFormat.media:
      return TypeNameFormat.media;
    case PigeonTypeNameFormat.absoluteUri:
      return TypeNameFormat.absoluteUri;
    case PigeonTypeNameFormat.nfcExternal:
      return TypeNameFormat.external;
    case PigeonTypeNameFormat.unknown:
      return TypeNameFormat.unknown;
    case PigeonTypeNameFormat.unchanged:
      return TypeNameFormat.unchanged;
  }
}
