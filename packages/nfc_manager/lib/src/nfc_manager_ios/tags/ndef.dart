import 'package:flutter/foundation.dart';
import 'package:ndef_record/ndef_record.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

/// The class providing access to NDEF operations for iOS.
///
/// Acquire an instance using [from(NfcTag)].
final class NdefIos {
  const NdefIos._(
    this._handle, {
    required this.status,
    required this.capacity,
    required this.cachedNdefMessage,
  });

  final String _handle;

  // TODO: DOC
  final NdefStatusIos status;

  // TODO: DOC
  final int capacity;

  // TODO: DOC
  final NdefMessage? cachedNdefMessage;

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NdefIos? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    final tech = data?.ndef;
    if (data == null || tech == null) return null;
    return NdefIos._(
      data.handle,
      status: NdefStatusIos.values.byName(tech.status.name),
      capacity: tech.capacity,
      cachedNdefMessage:
          tech.cachedNdefMessage == null
              ? null
              : NdefMessage(
                records:
                    tech.cachedNdefMessage!.records
                        .map(
                          (r) => NdefRecord(
                            typeNameFormat: TypeNameFormat.values.byName(
                              r.typeNameFormat.name,
                            ),
                            type: r.type,
                            identifier: r.identifier,
                            payload: r.payload,
                          ),
                        )
                        .toList(),
              ),
    );
  }

  // TODO: DOC
  Future<QueryNdefStatusResponseIos> queryNdefStatus() {
    return hostApi
        .ndefQueryNdefStatus(handle: _handle)
        .then(
          (value) => QueryNdefStatusResponseIos(
            status: NdefStatusIos.values.byName(value.status.name),
            capacity: value.capacity,
          ),
        );
  }

  // TODO: DOC
  Future<NdefMessage?> readNdef() {
    return hostApi
        .ndefReadNdef(handle: _handle)
        .then(
          (value) =>
              value == null
                  ? null
                  : NdefMessage(
                    records:
                        value.records
                            .map(
                              (r) => NdefRecord(
                                typeNameFormat: TypeNameFormat.values.byName(
                                  r.typeNameFormat.name,
                                ),
                                type: r.type,
                                identifier: r.identifier,
                                payload: r.payload,
                              ),
                            )
                            .toList(),
                  ),
        );
  }

  // TODO: DOC
  Future<void> writeNdef(NdefMessage message) {
    return hostApi.ndefWriteNdef(
      handle: _handle,
      message: NdefMessagePigeon(
        records:
            message.records
                .map(
                  (e) => NdefPayloadPigeon(
                    typeNameFormat: TypeNameFormatPigeon.values.byName(
                      e.typeNameFormat.name,
                    ),
                    type: e.type,
                    identifier: e.identifier,
                    payload: e.payload,
                  ),
                )
                .toList(),
      ),
    );
  }

  // TODO: DOC
  Future<void> writeLock() {
    return hostApi.ndefWriteLock(handle: _handle);
  }
}

// TODO: DOC
final class QueryNdefStatusResponseIos {
  // TODO: DOC
  @visibleForTesting
  const QueryNdefStatusResponseIos({
    required this.status,
    required this.capacity,
  });

  // TODO: DOC
  final NdefStatusIos status;

  // TODO: DOC
  final int capacity;
}

// TODO: DOC
enum NdefStatusIos {
  // TODO: DOC
  notSupported,

  // TODO: DOC
  readOnly,

  // TODO: DOC
  readWrite,
}
