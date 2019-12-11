library nfc_manager;

import 'dart:convert' show utf8, ascii;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show required;
import 'package:flutter/services.dart' show MethodChannel, MethodCall;

part 'src/ndef.dart';
part 'src/nfc_manager.dart';
part 'src/tag.dart';
part 'src/translator.dart';
