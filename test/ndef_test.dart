import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  test('create_text_record', () {
    NdefRecord record = NdefRecord.createTextRecord('text');
    expect(record.typeNameFormat, 0x01);
    expect(record.type, [0x54]);
    expect(record.identifier, []);
    expect(record.payload, [0x02]+'entext'.codeUnits);
  });

  test('create_text_record_languageCode', () {
    NdefRecord record = NdefRecord.createTextRecord('text', languageCode: 'zh');
    expect(record.typeNameFormat, 0x01);
    expect(record.type, [0x54]);
    expect(record.identifier, []);
    expect(record.payload, [0x02]+'zhtext'.codeUnits);
  });

  test('create_uri_record', () {
    NdefRecord record = NdefRecord.createUriRecord(Uri.parse('https://flutter.dev'));
    expect(record.typeNameFormat, 0x01);
    expect(record.type, [0x55]);
    expect(record.identifier, []);
    expect(record.payload, [4]+'flutter.dev'.codeUnits);
  });

  test('create_uri_record_unknown_prefix', () {
    NdefRecord record = NdefRecord.createUriRecord(Uri.parse('unknown://flutter.dev'));
    expect(record.typeNameFormat, 0x01);
    expect(record.type, [0x55]);
    expect(record.identifier, []);
    expect(record.payload, [0]+'unknown://flutter.dev'.codeUnits);
  });

  test('create_mime_record', () {
    NdefRecord record = NdefRecord.createMimeRecord('text/plain', Uint8List.fromList('hello'.codeUnits));
    expect(record.typeNameFormat, 0x02);
    expect(record.type, 'text/plain'.codeUnits);
    expect(record.identifier, []);
    expect(record.payload, 'hello'.codeUnits);
  });

  test('create_external_record', () {
    NdefRecord record = NdefRecord.createExternalRecord('com.mydomain', 'mytype', Uint8List.fromList('hello'.codeUnits));
    expect(record.typeNameFormat, 0x04);
    expect(record.type, 'com.mydomain:mytype'.codeUnits);
    expect(record.identifier, []);
    expect(record.payload, 'hello'.codeUnits);
  });
}
