import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

class Iso15693IOS {
  const Iso15693IOS(this._tag, {
    required this.icManufacturerCode,
    required this.icSerialNumber,
  });

  final NfcTag _tag;

  final int icManufacturerCode;

  final Uint8List icSerialNumber;

  static Iso15693IOS? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).iso15693;
    return pigeon == null ? null : Iso15693IOS(
      tag,
      icManufacturerCode: pigeon.icManufacturerCode!,
      icSerialNumber: pigeon.icSerialNumber!,
    );
  }

  Future<void> stayQuiet() async {
    return hostApi.iso15693StayQuiet(_tag.handle);
  }

  Future<Uint8List> readSingleBlock({
    required List<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
  }) async {
    return hostApi.iso15693ReadSingleBlock(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList(), blockNumber);
  }

  Future<void> writeSingleBlock({
    required List<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
    required Uint8List dataBlock,
  }) async {
    return hostApi.iso15693WriteSingleBlock(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList(), blockNumber, dataBlock);
  }

  Future<void> lockBlock({
    required List<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
  }) async {
    return hostApi.iso15693LockBlock(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList(), blockNumber);
  }

  Future<List<Uint8List>> readMultipleBlocks({
    required List<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
  }) async {
    return hostApi.iso15693ReadMultipleBlocks(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList(), blockNumber, numberOfBlocks)
      .then((value) => List.from(value));
  }

  Future<void> writeMultipleBlocks({
    required List<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
    required List<Uint8List> dataBlocks,
  }) async {
    return hostApi.iso15693WriteMultipleBlocks(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList(), blockNumber, numberOfBlocks, dataBlocks);
  }

  Future<void> select({
    required List<Iso15693RequestFlag> requestFlags,
  }) async {
    return hostApi.iso15693Select(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList());
  }

  Future<void> resetToReady({
    required List<Iso15693RequestFlag> requestFlags,
  }) async {
    return hostApi.iso15693ResetToReady(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList());
  }

  Future<void> writeAfi({
    required List<Iso15693RequestFlag> requestFlags,
    required int afi,
  }) async {
    return hostApi.iso15693WriteAfi(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList(), afi);
  }

  Future<void> lockAfi({
    required List<Iso15693RequestFlag> requestFlags,
  }) async {
    return hostApi.iso15693LockAfi(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList());
  }

  Future<void> writeDsfId({
    required List<Iso15693RequestFlag> requestFlags,
    required int dsfId,
  }) async {
    return hostApi.iso15693WriteDsfId(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList(), dsfId);
  }

  Future<void> lockDsfId({
    required List<Iso15693RequestFlag> requestFlags,
  }) async {
    return hostApi.iso15693LockDsfId(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList());
  }

  Future<Iso15693SystemInfo> getSystemInfo({
    required List<Iso15693RequestFlag> requestFlags,
  }) async {
    return hostApi.iso15693GetSystemInfo(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList())
      .then((value) => Iso15693SystemInfo(
        applicationFamilyIdentifier: value.applicationFamilyIdentifier!,
        blockSize: value.blockSize!,
        dataStorageFormatIdentifier: value.dataStorageFormatIdentifier!,
        icReference: value.icReference!,
        totalBlocks: value.totalBlocks!,
      ));
  }

  Future<List<int>> getMultipleBlockSecurityStatus({
    required List<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
  }) async {
    return hostApi.iso15693GetMultipleBlockSecurityStatus(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList(), blockNumber, numberOfBlocks)
      .then((value) => List.from(value));
  }

  Future<Uint8List> customCommand({
    required List<Iso15693RequestFlag> requestFlags,
    required int customCommandCode,
    required Uint8List customRequestParameters,
  }) async {
    return hostApi.iso15693CustomCommand(_tag.handle, requestFlags.map(iso15693RequestFlagToPigeon).toList(), customCommandCode, customRequestParameters);
  }
}

class Iso15693SystemInfo {
  const Iso15693SystemInfo({
    required this.applicationFamilyIdentifier,
    required this.blockSize,
    required this.dataStorageFormatIdentifier,
    required this.icReference,
    required this.totalBlocks,
  });

  final int applicationFamilyIdentifier;

  final int blockSize;

  final int dataStorageFormatIdentifier;

  final int icReference;

  final int totalBlocks;
}

enum Iso15693RequestFlag {
  address,

  dualSubCarriers,

  highDataRate,

  option,

  protocolExtension,

  select,
}
