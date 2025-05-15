import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager_felica/src/felica.dart';

final class FeliCaPlatformAndroid implements FeliCa {
  const FeliCaPlatformAndroid._(this._tech);

  final NfcFAndroid _tech;

  static FeliCaPlatformAndroid? from(NfcTag tag) {
    final tech = NfcFAndroid.from(tag);
    return tech == null ? null : FeliCaPlatformAndroid._(tech);
  }

  @override
  Uint8List get systemCode => _tech.systemCode;

  @override
  Uint8List get idm => _tech.manufacturer;

  @override
  Future<FeliCaPollingResponse> polling({
    required Uint8List systemCode,
    required FeliCaPollingRequestCode requestCode,
    required FeliCaPollingTimeSlot timeSlot,
  }) async {
    assert(systemCode.length == 2);
    final res = await _transceive([
      0x00,
      ...systemCode,
      requestCode.code,
      timeSlot.code,
    ]);
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final pmm = res.sublist(10, 18);
    final requestData = res.sublist(18);
    // ignore: invalid_use_of_visible_for_testing_member
    return FeliCaPollingResponse(pmm: pmm, requestData: requestData);
  }

  @override
  Future<List<Uint8List>> requestService({
    required List<Uint8List> nodeCodeList,
  }) async {
    assert(nodeCodeList.isNotEmpty && nodeCodeList.length <= 32);
    assert(!nodeCodeList.any((e) => e.length != 2));
    final res = await _transceive([
      0x02,
      ..._tech.tag.id,
      nodeCodeList.length,
      ...nodeCodeList.expand((e) => e),
    ]);
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final nodeLength = res[10];
    final nodeVersionList =
        List.generate(
          nodeLength,
          (i) => i,
        ).map((i) => res.sublist(i * 2 + 11, i * 2 + 13)).toList();
    assert(nodeVersionList.length == nodeLength);
    assert(!nodeVersionList.any((e) => e.length != 2));
    return nodeVersionList;
  }

  @override
  Future<int> requestResponse() async {
    final res = await _transceive([0x04, ..._tech.tag.id]);
    //final size = res[0];
    //final code = res[1;
    //final idm = res.sublist(2, 10);
    final mode = res[10];
    return mode;
  }

  @override
  Future<FeliCaReadWithoutEncryptionResponse> readWithoutEncryption({
    required List<Uint8List> serviceCodeList,
    required List<Uint8List> blockList,
  }) async {
    assert(serviceCodeList.isNotEmpty && serviceCodeList.length <= 16);
    assert(!serviceCodeList.any((e) => e.length != 2));
    assert(blockList.isNotEmpty);
    assert(!blockList.any((e) => e.length != 2 && e.length != 3));
    final res = await _transceive([
      0x06,
      ..._tech.tag.id,
      serviceCodeList.length,
      ...serviceCodeList.expand((e) => e),
      blockList.length,
      ...blockList.expand((e) => e),
    ]);
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final statusFlag1 = res[10];
    final statusFlag2 = res[11];
    final blockLength = statusFlag1 == 0x00 ? res[12] : 0;
    final blockData =
        statusFlag1 == 0x00
            ? List.generate(
              blockLength,
              (i) => i,
            ).map((i) => res.sublist(i * 16 + 13, i * 16 + 29)).toList()
            : <Uint8List>[];
    assert(blockData.length == blockLength);
    assert(!blockData.any((e) => e.length != 16));
    // ignore: invalid_use_of_visible_for_testing_member
    return FeliCaReadWithoutEncryptionResponse(
      statusFlag1: statusFlag1,
      statusFlag2: statusFlag2,
      blockData: blockData,
    );
  }

  @override
  Future<FeliCaStatusFlag> writeWithoutEncryption({
    required List<Uint8List> serviceCodeList,
    required List<Uint8List> blockList,
    required List<Uint8List> blockData,
  }) async {
    assert(serviceCodeList.isNotEmpty && serviceCodeList.length <= 16);
    assert(!serviceCodeList.any((e) => e.length != 2));
    assert(blockList.isNotEmpty);
    assert(!blockList.any((e) => e.length != 2 && e.length != 3));
    assert(blockData.length == blockList.length);
    assert(!blockData.any((e) => e.length != 16));
    final res = await _transceive([
      0x08,
      ..._tech.tag.id,
      serviceCodeList.length,
      ...serviceCodeList.expand((e) => e),
      blockList.length,
      ...blockList.expand((e) => e),
      ...blockData.expand((e) => e),
    ]);
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final statusFlag1 = res[10];
    final statusFlag2 = res[11];
    // ignore: invalid_use_of_visible_for_testing_member
    return FeliCaStatusFlag(statusFlag1: statusFlag1, statusFlag2: statusFlag2);
  }

