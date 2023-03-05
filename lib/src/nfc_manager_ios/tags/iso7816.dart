import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

class Iso7816IOS {
  const Iso7816IOS(this._tag, {
    required this.initialSelectedAID,
    required this.historicalBytes,
    required this.applicationData,
    required this.proprietaryApplicationDataCoding,
  });

  final NfcTag _tag;

  final String initialSelectedAID;

  final Uint8List? historicalBytes;

  final Uint8List? applicationData;

  final bool proprietaryApplicationDataCoding;

  static Iso7816IOS? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).iso7816;
    return pigeon == null ? null : Iso7816IOS(
      tag,
      initialSelectedAID: pigeon.initialSelectedAID!,
      historicalBytes: pigeon.historicalBytes,
      applicationData: pigeon.applicationData,
      proprietaryApplicationDataCoding: pigeon.proprietaryApplicationDataCoding!,
    );
  }

  Future<Iso7816ResponseApdu> sendCommand({
    required int instructionClass,
    required int instructionCode,
    required int p1Parameter,
    required int p2Parameter,
    required Uint8List data,
    required int expectedResponseLength,
  }) async {
    return hostApi.iso7816SendCommand(_tag.handle, PigeonISO7816APDU(
      instructionClass: instructionClass,
      instructionCode: instructionCode,
      p1Parameter: p1Parameter,
      p2Parameter: p2Parameter,
      data: data,
      expectedResponseLength: expectedResponseLength,
    )).then((value) => Iso7816ResponseApdu(
      payload: value.payload!,
      statusWord1: value.statusWord1!,
      statusWord2: value.statusWord2!,
    ));
  }

  Future<Iso7816ResponseApdu> sendCommandRaw({
    required Uint8List data,
  }) async {
    return hostApi.iso7816SendCommandRaw(_tag.handle, data)
      .then((value) => Iso7816ResponseApdu(
        payload: value.payload!,
        statusWord1: value.statusWord1!,
        statusWord2: value.statusWord2!,
      ));
  }
}

class Iso7816ResponseApdu {
  const Iso7816ResponseApdu({
    required this.payload,
    required this.statusWord1,
    required this.statusWord2,
  });

  final Uint8List payload;

  final int statusWord1;

  final int statusWord2;
}
