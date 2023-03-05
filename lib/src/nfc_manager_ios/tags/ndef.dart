import 'package:flutter/foundation.dart';
import 'package:ndef_record/ndef_record.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

/// The class providing access to NDEF operations for iOS.
///
/// Acquire an instance using [from(NfcTag)].
final class NdefIOS {
  const NdefIOS._(
    this._handle, {
    required this.status,
    required this.capacity,
    required this.cachedNdefMessage,
  });

  final String _handle;

  /// DOC:
  final NdefStatusIOS status;

  /// DOC:
  final int capacity;

  /// DOC:
  final NdefMessage? cachedNdefMessage;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NdefIOS? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as PigeonTag?;
    final tech = data?.ndef;
    if (data == null || tech == null) return null;
    return NdefIOS._(
      data.handle,
      status: NdefStatusIOS.values.byName(tech.status.name),
      capacity: tech.capacity,
      cachedNdefMessage: tech.cachedNdefMessage == null
          ? null
          : NdefMessage(
              records: tech.cachedNdefMessage!.records
                  .map((r) => NdefRecord(
                        typeNameFormat: TypeNameFormat.values.byName(
                          r!.typeNameFormat.name,
                        ),
                        type: r.type,
                        identifier: r.identifier,
                        payload: r.payload,
                      ))
                  .toList(),
            ),
    );
  }

  /// DOC:
  Future<QueryNdefStatusResponseIOS> queryNdefStatus() {
    return hostApi
        .ndefQueryNDEFStatus(
          handle: _handle,
        )
        .then((value) => QueryNdefStatusResponseIOS(
              status: NdefStatusIOS.values.byName(value.status.name),
              capacity: value.capacity,
            ));
  }

  /// DOC:
  Future<NdefMessage?> readNdef() {
    return hostApi
        .ndefReadNDEF(
          handle: _handle,
        )
        .then((value) => value == null
            ? null
            : NdefMessage(
                records: value.records
                    .map((r) => NdefRecord(
                          typeNameFormat: TypeNameFormat.values.byName(
                            r!.typeNameFormat.name,
                          ),
                          type: r.type,
                          identifier: r.identifier,
                          payload: r.payload,
                        ))
                    .toList(),
              ));
  }

  /// DOC:
  Future<void> writeNdef(NdefMessage message) {
    return hostApi.ndefWriteNDEF(
        handle: _handle,
        message: PigeonNdefMessage(
          records: message.records
              .map((e) => PigeonNdefPayload(
                    typeNameFormat: PigeonTypeNameFormat.values.byName(
                      e.typeNameFormat.name,
                    ),
                    type: e.type,
                    identifier: e.identifier,
                    payload: e.payload,
                  ))
              .toList(),
        ));
  }

  /// DOC:
  Future<void> writeLock() {
    return hostApi.ndefWriteLock(
      handle: _handle,
    );
  }
}

/// DOC:
class QueryNdefStatusResponseIOS {
  /// DOC:
  @visibleForTesting
  const QueryNdefStatusResponseIOS({
    required this.status,
    required this.capacity,
  });

  /// DOC:
  final NdefStatusIOS status;

  /// DOC:
  final int capacity;
}

/// DOC:
enum NdefStatusIOS {
  /// DOC:
  notSupported,

  /// DOC:
  readOnly,

  /// DOC:
  readWrite,
}
