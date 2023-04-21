import 'dart:typed_data';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_felica/felica.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/felica.dart';

class FeliCaPlatformIOS extends FeliCa {
  FeliCaPlatformIOS._(this._tech);

  final FeliCaIOS _tech;

  static FeliCaPlatformIOS? from(NfcTag tag) {
    final tech = FeliCaIOS.from(tag);
    return tech == null ? null : FeliCaPlatformIOS._(tech);
  }

  @override
  Future<FeliCaPollingResponse> polling(
      {required Uint8List systemCode,
      required FeliCaPollingRequestCode requestCode,
      required FeliCaPollingTimeSlot timeSlot}) {
    return _tech
        .polling(
            systemCode: systemCode,
            requestCode: _getFeliCaPollingRequestCodeIOS(requestCode),
            timeSlot: _getFeliCaPollingTimeSlotIOS(timeSlot))
        .then((value) => FeliCaPollingResponse(
              pmm: value.manufacturerParameter,
              requestData: value.requestData,
            ));
  }

  @override
  Future<List<Uint8List>> requestService(
      {required List<Uint8List> nodeCodeList}) {
    return _tech.requestService(nodeCodeList: nodeCodeList);
  }

  @override
  Future<int> requestResponse() {
    return _tech.requestResponse();
  }

  @override
  Future<FeliCaReadWithoutEncryptionResponse> readWithoutEncryption(
      {required List<Uint8List> serviceCodeList,
      required List<Uint8List> blockList}) {
    return _tech
        .readWithoutEncryption(
            serviceCodeList: serviceCodeList, blockList: blockList)
        .then((value) => FeliCaReadWithoutEncryptionResponse(
              statusFlag1: value.statusFlag1,
              statusFlag2: value.statusFlag2,
              blockData: value.blockData,
            ));
  }

  @override
  Future<FeliCaStatusFlag> writeWithoutEncryption(
      {required List<Uint8List> serviceCodeList,
      required List<Uint8List> blockList,
      required List<Uint8List> blockData}) {
    return _tech
        .writeWithoutEncryption(
            serviceCodeList: serviceCodeList,
            blockList: blockList,
            blockData: blockData)
        .then((value) => FeliCaStatusFlag(
            statusFlag1: value.statusFlag1, statusFlag2: value.statusFlag2));
  }

  @override
  Future<List<Uint8List>> requestSystemCode() {
    return _tech.requestSystemCode();
  }

  @override
  Future<FeliCaRequestServiceV2Response> requestServiceV2(
      {required List<Uint8List> nodeCodeList}) {
    return _tech
        .requestServiceV2(nodeCodeList: nodeCodeList)
        .then((value) => FeliCaRequestServiceV2Response(
              statusFlag1: value.statusFlag1,
              statusFlag2: value.statusFlag2,
              encryptionIdentifier: value.encryptionIdentifier,
              nodeKeyVersionListAes: value.nodeKeyVersionListAes,
              nodeKeyVersionListDes: value.nodeKeyVersionListDes,
            ));
  }

  @override
  Future<FeliCaRequestSpecificationVersionResponse>
      requestSpecificationVersion() {
    return _tech
        .requestSpecificationVersion()
        .then((value) => FeliCaRequestSpecificationVersionResponse(
              statusFlag1: value.statusFlag1,
              statusFlag2: value.statusFlag2,
              basicVersion: value.basicVersion,
              optionVersion: value.optionVersion,
            ));
  }

  @override
  Future<FeliCaStatusFlag> resetMode() {
    return _tech.resetMode().then((value) => FeliCaStatusFlag(
        statusFlag1: value.statusFlag1, statusFlag2: value.statusFlag2));
  }

  @override
  Future<Uint8List> sendFeliCaCommand({required Uint8List commandPacket}) {
    return _tech.sendFeliCaCommand(commandPacket: commandPacket);
  }
}

FeliCaPollingRequestCodeIOS _getFeliCaPollingRequestCodeIOS(
    FeliCaPollingRequestCode value) {
  switch (value) {
    case FeliCaPollingRequestCode.noRequest:
      return FeliCaPollingRequestCodeIOS.noRequest;
    case FeliCaPollingRequestCode.systemCode:
      return FeliCaPollingRequestCodeIOS.systemCode;
    case FeliCaPollingRequestCode.communicationPerformance:
      return FeliCaPollingRequestCodeIOS.communicationPerformance;
  }
}

FeliCaPollingTimeSlotIOS _getFeliCaPollingTimeSlotIOS(
    FeliCaPollingTimeSlot value) {
  switch (value) {
    case FeliCaPollingTimeSlot.max1:
      return FeliCaPollingTimeSlotIOS.max1;
    case FeliCaPollingTimeSlot.max2:
      return FeliCaPollingTimeSlotIOS.max2;
    case FeliCaPollingTimeSlot.max4:
      return FeliCaPollingTimeSlotIOS.max4;
    case FeliCaPollingTimeSlot.max8:
      return FeliCaPollingTimeSlotIOS.max8;
    case FeliCaPollingTimeSlot.max16:
      return FeliCaPollingTimeSlotIOS.max16;
  }
}
