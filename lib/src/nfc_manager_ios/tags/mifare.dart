import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/iso7816.dart';

/// The class providing access to MIFARE operations for iOS.
///
/// Acquire an instance using [from(NfcTag)].
class MiFareIOS {
  const MiFareIOS._(
    this._handle, {
    required this.mifareFamily,
    required this.historicalBytes,
  });

  final String _handle;

  final MiFareFamilyIOS mifareFamily;

  final Uint8List? historicalBytes;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static MiFareIOS? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag).miFare;
    return pigeon == null
        ? null
        : MiFareIOS._(
            tag.handle,
            mifareFamily: miFareFamilyFromPigeon(pigeon.mifareFamily!),
            historicalBytes: pigeon.historicalBytes,
          );
  }

  Future<Uint8List> sendMiFareCommand({
    required Uint8List commandPacket,
  }) {
    return hostApi.miFareSendMiFareCommand(_handle, commandPacket);
  }

  Future<Iso7816ResponseApduIOS> sendMiFareIso7816Command({
    required int instructionClass,
    required int instructionCode,
    required int p1Parameter,
    required int p2Parameter,
    required Uint8List data,
    required int expectedResponseLength,
  }) {
    return hostApi
        .miFareSendMiFareISO7816Command(
            _handle,
            PigeonISO7816APDU(
              instructionClass: instructionClass,
              instructionCode: instructionCode,
              p1Parameter: p1Parameter,
              p2Parameter: p2Parameter,
              data: data,
              expectedResponseLength: expectedResponseLength,
            ))
        .then((value) => Iso7816ResponseApduIOS(
              payload: value.payload!,
              statusWord1: value.statusWord1!,
              statusWord2: value.statusWord2!,
            ));
  }

  Future<Iso7816ResponseApduIOS> sendMiFareIso7816CommandRaw({
    required Uint8List data,
  }) {
    return hostApi
        .miFareSendMiFareISO7816CommandRaw(_handle, data)
        .then((value) => Iso7816ResponseApduIOS(
              payload: value.payload!,
              statusWord1: value.statusWord1!,
              statusWord2: value.statusWord2!,
            ));
  }
}

enum MiFareFamilyIOS {
  unknown,

  ultralight,

  plus,

  desfire,
}
