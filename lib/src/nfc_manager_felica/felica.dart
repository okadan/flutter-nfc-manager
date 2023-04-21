import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_felica/felica_platform_android.dart';
import 'package:nfc_manager/src/nfc_manager_felica/felica_platform_ios.dart';

/// The class providing access to FeliCa operations.
///
/// Acquire an instance using [from(NfcTag)].
abstract class FeliCa {
  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static FeliCa? from(NfcTag tag) {
    if (defaultTargetPlatform == TargetPlatform.android)
      return FeliCaPlatformAndroid.from(tag);
    if (defaultTargetPlatform == TargetPlatform.iOS)
      return FeliCaPlatformIOS.from(tag);
    return null;
  }

  /// Sends the Polling command as defined by FeliCa specification to the tag.
  Future<FeliCaPollingResponse> polling(
      {required Uint8List systemCode,
      required FeliCaPollingRequestCode requestCode,
      required FeliCaPollingTimeSlot timeSlot});

  /// Sends the Request Service command as defined by FeliCa specification to the tag.
  Future<List<Uint8List>> requestService(
      {required List<Uint8List> nodeCodeList});

  /// Sends the Request Response command as defined by FeliCa specification to the tag.
  Future<int> requestResponse();

  /// Sends the Read Without Encryption command as defined by FeliCa specification to the tag.
  Future<FeliCaReadWithoutEncryptionResponse> readWithoutEncryption(
      {required List<Uint8List> serviceCodeList,
      required List<Uint8List> blockList});

  /// Sends the Write Without Encryption command as defined by FeliCa specification to the tag.
  Future<FeliCaStatusFlag> writeWithoutEncryption(
      {required List<Uint8List> serviceCodeList,
      required List<Uint8List> blockList,
      required List<Uint8List> blockData});

  /// Sends the Request System Code command as defined by FeliCa specification to the tag.
  Future<List<Uint8List>> requestSystemCode();

  /// Sends the Request Service V2 command as defined by FeliCa specification to the tag.
  Future<FeliCaRequestServiceV2Response> requestServiceV2(
      {required List<Uint8List> nodeCodeList});

  /// Sends the Request Specification Version command as defined by FeliCa specification to the tag.
  Future<FeliCaRequestSpecificationVersionResponse>
      requestSpecificationVersion();

  /// Sends the Reset Mode command as defined by FeliCa specification to the tag.
  Future<FeliCaStatusFlag> resetMode();

  /// Sends the FeliCa command packet data to the tag.
  Future<Uint8List> sendFeliCaCommand({required Uint8List commandPacket});
}

/// The class representing the response from the Polling command.
class FeliCaPollingResponse {
  // DOC: const FeliCaPollingResponse
  const FeliCaPollingResponse({required this.pmm, required this.requestData});

  // DOC: pmm
  final Uint8List pmm;

  // DOC: requestData
  final Uint8List requestData;
}

/// The class representing the response from the Read Without Encryption command.
class FeliCaReadWithoutEncryptionResponse {
  // DOC: FeliCaReadWithoutEncryptionResponse
  const FeliCaReadWithoutEncryptionResponse({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.blockData,
  });

  // DOC: statusFlag1
  final int statusFlag1;

  // DOC: statusFlag2
  final int statusFlag2;

  // DOC: blockData
  final List<Uint8List> blockData;
}

/// The class representing the response from the Request Service V2 command.
class FeliCaRequestServiceV2Response {
  // DOC: FeliCaRequestServiceV2Response
  const FeliCaRequestServiceV2Response({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.encryptionIdentifier,
    required this.nodeKeyVersionListAes,
    required this.nodeKeyVersionListDes,
  });

  // DOC: statusFlag1
  final int statusFlag1;

  // DOC: statusFlag2
  final int statusFlag2;

  // DOC: encryptionIdentifier
  final int encryptionIdentifier;

  // DOC: nodeKeyVersionListAes
  final List<Uint8List> nodeKeyVersionListAes;

  // DOC: nodeKeyVersionListDes
  final List<Uint8List> nodeKeyVersionListDes;
}

/// The class representing the response from the Request Specification Version command.
class FeliCaRequestSpecificationVersionResponse {
  // DOC: FeliCaRequestSpecificationVersionResponse
  const FeliCaRequestSpecificationVersionResponse({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.basicVersion,
    required this.optionVersion,
  });

  // DOC: statusFlag1
  final int statusFlag1;

  // DOC: statusFlag2
  final int statusFlag2;

  // DOC: basicVersion
  final Uint8List basicVersion;

  // DOC: optionVersion
  final Uint8List optionVersion;
}

/// The class representing the Status Flag defined by the FeliCa specification.
class FeliCaStatusFlag {
  // DOC: FeliCaStatusFlag
  const FeliCaStatusFlag(
      {required this.statusFlag1, required this.statusFlag2});

  // DOC: statusFlag1
  final int statusFlag1;

  // DOC: statusFlag2
  final int statusFlag2;
}

/// The constants specifying the type of the data to request when polling.
enum FeliCaPollingRequestCode {
  /// A constant that indicates no request.
  noRequest(0x00),

  /// A constant that indicates a system code request.
  systemCode(0x01),

  /// A constant that indicates a communication performance request.
  communicationPerformance(0x02);

  // DOC: FeliCaPollingRequestCode
  const FeliCaPollingRequestCode(this.code);

  // DOC: code
  final int code;
}

/// The constants specifying the maximum number of time slots.
enum FeliCaPollingTimeSlot {
  /// A constant that indicates a maximum of one slot.
  max1(0x00),

  /// A constant that indicates a maximum of two slots.
  max2(0x01),

  /// A constant that indicates a maximum of four slots.
  max4(0x03),

  /// A constant that indicates a maximum of eight slots.
  max8(0x07),

  /// A constant that indicates a maximum of sixteen slots.
  max16(0x0F);

  // DOC: FeliCaPollingTimeSlot
  const FeliCaPollingTimeSlot(this.code);

  // DOC: code
  final int code;
}
