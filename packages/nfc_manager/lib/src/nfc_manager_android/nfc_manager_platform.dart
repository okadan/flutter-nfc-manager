import 'dart:async';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/nfc_manager.dart';

final class NfcManagerAndroidPlatform implements NfcManager {
  @override
  Future<bool> isAvailable() {
    return NfcManagerAndroid.instance.isEnabled();
  }

  @override
  Future<void> startSession({
    required Set<NfcPollingOption> pollingOptions,
    required void Function(NfcTag) onDiscovered,
    String? alertMessageIos,
    bool invalidateAfterFirstReadIos = true,
    void Function(NfcReaderSessionErrorIos)? onSessionErrorIos,
    bool noPlatformSoundsAndroid = false,
  }) {
    return NfcManagerAndroid.instance.enableReaderMode(
      flags: {
        if (pollingOptions.contains(NfcPollingOption.iso14443)) ...{
          NfcReaderFlagAndroid.nfcA,
          NfcReaderFlagAndroid.nfcB,
        },
        if (pollingOptions.contains(NfcPollingOption.iso15693))
          NfcReaderFlagAndroid.nfcV,
        if (pollingOptions.contains(NfcPollingOption.iso18092))
          NfcReaderFlagAndroid.nfcF,
        if (noPlatformSoundsAndroid) NfcReaderFlagAndroid.noPlatformSounds,
      },
      onTagDiscovered: onDiscovered,
    );
  }

  @override
  Future<void> stopSession({String? alertMessageIos, String? errorMessageIos}) {
    return NfcManagerAndroid.instance.disableReaderMode();
  }
}
