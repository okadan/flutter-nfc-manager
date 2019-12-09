part of nfc_manager;

const MethodChannel _channel = MethodChannel('plugins.flutter.io/nfc_manager');

typedef NdefDiscoveredCallback = void Function(Ndef ndef);

typedef TagDiscoveredCallback = void Function(NfcTag tag);

enum TagPollingOption {
  iso14443,
  iso15693,
  iso18092,
}

class Nfc {
  Nfc._() { _channel.setMethodCallHandler(_handleMethodCall); }
  static Nfc _instance;
  static Nfc get instance => _instance ??= Nfc._();

  NdefDiscoveredCallback _onNdefDiscovered;

  TagDiscoveredCallback _onTagDiscovered;

  Future<bool> isAvailable() async {
    return _channel.invokeMethod('isAvailable', {});
  }

  Future<bool> startNdefSession({
    @required NdefDiscoveredCallback onDiscovered,
    String alertMessageIOS,
  }) async {
    _onNdefDiscovered = onDiscovered;
    return _channel.invokeMethod('startNdefSession', {
      'alertMessageIOS': alertMessageIOS,
    });
  }

  Future<bool> startTagSession({
    @required TagDiscoveredCallback onDiscovered,
    Set<TagPollingOption> pollingOptions,
    String alertMessageIOS,
  }) async {
    _onTagDiscovered = onDiscovered;
    return _channel.invokeMethod('startTagSession', {
      'pollingOptions': (pollingOptions?.toList() ?? TagPollingOption.values).map((e) => e.index).toList(),
      'alertMessageIOS': alertMessageIOS,
    });
  }

  Future<bool> stopSession({
    String errorMessageIOS,
    String alertMessageIOS,
  }) async {
    _onNdefDiscovered = null;
    _onTagDiscovered = null;
    return _channel.invokeMethod('stopSession', {
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
    NfcTag tag = _$nfcTagFromJson(arguments);
    Ndef ndef = _$ndefFromTag(tag);
    if (ndef != null && _onNdefDiscovered != null)
      _onNdefDiscovered(ndef);
    _disposeTag(tag);
  }

  Future<void> _handleOnTagDiscovered(Map<String, dynamic> arguments) async {
    NfcTag tag = _$nfcTagFromJson(arguments);
    if (_onTagDiscovered != null)
      _onTagDiscovered(tag);
    _disposeTag(tag);
  }

  Future<bool> _disposeTag(NfcTag tag) async {
    return _channel.invokeMethod('disposeTag', {
      'handle': tag._handle,
    });
  }
}
