import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

/// Provides access to FeliCa operations for iOS.
///
/// Acquire an instance using [from(NfcTag)].
final class FeliCaIos {
  const FeliCaIos._(
    this._handle, {
    required this.currentSystemCode,
    required this.currentIDm,
  });

  final String _handle;

  // DOC:
  final Uint8List currentSystemCode;

  // DOC:
  final Uint8List currentIDm;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static FeliCaIos? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.feliCa;
    if (data == null || tech == null) return null;
    return FeliCaIos._(
      data.handle,
      currentSystemCode: tech.currentSystemCode,
      currentIDm: tech.currentIDm,
    );
  }

  // DOC:
  Future<FeliCaPollingResponseIos> polling({
    required Uint8List systemCode,
    required FeliCaPollingRequestCodeIos requestCode,
    required FeliCaPollingTimeSlotIos timeSlot,
  }) {
    return hostApi
        .feliCaPolling(
          handle: _handle,
          systemCode: systemCode,
          requestCode: FeliCaPollingRequestCodePigeon.values.byName(
            requestCode.name,
          ),
          timeSlot: FeliCaPollingTimeSlotPigeon.values.byName(timeSlot.name),
        )
        .then(
          (value) => FeliCaPollingResponseIos(
            manufacturerParameter: value.manufacturerParameter,
            requestData: value.requestData,
          ),
        );
  }

  // DOC:
  Future<List<Uint8List>> requestService({
    required List<Uint8List> nodeCodeList,
  }) {
    return hostApi
        .feliCaRequestService(handle: _handle, nodeCodeList: nodeCodeList)
        .then((value) => List.from(value));
  }

  // DOC:
  Future<int> requestResponse() {
    return hostApi.feliCaRequestResponse(handle: _handle);
  }

  // DOC:
  Future<FeliCaReadWithoutEncryptionResponseIos> readWithoutEncryption({
    required List<Uint8List> serviceCodeList,
    required List<Uint8List> blockList,
  }) {
    return hostApi
        .feliCaReadWithoutEncryption(
          handle: _handle,
          serviceCodeList: serviceCodeList,
          blockList: blockList,
        )
        .then(
          (value) => FeliCaReadWithoutEncryptionResponseIos(
            statusFlag1: value.statusFlag1,
            statusFlag2: value.statusFlag2,
            blockData: List.from(value.blockData),
          ),
        );
  }

  // DOC:
  Future<FeliCaStatusFlagIos> writeWithoutEncryption({
    required List<Uint8List> serviceCodeList,
    required List<Uint8List> blockList,
    required List<Uint8List> blockData,
  }) {
    return hostApi
        .feliCaWriteWithoutEncryption(
          handle: _handle,
          serviceCodeList: serviceCodeList,
          blockList: blockList,
          blockData: blockData,
        )
        .then(
          (value) => FeliCaStatusFlagIos(
            statusFlag1: value.statusFlag1,
            statusFlag2: value.statusFlag2,
          ),
        );
  }

  // DOC:
  Future<List<Uint8List>> requestSystemCode() {
    return hostApi
        .feliCaRequestSystemCode(handle: _handle)
        .then((value) => List.from(value));
  }

  // DOC:
  Future<FeliCaRequestServiceV2ResponseIos> requestServiceV2({
    required List<Uint8List> nodeCodeList,
  }) {
    return hostApi
        .feliCaRequestServiceV2(handle: _handle, nodeCodeList: nodeCodeList)
        .then(
          (value) => FeliCaRequestServiceV2ResponseIos(
            statusFlag1: value.statusFlag1,
            statusFlag2: value.statusFlag2,
            encryptionIdentifier: value.encryptionIdentifier,
            nodeKeyVersionListAes: value.nodeKeyVersionListAES != null
                ? List.from(value.nodeKeyVersionListAES!)
                : null,
            nodeKeyVersionListDes: value.nodeKeyVersionListDES != null
                ? List.from(value.nodeKeyVersionListDES!)
                : null,
          ),
        );
  }

  // DOC:
  Future<FeliCaRequestSpecificationVersionResponseIos>
  requestSpecificationVersion() {
    return hostApi
        .feliCaRequestSpecificationVersion(handle: _handle)
        .then(
          (value) => FeliCaRequestSpecificationVersionResponseIos(
            statusFlag1: value.statusFlag1,
            statusFlag2: value.statusFlag2,
            basicVersion: value.basicVersion,
            optionVersion: value.optionVersion,
          ),
        );
  }

  // DOC:
  Future<FeliCaStatusFlagIos> resetMode() {
    return hostApi
        .feliCaResetMode(handle: _handle)
        .then(
          (value) => FeliCaStatusFlagIos(
            statusFlag1: value.statusFlag1,
            statusFlag2: value.statusFlag2,
          ),
        );
  }

  // DOC:
  Future<Uint8List> sendFeliCaCommand({required Uint8List commandPacket}) {
    return hostApi.feliCaSendFeliCaCommand(
      handle: _handle,
      commandPacket: commandPacket,
    );
  }
}

// DOC:
final class FeliCaPollingResponseIos {
  // DOC:
  @visibleForTesting
  const FeliCaPollingResponseIos({
    required this.manufacturerParameter,
    required this.requestData,
  });

  // DOC:
  final Uint8List manufacturerParameter;

  // DOC:
  final Uint8List? requestData;
}

// DOC:
final class FeliCaStatusFlagIos {
  // DOC:
  @visibleForTesting
  const FeliCaStatusFlagIos({
    required this.statusFlag1,
    required this.statusFlag2,
  });

  // DOC:
  final int statusFlag1;

  // DOC:
  final int statusFlag2;
}

// DOC:
final class FeliCaReadWithoutEncryptionResponseIos {
  // DOC:
  @visibleForTesting
  const FeliCaReadWithoutEncryptionResponseIos({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.blockData,
  });

  // DOC:
  final int statusFlag1;

  // DOC:
  final int statusFlag2;

  // DOC:
  final List<Uint8List> blockData;
}

// DOC:
final class FeliCaRequestServiceV2ResponseIos {
  // DOC:
  @visibleForTesting
  const FeliCaRequestServiceV2ResponseIos({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.encryptionIdentifier,
    required this.nodeKeyVersionListAes,
    required this.nodeKeyVersionListDes,
  });

  // DOC:
  final int statusFlag1;

  // DOC:
  final int statusFlag2;

  // DOC:
  final int encryptionIdentifier;

  // DOC:
  final List<Uint8List>? nodeKeyVersionListAes;

  // DOC:
  final List<Uint8List>? nodeKeyVersionListDes;
}

// DOC:
final class FeliCaRequestSpecificationVersionResponseIos {
  // DOC:
  @visibleForTesting
  const FeliCaRequestSpecificationVersionResponseIos({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.basicVersion,
    required this.optionVersion,
  });

  // DOC:
  final int statusFlag1;

  // DOC:
  final int statusFlag2;

  // DOC:
  final Uint8List? basicVersion;

  // DOC:
  final Uint8List? optionVersion;
}

// DOC:
enum FeliCaPollingRequestCodeIos {
  // DOC:
  noRequest,

  // DOC:
  systemCode,

  // DOC:
  communicationPerformance,
}

// DOC:
enum FeliCaPollingTimeSlotIos {
  // DOC:
  max1,

  // DOC:
  max2,

  // DOC:
  max4,

  // DOC:
  max8,

  // DOC:
  max16,
}
