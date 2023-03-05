import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager_platform.dart';
import 'package:nfc_manager/src/nfc_manager_android/nfc_manager_platform.dart';
import 'package:nfc_manager/src/nfc_manager_ios/nfc_manager_platform.dart';

class NfcManager {
  NfcManager._();

  static NfcManager? _instance;
  static NfcManager get instance => _getOrCreateInstance();

  static NfcManager _getOrCreateInstance() {
    if (_instance == null) {
      if (defaultTargetPlatform == TargetPlatform.android)
        NfcManagerPlatform.instance = NfcManagerAndroidPlatform();
      if (defaultTargetPlatform == TargetPlatform.iOS)
        NfcManagerPlatform.instance = NfcManagerIOSPlatform();
      _instance = NfcManager._();
    }
    return _instance!;
  }

  Future<bool> isAvailable() async {
    return NfcManagerPlatform.instance.isAvailable();
  }

  Future<void> startSession({
    Set<NfcPollingOption> pollingOptions =
      const {NfcPollingOption.iso14443, NfcPollingOption.iso15693, NfcPollingOption.iso18092},
    String? alertMessageIOS,
    required void Function(NfcTag) onDiscovered,
  }) async {
    return NfcManagerPlatform.instance.startSession(
      pollingOptions: pollingOptions,
      alertMessageIOS: alertMessageIOS,
      onDiscovered: onDiscovered,
    );
  }

  Future<void> stopSession({
    String? alertMessageIOS,
    String? errorMessageIOS,
  }) async {
    return NfcManagerPlatform.instance.stopSession(
      alertMessageIOS: alertMessageIOS,
      errorMessageIOS: errorMessageIOS,
    );
  }
}

class NfcTag {
  const NfcTag({required this.handle, required this.data});

  final String handle;

  final Object data;
}

enum NfcPollingOption {
  iso14443,

  iso15693,

  iso18092,
}
