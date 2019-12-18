part of nfc_manager;

const MethodChannel _channel = MethodChannel('plugins.flutter.io/nfc_manager');

/// Callback type for handling ndef detection.
typedef NdefDiscoveredCallback = void Function(Ndef ndef);

/// Callback type for handling tag detection.
typedef TagDiscoveredCallback = void Function(NfcTag tag);

/// Used with `NfcManager#startTagSession`.
///
/// Wraps `NFCTagReaderSession.PollingOption` on iOS and `NfcAdapter.FLAG_READER_*` on Android.
enum TagPollingOption {
  /// Supports NFC type A and B.
  iso14443,

  /// Supports NFC type F.
  iso18092,

  /// Supports NFC type V.
  iso15693,
}

/// Plugin for managing NFC sessions.
class NfcManager {
  NfcManager._() { _channel.setMethodCallHandler(_handleMethodCall); }
  static NfcManager _instance;
  static NfcManager get instance => _instance ??= NfcManager._();

  NdefDiscoveredCallback _onNdefDiscovered;

  TagDiscoveredCallback _onTagDiscovered;

  /// Checks whether the NFC is available on the device.
  Future<bool> isAvailable() async {
    return _channel.invokeMethod('isAvailable', {});
  }

  /// Start a session and register an ndef discovered callback.
  ///
  /// On iOS, this uses the `NFCNDEFReaderSession` API.
  ///
  /// On Android, this uses the `NfcAdapter#enableReaderMode` API.
  /// Android API Level 19 or later is required.
  Future<bool> startNdefSession({
    @required NdefDiscoveredCallback onDiscovered,
    String alertMessageIOS,
  }) async {
    _onNdefDiscovered = onDiscovered;
    return _channel.invokeMethod('startNdefSession', {
      'alertMessageIOS': alertMessageIOS,
    });
  }

  /// Start a session and register a tag discovered callback.
  ///
  /// On iOS, this uses the `NFCTagReaderSession` API.
  /// iOS13.0 or later is required.
  ///
  /// On Android, this uses the `NfcAdapter#enableReaderMode` API.
  /// Android API Level 19 or later is required.
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

  /// Stop a session and unregister a tag/ndef discovered callback.
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
