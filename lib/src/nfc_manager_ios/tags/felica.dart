import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

class FeliCaIOS {
  const FeliCaIOS(this._tag, {
    required this.currentSystemCode,
    required this.currentIDm,
  });

  final NfcTag _tag;

  final Uint8List currentSystemCode;

  final Uint8List currentIDm;

  static FeliCaIOS? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).feliCa;
    return pigeon == null ? null : FeliCaIOS(
      tag,
      currentSystemCode: pigeon.currentSystemCode!,
      currentIDm: pigeon.currentIDm!,
    );
  }

  Future<FeliCaPollingResponse> polling({
    required Uint8List systemCode,
    required FeliCaPollingRequestCode requestCode,
    required FeliCaPollingTimeSlot timeSlot,
  }) async {
    return hostApi.feliCaPolling(_tag.handle, systemCode, feliCaPollingRequestCodeToPigeon(requestCode), feliCaPollingTimeSlotToPigeon(timeSlot))
      .then((value) => FeliCaPollingResponse(
        manufacturerParameter: value.manufacturerParameter!,
        requestData: value.requestData!,
      ));
  }

  Future<List<Uint8List>> requestService({
    required List<Uint8List> nodeCodeList,
  }) async {
    return hostApi.feliCaRequestService(_tag.handle, nodeCodeList)
      .then((value) => List.from(value));
  }

  Future<int> requestResponse() async {
    return hostApi.feliCaRequestResponse(_tag.handle);
  }

  Future<FeliCaReadWithoutEncryptionResponse> readWithoutEncryption({
    required List<Uint8List> serviceCodeList,
    required List<Uint8List> blockList,
  }) async {
    return hostApi.feliCaReadWithoutEncryption(_tag.handle, serviceCodeList, blockList)
      .then((value) => FeliCaReadWithoutEncryptionResponse(
        statusFlag1: value.statusFlag1!,
        statusFlag2: value.statusFlag2!,
        blockData: List.from(value.blockData!),
      ));
  }

  Future<FeliCaStatusFlag> writeWithoutEncryption({
    required List<Uint8List> serviceCodeList,
    required List<Uint8List> blockList,
    required List<Uint8List> blockData,
  }) async {
    return hostApi.feliCaWriteWithoutEncryption(_tag.handle, serviceCodeList, blockList, blockData)
      .then((value) => FeliCaStatusFlag(
        statusFlag1: value.statusFlag1!,
        statusFlag2: value.statusFlag2!,
      ));
  }

  Future<List<Uint8List>> requestSystemCode() async {
    return hostApi.feliCaRequestSystemCode(_tag.handle).then((value) => List.from(value));
  }

  Future<FeliCaRequestServiceV2Response> requestServiceV2({
    required List<Uint8List> nodeCodeList,
  }) async {
    return hostApi.feliCaRequestServiceV2(_tag.handle, nodeCodeList)
      .then((value) => FeliCaRequestServiceV2Response(
        statusFlag1: value.statusFlag1!,
        statusFlag2: value.statusFlag2!,
        encryptionIdentifier: value.encryptionIdentifier!,
        nodeKeyVersionListAes: List.from(value.nodeKeyVersionListAES!),
        nodeKeyVersionListDes: List.from(value.nodeKeyVersionListDES!),
      ));
  }

  Future<FeliCaRequestSpecificationVersionResponse> requestSpecificationVersion() async {
    return hostApi.feliCaRequestSpecificationVersion(_tag.handle)
      .then((value) => FeliCaRequestSpecificationVersionResponse(
        statusFlag1: value.statusFlag1!,
        statusFlag2: value.statusFlag2!,
        basicVersion: value.basicVersion!,
        optionVersion: value.optionVersion!,
      ));
  }

  Future<FeliCaStatusFlag> resetMode() async {
    return hostApi.feliCaResetMode(_tag.handle)
      .then((value) => FeliCaStatusFlag(
        statusFlag1: value.statusFlag1!,
        statusFlag2: value.statusFlag2!,
      ));
  }

  Future<Uint8List> sendFeliCaCommand({
      required Uint8List commandPacket,
    }) async {
    return hostApi.feliCaSendFeliCaCommand(_tag.handle, commandPacket);
  }
}

enum FeliCaPollingRequestCode {
  noRequest,

  systemCode,

  communicationPerformance,
}

enum FeliCaPollingTimeSlot {
  max1,

  max2,

  max4,

  max8,

  max16,
}

class FeliCaPollingResponse {
  const FeliCaPollingResponse({
    required this.manufacturerParameter,
    required this.requestData,
  });

  final Uint8List manufacturerParameter;

  final Uint8List requestData;
}

class FeliCaStatusFlag {
  const FeliCaStatusFlag({
    required this.statusFlag1,
    required this.statusFlag2,
  });

  final int statusFlag1;

  final int statusFlag2;
}

class FeliCaReadWithoutEncryptionResponse {
  const FeliCaReadWithoutEncryptionResponse({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.blockData,
  });

  final int statusFlag1;

  final int statusFlag2;

  final List<Uint8List> blockData;
}

class FeliCaRequestServiceV2Response {
  const FeliCaRequestServiceV2Response({
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

class FeliCaRequestSpecificationVersionResponse {
  const FeliCaRequestSpecificationVersionResponse({
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
