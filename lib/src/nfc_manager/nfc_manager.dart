import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../channel.dart';
import '../translator.dart';

// NfcTagCallback
typedef NfcTagCallback = Future<void> Function(NfcTag tag);

// NfcErrorCallback
typedef NfcErrorCallback = Future<void> Function(NfcError error);

// NfcManager
class NfcManager {
  // NfcManager
  NfcManager._() { channel.setMethodCallHandler(_handleMethodCall); }
  static NfcManager _instance;
  static NfcManager get instance => _instance ??= NfcManager._();

  // _onDiscovered
  NfcTagCallback _onDiscovered;

  // _onError
  NfcErrorCallback _onError;

  // isAvailable
  Future<bool> isAvailable() async {
    return channel.invokeMethod('Nfc#isAvailable');
  }

  // startSession
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

  // stopSession
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

  void _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onDiscovered': _handleOnDiscovered(call); break;
      case 'onError': _handleOnError(call); break;
      default: throw('Not implemented: ${call.method}');
    }
  }

  void _handleOnDiscovered(MethodCall call) async {
    final tag = $GetNfcTag(Map.from(call.arguments));
    if (_onDiscovered != null) await _onDiscovered(tag);
    await _disposeTag(tag.handle);
  }

  void _handleOnError(MethodCall call) async {
    final error = $GetNfcError(Map.from(call.arguments));
    if (_onError != null) await _onError(error);
  }
}

// NfcTag
class NfcTag {
  // NfcTag
  const NfcTag({
    @required this.handle,
    @required this.data,
  });

  // handle
  final String handle;

  // data
  final Map<String, dynamic> data;
}

// NfcError
class NfcError {
  // NfcError
  NfcError({
    @required this.type,
    @required this.message,
    @required this.details,
  });

  // type
  final NfcErrorType type;

  // message
  final String message;

  // details
  final dynamic details;
}

// NfcPollingOption
enum NfcPollingOption {
  // iso14443
  iso14443,

  // iso15693
  iso15693,

  // iso18092
  iso18092,
}

// NfcErrorType
enum NfcErrorType {
  // sessionTimeout
  sessionTimeout,

  // systemIsBusy
  systemIsBusy,

  // userCanceled
  userCanceled,

  // unknown
  unknown,
}
