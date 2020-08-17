import './nfc_manager/nfc_manager.dart';
import './nfc_manager/nfc_ndef.dart';
import './platform_tags/felica.dart';
import './platform_tags/iso7816.dart';
import './platform_tags/iso15693.dart';
import './platform_tags/iso_dep.dart';
import './platform_tags/mifare.dart';
import './platform_tags/mifare_classic.dart';
import './platform_tags/mifare_ultralight.dart';
import './platform_tags/ndef_formatable.dart';
import './platform_tags/nfc_a.dart';
import './platform_tags/nfc_b.dart';
import './platform_tags/nfc_f.dart';
import './platform_tags/nfc_v.dart';

const Map<NfcPollingOption, String> $NfcPollingOptionTable = {
  NfcPollingOption.iso14443: 'iso14443',
  NfcPollingOption.iso15693: 'iso15693',
  NfcPollingOption.iso18092: 'iso18092',
};

const Map<NfcErrorType, String> $NfcErrorTypeTable = {
  NfcErrorType.sessionTimeout: 'sessionTimeout',
  NfcErrorType.systemIsBusy: 'systemIsBusy',
  NfcErrorType.userCanceled: 'userCanceled',
  NfcErrorType.unknown: 'unknown',
};

const Map<NdefTypeNameFormat, int> $NdefTypeNameFormatTable = {
  NdefTypeNameFormat.empty: 0x00,
  NdefTypeNameFormat.nfcWellknown: 0x01,
  NdefTypeNameFormat.media: 0x02,
  NdefTypeNameFormat.absoluteUri: 0x03,
  NdefTypeNameFormat.nfcExternal: 0x04,
  NdefTypeNameFormat.unknown: 0x05,
  NdefTypeNameFormat.unchanged: 0x06,
};

const Map<FeliCaPollingRequestCode, int> $FeliCaPollingRequestCodeTable = {
  FeliCaPollingRequestCode.noRequest: 0x00,
  FeliCaPollingRequestCode.systemCode: 0x01,
  FeliCaPollingRequestCode.communicationPerformance: 0x02,
};

const Map<FeliCaPollingTimeSlot, int> $FeliCaPollingTimeSlotTable = {
  FeliCaPollingTimeSlot.max1: 0x00,
  FeliCaPollingTimeSlot.max2: 0x01,
  FeliCaPollingTimeSlot.max4: 0x03,
  FeliCaPollingTimeSlot.max8: 0x07,
  FeliCaPollingTimeSlot.max16: 0x0F,
};

const Map<Iso15693RequestFlag, String> $Iso15693RequestFlagTable = {
  Iso15693RequestFlag.address: 'address',
  Iso15693RequestFlag.dualSubCarriers: 'dualSubCarriers',
  Iso15693RequestFlag.highDataRate: 'highDataRate',
  Iso15693RequestFlag.option: 'option',
  Iso15693RequestFlag.protocolExtension: 'protocolExtension',
  Iso15693RequestFlag.select: 'select',
};

const Map<MiFareFamily, int> $MiFareFamilyTable = {
  MiFareFamily.unknown: 1,
  MiFareFamily.ultralight: 2,
  MiFareFamily.plus: 3,
  MiFareFamily.desfire: 4,
};

NfcTag $GetNfcTag(Map<String, dynamic> arg) {
  return NfcTag(
    handle: arg.remove('handle'),
    data: arg,
  );
}

NfcError $GetNfcError(Map<String, dynamic> arg) {
  return NfcError(
    type: $NfcErrorTypeTable.entries.firstWhere((e) => e.value == arg['type'], orElse: () => null)?.key ?? NfcErrorType.unknown,
    message: arg['message'],
    details: arg['details'],
  );
}

