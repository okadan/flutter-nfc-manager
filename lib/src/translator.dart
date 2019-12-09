part of nfc_manager;

NfcTag _$nfcTagFromJson(Map<String, dynamic> data) {
  String handle = data.remove('handle');
  return NfcTag._(handle, data);
}

Ndef _$ndefFromTag(NfcTag tag) {
  if (tag.data['ndef'] == null)
    return null;

  Map<String, dynamic> data = Map<String, dynamic>.from(tag.data['ndef']);

  NdefMessage cachedMessage = data['cachedMessage'] != null
    ? _$ndefMessageFromJson(Map<String, dynamic>.from(data['cachedMessage']))
    : null;
  bool isWritable = data['isWritable'];
  int maxSize = data['maxSize'];

  return Ndef._(
    tag,
    cachedMessage,
    isWritable,
    maxSize,
  );
}

NfcA _$nfcAFromTag(NfcTag tag) {
  if (tag.data['nfca'] == null)
    return null;

  Map<String, dynamic> data = Map<String, dynamic>.from(tag.data['nfca']);

  Uint8List identifier = tag.data['id'];
  Uint8List atqa = data['atqa'];
  int sak = data['sak'];

  return NfcA._(
    tag,
    identifier,
    atqa,
    sak,
  );
}

NfcB _$nfcBFromTag(NfcTag tag) {
  if (tag.data['nfcb'] == null)
    return null;

  Map<String, dynamic> data = Map<String, dynamic>.from(tag.data['nfcb']);

  Uint8List identifier = tag.data['identifier'];
  Uint8List applicationData = data['applicationData'];
  Uint8List protocolInfo = data['protocolInfo'];

  return NfcB._(
    tag,
    identifier,
    applicationData,
    protocolInfo,
  );
}

NfcF _$nfcFFromTag(NfcTag tag) {
  if (tag.data['nfcf'] == null)
    return null;

  Map<String, dynamic> data = Map<String, dynamic>.from(tag.data['nfcf']);

  Uint8List identifier = tag.data['identifier'];
  Uint8List manufacturer = data['manufacturer'];
  Uint8List systemCode = data['systemCode'];

  return NfcF._(
    tag,
    identifier,
    manufacturer,
    systemCode,
  );
}

NfcV _$nfcVFromTag(NfcTag tag) {
  if (tag.data['nfcv'] == null)
    return null;

  Map<String, dynamic> data = Map<String, dynamic>.from(tag.data['nfcv']);

  Uint8List identifier = tag.data['identifier'];
  int dsfId = data['dsfId'];
  int responseFlags = data['responseFlags'];

  return NfcV._(
    tag,
    identifier,
    dsfId,
    responseFlags,
  );
}

IsoDep _$isoDepFromTag(NfcTag tag) {
  if (tag.data['isodep'] == null)
    return null;

  Map<String, dynamic> data = Map<String, dynamic>.from(tag.data['isodep']);

  Uint8List identifier = tag.data['identifier'];
  Uint8List hiLayerResponse = data['hiLayerResponse'];
  Uint8List historicalBytes = data['historicalBytes'];
  bool isExtendedLengthApduSupported = data['isExtendedLengthApduSupported'];

  return IsoDep._(
    tag,
    identifier,
    hiLayerResponse,
    historicalBytes,
    isExtendedLengthApduSupported,
  );
}

MiFareTag _$miFareTagFromTag(NfcTag tag) {
  if (tag.data['type'] != 'miFare')
    return null;

  int mifareFamily = tag.data['mifareFamily'];
  Uint8List identifier = tag.data['identifier'];
  Uint8List historicalBytes = tag.data['historicalBytes'];

  return MiFareTag._(
    tag,
    mifareFamily,
    identifier,
    historicalBytes,
  );
}

FeliCaTag _$felicaTagFromTag(NfcTag tag) {
  if (tag.data['type'] != 'feliCa')
    return null;

  Uint8List currentSystemCode = tag.data['currentSystemCode'];
  Uint8List currentIDm = tag.data['currentIDm'];

  return FeliCaTag._(
    tag,
    currentSystemCode,
    currentIDm,
  );
}

ISO15693Tag _$iso15693TagFromTag(NfcTag tag) {
  if (tag.data['type'] != 'iso15693')
    return null;

  int icManufacturerCode = tag.data['icManufacturerCode'];
  Uint8List icSerialNumber = tag.data['icSerialNumber'];
  Uint8List identifier = tag.data['identifier'];

  return ISO15693Tag._(
    tag,
    icManufacturerCode,
    icSerialNumber,
    identifier,
  );
}

ISO7816Tag _$iso7816TagFromTag(NfcTag tag) {
  if (tag.data['type'] != 'iso7816')
    return null;

  String initialSelectedAID = tag.data['initialSelectedAID'];
  Uint8List identifier = tag.data['identifier'];
  Uint8List historicalBytes = tag.data['historicalBytes'];
  Uint8List applicationData = tag.data['applicationData'];
  bool proprietaryApplicationDataCoding = tag.data['proprietaryApplicationDataCoding'];

  return ISO7816Tag._(
    tag,
    initialSelectedAID,
    identifier,
    historicalBytes,
    applicationData,
    proprietaryApplicationDataCoding,
  );
}

NdefMessage _$ndefMessageFromJson(Map<String, dynamic> data) {
  return NdefMessage((data['records'] as List)
    .map((e) => _$ndefRecordFromJson(Map<String, dynamic>.from(e))).toList()
  );
}

Map<String, dynamic> _$ndefMessageToJson(NdefMessage message) {
  return {'records': message.records.map(_$ndefRecordToJson).toList()};
}

NdefRecord _$ndefRecordFromJson(Map<String, dynamic> data) {
  return NdefRecord(
    typeNameFormat: data['typeNameFormat'],
    type: data['type'],
    identifier: data['identifier'],
    payload: data['payload'],
  );
}

Map<String, dynamic> _$ndefRecordToJson(NdefRecord record) {
  return {
    'typeNameFormat': record.typeNameFormat,
    'type': record.type,
    'identifier': record.identifier,
    'payload': record.payload,
  };
}
