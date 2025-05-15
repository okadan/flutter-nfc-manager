import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_felica/src/felica_platform_android.dart';
import 'package:nfc_manager_felica/src/felica_platform_ios.dart';

/// The class providing access to FeliCa operations.
///
/// Acquire an instance using [from(NfcTag)].
abstract class FeliCa {
  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static FeliCa? from(NfcTag tag) {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => FeliCaPlatformAndroid.from(tag),
      TargetPlatform.iOS => FeliCaPlatformIos.from(tag),
      _ => null,
    };
  }

  // TODO: DOC
  Uint8List get systemCode;

  // TODO: DOC
  Uint8List get idm;

  // TODO: DOC
  Future<FeliCaPollingResponse> polling({
    required Uint8List systemCode,
    required FeliCaPollingRequestCode requestCode,
    required FeliCaPollingTimeSlot timeSlot,
  });

  // TODO: DOC
  Future<List<Uint8List>> requestService({
    required List<Uint8List> nodeCodeList,
  });

  // TODO: DOC
  Future<int> requestResponse();

  // TODO: DOC
  Future<FeliCaReadWithoutEncryptionResponse> readWithoutEncryption({
    required List<Uint8List> serviceCodeList,
    required List<Uint8List> blockList,
  });

  // TODO: DOC
  Future<FeliCaStatusFlag> writeWithoutEncryption({
    required List<Uint8List> serviceCodeList,
    required List<Uint8List> blockList,
    required List<Uint8List> blockData,
  });

  // TODO: DOC
  Future<List<Uint8List>> requestSystemCode();

  // TODO: DOC
  Future<FeliCaRequestServiceV2Response> requestServiceV2({
    required List<Uint8List> nodeCodeList,
  });

  // TODO: DOC
  Future<FeliCaRequestSpecificationVersionResponse>
  requestSpecificationVersion();

  // TODO: DOC
  Future<FeliCaStatusFlag> resetMode();

  // TODO: DOC
  Future<Uint8List> sendFeliCaCommand({required Uint8List commandPacket});
}

// TODO: DOC
final class FeliCaPollingResponse {
  // TODO: DOC
  @visibleForTesting
  const FeliCaPollingResponse({required this.pmm, required this.requestData});

  // TODO: DOC
  final Uint8List pmm;

  // TODO: DOC
  final Uint8List? requestData;
}

// TODO: DOC
final class FeliCaReadWithoutEncryptionResponse {
  // TODO: DOC
  @visibleForTesting
  const FeliCaReadWithoutEncryptionResponse({
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
final class FeliCaRequestServiceV2Response {
  // TODO: DOC
  @visibleForTesting
  const FeliCaRequestServiceV2Response({
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
final class FeliCaRequestSpecificationVersionResponse {
  // TODO: DOC
  @visibleForTesting
  const FeliCaRequestSpecificationVersionResponse({
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
final class FeliCaStatusFlag {
  // TODO: DOC
  @visibleForTesting
  const FeliCaStatusFlag({
    required this.statusFlag1,
    required this.statusFlag2,
  });

  // TODO: DOC
  final int statusFlag1;

  // TODO: DOC
  final int statusFlag2;
}

/// The values that specify the type of the data to request when polling.
enum FeliCaPollingRequestCode {
  /// The value that indicates no request.
  noRequest._(0x00),

  /// The value that indicates a system code request.
  systemCode._(0x01),

  /// The value that indicates a communication performance request.
  communicationPerformance._(0x02);

  /// The code used in the actual command.
  final int code;

  const FeliCaPollingRequestCode._(this.code);
}

/// The values that specify the maximum number of time slots.
enum FeliCaPollingTimeSlot {
  /// The value that indicates a maximum of one slot.
  max1._(0x00),

  /// The value that indicates a maximum of two slots.
  max2._(0x01),

  /// The value that indicates a maximum of four slots.
  max4._(0x03),

  /// The value that indicates a maximum of right slots.
  max8._(0x07),

  /// The value that indicates a maximum of sixteen slots.
  max16._(0x0F);

  /// The code used in the actual command.
  final int code;

  const FeliCaPollingTimeSlot._(this.code);
}
