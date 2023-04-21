import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

/// The class providing access to ISO 15693 operations for iOS.
///
/// Acquire an instance using [from(NfcTag)].
class Iso15693IOS {
  const Iso15693IOS._(
    this._handle, {
    required this.icManufacturerCode,
    required this.icSerialNumber,
  });

  final String _handle;

  final int icManufacturerCode;

  final Uint8List icSerialNumber;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static Iso15693IOS? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).iso15693;
    return pigeon == null
        ? null
        : Iso15693IOS._(
            tag.handle,
            icManufacturerCode: pigeon.icManufacturerCode!,
            icSerialNumber: pigeon.icSerialNumber!,
          );
  }

  Future<void> stayQuiet() {
    return hostApi.iso15693StayQuiet(_handle);
  }

  Future<Uint8List> readSingleBlock({
    required List<Iso15693RequestFlagIOS> requestFlags,
    required int blockNumber,
  }) {
    return hostApi.iso15693ReadSingleBlock(_handle,
        requestFlags.map(iso15693RequestFlagToPigeon).toList(), blockNumber);
  }

  Future<void> writeSingleBlock({
    required List<Iso15693RequestFlagIOS> requestFlags,
    required int blockNumber,
    required Uint8List dataBlock,
  }) {
    return hostApi.iso15693WriteSingleBlock(
        _handle,
        requestFlags.map(iso15693RequestFlagToPigeon).toList(),
        blockNumber,
        dataBlock);
  }

  Future<void> lockBlock({
    required List<Iso15693RequestFlagIOS> requestFlags,
    required int blockNumber,
  }) {
    return hostApi.iso15693LockBlock(_handle,
        requestFlags.map(iso15693RequestFlagToPigeon).toList(), blockNumber);
  }

  Future<List<Uint8List>> readMultipleBlocks({
    required List<Iso15693RequestFlagIOS> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
  }) {
    return hostApi
        .iso15693ReadMultipleBlocks(
            _handle,
            requestFlags.map(iso15693RequestFlagToPigeon).toList(),
            blockNumber,
            numberOfBlocks)
        .then((value) => List.from(value));
  }

  Future<void> writeMultipleBlocks({
    required List<Iso15693RequestFlagIOS> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
    required List<Uint8List> dataBlocks,
  }) {
    return hostApi.iso15693WriteMultipleBlocks(
        _handle,
        requestFlags.map(iso15693RequestFlagToPigeon).toList(),
        blockNumber,
        numberOfBlocks,
        dataBlocks);
  }

  Future<void> select({
    required List<Iso15693RequestFlagIOS> requestFlags,
  }) {
    return hostApi.iso15693Select(
        _handle, requestFlags.map(iso15693RequestFlagToPigeon).toList());
  }

  Future<void> resetToReady({
    required List<Iso15693RequestFlagIOS> requestFlags,
  }) {
    return hostApi.iso15693ResetToReady(
        _handle, requestFlags.map(iso15693RequestFlagToPigeon).toList());
  }

  Future<void> writeAfi({
    required List<Iso15693RequestFlagIOS> requestFlags,
    required int afi,
  }) {
    return hostApi.iso15693WriteAfi(
        _handle, requestFlags.map(iso15693RequestFlagToPigeon).toList(), afi);
  }

  Future<void> lockAfi({
    required List<Iso15693RequestFlagIOS> requestFlags,
  }) {
    return hostApi.iso15693LockAfi(
        _handle, requestFlags.map(iso15693RequestFlagToPigeon).toList());
  }

  Future<void> writeDsfId({
    required List<Iso15693RequestFlagIOS> requestFlags,
    required int dsfId,
  }) {
    return hostApi.iso15693WriteDsfId(
        _handle, requestFlags.map(iso15693RequestFlagToPigeon).toList(), dsfId);
  }

  Future<void> lockDsfId({
    required List<Iso15693RequestFlagIOS> requestFlags,
  }) {
    return hostApi.iso15693LockDsfId(
        _handle, requestFlags.map(iso15693RequestFlagToPigeon).toList());
  }

  Future<Iso15693SystemInfoIOS> getSystemInfo({
    required List<Iso15693RequestFlagIOS> requestFlags,
  }) {
    return hostApi
        .iso15693GetSystemInfo(
            _handle, requestFlags.map(iso15693RequestFlagToPigeon).toList())
        .then((value) => Iso15693SystemInfoIOS(
              applicationFamilyIdentifier: value.applicationFamilyIdentifier!,
              blockSize: value.blockSize!,
              dataStorageFormatIdentifier: value.dataStorageFormatIdentifier!,
              icReference: value.icReference!,
              totalBlocks: value.totalBlocks!,
            ));
  }

  Future<List<int>> getMultipleBlockSecurityStatus({
    required List<Iso15693RequestFlagIOS> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
  }) {
    return hostApi
        .iso15693GetMultipleBlockSecurityStatus(
            _handle,
            requestFlags.map(iso15693RequestFlagToPigeon).toList(),
            blockNumber,
            numberOfBlocks)
        .then((value) => List.from(value));
  }

  Future<Uint8List> customCommand({
    required List<Iso15693RequestFlagIOS> requestFlags,
    required int customCommandCode,
    required Uint8List customRequestParameters,
  }) {
    return hostApi.iso15693CustomCommand(
        _handle,
        requestFlags.map(iso15693RequestFlagToPigeon).toList(),
        customCommandCode,
        customRequestParameters);
  }
}

class Iso15693SystemInfoIOS {
  const Iso15693SystemInfoIOS({
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

enum Iso15693RequestFlagIOS {
  address,

  dualSubCarriers,

  highDataRate,

  option,

  protocolExtension,

  select,
}
