import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ReadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  NfcTag _tag;

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Read')),
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: RaisedButton(
                child: Text('Start'),
                onPressed: _startToRead,
              ),
            ),

            if (_tag != null) ...[
              Text('AdditionalData: ${_tag.additionalData}'),
              if (_tag.ndef != null) ...[
                Text('Writable: ${_tag.ndef.isWritable}'),
                Text('MaxSize: ${_tag.ndef.maxSize}'),
                Text('AdditionalData(Ndef): ${_tag.ndef.additionalData}'),
                if (_tag.ndef.cachedNdef != null) ...[
                  Text('ByteLength: ${_tag.ndef.cachedNdef.byteLength}'),
                  ..._tag.ndef.cachedNdef.records.map((e) => Text(
                    '\n'
                    'Format: ${e.typeNameFormat}\n'
                    'Type: ${e.type}\n'
                    'Identifier: ${e.identifier}\n'
                    'Payload: ${e.payload}'
                  )).toList(),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _startToRead() {
    NfcManager.instance.startTagSession(
      onTagDiscovered: (tag) {
        setState(() => _tag = tag);
        NfcManager.instance.stopSession();
        print('Read success');
      }
    );
  }
}
