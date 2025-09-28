import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/nfc_manager.dart';

final class NfcManagerIosPlatform implements NfcManager {
  @override
  Future<bool> isAvailable() {
    return NfcManagerIos.instance.tagSessionReadingAvailable();
  }

  @override
  Future<NfcAvailability> checkAvailability() async {
    final isAvailable = await NfcManagerIos.instance
        .tagSessionReadingAvailable();
    return isAvailable ? NfcAvailability.enabled : NfcAvailability.unsupported;
  }

  @override
  Future<void> startSession({
    required Set<NfcPollingOption> pollingOptions,
    required void Function(NfcTag tag) onDiscovered,
    String? alertMessageIos,
    bool invalidateAfterFirstReadIos = true,
    void Function(NfcReaderSessionErrorIos)? onSessionErrorIos,
    bool noPlatformSoundsAndroid = false,
  }) {
    return NfcManagerIos.instance.tagSessionBegin(
      pollingOptions: pollingOptions,
      didDetectTag: onDiscovered,
      alertMessage: alertMessageIos,
      invalidateAfterFirstRead: invalidateAfterFirstReadIos,
      didInvalidateWithError: onSessionErrorIos,
    );
  }

  @override
  Future<void> stopSession({String? alertMessageIos, String? errorMessageIos}) {
    return NfcManagerIos.instance.tagSessionInvalidate(
      alertMessage: alertMessageIos,
      errorMessage: errorMessageIos,
    );
  }
}
