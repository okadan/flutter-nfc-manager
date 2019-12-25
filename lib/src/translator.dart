import 'dart:typed_data';

import './nfc_manager/nfc_manager.dart';
import './nfc_manager/nfc_ndef.dart';
import './platform_tags/platform_tags.dart';

NfcTag $nfcTagFromJson(Map<String, dynamic> data) {
  String handle = data.remove('handle');
  return NfcTag(handle: handle, data: data);
}

Ndef $ndefFromTag(NfcTag tag) {
  if (tag.data['ndef'] == null)
    return null;

  Map<String, dynamic> data = Map<String, dynamic>.from(tag.data['ndef']);

  NdefMessage cachedMessage = data['cachedMessage'] != null
    ? $ndefMessageFromJson(Map<String, dynamic>.from(data['cachedMessage']))
    : null;
  bool isWritable = data['isWritable'];
  int maxSize = data['maxSize'];

  return Ndef(
    tag: tag,
    cachedMessage: cachedMessage,
    isWritable: isWritable,
    maxSize: maxSize,
  );
}

NfcA $nfcAFromTag(NfcTag tag) {
  if (tag.data['nfca'] == null)
    return null;

  Map<String, dynamic> data = Map<String, dynamic>.from(tag.data['nfca']);

  Uint8List identifier = tag.data['id'];
  Uint8List atqa = data['atqa'];
  int sak = data['sak'];

  return NfcA(
    tag: tag,
    identifier: identifier,
    atqa: atqa,
    sak: sak,
  );
}

NfcB $nfcBFromTag(NfcTag tag) {
  if (tag.data['nfcb'] == null)
    return null;

  Map<String, dynamic> data = Map<String, dynamic>.from(tag.data['nfcb']);

  Uint8List identifier = tag.data['identifier'];
  Uint8List applicationData = data['applicationData'];
  Uint8List protocolInfo = data['protocolInfo'];

  return NfcB(
    tag: tag,
    identifier: identifier,
    applicationData: applicationData,
    protocolInfo: protocolInfo,
  );
}

NfcF $nfcFFromTag(NfcTag tag) {
  if (tag.data['nfcf'] == null)
    return null;

  Map<String, dynamic> data = Map<String, dynamic>.from(tag.data['nfcf']);

  Uint8List identifier = tag.data['identifier'];
  Uint8List manufacturer = data['manufacturer'];
  Uint8List systemCode = data['systemCode'];

  return NfcF(
    tag: tag,
    identifier: identifier,
    manufacturer: manufacturer,
    systemCode: systemCode,
  );
}

NfcV $nfcVFromTag(NfcTag tag) {
  if (tag.data['nfcv'] == null)
    return null;

  Map<String, dynamic> data = Map<String, dynamic>.from(tag.data['nfcv']);

  Uint8List identifier = tag.data['identifier'];
  int dsfId = data['dsfId'];
  int responseFlags = data['responseFlags'];

  return NfcV(
    tag: tag,
    identifier: identifier,
    dsfId: dsfId,
    responseFlags: responseFlags,
  );
}

IsoDep $isoDepFromTag(NfcTag tag) {
  if (tag.data['isodep'] == null)
    return null;

  Map<String, dynamic> data = Map<String, dynamic>.from(tag.data['isodep']);

  Uint8List identifier = tag.data['identifier'];
  Uint8List hiLayerResponse = data['hiLayerResponse'];
  Uint8List historicalBytes = data['historicalBytes'];
  bool isExtendedLengthApduSupported = data['isExtendedLengthApduSupported'];

  return IsoDep(
    tag: tag,
    identifier: identifier,
    hiLayerResponse: hiLayerResponse,
    historicalBytes: historicalBytes,
    isExtendedLengthApduSupported: isExtendedLengthApduSupported,
  );
}

MiFare $miFareFromTag(NfcTag tag) {
  if (tag.data['type'] != 'miFare')
    return null;

  int mifareFamily = tag.data['mifareFamily'];
  Uint8List identifier = tag.data['identifier'];
  Uint8List historicalBytes = tag.data['historicalBytes'];

  return MiFare(
    tag: tag,
    mifareFamily: mifareFamily,
    identifier: identifier,
    historicalBytes: historicalBytes,
  );
}

FeliCa $felicaFromTag(NfcTag tag) {
  if (tag.data['type'] != 'feliCa')
    return null;

  Uint8List currentSystemCode = tag.data['currentSystemCode'];
  Uint8List currentIDm = tag.data['currentIDm'];

  return FeliCa(
    tag: tag,
    currentSystemCode: currentSystemCode,
    currentIDm: currentIDm,
  );
}

ISO15693 $iso15693FromTag(NfcTag tag) {
  if (tag.data['type'] != 'iso15693')
    return null;

  int icManufacturerCode = tag.data['icManufacturerCode'];
  Uint8List icSerialNumber = tag.data['icSerialNumber'];
  Uint8List identifier = tag.data['identifier'];

  return ISO15693(
    tag: tag,
    icManufacturerCode: icManufacturerCode,
    icSerialNumber: icSerialNumber,
    identifier: identifier,
  );
}

ISO7816 $iso7816FromTag(NfcTag tag) {
  if (tag.data['type'] != 'iso7816')
    return null;

  String initialSelectedAID = tag.data['initialSelectedAID'];
  Uint8List identifier = tag.data['identifier'];
  Uint8List historicalBytes = tag.data['historicalBytes'];
  Uint8List applicationData = tag.data['applicationData'];
  bool proprietaryApplicationDataCoding = tag.data['proprietaryApplicationDataCoding'];

  return ISO7816(
    tag: tag,
    initialSelectedAID: initialSelectedAID,
    identifier: identifier,
    historicalBytes: historicalBytes,
    applicationData: applicationData,
    proprietaryApplicationDataCoding: proprietaryApplicationDataCoding,
  );
}

NdefMessage $ndefMessageFromJson(Map<String, dynamic> data) {
  return NdefMessage((data['records'] as List)
    .map((e) => $ndefRecordFromJson(Map<String, dynamic>.from(e))).toList()
  );
}

Map<String, dynamic> $ndefMessageToJson(NdefMessage message) {
  return {'records': message.records.map($ndefRecordToJson).toList()};
}

NdefRecord $ndefRecordFromJson(Map<String, dynamic> data) {
  return NdefRecord(
    typeNameFormat: data['typeNameFormat'],
    type: data['type'],
    identifier: data['identifier'],
    payload: data['payload'],
  );
}

Map<String, dynamic> $ndefRecordToJson(NdefRecord record) {
  return {
    'typeNameFormat': record.typeNameFormat,
    'type': record.type,
    'identifier': record.identifier,
    'payload': record.payload,
  };
}
