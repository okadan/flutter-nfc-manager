import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../channel.dart';
import '../translator.dart';
import './nfc_ndef.dart';

/// Callback for handling ndef detection.
typedef NdefDiscoveredCallback = Future<void> Function(Ndef ndef);

/// Callback for handling tag detection.
typedef TagDiscoveredCallback = Future<void> Function(NfcTag tag);

/// Callback for handling error from the session.
typedef SessionErrorCallback = void Function(NfcSessionError error);

/// Used with `NfcManager#startTagSession`.
///
/// This wraps `NFCTagReaderSession.PollingOption` on iOS and `NfcAdapter.FLAG_READER_*` on Android.
enum TagPollingOption {
  /// Represents `iso14443` on iOS, and `FLAG_READER_A` and `FLAG_READER_B` on Android.
  iso14443,

  /// Represents `iso15693` on iOS, and `FLAG_READER_V` on Android.
  iso15693,

  /// Represents `iso18092` on iOS, and `FLAG_READER_F` on Android.
  iso18092,
}

/// Plugin for managing NFC session.
class NfcManager {
  NfcManager._() { channel.setMethodCallHandler(_handleMethodCall); }
  static NfcManager _instance;
  static NfcManager get instance => _instance ??= NfcManager._();

  NdefDiscoveredCallback _onNdefDiscovered;

  TagDiscoveredCallback _onTagDiscovered;

  SessionErrorCallback _onError;

  /// Checks whether the NFC is available on the device.
  Future<bool> isAvailable() async {
    return channel.invokeMethod('isAvailable', {});
  }

  /// Start session and register ndef discovered callback.
  ///
  /// This uses `NFCNDEFReaderSession` on iOS, and `NfcAdapter#enableReaderMode` on Android.
  /// Requires iOS 11.0 or Android API level 19, or later.
  ///
  /// [onDiscovered] is called each time an ndef is discovered.
  ///
  /// [onError] is called when the session stops for some reason after the session started.
  Future<bool> startNdefSession({
    @required NdefDiscoveredCallback onDiscovered,
    String alertMessageIOS,
    SessionErrorCallback onError,
  }) async {
    _onNdefDiscovered = onDiscovered;
    _onError = onError;
    return channel.invokeMethod('startNdefSession', {
      'alertMessageIOS': alertMessageIOS,
    });
  }

  /// Start session and register tag discovered callback.
  ///
  /// This uses `NFCTagReanderSession` on iOS and `NfcAdapter#enableReaderMode` on Android.
  /// Requires iOS 13.0 or Android API level 19, or later.
  ///
  /// [onDiscovered] is called each time an ndef is discovered. Use [pollingOptions] to specify the tag types to discover. (default all types)
  ///
  /// [onError] is called when the session stops for some reason after the session started.
  Future<bool> startTagSession({
    @required TagDiscoveredCallback onDiscovered,
    Set<TagPollingOption> pollingOptions,
    String alertMessageIOS,
    SessionErrorCallback onError,
  }) async {
    _onTagDiscovered = onDiscovered;
    _onError = onError;
    return channel.invokeMethod('startTagSession', {
      'pollingOptions': (pollingOptions?.toList() ?? TagPollingOption.values).map((e) => e.index).toList(),
      'alertMessageIOS': alertMessageIOS,
    });
  }

  /// Stop session and unregister callback.
  ///
  /// This uses `NFCReaderSession` on iOS and `NfcAdapter#disableReaderMode` on Android.
  /// Requires iOS 11.0 or Android API level 19, or later.
  ///
  /// On iOS, use [alertMessageIOS] to indicate the success, and [errorMessageIOS] to indicate the failure.
  /// When both are used, [errorMessageIOS] has priority.
  Future<bool> stopSession({
    String errorMessageIOS,
    String alertMessageIOS,
  }) async {
    _onNdefDiscovered = null;
    _onTagDiscovered = null;
    _onError = null;
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
      case 'onError':
        _handleOnError(Map<String, dynamic>.from(call.arguments));
        break;
    }
  }

  Future<void> _handleNdefDiscovered(Map<String, dynamic> arguments) async {
    NfcTag tag = $nfcTagFromJson(arguments);
    Ndef ndef = $ndefFromTag(tag);
    if (ndef != null && _onNdefDiscovered != null)
      await _onNdefDiscovered(ndef);
    _disposeTag(tag);
  }

  Future<void> _handleOnTagDiscovered(Map<String, dynamic> arguments) async {
    NfcTag tag = $nfcTagFromJson(arguments);
    if (_onTagDiscovered != null)
      await _onTagDiscovered(tag);
    _disposeTag(tag);
  }

  Future<void> _handleOnError(Map<String, dynamic> arguments) async {
    if (_onError != null)
      _onError($nfcSessionErrorFromJson(arguments));
    _onNdefDiscovered = null;
    _onTagDiscovered = null;
    _onError = null;
  }

  Future<bool> _disposeTag(NfcTag tag) async {
    return channel.invokeMethod('disposeTag', {
      'handle': tag.handle,
    });
  }
}

/// Represents the tag detected by the session.
class NfcTag {
  NfcTag({
    @required this.handle,
    @required this.data,
  });

  /// String value used by this plugin internally.
  ///
  /// Don`t use in your application code.
  final String handle;

  /// Raw values that can be obtained on the native platform.
  ///
  /// Typically accessed from specific-tag that you instantiated from tag. (eg MiFare.fromTag)
  ///
  /// This property is experimental and may be changed without announcement in the future.
  /// Not recommended for use directly.
  final Map<String, dynamic> data;
}

/// Provides access to NDEF operations on the tag.
///
/// Acquire `Ndef` instance using `Ndef.fromTag(tag)`.
class Ndef {
  Ndef({
    @required this.tag,
    @required this.cachedMessage,
    @required this.isWritable,
    @required this.maxSize,
  });

  final NfcTag tag;

  /// NDEF message that was read from the tag at discovery time.
  final NdefMessage cachedMessage;

  /// Indicates whether the the tag can be written with NDEF Message.
  final bool isWritable;

  /// The maximum NDEF message size in bytes, that you can store.
  final int maxSize;

  /// Get an instance of `Ndef` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NDEF.
  factory Ndef.fromTag(NfcTag tag) => $ndefFromTag(tag);

  /// Overwrite an NDEF message on this tag.
  ///
  /// Requires iOS 13.0 or later, on iOS.
  Future<bool> write(NdefMessage message) async {
    return channel.invokeMethod('Ndef#write', {
      'handle': tag.handle,
      'message': $ndefMessageToJson(message),
    });
  }

  /// Make the tag read-only.
  ///
  /// Requires iOS 13.0 or later, on iOS.
  Future<bool> writeLock() async {
    return channel.invokeMethod('Ndef#writeLock', {
      'handle': tag.handle,
    });
  }
}

/// Represents the error from the session.
class NfcSessionError {
  NfcSessionError({
    @required this.type,
    @required this.message,
    @required this.details,
  });

  final NfcSessionErrorType type;
  final String message;
  final dynamic details;
}

/// Represents the reason for the error from the session.
enum NfcSessionErrorType {
  sessionTimeout,
  systemIsBusy,
  userCanceled,
  unknown,
}
