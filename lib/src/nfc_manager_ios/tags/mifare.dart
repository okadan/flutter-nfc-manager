import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/iso7816.dart';

class MiFareIOS {
  const MiFareIOS(this._tag, {
    required this.mifareFamily,
    required this.historicalBytes,
  });

  final NfcTag _tag;

  final MiFareFamily mifareFamily;

  final Uint8List? historicalBytes;

  static MiFareIOS? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag).miFare;
    return pigeon == null ? null : MiFareIOS(
      tag,
      mifareFamily: miFareFamilyFromPigeon(pigeon.mifareFamily!),
      historicalBytes: pigeon.historicalBytes,
    );
  }

  Future<Uint8List> sendMiFareCommand({
    required Uint8List commandPacket,
  }) async {
    return hostApi.miFareSendMiFareCommand(_tag.handle, commandPacket);
  }

  Future<Iso7816ResponseApdu> sendMiFareIso7816Command({
    required int instructionClass,
    required int instructionCode,
    required int p1Parameter,
    required int p2Parameter,
    required Uint8List data,
    required int expectedResponseLength,
  }) async {
    return hostApi.miFareSendMiFareISO7816Command(_tag.handle, PigeonISO7816APDU(
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

  Future<Iso7816ResponseApdu> sendMiFareIso7816CommandRaw({
    required Uint8List data,
  }) async {
    return hostApi.miFareSendMiFareISO7816CommandRaw(_tag.handle, data)
      .then((value) => Iso7816ResponseApdu(
        payload: value.payload!,
        statusWord1: value.statusWord1!,
        statusWord2: value.statusWord2!,
    ));
  }
}

enum MiFareFamily {
  unknown,

  ultralight,

  plus,

  desfire,
}
