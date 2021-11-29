@JS()
library flutter_nfc.js;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
/*
import 'package:flutter_nfc_web/global.dart';
import 'package:flutter_nfc_web/js_ndef_record.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
*/
import 'package:js/js.dart';

/// A web implementation of the FlutterNfcWeb plugin.
class NfcManagerPlugin {
  static MethodChannel? channel;

  static void registerWith(Registrar registrar) {
    // insert js file into html body
    html.document.body!.append(html.ScriptElement()
      ..src =
          'assets/packages/nfc_manager/assets/flutter_nfc.js' // ignore: unsafe_html
      ..type = 'application/javascript'
      ..defer = true);

    //register methodchannel
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
      case 'Nfc#startSession':
        _startNFCRead();
        return;
      //return _startNFCRead();
      case 'Nfc#disposeTag':
        // do nothing
        return;
      case 'stopNFCScan':
        //_stopNFCScan();
        return;
      case 'startNFCWrite':
        final List<String> recordsJson = call.arguments['records'];
        //_startNFCWrite(recordsJson);
        return;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'flutter_nfc_web for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Starts the NFCReader on JS-side
  _startNFCRead() async {
    html.document.on['readSuccessJS'].listen((html.Event event) {
      /*
      List<String> records = (event as html.CustomEvent).detail;
      List<JsNdefRecord> ndefRecords = [];
      for (String record in records) {
        ndefRecords.add(JsNdefRecord.fromJson(json.decode(record)));
      }
      tagDiscoveredCallback?.call(ndefRecords);
      */
      Map<dynamic, dynamic> jsTag = (event as html.CustomEvent).detail;
      channel?.invokeMethod("onDiscovered", jsTag);
    });

    startNDEFReaderJS();
  }

  // Stops the current NFCReader
  _stopNFCScan() {
    return stopNDEFReaderJS();
  }

/*
  // Start NFC Write
  _startNFCWrite(List<String> records) async {
    html.document.on['writeSuccessJS'].listen((html.Event event) {
      writeSuccessfullCallback?.call();
    });
    html.document.on['writeErrorJS'].listen((html.Event event) {
      writeErrorCallback?.call((event as html.CustomEvent).detail);
    });
    startNDEFWriterJS(records);
  }
*/
}

@JS()
external dynamic startNDEFReaderJS();
external dynamic stopNDEFReaderJS();
external dynamic startNDEFWriterJS(List<String> records);
