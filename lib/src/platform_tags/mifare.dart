import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';
import './iso7816.dart';

// MiFare
class MiFare {
  // MiFare
  const MiFare({
    @required this.tag,
    @required this.mifareFamily,
    @required this.identifier,
    @required this.historicalBytes,
  });

  // tag
  final NfcTag tag;

  // mifareFamily
  final MiFareFamily mifareFamily;

  // identifier
  final Uint8List identifier;

  // historicalBytes
  final Uint8List historicalBytes;

  // MiFare.from
  factory MiFare.from(NfcTag tag) => $GetMiFare(tag);

  // sendMifareCommand
  Future<Uint8List> sendMiFareCommand(Uint8List commandPacket) async {
    return channel.invokeMethod('MiFare#sendMiFareCommand', {
      'handle': tag.handle,
      'commandPacket': commandPacket,
    });
  }

  // sendMiFareIso7816Command
  Future<Iso7816ResponseApdu> sendMiFareIso7816Command({
    @required int instructionClass,
    @required int instructionCode,
    @required int p1Parameter,
    @required int p2Parameter,
    @required Uint8List data,
    @required int expectedResponseLength,
  }) async {
    return channel.invokeMethod('MiFare#sendMiFareIso7816Command', {
      'handle': tag.handle,
      'instructionClass': instructionClass,
      'instructionCode': instructionCode,
      'p1Parameter': p1Parameter,
      'p2Parameter': p2Parameter,
      'data': data,
      'expectedResponseLength': expectedResponseLength,
    }).then((value) => $GetIso7816ResponseApdu(Map.from(value)));
  }

  // sendMiFareIso7816CommandRaw
  Future<Iso7816ResponseApdu> sendMiFareIso7816CommandRaw(Uint8List data) async {
    return channel.invokeMethod('MiFare#sendMiFareIso7816CommandRaw', {
      'handle': tag.handle,
      'data': data,
    }).then((value) => $GetIso7816ResponseApdu(Map.from(value)));
  }
}

// MiFareFamily
enum MiFareFamily {
  // unknown
  unknown,

  // ultralight
  ultralight,

  // plus
  plus,

  // desfire
  desfire,
}
