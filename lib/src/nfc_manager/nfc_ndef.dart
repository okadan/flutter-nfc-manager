import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../channel.dart';
import '../translator.dart';
import './nfc_manager.dart';

/// The class provides access to NDEF operations on the tag.
/// 
/// Acquire `Ndef` instance using `Ndef.from`.
class Ndef {
  /// Constructs an instance with the given values for testing.
  /// 
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `Ndef.from` are valid.
  const Ndef({
    @required NfcTag tag,
    @required this.isWritable,
    @required this.maxSize,
    @required this.cachedMessage,
    @required this.additionalData,
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from Ndef#isWritable on Android, NFCNDEFTag#queryStatus on iOS.
  final bool isWritable;

  /// The value from Ndef#maxSize on Android, NFCNDEFTag#queryStatus on iOS.
  final int maxSize;

  /// The value from Ndef#cachedNdefMessage on Android, NFCNDEFTag#read on iOS.
  /// 
  /// This value is cached at tag discovery.
  final NdefMessage cachedMessage;

  /// The value represents some additional data.
  final Map<String, dynamic> additionalData;

  /// Get an instance of `Ndef` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NDEF.
  factory Ndef.from(NfcTag tag) => $GetNdef(tag);

  /// Read the current NDEF message on this tag.
  Future<NdefMessage> read() async {
    return channel.invokeMethod('Ndef#read', {
      'handle': _tag.handle,
    }).then((value) => $GetNdefMessage(Map.from(value)));
  }

  /// Write the NDEF message on this tag.
  Future<void> write(NdefMessage message) async {
    return channel.invokeMethod('Ndef#write', {
      'handle': _tag.handle,
      'message': $GetNdefMessageMap(message),
    });
  }

  /// Change the NDEF status to read-only.
  /// 
  /// This is a permanent action that you cannot undo. After locking the tag, you can no longer write data to it.
  Future<void> writeLock() async {
    return channel.invokeMethod('Ndef#writeLock', {
      'handle': _tag.handle,
    });
  }
}

/// The class represents the immutable NDEF message.
class NdefMessage {
  /// Constructs an instance with given records.
  const NdefMessage(this.records);

  /// Records.
  final List<NdefRecord> records;

  /// The length in bytes of the NDEF message when stored on the tag.
  int get byteLength =>
    records.isEmpty ? 0 : records.map((e) => e.byteLength).reduce((a, b) => a + b);
}

/// The class represents the immutable NDEF record.
class NdefRecord {
  /// URI_PREFIX_LIST
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

  /// Type Name Format.
  final NdefTypeNameFormat typeNameFormat;

  /// Type.
  final Uint8List type;

  /// Identifier.
  final Uint8List identifier;

  /// Payload.
  final Uint8List payload;

  /// The length in bytes of the NDEF record when stored on the tag.
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

  /// Constructs an instance with the given values.
  /// 
  /// Recommend to use other factory constructors such as `createText` or `createUri` where possible,
  /// since they will ensure that the records are formatted correctly according to the NDEF specification.
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

  /// Constructs an instance containing UTF-8 text.
  /// 
  /// Can specify the `languageCode` for the given text, `en` by default.
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

  /// Constructs an instance containing URI.
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

  /// Constructs an instance containing media data as defined by RFC 2046.
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

  /// Constructs an instance containing external (application-specific) data.
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

/// Represents the NDEF Type-Name-Format as defined by the NFC specification.
enum NdefTypeNameFormat {
  /// The record contains no data.
  empty,

  /// The record contains well-known NFC record type data.
  nfcWellknown,

  /// The record contains media data as defined by RFC 2046.
  media,

  /// The record contains uniform resource identifier.
  absoluteUri,

  /// The record contains NFC external type data.
  nfcExternal,

  /// The record type is unknown.
  unknown,

  /// The record is part of a series of records containing chunked data.
  unchanged,
}
