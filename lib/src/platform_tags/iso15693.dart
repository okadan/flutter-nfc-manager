import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

// Iso15693
class Iso15693 {
  // Iso15693
  const Iso15693({
    @required this.tag,
    @required this.identifier,
    @required this.icManufacturerCode,
    @required this.icSerialNumber,
  });

  // tag
  final NfcTag tag;

  // identifier
  final Uint8List identifier;

  // icManufacturerCode
  final int icManufacturerCode;

  // icSerialNumber
  final Uint8List icSerialNumber;

  // Iso15693.from
  factory Iso15693.from(NfcTag tag) => $GetIso15693(tag);

  // readSingleBlock
  Future<Uint8List> readSingleBlock({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int blockNumber,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#readSingleBlock', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber?.toUnsigned(8),
    });
  }

  // writeSingleBlock
  Future<void> writeSingleBlock({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int blockNumber,
    @required Uint8List dataBlock,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#writeSingleBlock', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber?.toUnsigned(8),
      'dataBlock': dataBlock,
    });
  }

  // lockBlock
  Future<void> lockBlock({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int blockNumber,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#lockBlock', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber?.toUnsigned(8),
    });
  }

  // readMultipleBlocks
  Future<List<Uint8List>> readMultipleBlocks({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int blockNumber,
    @required int numberOfBlocks,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#readMultipleBlocks', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
      'numberOfBlocks': numberOfBlocks,
    });
  }

  // writeMultipleBlocks
  Future<void> writeMultipleBlocks({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int blockNumber,
    @required int numberOfBlocks,
    @required List<Uint8List> dataBlocks,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#writeMultipleBlocks', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
      'numberOfBlocks': numberOfBlocks,
      'dataBlocks': dataBlocks,
    });
  }

  // getMultipleBlockSecurityStatus
  Future<List<int>> getMultipleBlockSecurityStatus({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int blockNumber,
    @required int numberOfBlocks,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#getMultipleBlockSecurityStatus', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
      'numberOfBlocks': numberOfBlocks,
    });
  }

  // writeAfi
  Future<void> writeAfi({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int afi,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#writeAfi', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'afi': afi?.toUnsigned(8),
    });
  }

  // lockAfi
  Future<void> lockAfi({
    @required Set<Iso15693RequestFlag> requestFlags,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#lockAfi', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
    });
  }

  // writeDsfId
  Future<void> writeDsfId({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int dsfId,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#writeDsfId', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'dsfId': dsfId?.toUnsigned(8),
    });
  }

  // lockDsfId
  Future<void> lockDsfId({
    @required Set<Iso15693RequestFlag> requestFlags,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#lockDsfId', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
    });
  }

  // resetToReady
  Future<void> resetToReady({
    @required Set<Iso15693RequestFlag> requestFlags,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#resetToReady', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
    });
  }

  // select
  Future<void> select({
    @required Set<Iso15693RequestFlag> requestFlags,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#select', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
    });
  }

  // stayQuiet
  Future<void> stayQuiet() async {
    return channel.invokeMethod('Iso15693#stayQuiet', {
      'handle': tag.handle,
    });
  }

  // extendedReadSingleBlock
  Future<Uint8List> extendedReadSingleBlock({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int blockNumber,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#extendedReadSingleBlock', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
    });
  }

  // extendedWriteSingleBlock
  Future<void> extendedWriteSingleBlock({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int blockNumber,
    @required Uint8List dataBlock,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#extendedWriteSingleBlock', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
      'dataBlock': dataBlock,
    });
  }

  // extendedLockBlock
  Future<void> extendedLockBlock({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int blockNumber,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#extendedLockBlock', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
    });
  }

  // extendedReadMultipleBlocks
  Future<List<Uint8List>> extendedReadMultipleBlocks({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int blockNumber,
    @required int numberOfBlocks,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#extendedReadMultipleBlocks', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
      'numberOfBlocks': numberOfBlocks,
    });
  }

  // getSystemInfo
  Future<Iso15693SystemInfo> getSystemInfo({
    @required Set<Iso15693RequestFlag> requestFlags,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#getSystemInfo', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
    }).then((value) => $GetIso15693SystemInfo(Map.from(value)));
  }

  // customCommand
  Future<Uint8List> customCommand({
    @required Set<Iso15693RequestFlag> requestFlags,
    @required int customCommandCode,
    @required Uint8List customRequestParameters,
  }) async {
    requestFlags ??= {};
    return channel.invokeMethod('Iso15693#customCommand', {
      'handle': tag.handle,
      'requestFlags': requestFlags.map((e) => $Iso15693RequestFlagTable[e]).toList(),
      'customCommandCode': customCommandCode,
      'customRequestParameters': customRequestParameters,
    });
  }
}

// Iso15693SystemInfo
class Iso15693SystemInfo {
  // Iso15693SystemInfo
  const Iso15693SystemInfo({
    @required this.applicationFamilyIdentifier,
    @required this.blockSize,
    @required this.dataStorageFormatIdentifier,
    @required this.icReference,
    @required this.totalBlocks,
  });

  // applicationFamilyIdentifier
  final int applicationFamilyIdentifier;

  // blockSize
  final int blockSize;

  // dataStorageFormatIdentifier
  final int dataStorageFormatIdentifier;

  // icReference
  final int icReference;

  // totalBlocks
  final int totalBlocks;
}

// Iso15693RequestFlag
enum Iso15693RequestFlag {
  // address
  address,

  // dualSubCarriers
  dualSubCarriers,

  // highDataRate
  highDataRate,

  // option
  option,

  // protocolExtension
  protocolExtension,

  // select
  select,
}
