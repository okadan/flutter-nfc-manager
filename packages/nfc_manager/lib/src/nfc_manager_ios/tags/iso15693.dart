import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

/// The class providing access to ISO 15693 operations for iOS.
///
/// Acquire an instance using [from(NfcTag)].
final class Iso15693Ios {
  const Iso15693Ios._(
    this._handle, {
    required this.identifier,
    required this.icManufacturerCode,
    required this.icSerialNumber,
  });

  final String _handle;

  // TODO: DOC
  final Uint8List identifier;

  // TODO: DOC
  final int icManufacturerCode;

  // TODO: DOC
  final Uint8List icSerialNumber;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static Iso15693Ios? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.iso15693;
    if (data == null || tech == null) return null;
    return Iso15693Ios._(
      data.handle,
      identifier: tech.identifier,
      icManufacturerCode: tech.icManufacturerCode,
      icSerialNumber: tech.icSerialNumber,
    );
  }

  // TODO: DOC
  Future<void> stayQuiet() {
    return hostApi.iso15693StayQuiet(handle: _handle);
  }

  // TODO: DOC
  Future<Uint8List> readSingleBlock({
    required Set<Iso15693RequestFlagIos> requestFlags,
    required int blockNumber,
  }) {
    return hostApi.iso15693ReadSingleBlock(
      handle: _handle,
      requestFlags:
          requestFlags
              .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
              .toList(),
      blockNumber: blockNumber,
    );
  }

  // TODO: DOC
  Future<void> writeSingleBlock({
    required Set<Iso15693RequestFlagIos> requestFlags,
    required int blockNumber,
    required Uint8List dataBlock,
  }) {
    return hostApi.iso15693WriteSingleBlock(
      handle: _handle,
      requestFlags:
          requestFlags
              .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
              .toList(),
      blockNumber: blockNumber,
      dataBlock: dataBlock,
    );
  }

  // TODO: DOC
  Future<void> lockBlock({
    required Set<Iso15693RequestFlagIos> requestFlags,
    required int blockNumber,
  }) {
    return hostApi.iso15693LockBlock(
      handle: _handle,
      requestFlags:
          requestFlags
              .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
              .toList(),
      blockNumber: blockNumber,
    );
  }

  // TODO: DOC
  Future<List<Uint8List>> readMultipleBlocks({
    required Set<Iso15693RequestFlagIos> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
  }) {
    return hostApi
        .iso15693ReadMultipleBlocks(
          handle: _handle,
          requestFlags:
              requestFlags
                  .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
                  .toList(),
          blockNumber: blockNumber,
          numberOfBlocks: numberOfBlocks,
        )
        .then((value) => List.from(value));
  }

  // TODO: DOC
  Future<void> writeMultipleBlocks({
    required Set<Iso15693RequestFlagIos> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
    required List<Uint8List> dataBlocks,
  }) {
    return hostApi.iso15693WriteMultipleBlocks(
      handle: _handle,
      requestFlags:
          requestFlags
              .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
              .toList(),
      blockNumber: blockNumber,
      numberOfBlocks: numberOfBlocks,
      dataBlocks: dataBlocks,
    );
  }

  // TODO: DOC
  Future<void> select({required Set<Iso15693RequestFlagIos> requestFlags}) {
    return hostApi.iso15693Select(
      handle: _handle,
      requestFlags:
          requestFlags
              .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
              .toList(),
    );
  }

  // TODO: DOC
  Future<void> resetToReady({
    required Set<Iso15693RequestFlagIos> requestFlags,
  }) {
    return hostApi.iso15693ResetToReady(
      handle: _handle,
      requestFlags:
          requestFlags
              .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
              .toList(),
    );
  }

  // TODO: DOC
  Future<void> writeAfi({
    required Set<Iso15693RequestFlagIos> requestFlags,
    required int afi,
  }) {
    return hostApi.iso15693WriteAfi(
      handle: _handle,
      requestFlags:
          requestFlags
              .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
              .toList(),
      afi: afi,
    );
  }

  // TODO: DOC
  Future<void> lockAfi({required Set<Iso15693RequestFlagIos> requestFlags}) {
    return hostApi.iso15693LockAfi(
      handle: _handle,
      requestFlags:
          requestFlags
              .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
              .toList(),
    );
  }

  // TODO: DOC
  Future<void> writeDsfId({
    required Set<Iso15693RequestFlagIos> requestFlags,
    required int dsfId,
  }) {
    return hostApi.iso15693WriteDsfId(
      handle: _handle,
      requestFlags:
          requestFlags
              .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
              .toList(),
      dsfId: dsfId,
    );
  }

  // TODO: DOC
  Future<void> lockDsfId({required Set<Iso15693RequestFlagIos> requestFlags}) {
    return hostApi.iso15693LockDsfId(
      handle: _handle,
      requestFlags:
          requestFlags
              .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
              .toList(),
    );
  }

  // TODO: DOC
  Future<Iso15693SystemInfoIos> getSystemInfo({
    required Set<Iso15693RequestFlagIos> requestFlags,
  }) {
    return hostApi
        .iso15693GetSystemInfo(
          handle: _handle,
          requestFlags:
              requestFlags
                  .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
                  .toList(),
        )
        .then(
          (value) => Iso15693SystemInfoIos(
            applicationFamilyIdentifier: value.applicationFamilyIdentifier,
            blockSize: value.blockSize,
            dataStorageFormatIdentifier: value.dataStorageFormatIdentifier,
            icReference: value.icReference,
            totalBlocks: value.totalBlocks,
          ),
        );
  }

  // TODO: DOC
  Future<List<int>> getMultipleBlockSecurityStatus({
    required Set<Iso15693RequestFlagIos> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
  }) {
    return hostApi
        .iso15693GetMultipleBlockSecurityStatus(
          handle: _handle,
          requestFlags:
              requestFlags
                  .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
                  .toList(),
          blockNumber: blockNumber,
          numberOfBlocks: numberOfBlocks,
        )
        .then((value) => List.from(value));
  }

  // TODO: DOC
  Future<Uint8List> customCommand({
    required Set<Iso15693RequestFlagIos> requestFlags,
    required int customCommandCode,
    required Uint8List customRequestParameters,
  }) {
    return hostApi.iso15693CustomCommand(
      handle: _handle,
      requestFlags:
          requestFlags
              .map((e) => Iso15693RequestFlagPigeon.values.byName(e.name))
              .toList(),
      customCommandCode: customCommandCode,
      customRequestParameters: customRequestParameters,
    );
  }
}

