import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

class NfcManagerIOS {
  NfcManagerIOS._() { _flutterApi = _NfcManagerIOSFlutterApi(this); }

  static NfcManagerIOS _instance = NfcManagerIOS._();
  static NfcManagerIOS get instance => _instance;

  // ignore: unused_field
  PigeonFlutterApi? _flutterApi;

  void Function(NfcTag)? _didDetectTag;
  void Function()? _didBecomeActive;
  void Function(String)? _didInvalidateWithError;

  Future<bool> tagReaderSessionReadingAvailable() async {
    return hostApi.tagReaderSessionReadingAvailable();
  }

  Future<void> tagReaderSessionBegin({
    required Set<NfcPollingOption> pollingOptions,
    required void Function(NfcTag)? didDetectTag,
    void Function()? didBecomeActive,
    void Function(String)? didInvalidateWithError,
    String? alertMessage,
  }) async {
    _didDetectTag = didDetectTag;
    _didBecomeActive = didBecomeActive;
    _didInvalidateWithError = didInvalidateWithError;
    return hostApi.tagReaderSessionBegin(
      pollingOptions.map(pigeonFromNfcPollingOption).toList(),
      alertMessage,
    );
  }

  Future<void> tagReaderSessionInvalidate({
    String? alertMessage,
    String? errorMessage,
  }) async {
    _didDetectTag = null;
    _didBecomeActive = null;
    _didInvalidateWithError = null;
    return hostApi.tagReaderSessionInvalidate(alertMessage, errorMessage);
  }

  Future<void> tagReaderSessionRestartPolling() async {
    return hostApi.tagReaderSessionRestartPolling();
  }

  Future<void> disposeTag({
    required String handle,
  }) async {
    return hostApi.disposeTag(handle);
  }
}

class _NfcManagerIOSFlutterApi implements PigeonFlutterApi {
  _NfcManagerIOSFlutterApi(this._instance);

  final NfcManagerIOS _instance;

  @override
  void tagReaderSessionDidBecomeActive() {
    _instance._didBecomeActive?.call();
  }

  @override
  void tagReaderSessionDidDetect(PigeonTag tag) {
    final nfcTag = NfcTag(handle: tag.handle!, data: tag.encode());
    _instance._didDetectTag?.call(nfcTag);
  }

  @override
  void tagReaderSessionDidInvalidateWithError(String error) {
    _instance._didInvalidateWithError?.call(error);
  }
}
