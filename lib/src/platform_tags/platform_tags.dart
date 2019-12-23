import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../channel.dart';
import '../translator.dart';
import '../nfc_manager/nfc_manager.dart' show NfcTag;

/// (Android only) Provides access to NFC-A operations on the tag.
///
/// Acquire `NfcA` instance using `NfcA.fromTag(tag)`.
class NfcA {
  NfcA({
    @required this.tag,
    @required this.identifier,
    @required this.atqa,
    @required this.sak,
  });

  final NfcTag tag;

  final Uint8List identifier;

  final Uint8List atqa;

  final int sak;

  /// Get an instance of `NfcA` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NFC-A.
  factory NfcA.fromTag(NfcTag tag) => $nfcAFromTag(tag);

  /// Send raw NFC-A commands to the tag.
  ///
  /// This wraps the Android platform `NfcA.transceive` API.
  Future<Uint8List> transceive(Uint8List data) async {
    return channel.invokeMethod('NfcA#transceive', {
      'handle': tag.handle,
      'data': data,
    });
  }
}

/// (Android only) Provides access to NFC-B operations on the tag.
///
/// Acquire `NfcB` instance using `NfcB.fromTag(tag)`.
class NfcB {
  NfcB({
    @required this.tag,
    @required this.identifier,
    @required this.applicationData,
    @required this.protocolInfo,
  });

  final NfcTag tag;

  final Uint8List identifier;

  final Uint8List applicationData;

  final Uint8List protocolInfo;

  /// Get an instance of `NfcB` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NFC-B.
  factory NfcB.fromTag(NfcTag tag) => $nfcBFromTag(tag);

  /// Send raw NFC-B commands to the tag.
  ///
  /// This wraps the Android platform `NfcB.transceive` API.
  Future<Uint8List> transceive(Uint8List data) async {
    return channel.invokeMethod('NfcB#transceive', {
      'handle': tag.handle,
      'data': data,
    });
  }
}

/// (Android only) Provides access to NFC-F operations on the tag.
///
/// Acquire `NfcF` instance using `NfcF.fromTag(tag)`.
class NfcF {
  NfcF({
    @required this.tag,
    @required this.identifier,
    @required this.manufacturer,
    @required this.systemCode,
  });

  final NfcTag tag;

  final Uint8List identifier;

  final Uint8List manufacturer;

  final Uint8List systemCode;

  /// Get an instance of `NfcF` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NFC-F.
  factory NfcF.fromTag(NfcTag tag) => $nfcFFromTag(tag);

  /// Send raw NFC-F commands to the tag.
  ///
  /// This wraps the Android platform `NfcF.transceive` API.
  Future<Uint8List> transceive(Uint8List data) async {
    return channel.invokeMethod('NfcF#transceive', {
      'handle': tag.handle,
      'data': data,
    });
  }
}

/// (Android only) Provides access to NFC-V operations on the tag.
///
/// Acquire `NfcV` instance using `NfcV.fromTag(tag)`.
class NfcV {
  NfcV({
    @required this.tag,
    @required this.identifier,
    @required this.dsfId,
    @required this.responseFlags,
  });

  final NfcTag tag;

  final Uint8List identifier;

  final int dsfId;

  final int responseFlags;

  /// Get an instance of `NfcV` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NFC-V.
  factory NfcV.fromTag(NfcTag tag) => $nfcVFromTag(tag);

  /// Send raw NFC-V commands to the tag.
  ///
  /// This wraps the Android platform `NfcV.transceive` API.
  Future<Uint8List> transceive(Uint8List data) async {
    return channel.invokeMethod('NfcV#transceive', {
      'handle': tag.handle,
      'data': data,
    });
  }
}

/// (Android only) Provides access to ISO14443-4 operations on the tag.
///
/// Acquire `IsoDep` instance using `IsoDep.fromTag(tag)`.
class IsoDep {
  IsoDep({
    @required this.tag,
    @required this.identifier,
    @required this.hiLayerResponse,
    @required this.historicalBytes,
    @required this.isExtendedLengthApduSupported,
  });

  final NfcTag tag;

  final Uint8List identifier;

  final Uint8List hiLayerResponse;

  final Uint8List historicalBytes;

  final bool isExtendedLengthApduSupported;

  /// Get an instance of `IsoDep` for the given tag.
  ///
  /// Returns null if the tag is not compatible with ISO14443-4.
  factory IsoDep.fromTag(NfcTag tag) => $isoDepFromTag(tag);

  /// Send raw ISO-DEP data to the tag.
  ///
  /// This wraps the Android platform `IsoDep.transceive` API.
  Future<Uint8List> transceive(Uint8List data) async {
    return channel.invokeMethod('IsoDep#transceive', {
      'handle': tag.handle,
      'data': data,
    });
  }
}

/// (iOS 13.0 or later only) Provides access to MiFare operations on the tag.
///
/// Acquire `MiFare` instance using `MiFare.fromTag(tag)`.
class MiFare {
  MiFare({
    @required this.tag,
    @required this.mifareFamily,
    @required this.identifier,
    @required this.historicalBytes,
  });

  final NfcTag tag;

  final int mifareFamily;

  final Uint8List identifier;

  final Uint8List historicalBytes;

  /// Get an instance of `MiFare` for the given tag.
  ///
  /// Returns null if the tag is not compatible with MiFare.
  factory MiFare.fromTag(NfcTag tag) => $miFareFromTag(tag);

