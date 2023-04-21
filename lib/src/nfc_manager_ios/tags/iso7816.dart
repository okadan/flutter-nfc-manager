import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

/// The class providing access to ISO 7816 operations for iOS.
///
/// Acquire an instance using [from(NfcTag)].
class Iso7816IOS {
  const Iso7816IOS._(
    this._handle, {
    required this.initialSelectedAID,
    required this.historicalBytes,
    required this.applicationData,
    required this.proprietaryApplicationDataCoding,
  });

  final String _handle;

  final String initialSelectedAID;

  final Uint8List? historicalBytes;

  final Uint8List? applicationData;

  final bool proprietaryApplicationDataCoding;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static Iso7816IOS? from(NfcTag tag) {
    final pigeon = PigeonTag.decode(tag.data).iso7816;
    return pigeon == null
        ? null
        : Iso7816IOS._(
            tag.handle,
            initialSelectedAID: pigeon.initialSelectedAID!,
            historicalBytes: pigeon.historicalBytes,
            applicationData: pigeon.applicationData,
            proprietaryApplicationDataCoding:
                pigeon.proprietaryApplicationDataCoding!,
          );
  }

  Future<Iso7816ResponseApduIOS> sendCommand({
    required int instructionClass,
    required int instructionCode,
    required int p1Parameter,
    required int p2Parameter,
    required Uint8List data,
    required int expectedResponseLength,
  }) {
    return hostApi
        .iso7816SendCommand(
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

  Future<Iso7816ResponseApduIOS> sendCommandRaw({
    required Uint8List data,
  }) {
    return hostApi
        .iso7816SendCommandRaw(_handle, data)
        .then((value) => Iso7816ResponseApduIOS(
              payload: value.payload!,
              statusWord1: value.statusWord1!,
              statusWord2: value.statusWord2!,
            ));
  }
}

class Iso7816ResponseApduIOS {
  const Iso7816ResponseApduIOS({
    required this.payload,
    required this.statusWord1,
    required this.statusWord2,
  });

  final Uint8List payload;

  final int statusWord1;

  final int statusWord2;
}
