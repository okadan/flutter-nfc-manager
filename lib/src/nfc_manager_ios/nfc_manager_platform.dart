import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/nfc_manager.dart';

class NfcManagerIOSPlatform implements NfcManager {
  @override
  Future<bool> isAvailable() {
    return NfcManagerIOS.instance.tagReaderSessionReadingAvailable();
  }

  @override
  Future<void> startSession({
    required Set<NfcPollingOption> pollingOptions,
    required void Function(NfcTag) onDiscovered,
    String? alertMessageIOS,
    bool invalidateAfterFirstReadIOS = true,
    void Function(NfcReaderSessionErrorIOS)? onSessionErrorIOS,
  }) {
    return NfcManagerIOS.instance.tagReaderSessionBegin(
      pollingOptions: pollingOptions,
      alertMessage: alertMessageIOS,
      didDetectTag: onDiscovered,
      didInvalidateWithError: onSessionErrorIOS,
    );
  }

  @override
  Future<void> stopSession({String? alertMessageIOS, String? errorMessageIOS}) {
    return NfcManagerIOS.instance.tagReaderSessionInvalidate(
      alertMessage: alertMessageIOS,
      errorMessage: errorMessageIOS,
    );
  }
}
