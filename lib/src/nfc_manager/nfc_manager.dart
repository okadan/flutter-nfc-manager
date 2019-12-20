import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../channel.dart';
import '../translator.dart';
import '../nfc_tags/nfc_tags.dart' show NfcTag, Ndef;

/// Callback type for handling ndef detection.
typedef NdefDiscoveredCallback = void Function(Ndef ndef);

/// Callback type for handling tag detection.
typedef TagDiscoveredCallback = void Function(NfcTag tag);

/// Used with `NfcManager#startTagSession`.
///
/// This wraps `NFCTagReaderSession.PollingOption` on iOS and `NfcAdapter.FLAG_READER_*` on Android.
enum TagPollingOption {
  /// Represents `iso14443` on iOS, and `FLAG_READER_A` and `FLAG_READER_B` on Android.
  iso14443,

  /// Represents `iso18092` on iOS, and `FLAG_READER_F` on Android.
  iso18092,

  /// Represents `iso15693` on iOS, and `FLAG_READER_V` on Android.
  iso15693,
}

/// Plugin for managing NFC session.
class NfcManager {
  NfcManager._() { channel.setMethodCallHandler(_handleMethodCall); }
  static NfcManager _instance;
  static NfcManager get instance => _instance ??= NfcManager._();

  NdefDiscoveredCallback _onNdefDiscovered;

  TagDiscoveredCallback _onTagDiscovered;

  /// Checks whether the NFC is available on the device.
  Future<bool> isAvailable() async {
    return channel.invokeMethod('isAvailable', {});
  }

  /// Start session and register ndef discovered callback.
  ///
  /// On iOS, this uses the `NFCNDEFReaderSession` API.
  ///
  /// On Android, this uses the `NfcAdapter#enableReaderMode` API.
  ///
  /// Requires iOS 11.0 or Android API level 19, or later.
  Future<bool> startNdefSession({
    @required NdefDiscoveredCallback onDiscovered,
    String alertMessageIOS,
  }) async {
    _onNdefDiscovered = onDiscovered;
    return channel.invokeMethod('startNdefSession', {
      'alertMessageIOS': alertMessageIOS,
    });
  }

  /// Start session and register tag discovered callback.
  ///
  /// On iOS, this uses the `NFCTagReaderSession` API.
  ///
  /// On Android, this uses the `NfcAdapter#enableReaderMode` API.
  ///
  /// Requires iOS 13.0 or Android API level 19, or later.
  Future<bool> startTagSession({
    @required TagDiscoveredCallback onDiscovered,
    Set<TagPollingOption> pollingOptions,
    String alertMessageIOS,
  }) async {
    _onTagDiscovered = onDiscovered;
    return channel.invokeMethod('startTagSession', {
      'pollingOptions': (pollingOptions?.toList() ?? TagPollingOption.values).map((e) => e.index).toList(),
      'alertMessageIOS': alertMessageIOS,
    });
  }

  /// Stop session and unregister tag/ndef discovered callback.
  ///
  /// Requires iOS 11.0 or Android API level 19, or later.
  Future<bool> stopSession({
    String errorMessageIOS,
    String alertMessageIOS,
  }) async {
    _onNdefDiscovered = null;
    _onTagDiscovered = null;
    return channel.invokeMethod('stopSession', {
      'errorMessageIOS': errorMessageIOS,
      'alertMessageIOS': alertMessageIOS,
    });
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNdefDiscovered':
        _handleNdefDiscovered(Map<String, dynamic>.from(call.arguments));
        break;
      case 'onTagDiscovered':
        _handleOnTagDiscovered(Map<String, dynamic>.from(call.arguments));
        break;
    }
  }

  Future<void> _handleNdefDiscovered(Map<String, dynamic> arguments) async {
    NfcTag tag = $nfcTagFromJson(arguments);
    Ndef ndef = $ndefFromTag(tag);
    if (ndef != null && _onNdefDiscovered != null)
      _onNdefDiscovered(ndef);
    _disposeTag(tag);
  }

  Future<void> _handleOnTagDiscovered(Map<String, dynamic> arguments) async {
    NfcTag tag = $nfcTagFromJson(arguments);
    if (_onTagDiscovered != null)
      _onTagDiscovered(tag);
    _disposeTag(tag);
  }

  Future<bool> _disposeTag(NfcTag tag) async {
    return channel.invokeMethod('disposeTag', {
      'handle': tag.handle,
    });
  }
}