  /// Send native MiFare command to the tag.
  ///
  /// This wraps the iOS platform `NFCMiFareTag.sendMiFareCommand` API.
  Future<Uint8List> sendMiFareCommand(Uint8List commandPacket) async {
    return channel.invokeMethod('MiFare#sendMiFareCommand', {
      'handle': tag.handle,
      'commandPacket': commandPacket,
    });
  }

  /// Send APDU to the tag.
  ///
  /// This wraps the iOS platform `NFCMiFareTag.sendMiFareISO7816Command` API.
  Future<Map<String, dynamic>> sendMiFareISO7816Command({
    @required int instructionClass,
    @required int instructionCode,
    @required int p1Parameter,
    @required int p2Parameter,
    @required Uint8List data,
    @required int expectedResponseLength,
  }) async {
    return channel.invokeMethod('ISO7816#sendCommand', {
      'instructionClass': instructionClass,
      'instructionCode': instructionCode,
      'p1Parameter': p1Parameter,
      'p2Parameter': p2Parameter,
      'data': data,
      'expectedResponseLength': expectedResponseLength,
    });
  }

  /// Send raw APDU to the tag.
  ///
  /// This wraps the iOS platform `NFCMiFareTag.sendMiFareISO7816Command` API with apdu instantiated with raw bytes.
  Future<Uint8List> sendMiFareISO7816CommandRow(Uint8List data) async {
    return channel.invokeMethod('ISO7816#sendCommand', {
      'handle': tag.handle,
      'data': data,
    });
  }
}

/// (iOS 13.0 or later only) Provides access to FeliCa operations on the tag.
///
/// Acquire `FeliCa` instance using `FeliCa.fromTag(tag)`.
class FeliCa {
  FeliCa({
    @required this.tag,
    @required this.currentSystemCode,
    @required this.currentIDm,
  });

  final NfcTag tag;

  final Uint8List currentSystemCode;

  final Uint8List currentIDm;

  /// Get an instance of `FeliCa` for the given tag.
  ///
  /// Returns null if the tag is not compatible with FeliCa.
  factory FeliCa.fromTag(NfcTag tag) => $felicaFromTag(tag);

  /// Send FeliCa command to the tag.
  ///
  /// This wraps the iOS platform `NFCFeliCaTag.sendFeliCaCommand` API.
  Future<Uint8List> sendFeliCaCommand(Uint8List commandPacket) async {
    return channel.invokeMethod('FeliCa#sendFeliCaCommand', {
      'handle': tag.handle,
      'commandPacket': commandPacket,
    });
  }
}

/// (iOS 13.0 or later only) Provides access to ISO15693 operations on the tag.
///
/// Acquire `ISO15693` instance using `ISO15693.fromTag(tag)`.
class ISO15693 {
  ISO15693({
    @required this.tag,
    @required this.icManufacturerCode,
    @required this.icSerialNumber,
    @required this.identifier,
  });

  final NfcTag tag;

  final int icManufacturerCode;

  final Uint8List icSerialNumber;

  final Uint8List identifier;

  /// Get an instance of `ISO15693` for the given tag.
  ///
  /// Returns null if the tag is not compatible with ISO15693.
  factory ISO15693.fromTag(NfcTag tag) => $iso15693FromTag(tag);

  /// Send custom command (0xA0 to 0xDF command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.customCommand` API.
  Future<Uint8List> customCommand({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int commandCode,
    @required Uint8List parameters,
  }) async {
    return channel.invokeMethod('ISO15693#customCommand', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'commandCode': commandCode,
      'parameters': parameters,
    });
  }
}

/// (iOS 13.0 or later only) Provides access to ISO7816 operations on the tag.
///
/// Acquire `ISO7816` instance using `ISO7816.fromTag(tag)`.
class ISO7816 {
  ISO7816({
    @required this.tag,
    @required this.initialSelectedAID,
    @required this.identifier,
    @required this.historicalBytes,
    @required this.applicationData,
    @required this.proprietaryApplicationDataCoding,
  });

  final NfcTag tag;

  final String initialSelectedAID;

  final Uint8List identifier;

  final Uint8List historicalBytes;

  final Uint8List applicationData;

  final bool proprietaryApplicationDataCoding;

  /// Get an instance of `ISO7816` for the given tag.
  ///
  /// Returns null if the tag is not compatible with ISO7816.
  factory ISO7816.fromTag(NfcTag tag) => $iso7816FromTag(tag);

  /// Send APDU to the tag.
  ///
  /// This wraps the iOS platform `NFCISO7816Tag.sendCommand` API.
  Future<Map<String, dynamic>> sendCommand({
    @required int instructionClass,
    @required int instructionCode,
    @required int p1Parameter,
    @required int p2Parameter,
    @required Uint8List data,
    @required int expectedResponseLength,
  }) async {
    return channel.invokeMethod('ISO7816#sendCommand', {
      'handle': tag.handle,
      'instructionClass': instructionClass,
      'instructionCode': instructionCode,
      'p1Parameter': p1Parameter,
      'p2Parameter': p2Parameter,
      'data': data,
      'expectedResponseLength': expectedResponseLength,
    });
  }

  /// Send raw APDU to the tag.
  ///
  /// This wraps the iOS platform `NFCISO7816Tag.sendCommand` API.
  Future<Uint8List> sendCommandRow(Uint8List data) async {
    return channel.invokeMethod('ISO7816#sendCommand', {
      'handle': tag.handle,
      'data': data,
    });
  }
}

/// Represents iOS platform `NFCISO15693Tag.RequestFlag`.
enum ISO15693RequestFlag {
  dualSubCarriers,
  highDataRate,
  protocolExtension,
  select,
  address,
  option,
}
