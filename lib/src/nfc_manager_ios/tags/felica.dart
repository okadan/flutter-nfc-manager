import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

/// The class providing access to FeliCa operations for iOS.
///
/// Acquire an instance using [from(NfcTag)].
final class FeliCaIOS {
  const FeliCaIOS._(
    this._handle, {
    required this.currentSystemCode,
    required this.currentIDm,
  });

  final String _handle;

  /// DOC:
  final Uint8List currentSystemCode;

  /// DOC:
  final Uint8List currentIDm;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static FeliCaIOS? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as PigeonTag?;
    final tech = data?.feliCa;
    if (data == null || tech == null) return null;
    return FeliCaIOS._(
      data.handle,
      currentSystemCode: tech.currentSystemCode,
      currentIDm: tech.currentIDm,
    );
  }

  /// DOC:
  Future<FeliCaPollingResponseIOS> polling({
    required Uint8List systemCode,
    required FeliCaPollingRequestCodeIOS requestCode,
    required FeliCaPollingTimeSlotIOS timeSlot,
  }) {
    return hostApi
        .feliCaPolling(
          handle: _handle,
          systemCode: systemCode,
          requestCode: PigeonFeliCaPollingRequestCode.values.byName(
            requestCode.name,
          ),
          timeSlot: PigeonFeliCaPollingTimeSlot.values.byName(
            timeSlot.name,
          ),
        )
        .then((value) => FeliCaPollingResponseIOS(
              manufacturerParameter: value.manufacturerParameter,
              requestData: value.requestData,
            ));
  }

  /// DOC:
  Future<List<Uint8List>> requestService({
    required List<Uint8List> nodeCodeList,
  }) {
    return hostApi
        .feliCaRequestService(
          handle: _handle,
          nodeCodeList: nodeCodeList,
        )
        .then((value) => List.from(value));
  }

  /// DOC:
  Future<int> requestResponse() {
    return hostApi.feliCaRequestResponse(
      handle: _handle,
    );
  }

  /// DOC:
  Future<FeliCaReadWithoutEncryptionResponseIOS> readWithoutEncryption({
    required List<Uint8List> serviceCodeList,
    required List<Uint8List> blockList,
  }) {
    return hostApi
        .feliCaReadWithoutEncryption(
          handle: _handle,
          serviceCodeList: serviceCodeList,
          blockList: blockList,
        )
        .then((value) => FeliCaReadWithoutEncryptionResponseIOS(
              statusFlag1: value.statusFlag1,
              statusFlag2: value.statusFlag2,
              blockData: List.from(value.blockData),
            ));
  }

  /// DOC:
  Future<FeliCaStatusFlagIOS> writeWithoutEncryption({
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
        .then((value) => FeliCaStatusFlagIOS(
              statusFlag1: value.statusFlag1,
              statusFlag2: value.statusFlag2,
            ));
  }

  /// DOC:
  Future<List<Uint8List>> requestSystemCode() {
    return hostApi
        .feliCaRequestSystemCode(
          handle: _handle,
        )
        .then((value) => List.from(value));
  }

  /// DOC:
  Future<FeliCaRequestServiceV2ResponseIOS> requestServiceV2({
    required List<Uint8List> nodeCodeList,
  }) {
    return hostApi
        .feliCaRequestServiceV2(
          handle: _handle,
          nodeCodeList: nodeCodeList,
        )
        .then((value) => FeliCaRequestServiceV2ResponseIOS(
              statusFlag1: value.statusFlag1,
              statusFlag2: value.statusFlag2,
              encryptionIdentifier: value.encryptionIdentifier,
              nodeKeyVersionListAes: List.from(value.nodeKeyVersionListAES),
              nodeKeyVersionListDes: List.from(value.nodeKeyVersionListDES),
            ));
  }

  /// DOC:
  Future<FeliCaRequestSpecificationVersionResponseIOS>
      requestSpecificationVersion() {
    return hostApi
        .feliCaRequestSpecificationVersion(
          handle: _handle,
        )
        .then((value) => FeliCaRequestSpecificationVersionResponseIOS(
              statusFlag1: value.statusFlag1,
              statusFlag2: value.statusFlag2,
              basicVersion: value.basicVersion,
              optionVersion: value.optionVersion,
            ));
  }

  /// DOC:
  Future<FeliCaStatusFlagIOS> resetMode() {
    return hostApi
        .feliCaResetMode(
          handle: _handle,
        )
        .then((value) => FeliCaStatusFlagIOS(
              statusFlag1: value.statusFlag1,
              statusFlag2: value.statusFlag2,
            ));
  }

  /// DOC:
  Future<Uint8List> sendFeliCaCommand({
    required Uint8List commandPacket,
  }) {
    return hostApi.feliCaSendFeliCaCommand(
      handle: _handle,
      commandPacket: commandPacket,
    );
  }
}

/// DOC:
enum FeliCaPollingRequestCodeIOS {
  /// DOC:
  noRequest,

  /// DOC:
  systemCode,

  /// DOC:
  communicationPerformance,
}

/// DOC:
enum FeliCaPollingTimeSlotIOS {
  /// DOC:
  max1,

  /// DOC:
  max2,

  /// DOC:
  max4,

  /// DOC:
  max8,

  /// DOC:
  max16,
}

/// DOC:
final class FeliCaPollingResponseIOS {
  /// DOC:
  @visibleForTesting
  const FeliCaPollingResponseIOS({
    required this.manufacturerParameter,
    required this.requestData,
  });

  /// DOC:
  final Uint8List manufacturerParameter;

  /// DOC:
  final Uint8List requestData;
}

/// DOC:
final class FeliCaStatusFlagIOS {
  /// DOC:
  @visibleForTesting
  const FeliCaStatusFlagIOS({
    required this.statusFlag1,
    required this.statusFlag2,
  });

  /// DOC:
  final int statusFlag1;

  /// DOC:
  final int statusFlag2;
}

/// DOC:
final class FeliCaReadWithoutEncryptionResponseIOS {
  /// DOC:
  @visibleForTesting
  const FeliCaReadWithoutEncryptionResponseIOS({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.blockData,
  });

  /// DOC:
  final int statusFlag1;

  /// DOC:
  final int statusFlag2;

  /// DOC:
  final List<Uint8List> blockData;
}

/// DOC:
final class FeliCaRequestServiceV2ResponseIOS {
  /// DOC:
  @visibleForTesting
  const FeliCaRequestServiceV2ResponseIOS({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.encryptionIdentifier,
    required this.nodeKeyVersionListAes,
    required this.nodeKeyVersionListDes,
  });

  /// DOC:
  final int statusFlag1;

  /// DOC:
  final int statusFlag2;

  /// DOC:
  final int encryptionIdentifier;

  /// DOC:
  final List<Uint8List> nodeKeyVersionListAes;

  /// DOC:
  final List<Uint8List> nodeKeyVersionListDes;
}

/// DOC:
final class FeliCaRequestSpecificationVersionResponseIOS {
  /// DOC:
  @visibleForTesting
  const FeliCaRequestSpecificationVersionResponseIOS({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.basicVersion,
    required this.optionVersion,
  });

  /// DOC:
  final int statusFlag1;

  /// DOC:
  final int statusFlag2;

  /// DOC:
  final Uint8List basicVersion;

  /// DOC:
  final Uint8List optionVersion;
}
