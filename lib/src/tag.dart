part of nfc_manager;

class NfcTag {
  NfcTag._(this._handle, this.data);

  final String _handle;

  final Map<String, dynamic> data;
}

class Ndef {
  Ndef._(this._tag, this.cachedMessage, this.isWritable, this.maxSize);

  final NfcTag _tag;

  final NdefMessage cachedMessage;

  final bool isWritable;

  final int maxSize;

  factory Ndef.fromTag(NfcTag tag) => _$ndefFromTag(tag);

  Future<bool> write(NdefMessage message) async {
    return _channel.invokeMethod('Ndef#write', {
      'handle': _tag._handle,
      'message': _$ndefMessageToJson(message),
    });
  }

  Future<bool> writeLock() async {
    return _channel.invokeMethod('Ndef#writeLock', {
      'handle': _tag._handle,
    });
  }
}

class NfcA {
  NfcA._(
    this._tag,
    this.identifier,
    this.atqa,
    this.sak,
  );

  final NfcTag _tag;

  final Uint8List identifier;

  final Uint8List atqa;

  final int sak;

  factory NfcA.fromTag(NfcTag tag) => _$nfcAFromTag(tag);

  Future<Uint8List> transceive(Uint8List data) async {
    return _channel.invokeMethod('NfcA#transceive', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}

class NfcB {
  NfcB._(
    this._tag,
    this.identifier,
    this.applicationData,
    this.protocolInfo,
  );

  final NfcTag _tag;

  final Uint8List identifier;

  final Uint8List applicationData;

  final Uint8List protocolInfo;

  factory NfcB.fromTag(NfcTag tag) => _$nfcBFromTag(tag);

  Future<Uint8List> transceive(Uint8List data) async {
    return _channel.invokeMethod('NfcB#transceive', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}

class NfcF {
  NfcF._(
    this._tag,
    this.identifier,
    this.manufacturer,
    this.systemCode,
  );

  final NfcTag _tag;

  final Uint8List identifier;

  final Uint8List manufacturer;

  final Uint8List systemCode;

  factory NfcF.fromTag(NfcTag tag) => _$nfcFFromTag(tag);

  Future<Uint8List> transceive(Uint8List data) async {
    return _channel.invokeMethod('NfcF#transceive', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}

class NfcV {
  NfcV._(
    this._tag,
    this.identifier,
    this.dsfId,
    this.responseFlags,
  );

  final NfcTag _tag;

  final Uint8List identifier;

  final int dsfId;

  final int responseFlags;

  factory NfcV.fromTag(NfcTag tag) => _$nfcVFromTag(tag);

  Future<Uint8List> transceive(Uint8List data) async {
    return _channel.invokeMethod('NfcV#transceive', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}

class IsoDep {
  IsoDep._(
    this._tag,
    this.identifier,
    this.hiLayerResponse,
    this.historicalBytes,
    this.isExtendedLengthApduSupported,
  );

  final NfcTag _tag;

  final Uint8List identifier;

  final Uint8List hiLayerResponse;

  final Uint8List historicalBytes;

  final bool isExtendedLengthApduSupported;

  factory IsoDep.fromTag(NfcTag tag) => _$isoDepFromTag(tag);

  Future<Uint8List> transceive(Uint8List data) async {
    return _channel.invokeMethod('IsoDep#transceive', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}

class MiFareTag {
  MiFareTag._(
    this._tag,
    this.mifareFamily,
    this.identifier,
    this.historicalBytes,
  );

  final NfcTag _tag;

  final int mifareFamily;

  final Uint8List identifier;

  final Uint8List historicalBytes;

  factory MiFareTag.fromTag(NfcTag tag) => _$miFareTagFromTag(tag);

  Future<Uint8List> sendMiFareCommand(Uint8List commandPacket) async {
    return _channel.invokeMethod('MiFare#sendMiFareCommand', {
      'handle': _tag._handle,
      'commandPacket': commandPacket,
    });
  }

  Future<Map<String, dynamic>> sendMiFareISO7816Command(
    int instructionClass,
    int instructionCode,
    int p1Parameter,
    int p2Parameter,
    Uint8List data,
    int expectedResponseLength,
  ) async {
    return _channel.invokeMethod('ISO7816#sendCommand', {
      'instructionClass': instructionClass,
      'instructionCode': instructionCode,
      'p1Parameter': p1Parameter,
      'p2Parameter': p2Parameter,
      'data': data,
      'expectedResponseLength': expectedResponseLength,
    });
  }

  Future<Map<String, dynamic>> sendMiFareISO7816CommandRow(Uint8List data) async {
    return _channel.invokeMethod('ISO7816#sendCommand', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}

class FeliCaTag {
  FeliCaTag._(
    this._tag,
    this.currentSystemCode,
    this.currentIDm,
  );

  final NfcTag _tag;

  final Uint8List currentSystemCode;

  final Uint8List currentIDm;

  factory FeliCaTag.fromTag(NfcTag tag) => _$felicaTagFromTag(tag);

  Future<Uint8List> sendFeliCaCommand(Uint8List commandPacket) async {
    return _channel.invokeMethod('FeliCa#sendFeliCaCommand', {
      'handle': _tag._handle,
      'commandPacket': commandPacket,
    });
  }
}

class ISO15693Tag {
  ISO15693Tag._(
    this._tag,
    this.icManufacturerCode,
    this.icSerialNumber,
    this.identifier,
  );

  final NfcTag _tag;

  final int icManufacturerCode;

  final Uint8List icSerialNumber;

  final Uint8List identifier;

  factory ISO15693Tag.fromTag(NfcTag tag) => _$iso15693TagFromTag(tag);

  Future<Uint8List> customCommand(Set<int> requestFlags, int commandCode, Uint8List parameters) async {
    return _channel.invokeMethod('ISO15693#customCommand', {
      'handle': _tag._handle,
      'requestFlags': requestFlags.toList(),
      'commandCode': commandCode,
      'parameters': parameters,
    });
  }
}

class ISO7816Tag {
  ISO7816Tag._(
    this._tag,
    this.initialSelectedAID,
    this.identifier,
    this.historicalBytes,
    this.applicationData,
    this.proprietaryApplicationDataCoding,
  );

  final NfcTag _tag;

  final String initialSelectedAID;

  final Uint8List identifier;

  final Uint8List historicalBytes;

  final Uint8List applicationData;

  final bool proprietaryApplicationDataCoding;

  factory ISO7816Tag.fromTag(NfcTag tag) => _$iso7816TagFromTag(tag);

  Future<Map<String, dynamic>> sendCommand(
    int instructionClass,
    int instructionCode,
    int p1Parameter,
    int p2Parameter,
    Uint8List data,
    int expectedResponseLength,
  ) async {
    return _channel.invokeMethod('ISO7816#sendCommand', {
      'handle': _tag._handle,
      'instructionClass': instructionClass,
      'instructionCode': instructionCode,
      'p1Parameter': p1Parameter,
      'p2Parameter': p2Parameter,
      'data': data,
      'expectedResponseLength': expectedResponseLength,
    });
  }

  Future<Map<String, dynamic>> sendCommandRow(Uint8List data) async {
    return _channel.invokeMethod('ISO7816#sendCommand', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}