NdefMessage $GetNdefMessage(Map<String, dynamic> arg) {
  return NdefMessage((arg['records'] as Iterable).map((e) => NdefRecord(
    typeNameFormat: $NdefTypeNameFormatTable.entries.firstWhere((ee) => ee.value == e['typeNameFormat']).key,
    type: e['type'],
    identifier: e['identifier'],
    payload: e['payload'],
  )).toList());
}

Map<String, dynamic> $GetNdefMessageMap(NdefMessage arg) {
  return {'records': arg.records.map((e) => {
    'typeNameFormat': $NdefTypeNameFormatTable[e.typeNameFormat],
    'type': e.type,
    'identifier': e.identifier,
    'payload': e.payload,
  }).toList()};
}

FeliCaPollingResponse $GetFeliCaPollingResponse(Map<String, dynamic> arg) {
  return FeliCaPollingResponse(
    manufacturerParameter: arg['manufacturerParameter'],
    requestData: arg['requestData'],
  );
}

FeliCaRequestServiceV2Response $GetFeliCaRequestServiceV2Response(Map<String, dynamic> arg) {
  return FeliCaRequestServiceV2Response(
    statusFlag1: arg['statusFlag1'],
    statusFlag2: arg['statusFlag2'],
    encryptionIdentifier: arg['encryptionIdentifier'],
    nodeKeyVersionListAes: arg['nodeKeyVersionListAes'],
    nodeKeyVersionListDes: arg['nodeKeyVersionListDes'],
  );
}

FeliCaReadWithoutEncryptionResponse $GetFeliCaReadWithoutEncryptionResponse(Map<String, dynamic> arg) {
  return FeliCaReadWithoutEncryptionResponse(
    statusFlag1: arg['statusFlag1'],
    statusFlag2: arg['statusFlag2'],
    blockData: arg['blockData'],
  );
}

FeliCaStatusFlag $GetFeliCaStatusFlag(Map<String, dynamic> arg) {
  return FeliCaStatusFlag(
    statusFlag1: arg['statusFlag1'],
    statusFlag2: arg['statusFlag2'],
  );
}

FeliCaRequestSpecificationVersionResponse $GetFeliCaRequestSpecificationVersionResponse(Map<String, dynamic> arg) {
  return FeliCaRequestSpecificationVersionResponse(
    statusFlag1: arg['statusFlag1'],
    statusFlag2: arg['statusFlag2'],
    basicVersion: arg['basicVersion'],
    optionVersion: arg['optionVersion'],
  );
}

Iso15693SystemInfo $GetIso15693SystemInfo(Map<String, dynamic> arg) {
  return Iso15693SystemInfo(
    dataStorageFormatIdentifier: arg['dataStorageFormatIdentifier'],
    applicationFamilyIdentifier: arg['applicationFamilyIdentifier'],
    blockSize: arg['blockSize'],
    totalBlocks: arg['totalBlocks'],
    icReference: arg['icReference'],
  );
}

Iso7816ResponseApdu $GetIso7816ResponseApdu(Map<String, dynamic> arg) {
  return Iso7816ResponseApdu(
    payload: arg['payload'],
    statusWord1: arg['statusWord1'],
    statusWord2: arg['statusWord2'],
  );
}

