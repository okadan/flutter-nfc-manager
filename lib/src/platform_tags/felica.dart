import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

// FeliCa
class FeliCa {
  // FeliCa
  const FeliCa({
    @required this.tag,
    @required this.currentSystemCode,
    @required this.currentIDm,
  });

  // tag
  final NfcTag tag;

  // currentSystemCode
  final Uint8List currentSystemCode;

  // currentIDm
  final Uint8List currentIDm;

  // FeliCa.from
  factory FeliCa.from(NfcTag tag) => $GetFeliCa(tag);

  // polling
  Future<FeliCaPollingResponse> polling({
    @required Uint8List systemCode,
    @required FeliCaPollingRequestCode requestCode,
    @required FeliCaPollingTimeSlot timeSlot,
  }) async {
    return channel.invokeMethod('FeliCa#polling', {
      'handle': tag.handle,
      'systemCode': systemCode,
      'requestCode': $FeliCaPollingRequestCodeTable[requestCode],
      'timeSlot': $FeliCaPollingTimeSlotTable[timeSlot],
    }).then((value) => $GetFeliCaPollingResponse(Map.from(value)));
  }

  // requestResponse
  Future<int> requestResponse() async {
    return channel.invokeMethod('FeliCa#requestResponse', {
      'handle': tag.handle,
    });
  }

  // requestSystemCode
  Future<List<Uint8List>> requestSystemCode() async {
    return channel.invokeMethod('FeliCa#requestSystemCode', {
      'handle': tag.handle,
    });
  }

  // requestService
  Future<List<Uint8List>> requestService({
    @required List<Uint8List> nodeCodeList,
  }) async {
    return channel.invokeMethod('FeliCa#requestService', {
      'handle': tag.handle,
      'nodeCodeList': nodeCodeList,
    });
  }

  // requestServiceV2
  Future<FeliCaRequestServiceV2Response> requestServiceV2({
    @required List<Uint8List> nodeCodeList,
  }) async {
    return channel.invokeMethod('FeliCa#requestServiceV2', {
      'handle': tag.handle,
      'nodeCodeList': nodeCodeList,
    }).then((value) => $GetFeliCaRequestServiceV2Response(Map.from(value)));
  }

  // readWithoutEncryption
  Future<FeliCaReadWithoutEncryptionResponse> readWithoutEncryption({
    @required List<Uint8List> serviceCodeList,
    @required List<Uint8List> blockList,
  }) async {
    return channel.invokeMethod('FeliCa#readWithoutEncryption', {
      'handle': tag.handle,
      'serviceCodeList': serviceCodeList,
      'blockList': blockList,
    }).then((value) => $GetFeliCaReadWithoutEncryptionResponse(Map.from(value)));
  }

  // writeWithoutEncryption
  Future<FeliCaStatusFlag> writeWithoutEncryption({
    @required List<Uint8List> serviceCodeList,
    @required List<Uint8List> blockList,
    @required List<Uint8List> blockData,
  }) async {
    return channel.invokeMethod('FeliCa#writeWithoutEncryption', {
      'handle': tag.handle,
      'serviceCodeList': serviceCodeList,
      'blockList': blockList,
      'blockData': blockData,
    }).then((value) => $GetFeliCaStatusFlag(Map.from(value)));
  }

  // requestSpecificationVersion
  Future<FeliCaRequestSpecificationVersionResponse> requestSpecificationVersion() async {
    return channel.invokeMethod('FeliCa#requestSpecificationVersionResponse', {
      'handle': tag.handle,
    }).then((value) => $GetFeliCaRequestSpecificationVersionResponse(Map.from(value)));
  }

  // resetMode
  Future<FeliCaStatusFlag> resetMode() async {
    return channel.invokeMethod('FeliCa#resetMode', {
      'handle': tag.handle,
    }).then((value) => $GetFeliCaStatusFlag(Map.from(value)));
  }

  // sendFeliCaCommand
  Future<Uint8List> sendFeliCaCommand(Uint8List commandPacket) async {
    return channel.invokeMethod('FeliCa#transceive', {
      'handle': tag.handle,
      'commandPacket': commandPacket,
    });
  }
}

// FeliCaPollingResponse
class FeliCaPollingResponse {
  // FeliCaPollingResponse
  const FeliCaPollingResponse({
    @required this.manufacturerParameter,
    @required this.requestData,
  });

  // manufacturerParameter
  final Uint8List manufacturerParameter;

  // requestData
  final Uint8List requestData;
}

// FeliCaRequestSpecificationVersionResponse
class FeliCaRequestSpecificationVersionResponse {
  // FeliCaRequestSpecificationVersionResponse
  const FeliCaRequestSpecificationVersionResponse({
    @required this.statusFlag1,
    @required this.statusFlag2,
    @required this.basicVersion,
    @required this.optionVersion,
  });

  // statusFlag1
  final int statusFlag1;

  // statusFlag2
  final int statusFlag2;

  // basicVersion
  final Uint8List basicVersion;

  // optionVersion
  final Uint8List optionVersion;
}

// FeliCaRequestServiceV2Response
class FeliCaRequestServiceV2Response {
  // FeliCaRequestServiceV2Response
  const FeliCaRequestServiceV2Response({
    @required this.statusFlag1,
    @required this.statusFlag2,
    @required this.encryptionIdentifier,
    @required this.nodeKeyVersionListAes,
    @required this.nodeKeyVersionListDes,
  });

  // statusFlag1
  final int statusFlag1;

  // statusFlag2
  final int statusFlag2;

  // encryptionIdentifier
  final int encryptionIdentifier;

  // nodeKeyVersionListAes
  final List<Uint8List> nodeKeyVersionListAes;

  // nodeKeyVersionListDes
  final List<Uint8List> nodeKeyVersionListDes;
}

// FeliCaReadWithoutEncryptionResponse
class FeliCaReadWithoutEncryptionResponse {
  // FeliCaReadWithoutEncryptionResponse
  const FeliCaReadWithoutEncryptionResponse({
    @required this.statusFlag1,
    @required this.statusFlag2,
    @required this.blockData,
  });

  // statusFlag1
  final int statusFlag1;

  // statusFlag2
  final int statusFlag2;

  // blockData
  final List<Uint8List> blockData;
}

// FeliCaStatusFlag
class FeliCaStatusFlag {
  // FeliCaStatusFlag
  const FeliCaStatusFlag({
    @required this.statusFlag1,
    @required this.statusFlag2,
  });

  // statusFlag1
  final int statusFlag1;

  // statusFlag2
  final int statusFlag2;
}

// FeliCaPollingRequestCode
enum FeliCaPollingRequestCode {
  // noRequest
  noRequest,

  // systemCode
  systemCode,

  // communicationPerformance
  communicationPerformance,
}

// FeliCaPollingTimeSlot
enum FeliCaPollingTimeSlot {
  // max1
  max1,

  // max2
  max2,

  // max4
  max4,

  // max8
  max8,

  // max16
  max16,
}
