import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_felica/felica.dart';

Uint8List _sizedUint8List(List<int> command) =>
    Uint8List.fromList([command.length + 1, ...command]);

class FeliCaPlatformAndroid extends FeliCa {
  FeliCaPlatformAndroid._(this._idm, this._tech);

  final _idm; // TODO: migrate to _tech

  final NfcFAndroid _tech;

  static FeliCaPlatformAndroid? from(NfcTag tag) {
    final tech = NfcFAndroid.from(tag);
    return tech == null || tag is! NfcTagAndroid
        ? null
        : FeliCaPlatformAndroid._(tag.id, tech);
  }

  @override
  Future<FeliCaPollingResponse> polling(
      {required Uint8List systemCode,
      required FeliCaPollingRequestCode requestCode,
      required FeliCaPollingTimeSlot timeSlot}) async {
    assert(systemCode.length == 2);
    final res = await _tech.transceive(_sizedUint8List([
      0x00,
      ...systemCode,
      requestCode.code,
      timeSlot.code,
    ]));
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final pmm = res.sublist(10, 18);
    final requestData = res.sublist(18);
    return FeliCaPollingResponse(pmm: pmm, requestData: requestData);
  }

  @override
  Future<List<Uint8List>> requestService(
      {required List<Uint8List> nodeCodeList}) async {
    assert(1 <= nodeCodeList.length && nodeCodeList.length <= 32);
    assert(!nodeCodeList.any((e) => e.length != 2));
    final res = await _tech.transceive(_sizedUint8List([
      0x02,
      ..._idm,
      nodeCodeList.length,
      ...nodeCodeList.expand((e) => e),
    ]));
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final nodeLength = res[10];
    final nodeVersionList = List.generate(nodeLength, (i) => i)
        .map((i) => res.sublist(i * 2 + 11, i * 2 + 13))
        .toList();
    assert(nodeVersionList.length == nodeLength &&
        !nodeVersionList.any((e) => e.length != 2));
    return nodeVersionList;
  }

  @override
  Future<int> requestResponse() async {
    final res = await _tech.transceive(_sizedUint8List([
      0x04,
      ..._idm,
    ]));
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final mode = res[10];
    return mode;
  }

  @override
  Future<FeliCaReadWithoutEncryptionResponse> readWithoutEncryption(
      {required List<Uint8List> serviceCodeList,
      required List<Uint8List> blockList}) async {
    assert(1 <= serviceCodeList.length &&
        serviceCodeList.length <= 16 &&
        !serviceCodeList.any((e) => e.length != 2));
    assert(blockList.isNotEmpty &&
        !blockList.any((e) => e.length != 2 && e.length != 3));
    final res = await _tech.transceive(_sizedUint8List([
      0x06,
      ..._idm,
      serviceCodeList.length,
      ...serviceCodeList.expand((e) => e),
      blockList.length,
      ...blockList.expand((e) => e),
    ]));
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final statusFlag1 = res[10];
    final statusFlag2 = res[11];
    final blockLength = statusFlag1 == 0x00 ? res[12] : 0;
    final blockData = statusFlag1 == 0x00
        ? List.generate(blockLength, (i) => i)
            .map((i) => res.sublist(i * 16 + 13, i * 16 + 29))
            .toList()
        : <Uint8List>[];
    assert(blockData.length == blockLength &&
        !blockData.any((e) => e.length != 16));
    return FeliCaReadWithoutEncryptionResponse(
      statusFlag1: statusFlag1,
      statusFlag2: statusFlag2,
      blockData: blockData,
    );
  }

