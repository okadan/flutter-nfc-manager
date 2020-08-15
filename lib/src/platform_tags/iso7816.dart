import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

// Iso7816
class Iso7816 {
  // Iso7816
  const Iso7816({
    @required this.tag,
    @required this.identifier,
    @required this.initialSelectedAID,
    @required this.historicalBytes,
    @required this.applicationData,
    @required this.proprietaryApplicationDataCoding,
  });

  // tag
  final NfcTag tag;

  // identifier
  final Uint8List identifier;

  // initialSelectedAID
  final String initialSelectedAID;

  // historicalBytes
  final Uint8List historicalBytes;

  // applicationData
  final Uint8List applicationData;

  // proprietaryApplicationDataCoding
  final bool proprietaryApplicationDataCoding;

  // Iso7816.from
  factory Iso7816.from(NfcTag tag) => $GetIso7816(tag);

  // sendCommand
  Future<Iso7816ResponseApdu> sendCommand({
    @required int instructionClass,
    @required int instructionCode,
    @required int p1Parameter,
    @required int p2Parameter,
    @required Uint8List data,
    @required int expectedResponseLength,
  }) async {
    return channel.invokeMethod('Iso7816#sendCommand', {
      'handle': tag.handle,
      'instructionClass': instructionClass,
      'instructionCode': instructionCode,
      'p1Parameter': p1Parameter,
      'p2Parameter': p2Parameter,
      'data': data,
      'expectedResponseLength': expectedResponseLength,
    }).then((value) => $GetIso7816ResponseApdu(Map.from(value)));
  }

  // sendCommandRaw
  Future<Iso7816ResponseApdu> sendCommandRaw(Uint8List data) async {
    return channel.invokeMethod('Iso7816#sendCommandRaw', {
      'handle': tag.handle,
      'data': data,
    }).then((value) => $GetIso7816ResponseApdu(Map.from(value)));
  }
}

// Iso7816ResponseApdu
class Iso7816ResponseApdu {
  // Iso7816ResponseApdu
  const Iso7816ResponseApdu({
    @required this.payload,
    @required this.statusWord1,
    @required this.statusWord2,
  });

  // payload
  final Uint8List payload;

  // statusWord1
  final int statusWord1;

  // statusRowd2
  final int statusWord2;
}
