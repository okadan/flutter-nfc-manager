import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../channel.dart';
import '../translator.dart';

/// Signature for `NfcManager.startSession` onDiscovered callback.
typedef NfcTagCallback = Future<void> Function(NfcTag tag);

/// Signature for `NfcManager.startSession` onError callback.
typedef NfcErrorCallback = Future<void> Function(NfcError error);

/// The entry point for accessing the NFC session.
class NfcManager {
  NfcManager._() { channel.setMethodCallHandler(_handleMethodCall); }
  static NfcManager _instance;

  /// A Singleton instance of NfcManager.
  static NfcManager get instance => _instance ??= NfcManager._();

  // _onDiscovered
  NfcTagCallback _onDiscovered;

  // _onError
  NfcErrorCallback _onError;

  /// Checks whether the NFC features are available.
  Future<bool> isAvailable() async {
    return channel.invokeMethod('Nfc#isAvailable');
  }

  /// Start the session and register callbacks for tag discovery.
  /// 
  /// This uses the NFCTagReaderSession (on iOS) or NfcAdapter#enableReaderMode (on Android).
  /// Requires iOS 13.0 or Android API 19, or later.
  /// 
  /// `onDiscovered` is called whenever the tag is discovered.
  /// 
  /// `pollingOptions` is used to specify the type of tags to be discovered. All types by default.
  /// 
  /// (iOS only) `alertMessage` is used to display the message on the popup shown when the session is started.
  /// 
  /// (iOS only) `onError` is called when the session is stopped for some reason after the session has started.
  Future<void> startSession({
    @required NfcTagCallback onDiscovered,
    Set<NfcPollingOption> pollingOptions,
    String alertMessage,
    NfcErrorCallback onError,
  }) async {
    _onDiscovered = onDiscovered;
    _onError = onError;
    pollingOptions ??= NfcPollingOption.values.toSet();
    return channel.invokeMethod('Nfc#startSession', {
      'pollingOptions': pollingOptions.map((e) => $NfcPollingOptionTable[e]).toList(),
      'alertMessage': alertMessage,
    });
  }


  /// Stop the session and unregister callbacks.
  /// 
  /// This uses the NFCTagReaderSession (on iOS) or NfcAdapter#disableReaderMode (on Android).
  /// Requires iOS 13.0 or Android API 19, or later.
  /// 
  /// (iOS only) `alertMessage` and `errorMessage` are used to display the success or error message on the popup.
  /// if both are used, `errorMessage` is used.
  Future<void> stopSession({
    String alertMessage,
    String errorMessage,
  }) async {
    _onDiscovered = null;
    _onError = null;
    return channel.invokeMethod('Nfc#stopSession', {
      'alertMessage': alertMessage,
      'errorMessage': errorMessage,
    });
  }

  // _disposeTag
  Future<void> _disposeTag(String handle) async {
    return channel.invokeMethod('Nfc#disposeTag', {
      'handle': handle,
    });
  }

  // _handleMethodCall
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onDiscovered': _handleOnDiscovered(call); break;
      case 'onError': _handleOnError(call); break;
      default: throw('Not implemented: ${call.method}');
    }
  }

  // _handleOnDiscovered
  void _handleOnDiscovered(MethodCall call) async {
    final tag = $GetNfcTag(Map.from(call.arguments));
    if (_onDiscovered != null) await _onDiscovered(tag);
    await _disposeTag(tag.handle);
  }

  // _handleOnError
  void _handleOnError(MethodCall call) async {
    final error = $GetNfcError(Map.from(call.arguments));
    if (_onError != null) await _onError(error);
  }
}

/// The class represents the tag discovered by the session.
class NfcTag {
  /// Constructs an instance with the given values for testing.
  /// 
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the onDiscovered callback of `NfcManager#startSession` are valid.
  const NfcTag({
    @required this.handle,
    @required this.data,
  });

  /// The value used by this plugin internally.
  final String handle;

  /// The raw values about this tag obtained from the native platform.
  /// 
  /// Don't use this values directly. Instead, access it via the platform_tags classes. For example:
  /// 
  /// ```dart
  /// final mifare = MiFare.from(tag);
  /// print(mifare.identifier);
  /// ```
  final Map<String, dynamic> data;
}

/// The class represents the error when the session is stopped.
class NfcError {
  /// Constructs an instance with the given values for testing.
  /// 
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the onError callback of `NfcManager#startSession` are valid.
  const NfcError({
    @required this.type,
    @required this.message,
    @required this.details,
  });

  /// The error type.
  final NfcErrorType type;

  /// The error message.
  final String message;

  /// The error details information.
  final dynamic details;
}

/// Represents the type of tag to be discovered by the session.
/// 
/// Typically used with `NfcManager#startSession` function.
enum NfcPollingOption {
  /// `iso14443` on iOS, and `FLAG_READER_A` and `FLAG_READER_B` on Android.
  iso14443,

  /// `iso15693` on iOS, and `FLAG_READER_V` on Android.
  iso15693,

  /// `iso18092` on iOS, and `FLAG_READER_F` on Android.
  iso18092,
}

/// Represents the type of error that occurs when the session has stopped.
enum NfcErrorType {
  /// The session timed out.
  sessionTimeout,

  /// The session failed because the system is busy.
  systemIsBusy,

  /// The user canceled the session.
  userCanceled,

  /// The session failed because the unexpected error has occurred.
  unknown,
}
