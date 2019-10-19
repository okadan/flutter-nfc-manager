import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';

class WritePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  List<NdefRecord> _records = [];

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Write')),
      body: SafeArea(
        child: ListView(
          children: [
            Row(
              children: [
                RaisedButton(
                  child: Text('Add a sample record'),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => _AddSampleRecordDialog((record) {
                      setState(() => _records.add(record));
                      Navigator.pop(context);
                    })
                  ),
                ),
                Spacer(),
                RaisedButton(
                  child: Text('Start'),
                  onPressed: _records.isEmpty ? null : _startToWrite,
                ),
                Spacer(flex: 10),
              ],
            ),

            ..._records.map((e) => Text(
              'Format: ${e.typeNameFormat}\n'
              'Type: ${e.type}\n'
              'Identifier: ${e.identifier}\n'
              'Payload: ${e.payload}\n\n'
            )).toList()
          ],
        ),
      ),
    );
  }

  void _startToWrite() {
    NfcManager.instance.startNdefSession(
      onDiscovered: (ndef) async {
        if (ndef.isWritable != true) {
          final error = 'ndef is not writable';
          NfcManager.instance.stopSession(errorMessageIOS: error);
          print(error);
          return;
        }

        try {
          await ndef.writeNdef(NdefMessage(_records));
          NfcManager.instance.stopSession();
          print('Write success');
        } on PlatformException catch (e) {
          NfcManager.instance.stopSession(errorMessageIOS: '$e');
          print(e);
        }
      },
    );
  }
}

class _AddSampleRecordDialog extends StatelessWidget {
  _AddSampleRecordDialog(this.onAdd);

  final Function(NdefRecord) onAdd;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Choose a record type'),
      children: [
        SimpleDialogOption(
          child: Text('Text'),
          onPressed: () => onAdd(
            NdefRecord.createTextRecord('Hello World'),
          ),
        ),
        SimpleDialogOption(
          child: Text('Uri'),
          onPressed: () => onAdd(
            NdefRecord.createUriRecord(Uri.parse('https://flutter.dev'))
          ),
        ),
      ],
    );
  }
}
