import 'dart:async';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

/// The entry point for accessing the NFC session on Android.
class NfcManagerAndroid {
  NfcManagerAndroid._() {
    _NfcManagerAndroidFlutterApi(this);
  }

  /// The instance of the [NfcManagerAndroid] to use.
  static NfcManagerAndroid get instance => _instance ??= NfcManagerAndroid._();
  static NfcManagerAndroid? _instance;

  // ignore: close_sinks
  final StreamController<int> _onStateChanged = StreamController.broadcast();

  /// DOC:
  Stream<int> get onStateChanged => _onStateChanged.stream;

  void Function(NfcTag)? _onTagDiscovered;

  /// DOC:
  Future<bool> isEnabled() {
    return hostApi.nfcAdapterIsEnabled();
  }

  /// DOC:
  Future<bool> isSecureNfcEnabled() {
    return hostApi.nfcAdapterIsSecureNfcEnabled();
  }

  /// DOC:
  Future<bool> isSecureNfcSupported() {
    return hostApi.nfcAdapterIsSecureNfcSupported();
  }

  /// DOC:
  Future<void> enableReaderMode({
    required Set<NfcReaderFlagAndroid> flags,
    required void Function(NfcTag) onTagDiscovered,
  }) {
    _onTagDiscovered = onTagDiscovered;
    return hostApi.nfcAdapterEnableReaderMode(
      flags: flags.map((e) => e.name).toList(),
    );
  }

  /// DOC:
  Future<void> disableReaderMode() {
    _onTagDiscovered = null;
    return hostApi.nfcAdapterDisableReaderMode();
  }

  /// DOC:
  Future<void> enableForegroundDispatch() {
    return hostApi.nfcAdapterEnableForegroundDispatch();
  }

  /// DOC:
  Future<void> disableForegroundDispatch() {
    return hostApi.nfcAdapterDisableForegroundDispatch();
  }
}

class _NfcManagerAndroidFlutterApi implements PigeonFlutterApi {
  _NfcManagerAndroidFlutterApi(this._instance) {
    PigeonFlutterApi.setup(this);
  }

  final NfcManagerAndroid _instance;

  @override
  void onAdapterStateChanged(int state) {
    _instance._onStateChanged.sink.add(state);
  }

  @override
  void onTagDiscovered(PigeonTag tag) {
    _instance._onTagDiscovered?.call(
      // ignore: invalid_use_of_visible_for_testing_member
      NfcTag(data: tag),
    );
  }
}

/// DOC:
enum NfcReaderFlagAndroid {
  /// DOC:
  nfcA,

  /// DOC:
  nfcB,

  /// DOC:
  nfcBarcode,

  /// DOC:
  nfcF,

  /// DOC:
  nfcV,

  /// DOC:
  noPlatformSounds,

  /// DOC:
  skipNdefCheck,
}