  @override
  Future<List<Uint8List>> requestSystemCode() async {
    final res = await _transceive([0x0C, ..._tech.tag.id]);
    //final size = res[0];
    //final code = res[1;
    //final idm = res.sublist(2, 10);
    final systemCodeLength = res[10];
    final systemCodeList =
        List.generate(
          systemCodeLength,
          (i) => i,
        ).map((i) => res.sublist(i * 2 + 11, i * 2 + 13)).toList();
    return systemCodeList;
  }

  @override
  Future<FeliCaRequestServiceV2Response> requestServiceV2({
    required List<Uint8List> nodeCodeList,
  }) async {
    assert(nodeCodeList.isNotEmpty && nodeCodeList.length <= 32);
    assert(!nodeCodeList.any((e) => e.length != 2));
    final res = await _transceive([
      0x32,
      ..._tech.tag.id,
      nodeCodeList.length,
      ...nodeCodeList.expand((e) => e),
    ]);
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final statusFlag1 = res[10];
    final statusFlag2 = res[11];
    final encryptionIdentifier =
        statusFlag1 == 0x00
            ? res[12]
            : 0; // TODO: should it be null instead of 0?
    final nodeLength = statusFlag1 == 0x00 ? res[13] : 0;
    final nodeKeyVersionListAes =
        statusFlag1 == 0x00
            ? List.generate(
              nodeLength,
              (i) => i,
            ).map((i) => res.sublist(i * 2 + 14, i * 2 + 16)).toList()
            : null;
    final nodeKeyVersionListDes =
        statusFlag1 == 0x00
            ? List.generate(nodeLength, (i) => i)
                .map(
                  (i) => res.sublist(
                    (i + nodeLength) * 2 + 14,
                    (i + nodeLength) * 2 + 16,
                  ),
                )
                .toList()
            : null;
    // ignore: invalid_use_of_visible_for_testing_member
    return FeliCaRequestServiceV2Response(
      statusFlag1: statusFlag1,
      statusFlag2: statusFlag2,
      encryptionIdentifier: encryptionIdentifier,
      nodeKeyVersionListAes: nodeKeyVersionListAes,
      nodeKeyVersionListDes: nodeKeyVersionListDes,
    );
  }

  @override
  Future<FeliCaRequestSpecificationVersionResponse>
  requestSpecificationVersion() async {
    final res = await _transceive([0x3C, ..._tech.tag.id, 0x00, 0x00]);
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final statusFlag1 = res[10];
    final statusFlag2 = res[11];
    //final formatVersion = statusFlag1 == 0x00
    //  ? res[12]
    //  : 0x00; // format version is fixed value.
    final basicVersion = statusFlag1 == 0x00 ? res.sublist(13, 15) : null;
    //final optionLength = statusFlag1 == 0x00
    //  ? res[15]
    //  : 0;
    final optionVersion = statusFlag1 == 0x00 ? res.sublist(16) : null;
    // ignore: invalid_use_of_visible_for_testing_member
    return FeliCaRequestSpecificationVersionResponse(
      statusFlag1: statusFlag1,
      statusFlag2: statusFlag2,
      basicVersion: basicVersion,
      optionVersion: optionVersion,
    );
  }

  @override
  Future<FeliCaStatusFlag> resetMode() async {
    final res = await _transceive([0x3E, ..._tech.tag.id, 0x00, 0x00]);
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final statusFlag1 = res[10];
    final statusFlag2 = res[11];
    // ignore: invalid_use_of_visible_for_testing_member
    return FeliCaStatusFlag(statusFlag1: statusFlag1, statusFlag2: statusFlag2);
  }

  @override
  Future<Uint8List> sendFeliCaCommand({
    required Uint8List commandPacket,
  }) async {
    final res = await _transceive(commandPacket);
    //final size = res[0];
    final response = res.sublist(1);
    return response;
  }

  Future<Uint8List> _transceive(List<int> data) {
    return _tech.transceive(
      Uint8List.fromList([
        data.length + 1, // adding packet size.
        ...data,
      ]),
    );
  }
}
