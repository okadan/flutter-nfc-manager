import 'dart:convert';
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
    Uint8List identifier,
    this.typeNameFormat,
    this.type,
    this.payload,
  ) : this.identifier = identifier ?? Uint8List.fromList([]);

  final Uint8List identifier;

  final int typeNameFormat;

  final Uint8List type;

  final Uint8List payload;

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
    Uint8List identifier,
    int typeNameFormat,
    Uint8List type,
    Uint8List payload,
  }) {
    final _identifier = identifier ?? Uint8List.fromList([]);
    final _payload = payload ?? Uint8List.fromList([]);
    final _type = type ?? Uint8List.fromList([]);

    switch (typeNameFormat) {
      case 0x00:
        if (_identifier.isNotEmpty || _payload.isNotEmpty || _type.isNotEmpty)
          throw('unexpected data in TNF_EMPTY record');
        break;
      case 0x01:
      case 0x02:
      case 0x03:
      case 0x04:
        break;
      case 0x05:
      case 0x07:
        if (_type.isNotEmpty)
          throw('unexpected type field in TNF_UNKNOWN or TNF_RESERVE record');
        break;
      case 0x06:
        throw('unexpected TNF_UNCHANGED in first chunk or logical record');
      default:
        throw('unexpected format value: $typeNameFormat');
    }

    return NdefRecord._(_identifier, typeNameFormat, _type, _payload);
  }

  /// Create an NDEF record containing external (applicattion-specific) data.
  /// 
  /// The exception may be thrown if the domain/type is empty.
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
      identifier: null,
      typeNameFormat: 0x04,
      type: bytes,
      payload: data,
    );
  }

  /// Create an NDEF record containing a UTF-8 text.
  /// 
  /// Can either specify the languageCode for the provided text,
  /// or otherwise the corresponding to the cached locale will be used.
  /// 
  /// The exception may be thrown if the text is empty or the languageCode is too long.
  factory NdefRecord.createTextRecord(String text, {String languageCode}) {
    if (text == null)
      throw('test is null');

    final languageCodeBytes = ascii.encode(
      languageCode ?? Locale.cachedLocale.languageCode,
    );
    if (languageCodeBytes.length >= 64)
      throw('languageCode is too long');

    final textBytes = languageCodeBytes + utf8.encode(text);

    return NdefRecord(
      identifier: null,
      typeNameFormat: 0x01,
      type: Uint8List.fromList([0x54]),
      payload: Uint8List.fromList([languageCodeBytes.length] + textBytes),
    );
  }

  /// Create an NDEF record containing a uri.
  /// 
  /// The uri string will be normalized to set the scheme to lower case.
  /// 
  /// The exception may be thrown if the uri has serious problems, for example it is empty.
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
      identifier: null,
      typeNameFormat: 0x01,
      type: Uint8List.fromList([0x55]),
      payload: Uint8List.fromList([prefixIndex] + uriBytes),
    );
  }

  factory NdefRecord.fromJson(Map<String, dynamic> data) {
    return NdefRecord(
      identifier: data['identifier'],
      typeNameFormat: data['typeNameFormat'],
      type: data['type'],
      payload: data['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'typeNameFormat': typeNameFormat,
      'type': type,
      'payload': payload,
    };
  }
}