  @override
  Future<FeliCaStatusFlag> writeWithoutEncryption(
      {required List<Uint8List> serviceCodeList,
      required List<Uint8List> blockList,
      required List<Uint8List> blockData}) async {
    assert(1 <= serviceCodeList.length &&
        serviceCodeList.length <= 16 &&
        !serviceCodeList.any((e) => e.length != 2));
    assert(blockList.isNotEmpty &&
        !blockList.any((e) => e.length != 2 && e.length != 3));
    assert(blockData.length == blockList.length &&
        !blockData.any((e) => e.length != 16));
    final res = await _tech.transceive(_sizedUint8List([
      0x08,
      ..._idm,
      serviceCodeList.length,
      ...serviceCodeList.expand((e) => e),
      blockList.length,
      ...blockList.expand((e) => e),
      ...blockData.expand((e) => e),
    ]));
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final statusFlag1 = res[10];
    final statusFlag2 = res[11];
    return FeliCaStatusFlag(
      statusFlag1: statusFlag1,
      statusFlag2: statusFlag2,
    );
  }

  @override
  Future<List<Uint8List>> requestSystemCode() async {
    final res = await _tech.transceive(_sizedUint8List([
      0x0C,
      ..._idm,
    ]));
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final systemCodeLength = res[10];
    final systemCodeList = List.generate(systemCodeLength, (i) => i)
        .map((i) => res.sublist(i * 2 + 11, i * 2 + 13))
        .toList();
    return systemCodeList;
  }

  @override
  Future<FeliCaRequestServiceV2Response> requestServiceV2(
      {required List<Uint8List> nodeCodeList}) async {
    assert(1 <= nodeCodeList.length &&
        nodeCodeList.length <= 32 &&
        !nodeCodeList.any((e) => e.length != 2));
    final res = await _tech.transceive(_sizedUint8List([
      0x32,
      ..._idm,
      nodeCodeList.length,
      ...nodeCodeList.expand((e) => e),
    ]));
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final statusFlag1 = res[10];
    final statusFlag2 = res[11];
    final encryptionIdentifier = statusFlag1 == 0x00 ? res[12] : 0; // TODO:
    final nodeLength = statusFlag1 == 0x00 ? res[13] : 0;
    final nodeKeyVersionListAes = statusFlag1 == 0x00
        ? List.generate(nodeLength, (i) => i)
            .map((i) => res.sublist(i * 2 + 14, i * 2 + 16))
            .toList()
        : <Uint8List>[];
    final nodeKeyVersionListDes = statusFlag1 == 0x00
        ? List.generate(nodeLength, (i) => i)
            .map((i) => res.sublist(
                (i + nodeLength) * 2 + 14, (i + nodeLength) * 2 + 16))
            .toList()
        : <Uint8List>[];
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
    final res = await _tech.transceive(_sizedUint8List([
      0x3C,
      ..._idm,
      0x00,
      0x00,
    ]));
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final statusFlag1 = res[10];
    final statusFlag2 = res[11];
    //final formatVersion = statusFlag1 == 0x00
    //  ? res[12]
    //  : 0x00; // format version is fixed value.
    final basicVersion =
        statusFlag1 == 0x00 ? res.sublist(13, 15) : Uint8List(0);
    //final optionLength = statusFlag1 == 0x00
    //  ? res[15]
    //  : 0;
    final optionVersion = statusFlag1 == 0x00 ? res.sublist(16) : Uint8List(0);
    return FeliCaRequestSpecificationVersionResponse(
      statusFlag1: statusFlag1,
      statusFlag2: statusFlag2,
      basicVersion: basicVersion,
      optionVersion: optionVersion,
    );
  }

  @override
  Future<FeliCaStatusFlag> resetMode() async {
    final res = await _tech.transceive(_sizedUint8List([
      0x3E,
      ..._idm,
      0x00,
      0x00,
    ]));
    //final size = res[0];
    //final code = res[1];
    //final idm = res.sublist(2, 10);
    final statusFlag1 = res[10];
    final statusFlag2 = res[11];
    return FeliCaStatusFlag(
      statusFlag1: statusFlag1,
      statusFlag2: statusFlag2,
    );
  }

  @override
  Future<Uint8List> sendFeliCaCommand(
      {required Uint8List commandPacket}) async {
    final res = await _tech.transceive(_sizedUint8List(commandPacket));
    //final size = res[0];
    final response = res.sublist(1);
    return response;
  }
}
