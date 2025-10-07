import 'dart:async';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

/// Provides access to the NFC session for Android.
final class NfcManagerAndroid {
  NfcManagerAndroid._() {
    _FlutterApiAndroid(this);
  }

  /// The default instance of [NfcManagerAndroid] to use.
  static NfcManagerAndroid get instance => _instance ??= NfcManagerAndroid._();
  static NfcManagerAndroid? _instance;

  // DOC:
  Stream<NfcAdapterStateAndroid> get onStateChanged => _onStateChanged.stream;
  final _onStateChanged = StreamController<NfcAdapterStateAndroid>.broadcast();

  void Function(NfcTag)? _onTagDiscovered;

  // DOC:
  Future<bool> isEnabled() {
    return hostApi.nfcAdapterIsEnabled();
  }

  // DOC:
  Future<bool> isSecureNfcEnabled() {
    return hostApi.nfcAdapterIsSecureNfcEnabled();
  }

  // DOC:
  Future<bool> isSecureNfcSupported() {
    return hostApi.nfcAdapterIsSecureNfcSupported();
  }

  // DOC:
  Future<void> enableReaderMode({
    required Set<NfcReaderFlagAndroid> flags,
    required void Function(NfcTag) onTagDiscovered,
  }) {
    _onTagDiscovered = onTagDiscovered;
    return hostApi.nfcAdapterEnableReaderMode(
      flags: flags.map((e) => ReaderFlagPigeon.values.byName(e.name)).toList(),
    );
  }

  // DOC:
  Future<void> disableReaderMode() {
    _onTagDiscovered = null;
    return hostApi.nfcAdapterDisableReaderMode();
  }
}

final class _FlutterApiAndroid implements FlutterApiPigeon {
  _FlutterApiAndroid(this._instance) {
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
    // ignore: invalid_use_of_visible_for_testing_member
    _instance._onTagDiscovered?.call(NfcTag(data: tag));
  }
}

// DOC:
enum NfcReaderFlagAndroid {
  // DOC:
  nfcA,

  // DOC:
  nfcB,

  // DOC:
  nfcBarcode,

  // DOC:
  nfcF,

  // DOC:
  nfcV,

  // DOC:
  noPlatformSounds,

  // DOC:
  skipNdefCheck,
}

// DOC:
enum NfcAdapterStateAndroid {
  // DOC:
  off,

  // DOC:
  turningOn,

  // DOC:
  on,

  // DOC:
  turningOff,
}
