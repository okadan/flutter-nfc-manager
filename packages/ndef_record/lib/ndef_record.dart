import 'dart:typed_data' show Uint8List;

import 'package:collection/collection.dart';

const _iterableEquality = IterableEquality<Object>();

/// The values that indicate the content type for the payload data.
enum TypeNameFormat {
  /// The payload contains no data.
  empty,

  /// The payload contains well-known record type data.
  wellKnown,

  /// The payload contains media data as defined by RFC 2046.
  media,

  /// The payload contains a uniform resource identifier.
  absoluteUri,

  /// The payload contains NFC external type data.
  external,

  /// The payload data type is unknown.
  unknown,

  /// The payload is part of a series of records containing chunked data.
  unchanged,
}

/// The NDEF message consisting of a list of records.
final class NdefMessage {
  /// Constructs an NDEF message from list of records.
  const NdefMessage({required this.records});

  /// The list of records for the message.
  final List<NdefRecord> records;

  /// The length of this message in bytes.
  int get byteLength {
    return records.fold(0, (p, e) => p + e.byteLength);
  }

  @override
  int get hashCode {
    return Object.hashAll(records);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NdefMessage &&
        _iterableEquality.equals(other.records, records);
  }
}

/// The NDEF record in an message.
final class NdefRecord {
  const NdefRecord._({
    required this.typeNameFormat,
    required this.type,
    required this.identifier,
    required this.payload,
  });

  /// The Type Name Format field of the record, as defined by the NDEF specification.
  final TypeNameFormat typeNameFormat;

  /// The type of the record, as defined by the NDEF specification.
  final Uint8List type;

  /// The identifier of the record, as defined by the NDEF specification.
  final Uint8List identifier;

  /// The payload of the record, as defined by the NDEF specification.
  final Uint8List payload;

  /// Constructs an NDEF record from its fields.
  ///
  /// Throws [FormatException] if a valid record cannot be created.
  factory NdefRecord({
    required TypeNameFormat typeNameFormat,
    required Uint8List type,
    required Uint8List identifier,
    required Uint8List payload,
  }) {
    switch (typeNameFormat) {
      case TypeNameFormat.empty:
        if (type.isNotEmpty || identifier.isNotEmpty || payload.isNotEmpty) {
          throw FormatException('unexpected data in EMPTY record.');
        }
      case TypeNameFormat.unknown:
        if (type.isNotEmpty) {
          throw FormatException('unexpected type field in UNKNOWN record.');
        }
      case TypeNameFormat.unchanged:
        throw FormatException(
          'unexpected UNCHANGED record in first chunk or logical record.',
        );
      default:
        break;
    }
    return NdefRecord._(
      typeNameFormat: typeNameFormat,
      type: type,
      identifier: identifier,
      payload: payload,
    );
  }

  /// The length of this record in bytes.
  int get byteLength {
    int length = 3 + type.length + identifier.length + payload.length;

    // long record
    if (payload.length > 255) {
      length += 3;
    }

    // identifier length
    if (typeNameFormat == TypeNameFormat.empty || identifier.isNotEmpty) {
      length += 1;
    }

    return length;
  }

  @override
  int get hashCode {
    return Object.hashAll([typeNameFormat, ...type, ...identifier, ...payload]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NdefRecord &&
        other.typeNameFormat == typeNameFormat &&
        _iterableEquality.equals(other.type, type) &&
        _iterableEquality.equals(other.identifier, identifier) &&
        _iterableEquality.equals(other.payload, payload);
  }
}
