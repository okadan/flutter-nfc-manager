import 'dart:typed_data';

class NdefMessage {
  const NdefMessage({required this.records});

  final List<NdefRecord> records;

  static NdefMessage parse({required Uint8List data}) {
    final records = NdefRecord.parse(data: data, ignoreMbMe: false);
    return NdefMessage(records: records);
  }

  int get byteLength {
    return records.isEmpty
      ? 0
      : records.map((e) => e.byteLength).reduce((a, b) => a + b);
  }

  Uint8List toByteArray() {
    final List<int> data = [];
    for (var i = 0; i < records.length; i++) {
      final bool mb = i == 0;
      final bool me = i == records.length - 1;
      data.addAll(records[i].toByteArray(mb: mb, me: me));
    }
    return Uint8List.fromList(data);
  }
}

class NdefRecord {
  NdefRecord._({
    required this.typeNameFormat,
    required this.type,
    required this.identifier,
    required this.payload,
  });

  final NdefTypeNameFormat typeNameFormat;

  final Uint8List type;

  final Uint8List identifier;

  final Uint8List payload;

  static const int _mb = 0x80;
  static const int _me = 0x40;
  static const int _cf = 0x20;
  static const int _sr = 0x10;
  static const int _il = 0x08;

  factory NdefRecord({
    required NdefTypeNameFormat typeNameFormat,
    required Uint8List type,
    required Uint8List identifier,
    required Uint8List payload,
  }) {
    _validateTnf(typeNameFormat.index, type, identifier, payload);
    return NdefRecord._(
      typeNameFormat: typeNameFormat,
      type: type,
      identifier: identifier,
      payload: payload,
    );
  }

  static List<NdefRecord> parse({required Uint8List data, required bool ignoreMbMe}) {
    final List<NdefRecord> records = [];

    var type = <int>[];
    var id = <int>[];
    var payload = <int>[];
    var chunks = <List<int>>[];
    var inChunk = false;
    var chunkTnf = -1;
    var me = false;

    while (!me) {
      final flag = data.removeAt(0);
      final mb = (flag & _me) != 0;
      me = (flag & _me) != 0;
      final cf = (flag & _cf) != 0;
      final sr = (flag & _sr) != 0;
      final il = (flag & _il) != 0;
      var tnf = flag & 0x07;

      if (!mb && records.isEmpty && !inChunk && !ignoreMbMe) {
        throw 'expected MB flag';
      } else if (mb && (records.isNotEmpty || inChunk) && !ignoreMbMe) {
        throw 'unexpected MB flag';
      } else if (inChunk && il) {
        throw 'unexpected IL flag in non-leading chunk';
      } else if (cf && me) {
        throw 'unexpected ME flag in non-trailing chunk';
      } else if (inChunk && tnf != NdefTypeNameFormat.unchanged.index) {
        throw 'expected UNCHANGED in non-leading chunk';
      } else if (!inChunk && tnf == NdefTypeNameFormat.unchanged.index) {
        throw 'unexpected UNCHANGED in first chunk or unchunked record';
      }

      final typeLength = data.removeAt(0) & 0xFF;
      var payloadLength = sr ? (data.removeAt(0) & 0xFF) : (data.removeAt(0) & 0xFFFFFFFF);
      final idLength = il ? data.removeAt(0) & 0xFF : 0;

      if (inChunk && typeLength != 0) {
          throw 'expected zero-length type in non-leading chunk';
      }

      if (!inChunk) {
        type = data.getRange(0, typeLength).toList();
        data.removeRange(0, typeLength);
        id = data.getRange(0, idLength).toList();
        data.removeRange(0, idLength);
      }

      _ensureSanePayloadSize(payloadLength);

      payload = data.getRange(0, payloadLength).toList();
      data.removeRange(0, payloadLength);

      if (cf && !inChunk) {
        // first chunk
        if (typeLength == 0 && tnf != NdefTypeNameFormat.unknown.index) {
          throw 'expected non-zero type length in first chunk';
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
        _ensureSanePayloadSize(payloadLength);
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

      _validateTnf(
        tnf,
        Uint8List.fromList(type),
        Uint8List.fromList(id),
        Uint8List.fromList(payload),
      );

      records.add(NdefRecord._(
        typeNameFormat: NdefTypeNameFormat.values[tnf],
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

  int get byteLength {
    var length = 3 + type.length + identifier.length + payload.length;

    // not short record
    if (payload.length > 255)
      length += 3;

    // id length
    if (typeNameFormat == NdefTypeNameFormat.empty || identifier.isNotEmpty)
      length += 1;

    return length;
  }

  Uint8List toByteArray({required bool mb, required bool me}) {
    final sr = payload.length < 256;
    final il = typeNameFormat == NdefTypeNameFormat.empty || identifier.isNotEmpty;
    final int flags = (mb ? _mb : 0) | (me ? _me : 0) | (sr ? _sr : 0) | (il ? _il : 0) | typeNameFormat.index;
    return Uint8List.fromList([
      flags,
      type.length,
      payload.length,
      if (il) identifier.length,
      ...type,
      ...identifier,
      ...payload,
    ]);
  }

  static void _validateTnf(int tnf, Uint8List type, Uint8List id, Uint8List payload) {
    if (NdefTypeNameFormat.values.length <= tnf)
      throw 'unexpected tnf value: $tnf.';
    final typeNameFormat = NdefTypeNameFormat.values[tnf];
    switch (typeNameFormat) {
      case NdefTypeNameFormat.empty:
        if (type.isNotEmpty || id.isNotEmpty || payload.isNotEmpty)
          throw 'unexpected data in EMPTY record.';
        break;
      case NdefTypeNameFormat.nfcWellknown:
      case NdefTypeNameFormat.media:
      case NdefTypeNameFormat.absoluteUri:
      case NdefTypeNameFormat.external:
        break;
      case NdefTypeNameFormat.unknown:
        if (type.isNotEmpty)
          throw 'unexpected type field in UNKNOWN record.';
        break;
      case NdefTypeNameFormat.unchanged:
        throw 'unexpected UNCHANGED in first chunk or logical record.';
    }
  }

  static void _ensureSanePayloadSize(int size) {
    const int MAX_PAYLOAD_SIZE = 10 * (1 << 20); // 10 MB.
    if (size > MAX_PAYLOAD_SIZE)
      throw 'payload above max limit: $size > $MAX_PAYLOAD_SIZE.';
  }
}

enum NdefTypeNameFormat {
  empty,

  nfcWellknown,

  media,

  absoluteUri,

  external,

  unknown,

  unchanged,
}
