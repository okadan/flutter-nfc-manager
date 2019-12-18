part of nfc_manager;

/// Represents the tag detected by the session.
class NfcTag {
  NfcTag._(this._handle, this.data);

  final String _handle;

  /// Raw values that can be obtained on the native platform.
  ///
  /// Typically accessed from specific-tag-type that you instantiated (eg NfcA.fromTag).
  ///
  /// This property is experimental and may be changed without announcement in the future.
  /// Not recommended for use directly.
  final Map<String, dynamic> data;
}

/// Provides access to ndef operations on the tag.
///
/// Acquire `Ndef` object using `fromTag(tag)`.
class Ndef {
  Ndef._(this._tag, this.cachedMessage, this.isWritable, this.maxSize);

  final NfcTag _tag;

  /// An ndef message that was read from the tag at discovery time.
  final NdefMessage cachedMessage;

  /// Indicates whether the the tag can be written with ndef.
  final bool isWritable;

  /// The maximum NDEF message size in bytes, that you can store.
  final int maxSize;

  /// Get an instance of `Ndef` for the given tag.
  ///
  /// Returns null if the tag is not compatible with ndef.
  factory Ndef.fromTag(NfcTag tag) => _$ndefFromTag(tag);

  /// Overwrite an ndef message on this tag.
  ///
  /// On iOS, iOS13.0 or later is required.
  Future<bool> write(NdefMessage message) async {
    return _channel.invokeMethod('Ndef#write', {
      'handle': _tag._handle,
      'message': _$ndefMessageToJson(message),
    });
  }

  /// Make the tag read-only.
  ///
  /// On iOS, iOS13.0 or later is required.
  Future<bool> writeLock() async {
    return _channel.invokeMethod('Ndef#writeLock', {
      'handle': _tag._handle,
    });
  }
}

