import 'dart:async';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

/// The class providing access to the NFC features for Android.
final class NfcManagerAndroid {
  NfcManagerAndroid._() {
    _NfcFlutterApiAndroid(this);
  }

  /// The instance of the [NfcManagerAndroid] to use.
  static NfcManagerAndroid get instance => _instance ??= NfcManagerAndroid._();
  static NfcManagerAndroid? _instance;

  // TODO: DOC
  Stream<NfcAdapterStateAndroid> get onStateChanged => _onStateChanged.stream;
  final _onStateChanged = StreamController<NfcAdapterStateAndroid>.broadcast();

  void Function(NfcTag)? _onTagDiscovered;

  // TODO: DOC
  Future<bool> isEnabled() {
    return hostApi.nfcAdapterIsEnabled();
  }

  // TODO: DOC
  Future<bool> isSecureNfcEnabled() {
    return hostApi.nfcAdapterIsSecureNfcEnabled();
  }

  // TODO: DOC
  Future<bool> isSecureNfcSupported() {
    return hostApi.nfcAdapterIsSecureNfcSupported();
  }

  // TODO: DOC
  Future<void> enableReaderMode({
    required Set<NfcReaderFlagAndroid> flags,
    required void Function(NfcTag) onTagDiscovered,
  }) {
    _onTagDiscovered = onTagDiscovered;
    return hostApi.nfcAdapterEnableReaderMode(
      flags: flags.map((e) => ReaderFlagPigeon.values.byName(e.name)).toList(),
    );
  }

  // TODO: DOC
  Future<void> disableReaderMode() {
    _onTagDiscovered = null;
    return hostApi.nfcAdapterDisableReaderMode();
  }
}

class _NfcFlutterApiAndroid implements FlutterApiPigeon {
  _NfcFlutterApiAndroid(this._instance) {
    FlutterApiPigeon.setUp(this);
  }

  final NfcManagerAndroid _instance;

  @override
  void onAdapterStateChanged(AdapterStatePigeon state) {
    _instance._onStateChanged.sink.add(
      NfcAdapterStateAndroid.values.byName(state.name),
    );
  }

  @override
  void onTagDiscovered(TagPigeon tag) {
    _instance._onTagDiscovered?.call(
      // ignore: invalid_use_of_visible_for_testing_member
      NfcTag(data: tag),
    );
  }
}

// TODO: DOC
enum NfcReaderFlagAndroid {
  // TODO: DOC
  nfcA,

  // TODO: DOC
  nfcB,

  // TODO: DOC
  nfcBarcode,

  // TODO: DOC
  nfcF,

  // TODO: DOC
  nfcV,

  // TODO: DOC
  noPlatformSounds,

  // TODO: DOC
  skipNdefCheck,
}

// TODO: DOC
enum NfcAdapterStateAndroid {
  // TODO: DOC
  off,

  // TODO: DOC
  turningOn,

  // TODO: DOC
  on,

  // TODO: DOC
  turningOff,
}