// TODO: DOC
// TODO: Add [NFCISO15693SystemInfo.uniqueIdentifier](https://developer.apple.com/documentation/corenfc/nfciso15693systeminfo/3585154-uniqueidentifier). This can be now used with iOS 14.0 or later.
final class Iso15693SystemInfoIos {
  // TODO: DOC
  @visibleForTesting
  const Iso15693SystemInfoIos({
    required this.applicationFamilyIdentifier,
    required this.blockSize,
    required this.dataStorageFormatIdentifier,
    required this.icReference,
    required this.totalBlocks,
  });

  // TODO: DOC
  final int applicationFamilyIdentifier;

  // TODO: DOC
  final int blockSize;

  // TODO: DOC
  final int dataStorageFormatIdentifier;

  // TODO: DOC
  final int icReference;

  // TODO: DOC
  final int totalBlocks;
}

// TODO: DOC
// TODO: Add [NFCISO15693RequestFlag.commandSpecificBit8](https://developer.apple.com/documentation/corenfc/nfciso15693requestflag/3551911-commandspecificbit8). This can be now used with iOS 14.0 or later.
enum Iso15693RequestFlagIos {
  // TODO: DOC
  address,

  // TODO: DOC
  dualSubCarriers,

  // TODO: DOC
  highDataRate,

  // TODO: DOC
  option,

  // TODO: DOC
  protocolExtension,

  // TODO: DOC
  select,
}
