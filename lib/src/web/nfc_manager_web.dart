@JS()
library flutter_nfc.js;

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:nfc_manager/nfc_manager.dart';

/// A web implementation of the NFC-Manager plugin.
class NfcManagerPlugin {
  static MethodChannel? channel;
  static StreamSubscription<html.Event>? jsSuccessSubscription;
  static StreamSubscription<html.Event>? jsErrorSubscription;

  static void registerWith(Registrar registrar) {
    // Insert JS into Html Body
    html.document.body!.append(html.ScriptElement()
      ..src =
          'assets/packages/nfc_manager/assets/flutter_nfc.js' // ignore: unsafe_html
      ..type = 'application/javascript'
      ..defer = true);

    // Register Methodchannel
    channel = MethodChannel(
      'plugins.flutter.io/nfc_manager',
      const StandardMethodCodec(),
      registrar,
    );
    final pluginInstance = NfcManagerPlugin();
    channel?.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'Nfc#isAvailable':
        bool isAvailable = await promiseToFuture(isNDEFReaderAvailable());
        return isAvailable;
      case 'Nfc#startSession':
        return _startSession();
      case 'Nfc#stopSession':
        return _stopSession();
      case 'Nfc#disposeTag':
        // do nothing
        return;
      case 'Ndef#write':
        final Map<String, dynamic> recordsJson = call.arguments['message'];
        await _startNFCWrite(recordsJson);
        return;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'nfc_manager for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Starts the NFCReader on JS-side
  void _startSession() {
    // Attach event handler for JS callback
    jsSuccessSubscription =
        html.document.on['readSuccessJS'].listen((html.Event event) {
      Map<dynamic, dynamic> jsTag = (event as html.CustomEvent).detail;
      channel?.invokeMethod("onDiscovered", jsTag);
    });
    jsErrorSubscription =
        html.document.on['readErrorJS'].listen((html.Event event) {
      Map<dynamic, dynamic> jsErrorObj = (event as html.CustomEvent).detail;
      channel?.invokeMethod("onError", jsErrorObj);
    });
    startNDEFReaderJS();
  }

  void _stopSession() {
    jsSuccessSubscription?.cancel();
    jsErrorSubscription?.cancel();
    stopNDEFReaderJS();
  }

  // Start NFC Write
  Future<void> _startNFCWrite(Map<String, dynamic> ndefMessage) async {
    if (ndefMessage['records'].length == 0) return;
    List<NdefRecord> ndefRecords = [];
    for (Map<String, dynamic> ndefRecordMap in ndefMessage['records']) {
      NdefRecord record = NdefRecord(
          ndefRecordMap["typeNameFormat"],
          ndefRecordMap["type"],
          ndefRecordMap["identifier"],
          ndefRecordMap["payload"]);
      ndefRecords.add(record);
    }
    await startNDEFWriterJS(ndefRecords);
    return;
  }
}

@JS()
external Future<bool> isNDEFReaderAvailable();
external dynamic startNDEFReaderJS();
external dynamic stopNDEFReaderJS();
external Future<void> startNDEFWriterJS(List<NdefRecord> records);

@JS()
@anonymous
class NdefRecord {
  external NdefTypeNameFormat get typeNameFormat;
  external set typeNameFormat(NdefTypeNameFormat typeNameFormat);
  external Uint8List get type;
  external set type(Uint8List type);
  external Uint8List get identifier;
  external set identifier(Uint8List identifier);
  external Uint8List get payload;
  external set payload(Uint8List payload);
  external NdefRecord(NdefTypeNameFormat typeNameFormat, Uint8List type,
      Uint8List identifier, Uint8List payload);
}
