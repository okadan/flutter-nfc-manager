import 'dart:convert' show ascii, utf8;
import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:flutter/widgets.dart';

class NdefMessage {
  NdefMessage(this.records);

  final List<NdefRecord> records;

  int get byteLength => records.isEmpty
    ? 0
    : records.map((e) => e.byteLength).reduce((x, y) => x+y);

  factory NdefMessage.fromJson(Map<String, dynamic> data) {
    return NdefMessage(
      (data['records'] as List)
        .map((e) => NdefRecord.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'records': records.map((e) => e.toJson()).toList(),
    };
  }
}

class NdefRecord {
  static const URI_PREFIX_LIST = [
    '',
    'http://www.',
    'https://www.',
    'http://',
    'https://',
    'tel:',
    'mailto:',
    'ftp://anonymous:anonymous@',
    'ftp://ftp.',
    'ftps://',
    'sftp://',
    'smb://',
    'nfs://',
    'ftp://',
    'dav://',
    'news:',
    'telnet://',
    'imap:',
    'rtsp://',
    'urn:',
    'pop:',
    'sip:',
    'sips:',
    'tftp:',
    'btspp://',
    'btl2cap://',
    'btgoep://',
    'tcpobex://',
    'irdaobex://',
    'file://',
    'urn:epc:id:',
    'urn:epc:tag:',
    'urn:epc:pat:',
    'urn:epc:raw:',
    'urn:epc:',
    'urn:nfc:',
  ];

  NdefRecord._(
    this.typeNameFormat,
    this.type,
    this.identifier,
    this.payload,
  );

  final int typeNameFormat;

  final Uint8List type;

  final Uint8List identifier;

  final Uint8List payload;

  /// Length in bytes that stored on this record.
  int get byteLength {
    var length = 3 + type.length + identifier.length + payload.length;

    // Not Short Record
    if (payload.length >= 256)
      length += 3;

    // ID Length
    if (typeNameFormat == 0x00 || identifier.length > 0)
      length += 1;

    return length;
  }

  /// Create an NDEF record from its component fields.
  /// 
  /// Recommended to use other factory constructors such as `createExternalRecord` where possible,
  /// since they perform validation that the record is correctly formatted as NDEF.
  /// However if you know what you are doing then this constructor offers the most flexibility.
  factory NdefRecord({
    int typeNameFormat,
    Uint8List type,
    Uint8List identifier,
    Uint8List payload,
  }) {
    final _type = type ?? Uint8List.fromList([]);
    final _identifier = identifier ?? Uint8List.fromList([]);
    final _payload = payload ?? Uint8List.fromList([]);

    _validateFormat(typeNameFormat, _type, _identifier, _payload);

    return NdefRecord._(typeNameFormat, _type, _identifier, _payload);
  }

  /// Create an NDEF record containing external (applicattion-specific) data.
  factory NdefRecord.createExternalRecord(String domain, String type, Uint8List data) {
    if (domain == null)
      throw('domain is null');
    if (type == null)
      throw('type is null');

    final _domain = domain.trim().toLowerCase();
    final _type = type.trim().toLowerCase();

    if (_domain.isEmpty)
      throw('domain is empty');
    if (_type.isEmpty)
      throw('type is empty');

    final domainBytes = utf8.encode(_domain);
    final typeBytes = utf8.encode(_type);
    final bytes = domainBytes + ':'.codeUnits + typeBytes;

    return NdefRecord(
      typeNameFormat: 0x04,
      type: bytes,
      identifier: null,
      payload: data,
    );
  }

  /// Create an NDEF record containing a mime data
  factory NdefRecord.createMimeRecord(String type, Uint8List data) {
    if (type == null)
      throw('type is null');
    final normalized = type.toLowerCase().trim().split(';').first;
    if (normalized.isEmpty)
      throw('type is empty');

    final slashIndex = normalized.indexOf('/');
    if (slashIndex == 0)
      throw('type must have major type');
    if (slashIndex == normalized.length - 1)
      throw('type must have minor type');

    return NdefRecord(
      typeNameFormat: 0x02,
      type: ascii.encode(type),
      identifier: null,
      payload: data,
    );
  }

  /// Create an NDEF record containing a UTF-8 text.
  /// 
  /// Can either specify the languageCode for the provided text,
  /// or otherwise the corresponding to the cached locale will be used.
  factory NdefRecord.createTextRecord(String text, {String languageCode}) {
    if (text == null)
      throw('text is null');

    final languageCodeBytes = ascii.encode(
      languageCode ?? Locale.cachedLocale.languageCode,
    );
    if (languageCodeBytes.length >= 64)
      throw('languageCode is too long');

    final textBytes = languageCodeBytes + utf8.encode(text);

    return NdefRecord(
      typeNameFormat: 0x01,
      type: Uint8List.fromList([0x54]),
      identifier: null,
      payload: Uint8List.fromList([languageCodeBytes.length] + textBytes),
    );
  }

  /// Create an NDEF record containing a uri.
  factory NdefRecord.createUriRecord(Uri uri) {
    if (uri == null)
      throw('uri is null');

    final uriString = uri.normalizePath().toString();
    if (uriString.length < 1)
      throw('uri is empty');

    var prefixIndex = URI_PREFIX_LIST.indexWhere((e) => uriString.startsWith(e), 1);
    if (prefixIndex < 0) prefixIndex = 0;

    final uriBytes = utf8.encode(
      uriString.substring(URI_PREFIX_LIST[prefixIndex].length),
    );

    return NdefRecord(
      typeNameFormat: 0x01,
      type: Uint8List.fromList([0x55]),
      identifier: null,
      payload: Uint8List.fromList([prefixIndex] + uriBytes),
    );
  }

  factory NdefRecord.fromJson(Map<String, dynamic> data) {
    return NdefRecord(
      typeNameFormat: data['typeNameFormat'],
      type: data['type'],
      identifier: data['identifier'],
      payload: data['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typeNameFormat': typeNameFormat,
      'type': type,
      'identifier': identifier,
      'payload': payload,
    };
  }
}

void _validateFormat(int format, Uint8List type, Uint8List identifier, Uint8List payload) {
  switch (format) {
    case 0x00:
      if (type.isNotEmpty || identifier.isNotEmpty || payload.isNotEmpty)
        throw('unexpected data in EMPTY record');
        break;
    case 0x01:
    case 0x02:
    case 0x03:
    case 0x04:
      break;
    case 0x05:
    case 0x07:
      if (type.isNotEmpty)
        throw('unexpected type field in UNKNOWN or RESERVE record');
      break;
    case 0x06:
      throw('unexpected UNCHANGED in first chunk or logical record');
    default:
      throw('unexpected format value: $format');
  }
}
