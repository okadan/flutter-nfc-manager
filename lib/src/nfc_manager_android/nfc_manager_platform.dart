import 'dart:async';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/nfc_manager.dart';

class NfcManagerAndroidPlatform implements NfcManager {
  @override
  Future<bool> isAvailable() {
    return NfcManagerAndroid.instance.isEnabled();
  }

  @override
  Future<void> startSession({
    required Set<NfcPollingOption> pollingOptions,
    required void Function(NfcTag) onDiscovered,
    String? alertMessageIOS,
    bool invalidateAfterFirstReadIOS = true,
    void Function(NfcReaderSessionErrorIOS)? onSessionErrorIOS,
  }) {
    return NfcManagerAndroid.instance.enableReaderMode(
      flags: {
        if (pollingOptions.contains(NfcPollingOption.iso14443)) ...{
          NfcReaderFlagAndroid.nfcA,
          NfcReaderFlagAndroid.nfcB
        },
        if (pollingOptions.contains(NfcPollingOption.iso15693))
          NfcReaderFlagAndroid.nfcV,
        if (pollingOptions.contains(NfcPollingOption.iso18092))
          NfcReaderFlagAndroid.nfcF,
      },
      onTagDiscovered: onDiscovered,
    );
  }

  @override
  Future<void> stopSession({String? alertMessageIOS, String? errorMessageIOS}) {
    return NfcManagerAndroid.instance.disableReaderMode();
  }
}
