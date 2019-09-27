import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import './read.dart';
import './write.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('NfcManager Example')),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.isAvailable(),
            builder: (context, ss) {
              if (!ss.hasData) return Container();
              if (!ss.data)  return Center(child: Text('Not available on the current device'));
              return ListView(
                children: [
                  ListTile(
                    title: Text('Read'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ReadPage(),
                    )),
                  ),
                  ListTile(
                    title: Text('Write'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => WritePage(),
                    )),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
