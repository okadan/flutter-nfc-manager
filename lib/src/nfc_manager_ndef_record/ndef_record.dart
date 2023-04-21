import "dart:typed_data" show Uint8List;

// The flag indicating that this is the first record in a message.
const int _mb = 0x80;

// The flag indicating that this is the last record in a message.
const int _me = 0x40;

// Tha flag indicating that this record is chunked.
const int _cf = 0x20;

// Tha flag indicating that this record is formatted as a short record.
const int _sr = 0x10;

// Tha flag indicating that this record has an ID length.
const int _il = 0x08;

/// The NDEF message consisting of a list of records.
class NdefMessage {
  /// Constructs an NDEF message from list of records.
  NdefMessage({required this.records});

  /// The list of records for the message.
  final List<NdefRecord> records;

  /// The length of this message in bytes.
  int get byteLength => records.fold(0, (p, e) => p + e.byteLength);

  /// Constructs an NDEF message by parsing raw bytes.
  ///
  /// Throws [FormatException] if bytes cannot be parsed.
  static NdefMessage parse(Uint8List bytes) {
    return NdefMessage(
      records: NdefRecord.parse(bytes, ignoreMbMe: false),
    );
  }

  /// Returns this NDEF message as raw bytes.
  Uint8List toBytes() {
    final bytes = Uint8List(byteLength);
    for (var i = 0; i < records.length; i++) {
      final mb = i == 0;
      final me = i == records.length - 1;
      bytes.addAll(records[i].toBytes(mb: mb, me: me));
    }
    return bytes;
  }
}

/// The NDEF record in an message.
class NdefRecord {
  /// Constructs an NDEF record from its fields.
  ///
  /// Throws [FormatException] if a valid record cannot be created.
  NdefRecord({
    required this.typeNameFormat,
    required this.type,
    required this.identifier,
    required this.payload,
  }) {
    _validate(typeNameFormat, type, identifier, payload);
  }

  /// The Type Name Format field of the record, as defined by the NDEF specification.
  final TypeNameFormat typeNameFormat;

  /// The type of the record, as defined by the NDEF specification.
  final Uint8List type;

  /// The identifier of the record, as defined by the NDEF specification.
  final Uint8List identifier;

  /// The payload of the record, as defined by the NDEF specification.
  final Uint8List payload;

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

  /// Constructs the list of NDEF records by parsing raw bytes.
  ///
  /// Throws [FormatException] if bytes cannot be parsed.
  static List<NdefRecord> parse(Uint8List bytes, {required bool ignoreMbMe}) {
    final records = <NdefRecord>[];

    var type = <int>[];
    var id = <int>[];
    var payload = <int>[];
    var chunks = <List<int>>[];
    var inChunk = false;
    var chunkTnf = -1;
    var me = false;

    while (!me) {
      final flag = bytes.removeAt(0);
      final mb = (flag & _me) != 0;
      me = (flag & _me) != 0;
      final cf = (flag & _cf) != 0;
      final sr = (flag & _sr) != 0;
      final il = (flag & _il) != 0;
      var tnf = flag & 0x07;

      if (!mb && records.isEmpty && !inChunk && !ignoreMbMe) {
        throw FormatException("expected MB flag");
      } else if (mb && (records.isNotEmpty || inChunk) && !ignoreMbMe) {
        throw FormatException("unexpected MB flag");
      } else if (inChunk && il) {
        throw FormatException("unexpected IL flag in non-leading chunk");
      } else if (cf && me) {
        throw FormatException("unexpected ME flag in non-trailing chunk");
      } else if (inChunk && tnf != TypeNameFormat.unchanged.index) {
        throw FormatException("expected UNCHANGED in non-leading chunk");
      } else if (!inChunk && tnf == TypeNameFormat.unchanged.index) {
        throw FormatException(
            "unexpected UNCHANGED in first chunk or unchunked record");
      }

      final typeLength = bytes.removeAt(0) & 0xFF;
      var payloadLength =
          sr ? (bytes.removeAt(0) & 0xFF) : (bytes.removeAt(0) & 0xFFFFFFFF);
      final idLength = il ? bytes.removeAt(0) & 0xFF : 0;

      if (inChunk && typeLength != 0) {
        throw FormatException("expected zero-length type in non-leading chunk");
      }

      if (!inChunk) {
        type = bytes.getRange(0, typeLength).toList();
        bytes.removeRange(0, typeLength);
        id = bytes.getRange(0, idLength).toList();
        bytes.removeRange(0, idLength);
      }

      _validatePayloadSize(payloadLength);

      payload = bytes.getRange(0, payloadLength).toList();
      bytes.removeRange(0, payloadLength);

      if (cf && !inChunk) {
        // first chunk
        if (typeLength == 0 && tnf != TypeNameFormat.unknown.index) {
          throw FormatException("expected non-zero type length in first chunk");
        }
        chunks.clear();
        chunkTnf = tnf;
      }
      if (cf || inChunk) {
        // any chunk
        chunks.add(payload);
      }
      if (!cf && inChunk) {
        // last chunk, flatten the payload
        payloadLength = chunks.map((e) => e.length).reduce((a, b) => a + b);
        _validatePayloadSize(payloadLength);
        payload = chunks.expand((e) => e).toList();
        tnf = chunkTnf;
      }
      if (cf) {
        // more chunks to come
        inChunk = true;
        continue;
      } else {
        inChunk = false;
      }

      records.add(NdefRecord(
        typeNameFormat: TypeNameFormat.values[tnf],
        type: Uint8List.fromList(type),
        identifier: Uint8List.fromList(id),
        payload: Uint8List.fromList(payload),
      ));

      if (ignoreMbMe) {
        break;
      }
    }

    return records;
  }

