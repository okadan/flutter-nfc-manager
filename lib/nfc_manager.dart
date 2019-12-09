library nfc_manager;

import 'dart:convert' show utf8, ascii;
import 'dart:typed_data' show Uint8List;
import 'dart:ui' show Locale;

import 'package:flutter/services.dart' show MethodChannel, MethodCall;
import 'package:meta/meta.dart';

part 'src/ndef.dart';
part 'src/nfc.dart';
part 'src/tag.dart';
part 'src/translator.dart';
