import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

/// The class providing access to FeliCa operations for iOS.
///
/// Acquire an instance using [from(NfcTag)].
class FeliCaIOS {
  const FeliCaIOS._(
    this._handle, {
    required this.currentSystemCode,
    required this.currentIDm,
  });

  final String _handle;

  final Uint8List currentSystemCode;

  final Uint8List currentIDm;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static FeliCaIOS? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).feliCa;
    return pigeon == null
        ? null
        : FeliCaIOS._(
            tag.handle,
            currentSystemCode: pigeon.currentSystemCode!,
            currentIDm: pigeon.currentIDm!,
          );
  }

  Future<FeliCaPollingResponseIOS> polling({
    required Uint8List systemCode,
    required FeliCaPollingRequestCodeIOS requestCode,
    required FeliCaPollingTimeSlotIOS timeSlot,
  }) {
    return hostApi
        .feliCaPolling(
            _handle,
            systemCode,
            feliCaPollingRequestCodeToPigeon(requestCode),
            feliCaPollingTimeSlotToPigeon(timeSlot))
        .then((value) => FeliCaPollingResponseIOS(
              manufacturerParameter: value.manufacturerParameter!,
              requestData: value.requestData!,
            ));
  }

  Future<List<Uint8List>> requestService({
    required List<Uint8List> nodeCodeList,
  }) {
    return hostApi
        .feliCaRequestService(_handle, nodeCodeList)
        .then((value) => List.from(value));
  }

  Future<int> requestResponse() {
    return hostApi.feliCaRequestResponse(_handle);
  }

  Future<FeliCaReadWithoutEncryptionResponseIOS> readWithoutEncryption({
    required List<Uint8List> serviceCodeList,
    required List<Uint8List> blockList,
  }) {
    return hostApi
        .feliCaReadWithoutEncryption(_handle, serviceCodeList, blockList)
        .then((value) => FeliCaReadWithoutEncryptionResponseIOS(
              statusFlag1: value.statusFlag1!,
              statusFlag2: value.statusFlag2!,
              blockData: List.from(value.blockData!),
            ));
  }

  Future<FeliCaStatusFlagIOS> writeWithoutEncryption({
    required List<Uint8List> serviceCodeList,
    required List<Uint8List> blockList,
    required List<Uint8List> blockData,
  }) {
    return hostApi
        .feliCaWriteWithoutEncryption(
            _handle, serviceCodeList, blockList, blockData)
        .then((value) => FeliCaStatusFlagIOS(
              statusFlag1: value.statusFlag1!,
              statusFlag2: value.statusFlag2!,
            ));
  }

  Future<List<Uint8List>> requestSystemCode() {
    return hostApi
        .feliCaRequestSystemCode(_handle)
        .then((value) => List.from(value));
  }

  Future<FeliCaRequestServiceV2ResponseIOS> requestServiceV2({
    required List<Uint8List> nodeCodeList,
  }) {
    return hostApi
        .feliCaRequestServiceV2(_handle, nodeCodeList)
        .then((value) => FeliCaRequestServiceV2ResponseIOS(
              statusFlag1: value.statusFlag1!,
              statusFlag2: value.statusFlag2!,
              encryptionIdentifier: value.encryptionIdentifier!,
              nodeKeyVersionListAes: List.from(value.nodeKeyVersionListAES!),
              nodeKeyVersionListDes: List.from(value.nodeKeyVersionListDES!),
            ));
  }

  Future<FeliCaRequestSpecificationVersionResponseIOS>
      requestSpecificationVersion() {
    return hostApi
        .feliCaRequestSpecificationVersion(_handle)
        .then((value) => FeliCaRequestSpecificationVersionResponseIOS(
              statusFlag1: value.statusFlag1!,
              statusFlag2: value.statusFlag2!,
              basicVersion: value.basicVersion!,
              optionVersion: value.optionVersion!,
            ));
  }

  Future<FeliCaStatusFlagIOS> resetMode() {
    return hostApi.feliCaResetMode(_handle).then((value) => FeliCaStatusFlagIOS(
          statusFlag1: value.statusFlag1!,
          statusFlag2: value.statusFlag2!,
        ));
  }

  Future<Uint8List> sendFeliCaCommand({
    required Uint8List commandPacket,
  }) {
    return hostApi.feliCaSendFeliCaCommand(_handle, commandPacket);
  }
}

enum FeliCaPollingRequestCodeIOS {
  noRequest,

  systemCode,

  communicationPerformance,
}

enum FeliCaPollingTimeSlotIOS {
  max1,

  max2,

  max4,

  max8,

  max16,
}

class FeliCaPollingResponseIOS {
  const FeliCaPollingResponseIOS({
    required this.manufacturerParameter,
    required this.requestData,
  });

  final Uint8List manufacturerParameter;

  final Uint8List requestData;
}

class FeliCaStatusFlagIOS {
  const FeliCaStatusFlagIOS({
    required this.statusFlag1,
    required this.statusFlag2,
  });

  final int statusFlag1;

  final int statusFlag2;
}

class FeliCaReadWithoutEncryptionResponseIOS {
  const FeliCaReadWithoutEncryptionResponseIOS({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.blockData,
  });

  final int statusFlag1;

  final int statusFlag2;

  final List<Uint8List> blockData;
}

class FeliCaRequestServiceV2ResponseIOS {
  const FeliCaRequestServiceV2ResponseIOS({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.encryptionIdentifier,
    required this.nodeKeyVersionListAes,
    required this.nodeKeyVersionListDes,
  });

  final int statusFlag1;

  final int statusFlag2;

  final int encryptionIdentifier;

  final List<Uint8List> nodeKeyVersionListAes;

  final List<Uint8List> nodeKeyVersionListDes;
}

class FeliCaRequestSpecificationVersionResponseIOS {
  const FeliCaRequestSpecificationVersionResponseIOS({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.basicVersion,
    required this.optionVersion,
  });

  final int statusFlag1;

  final int statusFlag2;

  final Uint8List basicVersion;

  final Uint8List optionVersion;
}
