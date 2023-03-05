import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

class NfcManagerAndroid {
  NfcManagerAndroid._() { _flutterApi = _NfcManagerAndroidFlutterApi(this); }

  static NfcManagerAndroid _instance = NfcManagerAndroid._();
  static NfcManagerAndroid get instance => _instance;

  // ignore: unused_field
  PigeonFlutterApi? _flutterApi;

  // ignore: close_sinks
  final StreamController<int> _onAdapterStateChangedController = StreamController<int>.broadcast();
  Stream<int> get onAdapterStateChanged => _onAdapterStateChangedController.stream;

  void Function(AndroidNfcTag)? _onTagDiscovered;

  Future<bool> isEnabled() async {
    return hostApi.adapterIsEnabled();
  }

  Future<bool> isSecureNfcEnabled() async {
    return hostApi.adapterIsSecureNfcEnabled();
  }

  Future<bool> isSecureNfcSupported() async {
    return hostApi.adapterIsSecureNfcSupported();
  }

  Future<void> enableReaderMode({
    required List<NfcReaderFlagAndroid> flags,
    required void Function(AndroidNfcTag) onTagDiscovered,
  }) async {
    _onTagDiscovered = onTagDiscovered;
    return hostApi.adapterEnableReaderMode(flags.map(pigeonFromNfcReaderFlagAndroid).toList());
  }

  Future<void> disableReaderMode() async {
    _onTagDiscovered = null;
    return hostApi.adapterDisableReaderMode();
  }

  Future<void> enableForegroundDispatch() async {
    return hostApi.adapterEnableForegroundDispatch();
  }

  Future<void> disableForegroundDispatch() async {
    return hostApi.adapterDisableForegroundDispatch();
  }

  Future<void> disposeTag({ required String handle }) async {
    return hostApi.disposeTag(handle);
  }
}

class AndroidNfcTag extends NfcTag {
  const AndroidNfcTag({
    required super.handle,
    required super.data,
    required this.id,
    required this.techList,
  });

  final Uint8List id;

  final List<String> techList;
}

class _NfcManagerAndroidFlutterApi implements PigeonFlutterApi {
  _NfcManagerAndroidFlutterApi(this._instance);

  final NfcManagerAndroid _instance;

  @override
  void onAdapterStateChanged(int state) {
    _instance._onAdapterStateChangedController.sink.add(state);
  }

  @override
  void onTagDiscovered(PigeonTag tag) {
    final nfcTag = AndroidNfcTag(handle: tag.handle!, id: tag.id!, techList: tag.techList!.cast(), data: tag.encode());
    _instance._onTagDiscovered?.call(nfcTag);
  }
}

enum NfcReaderFlagAndroid {
  nfcA,
  nfcB,
  nfcBarcode,
  nfcF,
  nfcV,
  noPlatformSounds,
  skipNdefCheck,
}
