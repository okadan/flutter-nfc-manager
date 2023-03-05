import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';

abstract class NfcManagerPlatform {
  static late final NfcManagerPlatform instance;

  Future<bool> isAvailable();

  Future<void> startSession({Set<NfcPollingOption> pollingOptions, String? alertMessageIOS, required void Function(NfcTag) onDiscovered});

  Future<void> stopSession({String? alertMessageIOS, String? errorMessageIOS});
}
