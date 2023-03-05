import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

/// The class providing access to FeliCa operations for iOS.
///
/// Acquire an instance using [from(NfcTag)].
final class FeliCaIos {
  const FeliCaIos._(
    this._handle, {
    required this.currentSystemCode,
    required this.currentIDm,
  });

  final String _handle;

  // TODO: DOC
  final Uint8List currentSystemCode;

  // TODO: DOC
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

  // TODO: DOC
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

  // TODO: DOC
  Future<List<Uint8List>> requestService({
    required List<Uint8List> nodeCodeList,
  }) {
    return hostApi
        .feliCaRequestService(handle: _handle, nodeCodeList: nodeCodeList)
        .then((value) => List.from(value));
  }

  // TODO: DOC
  Future<int> requestResponse() {
    return hostApi.feliCaRequestResponse(handle: _handle);
  }

  // TODO: DOC
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

  // TODO: DOC
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

  // TODO: DOC
  Future<List<Uint8List>> requestSystemCode() {
    return hostApi
        .feliCaRequestSystemCode(handle: _handle)
        .then((value) => List.from(value));
  }

  // TODO: DOC
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
            nodeKeyVersionListAes:
                value.nodeKeyVersionListAES != null
                    ? List.from(value.nodeKeyVersionListAES!)
                    : null,
            nodeKeyVersionListDes:
                value.nodeKeyVersionListDES != null
                    ? List.from(value.nodeKeyVersionListDES!)
                    : null,
          ),
        );
  }

  // TODO: DOC
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

  // TODO: DOC
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

  // TODO: DOC
  Future<Uint8List> sendFeliCaCommand({required Uint8List commandPacket}) {
    return hostApi.feliCaSendFeliCaCommand(
      handle: _handle,
      commandPacket: commandPacket,
    );
  }
}

// TODO: DOC
final class FeliCaPollingResponseIos {
  // TODO: DOC
  @visibleForTesting
  const FeliCaPollingResponseIos({
    required this.manufacturerParameter,
    required this.requestData,
  });

  // TODO: DOC
  final Uint8List manufacturerParameter;

  // TODO: DOC
  final Uint8List? requestData;
}

// TODO: DOC
final class FeliCaStatusFlagIos {
  // TODO: DOC
  @visibleForTesting
  const FeliCaStatusFlagIos({
    required this.statusFlag1,
    required this.statusFlag2,
  });

  // TODO: DOC
  final int statusFlag1;

  // TODO: DOC
  final int statusFlag2;
}

// TODO: DOC
final class FeliCaReadWithoutEncryptionResponseIos {
  // TODO: DOC
  @visibleForTesting
  const FeliCaReadWithoutEncryptionResponseIos({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.blockData,
  });

  // TODO: DOC
  final int statusFlag1;

  // TODO: DOC
  final int statusFlag2;

  // TODO: DOC
  final List<Uint8List> blockData;
}

// TODO: DOC
final class FeliCaRequestServiceV2ResponseIos {
  // TODO: DOC
  @visibleForTesting
  const FeliCaRequestServiceV2ResponseIos({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.encryptionIdentifier,
    required this.nodeKeyVersionListAes,
    required this.nodeKeyVersionListDes,
  });

  // TODO: DOC
  final int statusFlag1;

  // TODO: DOC
  final int statusFlag2;

  // TODO: DOC
  final int encryptionIdentifier;

  // TODO: DOC
  final List<Uint8List>? nodeKeyVersionListAes;

  // TODO: DOC
  final List<Uint8List>? nodeKeyVersionListDes;
}

// TODO: DOC
final class FeliCaRequestSpecificationVersionResponseIos {
  // TODO: DOC
  @visibleForTesting
  const FeliCaRequestSpecificationVersionResponseIos({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.basicVersion,
    required this.optionVersion,
  });

  // TODO: DOC
  final int statusFlag1;

  // TODO: DOC
  final int statusFlag2;

  // TODO: DOC
  final Uint8List? basicVersion;

  // TODO: DOC
  final Uint8List? optionVersion;
}

// TODO: DOC
enum FeliCaPollingRequestCodeIos {
  // TODO: DOC
  noRequest,

  // TODO: DOC
  systemCode,

  // TODO: DOC
  communicationPerformance,
}

// TODO: DOC
enum FeliCaPollingTimeSlotIos {
  // TODO: DOC
  max1,

  // TODO: DOC
  max2,

  // TODO: DOC
  max4,

  // TODO: DOC
  max8,

  // TODO: DOC
  max16,
}
