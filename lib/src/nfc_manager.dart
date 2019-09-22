import 'package:flutter/services.dart';

import './ndef.dart';

const _channel = MethodChannel('plugins.flutter.io/nfc_manager');

class NfcManager {
  NfcManager._() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onTagDiscovered':
          _handleOnTagDiscovered(Map<String, dynamic>.from(call.arguments));
          break;
        default:
          throw('Not implemented: ${call.method}');
      }
    });
  }

  static NfcManager _instance;
  static NfcManager get instance => _instance ??= NfcManager._();

  /// Checks whether the device supports NFC.
  static Future<bool> isAvailable() =>
    _channel.invokeMethod('isAvailable');

  void Function(NfcTag) _onTagDiscovered;

  /// Start a reader session.
  /// 
  /// Requires Android API level 19 or iOS11.0.
  /// 
  /// On Android, this uses the `NfcAdapter#enableReaderMode`, and supporting NfcA/NfcB/NfcF/NfcV flags.
  /// On iOS, this uses the `NFCTagReaderSession` for iOS 13.0 or newer, and `NFCNDEFReaderSession` otherwise.
  Future<bool> startSession({
    void Function(NfcTag) onTagDiscovered,
  }) {
    _onTagDiscovered = onTagDiscovered;
    return _channel.invokeMethod('startSession');
  }

  /// Stop a reader session.
  /// 
  /// Requires API level 19 or iOS 11.0.
  /// 
  /// On iOS 13.0 or newer, you can display an `errorMessageIOS` to the user.
  Future<bool> stopSession({
    String errorMessageIOS,
  }) {
    _onTagDiscovered = null;
    return _channel.invokeMethod('stopSession', {
      'errorMessageIOS': errorMessageIOS,
    });
  }

  Future<void> _handleOnTagDiscovered(Map<String, dynamic> arguments) async {
    final tag = NfcTag._fromJson(arguments);
    if (_onTagDiscovered != null)
      _onTagDiscovered(tag);
    await tag._dispose();
  }
}

class NfcTag {
  NfcTag._(this._key, this.ndef, this.additionalData);

  final String _key;

  /// Access point to the NDEF features on this tag.
  /// 
  /// If this value is null, means that this tag is not supporting the NDEF.
  final NfcNdef ndef;

  /// Various data not yet used by this plugin.
  /// 
  /// This data may be used/modified to improve this plugin in the future.
  /// Please use with caution.
  final Map<String, dynamic> additionalData;

  factory NfcTag._fromJson(Map<String, dynamic> data) {
    final key = data.remove('key');
    final ndef = data.containsKey('ndef')
      ? NfcNdef._fromJson(key, Map<String, dynamic>.from(data.remove('ndef')))
      : null;
    return NfcTag._(key, ndef, data);
  }

  Future<bool> _dispose() =>
    _channel.invokeMethod('dispose', {'key': _key});
}

class NfcNdef {
  NfcNdef._(
    this._tagKey,
    this.cachedNdef,
    this.isWritable,
    this.maxSize,
    this.additionalData,
  );

  final String _tagKey;

  /// An NDEF message that was read from the tag at discovery time.
  final NdefMessage cachedNdef;

  /// Whether the tag is NDEF writable.
  final bool isWritable;

  /// The maximum NDEF message size in bytes, that you can store.
  final int maxSize;

  /// Various data not yet used by this plugin.
  /// 
  /// This data may be used/modified to improve this plugin in the future.
  /// Please use with caution.
  final Map<String, dynamic> additionalData;

  /// Overwrite an NDEF message on this tag.
  /// 
  /// Requires any Android API level or iOS 13.0.
  Future<bool> writeNdef(NdefMessage message) {
    return _channel.invokeMethod('writeNdef', {
      'key': _tagKey,
      'message': message.toJson(),
    });
  }

  /// Make the tag read-only.
  /// 
  /// Requires any Android API level or iOS 13.0.
  /// 
  /// This is the permanent action that you cannot undo.
  /// After locking the tag, you can no longer write data to it.
  Future<bool> writeLock() {
    return _channel.invokeMethod('writeLock', {'key': _tagKey});
  }

  factory NfcNdef._fromJson(String key, Map<String, dynamic> data) {
    final ndefMessage = data.containsKey('cachedNdef')
      ? NdefMessage.fromJson(Map<String, dynamic>.from(data.remove('cachedNdef')))
      : null;
    final isWritable = data.remove('isWritable') as bool;
    final maxSize = data.remove('maxSize') as int;
    return NfcNdef._(key, ndefMessage, isWritable, maxSize, data);
  }
}
