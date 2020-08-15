import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../channel.dart';
import '../translator.dart';
import './nfc_manager.dart';

// Ndef
class Ndef {
  // Ndef
  const Ndef({
    @required this.tag,
    @required this.isWritable,
    @required this.maxSize,
    @required this.cachedMessage,
    @required this.additionalData,
  });

  // tag
  final NfcTag tag;

  // isWritable;
  final bool isWritable;

  // maxSize
  final int maxSize;

  // cachedMessage
  final NdefMessage cachedMessage;

  // additionalData
  final Map<String, dynamic> additionalData;

  // Ndef.from
  factory Ndef.from(NfcTag tag) => $GetNdef(tag);

  // read
  Future<NdefMessage> read() async {
    return channel.invokeMethod('Ndef#read', {
      'handle': tag.handle,
    }).then((value) => $GetNdefMessage(Map.from(value)));
  }

  // write
  Future<void> write(NdefMessage message) async {
    return channel.invokeMethod('Ndef#write', {
      'handle': tag.handle,
      'message': $GetNdefMessageMap(message),
    });
  }

  // writeLock
  Future<void> writeLock() async {
    return channel.invokeMethod('Ndef#writeLock', {
      'handle': tag.handle,
    });
  }
}

// NdefMessage
class NdefMessage {
  // NdefMessage
  const NdefMessage(this.records);

  // records
  final List<NdefRecord> records;

  // byteLength
  int get byteLength =>
    records.isEmpty ? 0 : records.map((e) => e.byteLength).reduce((a, b) => a + b);
}

// NdefRecord
class NdefRecord {
  // URI_PREFIX_LIST
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

  // NdefRecord
  const NdefRecord._({
    @required this.typeNameFormat,
    @required this.type,
    @required this.identifier,
    @required this.payload,
  });

  // typeNameFormat
  final NdefTypeNameFormat typeNameFormat;

  // type
  final Uint8List type;

  // identifier
  final Uint8List identifier;

  // payload
  final Uint8List payload;

  // byteLength
  int get byteLength {
    var length = 3 + type.length + identifier.length + payload.length;

    // not short record
    if (payload.length > 255)
      length += 3;

    // id length
    if (typeNameFormat == NdefTypeNameFormat.empty || identifier.length > 0)
      length += 1;

    return length;
  }

  // NdefRecord
  factory NdefRecord({
    @required NdefTypeNameFormat typeNameFormat,
    @required Uint8List type,
    @required Uint8List identifier,
    @required Uint8List payload,
  }) {
    type ??= Uint8List.fromList([]);
    identifier ??= Uint8List.fromList([]);
    payload ??= Uint8List.fromList([]);

    _validateFormat(typeNameFormat, type, identifier, payload);

    return NdefRecord._(
      typeNameFormat: typeNameFormat,
      type: type,
      identifier: identifier,
      payload: payload,
    );
  }

  // NdefRecord.createText
  factory NdefRecord.createText(String text, { String languageCode = 'en' }) {
    if (text == null)
      throw('text is null');

    final languageCodeBytes = ascii.encode(languageCode);
    if (languageCodeBytes.length >= 64)
      throw('languageCode is too long');

    return NdefRecord(
      typeNameFormat: NdefTypeNameFormat.nfcWellknown,
      type: Uint8List.fromList([0x54]),
      identifier: null,
      payload: Uint8List.fromList(
        [languageCodeBytes.length] + languageCodeBytes + utf8.encode(text),
      ),
    );
  }

  // NdefRecord.createUri
  factory NdefRecord.createUri(Uri uri) {
    if (uri == null)
      throw('uri is null');

    final uriString = uri.normalizePath().toString();
    if (uriString.isEmpty)
      throw('uri is empty');

    int prefixIndex = URI_PREFIX_LIST.indexWhere((e) => uriString.startsWith(e), 1);
    if (prefixIndex < 0) prefixIndex = 0;

    return NdefRecord(
      typeNameFormat: NdefTypeNameFormat.nfcWellknown,
      type: Uint8List.fromList([0x55]),
      identifier: null,
      payload: Uint8List.fromList(
        [prefixIndex] + utf8.encode(uriString.substring(URI_PREFIX_LIST[prefixIndex].length)),
      )
    );
  }

  // NdefRecord.createMime
  factory NdefRecord.createMime(String type, Uint8List data) {
    type = type?.toLowerCase()?.trim()?.split(';')?.first;
    if (type == null || type.isEmpty)
      throw('type is null or empty');

    final slashIndex = type.indexOf('/');
    if (slashIndex == 0)
      throw('type must have mojor type');
    if (slashIndex == type.length - 1)
      throw('type must have minor type');

    return NdefRecord(
      typeNameFormat: NdefTypeNameFormat.media,
      type: ascii.encode(type),
      identifier: null,
      payload: data,
    );
  }

  // NdefRecord.createExternal
  factory NdefRecord.createExternal(String domain, String type, Uint8List data) {
    domain = domain?.trim()?.toLowerCase();
    type = type?.trim()?.toLowerCase();
    if (domain == null || domain.isEmpty)
      throw('domain is null or empty');
    if (type == null || type.isEmpty)
      throw('type is null or empty');

    return NdefRecord(
      typeNameFormat: NdefTypeNameFormat.nfcExternal,
      type: Uint8List.fromList(utf8.encode(domain) + ':'.codeUnits + utf8.encode(type)),
      identifier: null,
      payload: data,
    );
  }

  // _validateFormat
  static void _validateFormat(
    NdefTypeNameFormat format, Uint8List type, Uint8List identifier, Uint8List payload) {
    switch (format) {
      case NdefTypeNameFormat.empty:
        if (type.isNotEmpty || identifier.isNotEmpty || payload.isNotEmpty)
          throw('unexpected data in EMPTY record');
        break;
      case NdefTypeNameFormat.nfcWellknown:
      case NdefTypeNameFormat.media:
      case NdefTypeNameFormat.absoluteUri:
      case NdefTypeNameFormat.nfcExternal:
        break;
      case NdefTypeNameFormat.unknown:
        if (type.isNotEmpty)
          throw('unexpected type field in UNKNOWN record');
        break;
      case NdefTypeNameFormat.unchanged:
        throw('unexpected UNCHANGED in first chunk or logical record');
      default:
        throw('unexpected format: $format');
    }
  }
}

// NdefTypeNameFormat
enum NdefTypeNameFormat {
  // empty
  empty,

  // nfcWellknown
  nfcWellknown,

  // media
  media,

  // absoluteUri
  absoluteUri,

  // nfcExternal
  nfcExternal,

  // unknown
  unknown,

  // unchanged
  unchanged,
}
