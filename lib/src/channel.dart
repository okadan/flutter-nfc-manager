import 'package:flutter/services.dart';

const baseChannelName = 'plugins.flutter.io/nfc_manager';

const MethodChannel channel = MethodChannel(baseChannelName);
const EventChannel eventChannel = EventChannel(baseChannelName + '/stream');