  /// Returns this NDEF record as raw bytes.
  Uint8List toBytes({required bool mb, required bool me}) {
    final sr = payload.length < 256;
    final il = typeNameFormat == TypeNameFormat.empty || identifier.isNotEmpty;
    final flags = (mb ? _mb : 0) |
        (me ? _me : 0) |
        (sr ? _sr : 0) |
        (il ? _il : 0) |
        typeNameFormat.index;
    return Uint8List.fromList([
      flags,
      type.length,
      if (sr)
        payload.length
      else
        ...(Uint8List(4)..buffer.asByteData().setInt32(0, payload.length)),
      if (il) identifier.length,
      ...type,
      ...identifier,
      ...payload,
    ]);
  }

  // Perform simple validation that the fields are valid.
  static void _validate(TypeNameFormat typeNameFormat, Uint8List type,
      Uint8List identifier, Uint8List payload) {
    switch (typeNameFormat) {
      case TypeNameFormat.empty:
        if (type.isNotEmpty || identifier.isNotEmpty || payload.isNotEmpty) {
          throw FormatException("unexpected data in EMPTY record.");
        }
        break;
      case TypeNameFormat.wellKnown:
      case TypeNameFormat.media:
      case TypeNameFormat.absoluteUri:
      case TypeNameFormat.external:
        break;
      case TypeNameFormat.unknown:
        if (type.isNotEmpty) {
          throw FormatException("unexpected type field in UNKNOWN record.");
        }
        break;
      case TypeNameFormat.unchanged:
        throw FormatException(
            "unexpected UNCHANGED record in first chunk or logical record.");
    }
  }

  // Perfofrm simple validation that the payload size is valid.
  static void _validatePayloadSize(int size) {
    const int maxPayloadSize = 10 * (1 << 20); // 10 MB.
    if (size > maxPayloadSize) {
      throw FormatException("payload above max limit: $size > $maxPayloadSize");
    }
  }
}

/// The values that specify the content type for the payload data.
enum TypeNameFormat {
  /// The type indicating that the payload contains no data.
  empty,

  /// The type indicating that the payload contains well-known record type data.
  wellKnown,

  /// The type indicating that the payload contains media data as defined by RFC 2046.
  media,

  /// The type indicating that the payload contains a uniform resource identifier.
  absoluteUri,

  /// The type indicating that the payload contains NFC external type data.
  external,

  /// The type indicating that the payload data type is unknown.
  unknown,

  /// The type indicating that the payload is part of a series of records containing chunked data.
  unchanged,
}
