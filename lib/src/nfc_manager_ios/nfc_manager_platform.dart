import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager_platform.dart';
import 'package:nfc_manager/src/nfc_manager_ios/nfc_manager.dart';

class NfcManagerIOSPlatform extends NfcManagerPlatform {
  @override
  Future<bool> isAvailable() {
    return NfcManagerIOS.instance.tagReaderSessionReadingAvailable();
  }

  @override
  Future<void> startSession({
    Set<NfcPollingOption> pollingOptions =
      const {NfcPollingOption.iso14443, NfcPollingOption.iso15693, NfcPollingOption.iso18092},
    String? alertMessageIOS,
    required void Function(NfcTag p1) onDiscovered,
  }) {
    return NfcManagerIOS.instance.tagReaderSessionBegin(
      pollingOptions: pollingOptions,
      alertMessage: alertMessageIOS,
      didDetectTag: onDiscovered,
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