Ndef $GetNdef(NfcTag arg) {
  if (arg.data['ndef'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['ndef']);
  return Ndef(
    tag: arg,
    isWritable: data.remove('isWritable'),
    maxSize: data.remove('maxSize'),
    cachedMessage: data['cachedMessage'] == null ? null : $GetNdefMessage(Map<String, dynamic>.from(data.remove('cachedMessage'))),
    additionalData: data,
  );
}

FeliCa $GetFeliCa(NfcTag arg) {
  if (arg.data['felica'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['felica']);
  return FeliCa(
    tag: arg,
    currentSystemCode: data['currentSystemCode'],
    currentIDm: data['currentIDm'],
  );
}

Iso7816 $GetIso7816(NfcTag arg) {
  if (arg.data['iso7816'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['iso7816']);
  return Iso7816(
    tag: arg,
    identifier: data['identifier'],
    historicalBytes: data['historicalBytes'],
    applicationData: data['applicationData'],
    initialSelectedAID: data['initialSelectedAID'],
    proprietaryApplicationDataCoding: data['proprietaryApplicationDataCoding'],
  );
}

Iso15693 $GetIso15693(NfcTag arg) {
  if (arg.data['iso15693'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['iso15693']);
  return Iso15693(
    tag: arg,
    identifier: data['identifier'],
    icManufacturerCode: data['icManufacturerCode'],
    icSerialNumber: data['icSerialNumber'],
  );
}

MiFare $GetMiFare(NfcTag arg) {
  if (arg.data['mifare'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['mifare']);
  return MiFare(
    tag: arg,
    identifier: data['identifier'],
    mifareFamily: $MiFareFamilyTable.entries.firstWhere((e) => e.value == data['mifareFamily']).key,
    historicalBytes: data['historicalBytes']
  );
}

NfcA $GetNfcA(NfcTag arg) {
  if (arg.data['nfca'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['nfca']);
  return NfcA(
    tag: arg,
    identifier: data['identifier'],
    atqa: data['atqa'],
    sak: data['sak'],
    maxTransceiveLength: data['maxTransceiveLength'],
    timeout: data['timeout'],
  );
}

NfcB $GetNfcB(NfcTag arg) {
  if (arg.data['nfcb'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['nfcb']);
  return NfcB(
    tag: arg,
    identifier: data['identifier'],
    applicationData: data['applicationData'],
    protocolInfo: data['protocolInfo'],
    maxTransceiveLength: data['maxTransceiveLength'],
  );
}

NfcF $GetNfcF(NfcTag arg) {
  if (arg.data['nfcf'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['nfcf']);
  return NfcF(
    tag: arg,
    identifier: data['identifier'],
    manufacturer: data['manufacturer'],
    systemCode: data['systemCode'],
    maxTransceiveLength: data['maxTransceiveLength'],
    timeout: data['timeout'],
  );
}

NfcV $GetNfcV(NfcTag arg) {
  if (arg.data['nfcv'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['nfcv']);
  return NfcV(
    tag: arg,
    identifier: data['identifier'],
    dsfId: data['dsfId'],
    responseFlags: data['responseFlags'],
    maxTransceiveLength: data['maxTransceiveLength'],
  );
}

IsoDep $GetIsoDep(NfcTag arg) {
  if (arg.data['isodep'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['isodep']);
  return IsoDep(
    tag: arg,
    identifier: data['identifier'],
    hiLayerResponse: data['hiLayerResponse'],
    historicalBytes: data['historicalBytes'],
    isExtendedLengthApduSupported: data['isExtendedLengthApduSupported'],
    maxTransceiveLength: data['maxTransceiveLength'],
    timeout: data['timeout'],
  );
}

MifareClassic $GetMifareClassic(NfcTag arg) {
  if (arg.data['mifareclassic'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['mifareclassic']);
  return MifareClassic(
    tag: arg,
    identifier: data['identifier'],
    type: data['type'],
    blockCount: data['blockCount'],
    sectorCount: data['sectorCount'],
    size: data['size'],
    maxTransceiveLength: data['maxTransceiveLength'],
    timeout: data['timeout'],
  );
}

MifareUltralight $GetMifareUltralight(NfcTag arg) {
  if (arg.data['mifareultralight'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['mifareultralight']);
  return MifareUltralight(
    tag: arg,
    identifier: data['identifier'],
    type: data['type'],
    maxTransceiveLength: data['maxTransceiveLength'],
    timeout: data['timeout'],
  );
}

NdefFormatable $GetNdefFormatable(NfcTag arg) {
  if (arg.data['ndefformatable'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['ndefformatable']);
  return NdefFormatable(
    tag: arg,
    identifier: data['identifier'],
  );
}
