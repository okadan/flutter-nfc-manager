import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

/// The class providing access to ISO 7816 operations for iOS.
///
/// Acquire an instance using [from(NfcTag)].
final class Iso7816Ios {
  const Iso7816Ios._(
    this._handle, {
    required this.initialSelectedAID,
    required this.identifier,
    required this.historicalBytes,
    required this.applicationData,
    required this.proprietaryApplicationDataCoding,
  });

  final String _handle;

  // TODO: DOC
  final String initialSelectedAID;

  // TODO: DOC
  final Uint8List identifier;

  // TODO: DOC
  final Uint8List? historicalBytes;

  // TODO: DOC
  final Uint8List? applicationData;

  // TODO: DOC
  final bool proprietaryApplicationDataCoding;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static Iso7816Ios? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.iso7816;
    if (data == null || tech == null) return null;
    return Iso7816Ios._(
      data.handle,
      initialSelectedAID: tech.initialSelectedAID,
      identifier: tech.identifier,
      historicalBytes: tech.historicalBytes,
      applicationData: tech.applicationData,
      proprietaryApplicationDataCoding: tech.proprietaryApplicationDataCoding,
    );
  }

  // TODO: DOC
  Future<Iso7816ResponseApduIos> sendCommand({
    required int instructionClass,
    required int instructionCode,
    required int p1Parameter,
    required int p2Parameter,
    required Uint8List data,
    required int expectedResponseLength,
  }) {
    return hostApi
        .iso7816SendCommand(
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
          (value) => Iso7816ResponseApduIos(
            payload: value.payload,
            statusWord1: value.statusWord1,
            statusWord2: value.statusWord2,
          ),
        );
  }

  // TODO: DOC
  Future<Iso7816ResponseApduIos> sendCommandRaw({required Uint8List data}) {
    return hostApi
        .iso7816SendCommandRaw(handle: _handle, data: data)
        .then(
          (value) => Iso7816ResponseApduIos(
            payload: value.payload,
            statusWord1: value.statusWord1,
            statusWord2: value.statusWord2,
          ),
        );
  }
}

// TODO: DOC
final class Iso7816ResponseApduIos {
  // TODO: DOC
  @visibleForTesting
  const Iso7816ResponseApduIos({
    required this.payload,
    required this.statusWord1,
    required this.statusWord2,
  });

  // TODO: DOC
  final Uint8List payload;

  // TODO: DOC
  final int statusWord1;

  // TODO: DOC
  final int statusWord2;
}
