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

/// (iOS only) Provides access to MiFare operations on the tag.
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
  Future<Uint8List> sendMiFareISO7816Command({
    @required int instructionClass,
    @required int instructionCode,
    @required int p1Parameter,
    @required int p2Parameter,
    @required Uint8List data,
    @required int expectedResponseLength,
  }) async {
    return channel.invokeMethod('ISO7816#sendCommand', {
      'handle': tag.handle,
      'apdu': {
        'instructionClass': instructionClass,
        'instructionCode': instructionCode,
        'p1Parameter': p1Parameter,
        'p2Parameter': p2Parameter,
        'data': data,
        'expectedResponseLength': expectedResponseLength,
      },
    });
  }

  /// Send raw APDU to the tag.
  ///
  /// This wraps the iOS platform `NFCMiFareTag.sendMiFareISO7816Command` API with apdu instantiated with raw bytes.
  Future<Uint8List> sendMiFareISO7816CommandRaw(Uint8List data) async {
    return channel.invokeMethod('ISO7816#sendCommand', {
      'handle': tag.handle,
      'apdu': {
        'data': data,
      },
    });
  }
}

/// (iOS only) Provides access to FeliCa operations on the tag.
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

/// (iOS only) Provides access to ISO15693 operations on the tag.
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

  /// Sends the Get System Information command (0x2B command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.getSystemInfo` API.
  Future<dynamic> getSystemInfo({
    @required Set<ISO15693RequestFlag> requestFlags,
  }) async {
    return channel.invokeMethod('ISO15693#getSystemInfo', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
    });
  }

  /// Sends a Read Single Block command (0x20 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.readSingleBlock` API.
  Future<Uint8List> readSingleBlock({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int blockNumber,
  }) async {
    return channel.invokeMethod('ISO15693#readSingleBlock', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'blockNumber': blockNumber % 256,
    });
  }

  /// Sends the Write Single Block command (0x21 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.writeSingleBlock` API.
  Future<bool> writeSingleBlock({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int blockNumber,
    @required Uint8List dataBlock,
  }) async {
    return channel.invokeMethod('ISO15693#writeSingleBlock', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'blockNumber': blockNumber % 256,
      'dataBlock': dataBlock,
    });
  }

  /// Sends the Lock Block command (0x22 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.lockBlock` API.
  Future<bool> lockBlock({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int blockNumber,
  }) async {
    return channel.invokeMethod('ISO15693#lockBlock', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'blockNumber': blockNumber % 256,
    });
  }

  /// Sends the Read Multiple Blocks command (0x23 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.readMultipleBlocks` API.
  Future<List<Uint8List>> readMultipleBlocks({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int blockNumber,
    @required int numberOfBlocks,
  }) async {
    return channel.invokeMethod('ISO15693#readMultipleBlocks', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'blockNumber': blockNumber % 256,
      'numberOfBlocks': numberOfBlocks,
    });
  }

  /// Sends the Write Multiple Blocks command (0x24 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.writeMultipleBlocks` API.
  Future<bool> writeMultipleBlocks({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int blockNumber,
    @required int numberOfBlocks,
    @required List<Uint8List> dataBlocks,
  }) async {
    return channel.invokeMethod('ISO15693#writeMultipleBlocks', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'blockNumber': blockNumber % 256,
      'numberOfBlocks': numberOfBlocks,
      'dataBlocks': dataBlocks,
    });
  }

  /// Sends the Get Multiple Block Security Status command (0x2C command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.getMultipleBlockSecurityStatus` API.
  Future<List<int>> getMultipleBlockSecurityStatus({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int blockNumber,
    @required int numberOfBlocks,
  }) async {
    return channel.invokeMethod('ISO15693#getMultipleBlockSecurityStatus', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'blockNumber': blockNumber % 256,
      'numberOfBlocks': numberOfBlocks,
    });
  }

  /// Sends the Write AFI command (0x27 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.writeAFI` API.
  Future<bool> writeAfi({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int afi,
  }) async {
    return channel.invokeMethod('ISO15693#writeAfi', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'afi': afi % 256,
    });
  }

  /// Sends the Lock AFI command (0x28 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.lockAfi` API.
  Future<bool> lockAfi({
    @required Set<ISO15693RequestFlag> requestFlags,
  }) async {
    return channel.invokeMethod('ISO15693#lockAfi', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
    });
  }

  /// Sends the Write DSFID command (0x29 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.writeDSFID` API.
  Future<bool> writeDsfId({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int dsfId,
  }) async {
    return channel.invokeMethod('ISO15693#writeDsfId', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'dsfId': dsfId % 256,
    });
  }

  /// Sends the Lock DSFID command (0x2A command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.lockDSFID` API.
  Future<bool> lockDsfId({
    @required Set<ISO15693RequestFlag> requestFlags,
  }) async {
    return channel.invokeMethod('ISO15693#lockDsfId', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
    });
  }

  /// Sends the Reset To Ready command (0x26 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.resetToReady` API.
  Future<bool> resetToReady({
    @required Set<ISO15693RequestFlag> requestFlags,
  }) async {
    return channel.invokeMethod('ISO15693#resetToReady', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
    });
  }

  /// Sends the Select command (0x25 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.select` API.
  Future<bool> select({
    @required Set<ISO15693RequestFlag> requestFlags,
  }) async {
    return channel.invokeMethod('ISO15693#select', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
    });
  }

  /// Sends the Stay Quiet command (0x02 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.stayQuiet` API.
  Future<bool> stayQuiet({
    @required Set<ISO15693RequestFlag> requestFlags,
  }) async {
    return channel.invokeMethod('ISO15693#stayQuiet', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
    });
  }

  /// Sends the Extended Read Single Block command (0x30 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.extendedReadSingleBlock` API.
  Future<Uint8List> extendedReadSingleBlock({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int blockNumber,
  }) async {
    return channel.invokeMethod('ISO15693#extendedReadSingleBlock', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'blockNumber': blockNumber,
    });
  }

  /// Sends the Extended Write Single Block command (0x31 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.extendedWriteSingleBlock` API.
  Future<bool> extendedWriteSingleBlock({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int blockNumber,
    @required Uint8List dataBlock,
  }) async {
    return channel.invokeMethod('ISO15693#extendedWriteSingleBlock', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'blockNumber': blockNumber,
      'dataBlock': dataBlock,
    });
  }

  /// Sends the Extended Lock Block command (0x32 command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.extendedLockBlock` API.
  Future<bool> extendedLockBlock({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int blockNumber,
  }) async {
    return channel.invokeMethod('ISO15693#extendedLockBlock', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'blockNumber': blockNumber,
    });
  }

  /// Sends the Extended Read Multiple Blocks command (0x3s command code) to the tag.
  ///
  /// This wraps the iOS platform `NFCISO15693Tag.extendedReadMultipleBlocks` API.
  Future<Uint8List> extendedReadMultipleBlocks({
    @required Set<ISO15693RequestFlag> requestFlags,
    @required int blockNumber,
    @required int numberOfBlocks,
  }) async {
    return channel.invokeMethod('ISO15693#extendedReadMultipleBlocks', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => e.index).toList(),
      'blockNumber': blockNumber,
      'numberOfBlocks': numberOfBlocks,
    });
  }

  /// Sends custom command (0xA0 to 0xDF command code) to the tag.
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

/// (iOS only) Provides access to ISO7816 operations on the tag.
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
  Future<Uint8List> sendCommand({
    @required int instructionClass,
    @required int instructionCode,
    @required int p1Parameter,
    @required int p2Parameter,
    @required Uint8List data,
    @required int expectedResponseLength,
  }) async {
    return channel.invokeMethod('ISO7816#sendCommand', {
      'handle': tag.handle,
      'apdu': {
        'instructionClass': instructionClass,
        'instructionCode': instructionCode,
        'p1Parameter': p1Parameter,
        'p2Parameter': p2Parameter,
        'data': data,
        'expectedResponseLength': expectedResponseLength,
      },
    });
  }

  /// Send raw APDU to the tag.
  ///
  /// This wraps the iOS platform `NFCISO7816Tag.sendCommand` API with apdu instantiated with raw bytes.
  Future<Uint8List> sendCommandRaw(Uint8List data) async {
    return channel.invokeMethod('ISO7816#sendCommand', {
      'handle': tag.handle,
      'apdu': {
        'data': data,
      },
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
