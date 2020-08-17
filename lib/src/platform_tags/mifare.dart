import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';
import './iso7816.dart';

/// (iOS only) The class provides access to NFCMiFareTag API for iOS.
/// 
/// Acquire `MiFare` instance using `MiFare.from`.
class MiFare {
  /// Constructs an instance with the given values for testing.
  /// 
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `MiFare.from` are valid.
  const MiFare({
    @required NfcTag tag,
    @required this.mifareFamily,
    @required this.identifier,
    @required this.historicalBytes,
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from NFCMiFareTag#mifareFamily on iOS.
  final MiFareFamily mifareFamily;

  /// The value from NFCMiFareTag#identifier on iOS.
  final Uint8List identifier;

  /// The value from NFCMiFareTag#historicalBytes on iOS.
  final Uint8List historicalBytes;

  /// Get an instance of `MiFare` for the given tag.
  ///
  /// Returns null if the tag is not compatible with MiFare.
  factory MiFare.from(NfcTag tag) => $GetMiFare(tag);

  /// Sends the native MiFare command to the tag.
  /// 
  /// This uses NFCMiFareTag#sendMiFareCommand API on iOS.
  Future<Uint8List> sendMiFareCommand(Uint8List commandPacket) async {
    return channel.invokeMethod('MiFare#sendMiFareCommand', {
      'handle': _tag.handle,
      'commandPacket': commandPacket,
    });
  }

  /// Sends the ISO7816 APDU to the tag.
  /// 
  /// This uses NFCMiFareTag#sendMiFareISO7816Command API on iOS.
  Future<Iso7816ResponseApdu> sendMiFareIso7816Command({
    @required int instructionClass,
    @required int instructionCode,
    @required int p1Parameter,
    @required int p2Parameter,
    @required Uint8List data,
    @required int expectedResponseLength,
  }) async {
    return channel.invokeMethod('MiFare#sendMiFareIso7816Command', {
      'handle': _tag.handle,
      'instructionClass': instructionClass,
      'instructionCode': instructionCode,
      'p1Parameter': p1Parameter,
      'p2Parameter': p2Parameter,
      'data': data,
      'expectedResponseLength': expectedResponseLength,
    }).then((value) => $GetIso7816ResponseApdu(Map.from(value)));
  }

  /// Sends the ISO7816 APDU to the tag.
  /// 
  /// This uses NFCMiFareTag#sendMiFareISO7816Command API on iOS.
  Future<Iso7816ResponseApdu> sendMiFareIso7816CommandRaw(Uint8List data) async {
    return channel.invokeMethod('MiFare#sendMiFareIso7816CommandRaw', {
      'handle': _tag.handle,
      'data': data,
    }).then((value) => $GetIso7816ResponseApdu(Map.from(value)));
  }
}

/// Represents NFCMiFareFamily on iOS.
enum MiFareFamily {
  /// Indicates NFCMiFareFamily#unknown on iOS.
  unknown,

  /// Indicates NFCMiFareFamily#ultralight on iOS.
  ultralight,

  /// Indicates NFCMiFareFamily#plus on iOS.
  plus,

  /// Indicates NFCMiFareFamily#desfire on iOS.
  desfire,
}