/// (Android only) Provides access to NFC-A operations on the tag.
///
/// Acquire `NfcA` object using `fromTag(tag)`.
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

  /// Get an instance of `NfcA` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NFC-A.
  factory NfcA.fromTag(NfcTag tag) => _$nfcAFromTag(tag);

  /// Send raw NFC-A commands to the tag.
  ///
  /// This wraps the Android platform `NfcA.transceive` API.
  /// See: https://developer.android.com/reference/android/nfc/tech/NfcA#transceive(byte%5B%5D)
  Future<Uint8List> transceive(Uint8List data) async {
    return _channel.invokeMethod('NfcA#transceive', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}

/// (Android only) Provides access to NFC-B operations on the tag.
///
/// Acquire `NfcB` object using `fromTag(tag)`.
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

  /// Get an instance of `NfcB` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NFC-B.
  factory NfcB.fromTag(NfcTag tag) => _$nfcBFromTag(tag);

  /// Send raw NFC-B commands to the tag.
  ///
  /// This wraps the Android platform `NfcB.transceive` API.
  /// See: https://developer.android.com/reference/android/nfc/tech/NfcB#transceive(byte%5B%5D)
  Future<Uint8List> transceive(Uint8List data) async {
    return _channel.invokeMethod('NfcB#transceive', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}

/// (Android only) Provides access to NFC-F operations on the tag.
///
/// Acquire `NfcF` object using `fromTag(tag)`.
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

  /// Get an instance of `NfcF` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NFC-F.
  factory NfcF.fromTag(NfcTag tag) => _$nfcFFromTag(tag);

  /// Send raw NFC-F commands to the tag.
  ///
  /// This wraps the Android platform `NfcF.transceive` API.
  /// See: https://developer.android.com/reference/android/nfc/tech/NfcF#transceive(byte%5B%5D)
  Future<Uint8List> transceive(Uint8List data) async {
    return _channel.invokeMethod('NfcF#transceive', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}

/// (Android only) Provides access to NFC-V operations on the tag.
///
/// Acquire `NfcV` object using `fromTag(tag)`.
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

  /// Get an instance of `NfcV` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NFC-V.
  factory NfcV.fromTag(NfcTag tag) => _$nfcVFromTag(tag);

  /// Send raw NFC-V commands to the tag.
  ///
  /// This wraps the Android platform `NfcV.transceive` API.
  /// See: https://developer.android.com/reference/android/nfc/tech/NfcV#transceive(byte%5B%5D)
  Future<Uint8List> transceive(Uint8List data) async {
    return _channel.invokeMethod('NfcV#transceive', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}

/// (Android only) Provides access to ISO 14443-4 operations on the tag.
///
/// Acquire `IsoDep` object using `fromTag(tag)`.
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

  /// Get an instance of `IsoDep` for the given tag.
  ///
  /// Returns null if the tag is not compatible with ISO14443-4.
  factory IsoDep.fromTag(NfcTag tag) => _$isoDepFromTag(tag);

  /// Send raw ISO-DEP data to the tag.
  ///
  /// This wraps the Android platform `IsoDep.transceive` API.
  /// See: https://developer.android.com/reference/android/nfc/tech/IsoDep#transceive(byte%5B%5D)
  Future<Uint8List> transceive(Uint8List data) async {
    return _channel.invokeMethod('IsoDep#transceive', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}

/// (iOS only) Provides access to MiFare operations on the tag.
///
/// Acquire `MiFare` object using `fromTag(tag)`.
class MiFare {
  MiFare._(
    this._tag,
    this.mifareFamily,
    this.identifier,
    this.historicalBytes,
  );

  final NfcTag _tag;

  final int mifareFamily;

  final Uint8List identifier;

  final Uint8List historicalBytes;

  /// Get an instance of `MiFare` for the given tag.
  ///
  /// Returns null if the tag is not compatible with MiFare.
  factory MiFare.fromTag(NfcTag tag) => _$miFareFromTag(tag);

  /// Send native MIFARE command to the tag.
  ///
  /// This wraps the iOS platform `NFCMiFareTag.sendMiFareCommand` API.
  /// See: https://developer.apple.com/documentation/corenfc/nfcmifaretag/3043838-sendmifarecommand
  Future<Uint8List> sendMiFareCommand(Uint8List commandPacket) async {
    return _channel.invokeMethod('MiFare#sendMiFareCommand', {
      'handle': _tag._handle,
      'commandPacket': commandPacket,
    });
  }

  /// Send ISO7816 command apdu to the tag.
  ///
  /// This wraps the iOS platform `NFCMiFareTag.sendMiFareISO7816Command` API.
  /// See: https://developer.apple.com/documentation/corenfc/nfcmifaretag/3153114-sendmifareiso7816command
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

  /// Send ISO7816 raw command apdu to the tag.
  ///
  /// This wraps the iOS platform `NFCMiFareTag.sendMiFareISO7816Command` API with apdu instantiated with raw bytes.
  /// See: https://developer.apple.com/documentation/corenfc/nfcmifaretag/3153114-sendmifareiso7816command
  Future<Map<String, dynamic>> sendMiFareISO7816CommandRow(Uint8List data) async {
    return _channel.invokeMethod('ISO7816#sendCommand', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}

/// (iOS only) Provides access to FeliCa operations on the tag.
///
/// Acquire `FeliCa` object using `fromTag(tag)`.
class FeliCa {
  FeliCa._(
    this._tag,
    this.currentSystemCode,
    this.currentIDm,
  );

  final NfcTag _tag;

  final Uint8List currentSystemCode;

  final Uint8List currentIDm;

  /// Get an instance of `FeliCa` for the given tag.
  ///
  /// Returns null if the tag is not compatible with FeliCa.
  factory FeliCa.fromTag(NfcTag tag) => _$felicaFromTag(tag);

  /// Send FeliCa command to the tag.
  ///
  /// This wraps the iOS platform `NFCFeliCaTag.sendFeliCaCommand` API.
  /// See: https://developer.apple.com/documentation/corenfc/nfcfelicatag/3043786-sendfelicacommand
  Future<Uint8List> sendFeliCaCommand(Uint8List commandPacket) async {
    return _channel.invokeMethod('FeliCa#sendFeliCaCommand', {
      'handle': _tag._handle,
      'commandPacket': commandPacket,
    });
  }
}

/// (iOS only) Provides access to ISO15693 operations on the tag.
///
/// Acquire `ISO15693` object using `fromTag(tag)`.
class ISO15693 {
  ISO15693._(
    this._tag,
    this.icManufacturerCode,
    this.icSerialNumber,
    this.identifier,
  );

  final NfcTag _tag;

  final int icManufacturerCode;

  final Uint8List icSerialNumber;

  final Uint8List identifier;

  /// Get an instance of `ISO15693` for the given tag.
  ///
  /// Returns null if the tag is not compatible with ISO15693.
  factory ISO15693.fromTag(NfcTag tag) => _$iso15693FromTag(tag);

  /// Send custom command (0xA0 to 0xDF command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.customCommand` API.
  /// See: https://developer.apple.com/documentation/corenfc/nfciso15693tag/3043799-customcommand
  Future<Uint8List> customCommand(Set<int> requestFlags, int commandCode, Uint8List parameters) async {
    return _channel.invokeMethod('ISO15693#customCommand', {
      'handle': _tag._handle,
      'requestFlags': requestFlags.toList(),
      'commandCode': commandCode,
      'parameters': parameters,
    });
  }
}

/// (iOS only) Provides access to ISO7816 operations on the tag.
///
/// Acquire `ISO7816` object using `fromTag(tag)`.
class ISO7816 {
  ISO7816._(
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

  /// Get an instance of `ISO7816` for the given tag.
  ///
  /// Returns null if the tag is not compatible with ISO7816.
  factory ISO7816.fromTag(NfcTag tag) => _$iso7816FromTag(tag);

  /// Send apdu to the tag.
  ///
  /// This wraps the iOS platform `NFCISO7816Tag.sendCommand` API.
  /// See: https://developer.apple.com/documentation/corenfc/nfciso7816tag/3043835-sendcommand
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

  /// Send raw apdu to the tag.
  ///
  /// This wraps the iOS platform `NFCISO7816Tag.sendCommand` API.
  /// See: https://developer.apple.com/documentation/corenfc/nfciso7816tag/3043835-sendcommand
  Future<Map<String, dynamic>> sendCommandRow(Uint8List data) async {
    return _channel.invokeMethod('ISO7816#sendCommand', {
      'handle': _tag._handle,
      'data': data,
    });
  }
}
