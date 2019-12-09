import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ValueNotifier<dynamic> result = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('NfcManager Plugin Example')),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: Nfc.instance.isAvailable(),
            builder: (context, ss) => ss.data != true
              ? Center(child: Text('Nfc.isAvailable(): ${ss.data}'))
              : Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.vertical,
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.all(4),
                      constraints: BoxConstraints.expand(),
                      decoration: BoxDecoration(border: Border.all()),
                      child: SingleChildScrollView(
                        child: ValueListenableBuilder<dynamic>(
                          valueListenable: result,
                          builder: (context, value, _) => Text('${value ?? ''}'),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: GridView.count(
                      padding: EdgeInsets.all(4),
                      crossAxisCount: 2,
                      childAspectRatio: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      children: [
                        RaisedButton(child: Text('Tag Read'), onPressed: _tagRead),
                        RaisedButton(child: Text('Ndef Write'), onPressed: _ndefWrite),
                        RaisedButton(child: Text('Ndef Write Lock'), onPressed: _ndefWriteLock),
                      ],
                    ),
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }

  void _tagRead() {
    Nfc.instance.startTagSession(onDiscovered: (NfcTag tag) {
      result.value = tag.data;
      Nfc.instance.stopSession();
    });
  }

  void _ndefWrite() {
    Nfc.instance.startTagSession(onDiscovered: (NfcTag tag) async {
      Ndef ndef = Ndef.fromTag(tag);
      if (ndef == null) {
        result.value = 'Tag is not ndef';
        Nfc.instance.stopSession(errorMessageIOS: result.value);
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createTextRecord('Hello World!'),
        NdefRecord.createUriRecord(Uri.parse('https://flutter.dev')),
        NdefRecord.createMimeRecord('text/plain', Uint8List.fromList('Hello'.codeUnits)),
        NdefRecord.createExternalRecord('com.example', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
      ]);

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';
        Nfc.instance.stopSession();
      } catch (e) {
        result.value = e;
        Nfc.instance.stopSession(errorMessageIOS: result.value.toString());
        return;
      }
    });
  }

  void _ndefWriteLock() {
    Nfc.instance.startTagSession(onDiscovered: (NfcTag tag) async {
      Ndef ndef = Ndef.fromTag(tag);
      if (ndef == null) {
        result.value = 'Tag is not ndef';
        Nfc.instance.stopSession(errorMessageIOS: result.value.toString());
        return;
      }

      try {
        await ndef.writeLock();
        result.value = 'Success to "Ndef Write Lock"';
        Nfc.instance.stopSession();
      } catch (e) {
        result.value = e;
        Nfc.instance.stopSession(errorMessageIOS: result.value.toString());
        return;
      }
    });
  }
}
