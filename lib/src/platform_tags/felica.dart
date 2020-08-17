import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

/// The class provides access to NFCFelicaTag API for iOS.
/// 
/// Acquire `FeliCa` instance using `FeliCa.from`.
class FeliCa {
  /// Constructs an instance with the given values for testing.
  /// 
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `FeliCa.from` are valid.
  const FeliCa({
    @required NfcTag tag,
    @required this.currentSystemCode,
    @required this.currentIDm,
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from NFCFeliCaTag#currentSystemCode on iOS.
  final Uint8List currentSystemCode;

  /// The value from NFCFeliCaTag#currentIDm on iOS.
  final Uint8List currentIDm;

  /// Get an instance of `FeliCa` for the given tag.
  ///
  /// Returns null if the tag is not compatible with FeliCa.
  factory FeliCa.from(NfcTag tag) => $GetFeliCa(tag);

  /// Sends the Polling command to the tag.
  /// 
  /// This uses NFCFeliCaTag#polling API on iOS.
  Future<FeliCaPollingResponse> polling({
    @required Uint8List systemCode,
    @required FeliCaPollingRequestCode requestCode,
    @required FeliCaPollingTimeSlot timeSlot,
  }) async {
    return channel.invokeMethod('FeliCa#polling', {
      'handle': _tag.handle,
      'systemCode': systemCode,
      'requestCode': $FeliCaPollingRequestCodeTable[requestCode],
      'timeSlot': $FeliCaPollingTimeSlotTable[timeSlot],
    }).then((value) => $GetFeliCaPollingResponse(Map.from(value)));
  }

  /// Sends the Request Response command to the tag.
  /// 
  /// This uses NFCFeliCaTag#requestResponse API on iOS.
  Future<int> requestResponse() async {
    return channel.invokeMethod('FeliCa#requestResponse', {
      'handle': _tag.handle,
    });
  }

  /// Sends the Request System Code command to the tag.
  /// 
  /// This uses NFCFeliCaTag#requestSystemCode API on iOS.
  Future<List<Uint8List>> requestSystemCode() async {
    return channel.invokeMethod('FeliCa#requestSystemCode', {
      'handle': _tag.handle,
    });
  }

  /// Sends the Request Service command to the tag.
  /// 
  /// This uses NFCFeliCaTag#requestService API on iOS.
  Future<List<Uint8List>> requestService({
    @required List<Uint8List> nodeCodeList,
  }) async {
    return channel.invokeMethod('FeliCa#requestService', {
      'handle': _tag.handle,
      'nodeCodeList': nodeCodeList,
    });
  }

  /// Sends the Request Service V2 command to the tag.
  /// 
  /// This uses NFCFeliCaTag#requestServiceV2 API on iOS.
  Future<FeliCaRequestServiceV2Response> requestServiceV2({
    @required List<Uint8List> nodeCodeList,
  }) async {
    return channel.invokeMethod('FeliCa#requestServiceV2', {
      'handle': _tag.handle,
      'nodeCodeList': nodeCodeList,
    }).then((value) => $GetFeliCaRequestServiceV2Response(Map.from(value)));
  }

  /// Sends the Read Without Encryption command to the tag.
  /// 
  /// This uses NFCFeliCaTag#readWithoutEncryption API on iOS.
  Future<FeliCaReadWithoutEncryptionResponse> readWithoutEncryption({
    @required List<Uint8List> serviceCodeList,
    @required List<Uint8List> blockList,
  }) async {
    return channel.invokeMethod('FeliCa#readWithoutEncryption', {
      'handle': _tag.handle,
      'serviceCodeList': serviceCodeList,
      'blockList': blockList,
    }).then((value) => $GetFeliCaReadWithoutEncryptionResponse(Map.from(value)));
  }

  /// Sends the Write Without Encryption command to the tag.
  /// 
  /// This uses NFCFeliCaTag#writeWithoutEncryption API on iOS.
  Future<FeliCaStatusFlag> writeWithoutEncryption({
    @required List<Uint8List> serviceCodeList,
    @required List<Uint8List> blockList,
    @required List<Uint8List> blockData,
  }) async {
    return channel.invokeMethod('FeliCa#writeWithoutEncryption', {
      'handle': _tag.handle,
      'serviceCodeList': serviceCodeList,
      'blockList': blockList,
      'blockData': blockData,
    }).then((value) => $GetFeliCaStatusFlag(Map.from(value)));
  }

  /// Sends the Request Specification Version command to the tag.
  /// 
  /// This uses NFCFeliCaTag#requestSpecificationVersion API on iOS.
  Future<FeliCaRequestSpecificationVersionResponse> requestSpecificationVersion() async {
    return channel.invokeMethod('FeliCa#requestSpecificationVersionResponse', {
      'handle': _tag.handle,
    }).then((value) => $GetFeliCaRequestSpecificationVersionResponse(Map.from(value)));
  }

  /// Sends the Reset Mode command to the tag.
  /// 
  /// This uses NFCFeliCaTag#resetMode API on iOS.
  Future<FeliCaStatusFlag> resetMode() async {
    return channel.invokeMethod('FeliCa#resetMode', {
      'handle': _tag.handle,
    }).then((value) => $GetFeliCaStatusFlag(Map.from(value)));
  }

  /// Sends the FeliCa command packet data to the tag.
  /// 
  /// This uses NFCFeliCaTag#sendFeliCaCommand API on iOS.
  Future<Uint8List> sendFeliCaCommand(Uint8List commandPacket) async {
    return channel.invokeMethod('FeliCa#transceive', {
      'handle': _tag.handle,
      'commandPacket': commandPacket,
    });
  }
}

/// The class represents the response of the Polling command.
class FeliCaPollingResponse {
  /// Constructs an instance with the given values.
  const FeliCaPollingResponse({
    @required this.manufacturerParameter,
    @required this.requestData,
  });

  /// Manufacturer Parameter.
  final Uint8List manufacturerParameter;

  /// Request Data.
  final Uint8List requestData;
}

/// The class represents the response of the Request Specification Version command.
class FeliCaRequestSpecificationVersionResponse {
  /// Constructs an instance with the given values.
  const FeliCaRequestSpecificationVersionResponse({
    @required this.statusFlag1,
    @required this.statusFlag2,
    @required this.basicVersion,
    @required this.optionVersion,
  });

  /// Status Flag1.
  final int statusFlag1;

  /// Status Flag2.
  final int statusFlag2;

  /// Basic Version.
  final Uint8List basicVersion;

  /// Option Version.
  final Uint8List optionVersion;
}

/// The class represents the response of the Request Service V2 command.
class FeliCaRequestServiceV2Response {
  /// Constructs an instance with the given values.
  const FeliCaRequestServiceV2Response({
    @required this.statusFlag1,
    @required this.statusFlag2,
    @required this.encryptionIdentifier,
    @required this.nodeKeyVersionListAes,
    @required this.nodeKeyVersionListDes,
  });

  /// Status Flag1.
  final int statusFlag1;

  /// Status Flag2.
  final int statusFlag2;

  /// Encryption Identifier.
  final int encryptionIdentifier;

  /// Node Key Version List AES.
  final List<Uint8List> nodeKeyVersionListAes;

  /// Node Key Version List DES.
  final List<Uint8List> nodeKeyVersionListDes;
}

/// The class represents the response of the Read Without Encryption command.
class FeliCaReadWithoutEncryptionResponse {
  /// Constructs an instance with the given values.
  const FeliCaReadWithoutEncryptionResponse({
    @required this.statusFlag1,
    @required this.statusFlag2,
    @required this.blockData,
  });

  /// Status Flag1.
  final int statusFlag1;

  /// Status Flag2.
  final int statusFlag2;

  /// Block Data.
  final List<Uint8List> blockData;
}

/// The class represents the status flags of the command.
class FeliCaStatusFlag {
  /// Constructs an instance with the given values.
  const FeliCaStatusFlag({
    @required this.statusFlag1,
    @required this.statusFlag2,
  });

  /// Status Flag1.
  final int statusFlag1;

  /// Status Flag2.
  final int statusFlag2;
}

/// Represents PollingRequestCode on iOS.
enum FeliCaPollingRequestCode {
  /// Indicates PollingRequestCode#noRequest on iOS.
  noRequest,

  /// Indicates PollingRequestCode#systemCode on iOS.
  systemCode,

  /// Indicates PollingRequestCode#communicationPerformamce on iOS.
  communicationPerformance,
}

/// Represents PollingTimeSlot on iOS.
enum FeliCaPollingTimeSlot {
  /// Indicates PollingTimeSlot#max1 on iOS.
  max1,

  /// Indicates PollingTimeSlot#max2 on iOS.
  max2,

  /// Indicates PollingTimeSlot#max4 on iOS.
  max4,

  /// Indicates PollingTimeSlot#max8 on iOS.
  max8,

  /// Indicates PollingTimeSlot#max16 on iOS.
  max16,
}
