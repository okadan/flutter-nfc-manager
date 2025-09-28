import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/iso7816.dart';

/// Provides access to MiFare operations for iOS.
///
/// Acquire an instance using [from(NfcTag)].
final class MiFareIos {
  const MiFareIos._(
    this._handle, {
    required this.identifier,
    required this.mifareFamily,
    required this.historicalBytes,
  });

  final String _handle;

  // DOC:
  final Uint8List identifier;

  // DOC:
  final MiFareFamilyIos mifareFamily;

  // DOC:
  final Uint8List? historicalBytes;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static MiFareIos? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.miFare;
    if (data == null || tech == null) return null;
    return MiFareIos._(
      data.handle,
      identifier: tech.identifier,
      mifareFamily: MiFareFamilyIos.values.byName(tech.mifareFamily.name),
      historicalBytes: tech.historicalBytes,
    );
  }

  // DOC:
  Future<Uint8List> sendMiFareCommand({required Uint8List commandPacket}) {
    return hostApi.miFareSendMiFareCommand(
      handle: _handle,
      commandPacket: commandPacket,
    );
  }

  // DOC:
  Future<Iso7816ResponseApduIos> sendMiFareIso7816Command({
    required int instructionClass,
    required int instructionCode,
    required int p1Parameter,
    required int p2Parameter,
    required Uint8List data,
    required int expectedResponseLength,
  }) {
    return hostApi
        .miFareSendMiFareISO7816Command(
          handle: _handle,
          apdu: Iso7816ApduPigeon(
            instructionClass: instructionClass,
            instructionCode: instructionCode,
            p1Parameter: p1Parameter,
            p2Parameter: p2Parameter,
            data: data,
            expectedResponseLength: expectedResponseLength,
          ),
        )
        .then(
          // ignore: invalid_use_of_visible_for_testing_member
          (value) => Iso7816ResponseApduIos(
            payload: value.payload,
            statusWord1: value.statusWord1,
            statusWord2: value.statusWord2,
          ),
        );
  }

  // DOC:
  Future<Iso7816ResponseApduIos> sendMiFareIso7816CommandRaw({
    required Uint8List data,
  }) {
    return hostApi
        .miFareSendMiFareISO7816CommandRaw(handle: _handle, data: data)
        .then(
          // ignore: invalid_use_of_visible_for_testing_member
          (value) => Iso7816ResponseApduIos(
            payload: value.payload,
            statusWord1: value.statusWord1,
            statusWord2: value.statusWord2,
          ),
        );
  }
}

// DOC:
enum MiFareFamilyIos {
  // DOC:
  unknown,

  // DOC:
  ultralight,

  // DOC:
  plus,

  // DOC:
  desfire,
}
