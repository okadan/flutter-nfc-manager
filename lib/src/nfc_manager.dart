import 'package:flutter/services.dart';

import './ndef.dart';

const _channel = MethodChannel('plugins.flutter.io/nfc_manager');

enum NfcSessionType {
  ndef,
  tag,
}

enum NfcTagPollingOption {
  iso14443,
  iso15693,
  iso18092,
}

typedef void NfcNdefDiscoveredCallback(NfcNdef ndef);

typedef void NfcTagDiscoveredCallback(NfcTag tag);

class NfcManager {
  NfcManager._() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onNdefDiscovered':
          _handleNdefDiscovered(Map<String, dynamic>.from(call.arguments));
          break;
        case 'onTagDiscovered':
          _handleTagDiscovered(Map<String, dynamic>.from(call.arguments));
          break;
        default:
          throw('Not implemented: ${call.method}');
      }
    });
  }

  static NfcManager _instance;
  static NfcManager get instance => _instance ??= NfcManager._();

  /// Checks whether the session is available for specific type.
  static Future<bool> isAvailable(NfcSessionType type) {
    return _channel.invokeMethod('isAvailable', {
      'type': type.index,
    });
  }

  NfcNdefDiscoveredCallback _onNdefDiscovered;

  NfcTagDiscoveredCallback _onTagDiscovered;

  /// Start a reader session to detect ndef.
  Future<bool> startNdefSession({
    NfcNdefDiscoveredCallback onDiscovered,
    String alertMessageIOS,
  }) {
    _onNdefDiscovered = onDiscovered;
    return _channel.invokeMethod('startNdefSession', {
      'alertMessageIOS': alertMessageIOS,
    });
  }

  /// Start a reader session to detect tag.
  Future<bool> startTagSession({
    NfcTagDiscoveredCallback onDiscovered,
    Set<NfcTagPollingOption> pollingOptions,
    String alertMessageIOS,
  }) {
    _onTagDiscovered = onDiscovered;

    final effectiveOptions = pollingOptions != null && pollingOptions.isNotEmpty
      ? pollingOptions.toList()
      : NfcTagPollingOption.values;

    return _channel.invokeMethod('startTagSession', {
      'pollingOptions': effectiveOptions.map((e) => e.index).toList(),
      'alertMessageIOS': alertMessageIOS,
    });
  }

  /// Stop a reader session.
  Future<bool> stopSession({
    String alertMessageIOS,
    String errorMessageIOS,
  }) {
    assert(!(alertMessageIOS != null && errorMessageIOS != null));
    _onNdefDiscovered = null;
    _onTagDiscovered = null;
    return _channel.invokeMethod('stopSession', {
      'alertMessageIOS': alertMessageIOS,
      'errorMessageIOS': errorMessageIOS,
    });
  }

  Future<bool> _dispose(String key) {
    return _channel.invokeMethod('dispose', {
      'key': key,
    });
  }

  Future<void> _handleNdefDiscovered(Map<String, dynamic> arguments) async {
    final ndef = NfcNdef._fromJson(arguments['key'], Map<String, dynamic>.from(arguments['ndef']));
    if (_onNdefDiscovered != null)
      _onNdefDiscovered(ndef);
    await _dispose(ndef._tagKey);
  }

  Future<void> _handleTagDiscovered(Map<String, dynamic> arguments) async {
    final tag = NfcTag._fromJson(arguments);
    if (_onTagDiscovered != null)
      _onTagDiscovered(tag);
    await _dispose(tag._key);
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
}

class NfcNdef {
  NfcNdef._(
    this._tagKey,
    this.cachedMessage,
    this.isWritable,
    this.maxSize,
    this.additionalData,
  );

  final String _tagKey;

  /// An NDEF message that was read from the tag at discovery time.
  final NdefMessage cachedMessage;

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
  Future<bool> writeNdef(NdefMessage message) {
    return _channel.invokeMethod('writeNdef', {
      'key': _tagKey,
      'message': message.toJson(),
    });
  }

  /// Make the tag read-only.
  Future<bool> writeLock() {
    return _channel.invokeMethod('writeLock', {'key': _tagKey});
  }

  factory NfcNdef._fromJson(String key, Map<String, dynamic> data) {
    final ndefMessage = data['cachedMessage'] != null
      ? NdefMessage.fromJson(Map<String, dynamic>.from(data.remove('cachedMessage')))
      : null;
    final isWritable = data.remove('isWritable') as bool;
    final maxSize = data.remove('maxSize') as int;
    return NfcNdef._(key, ndefMessage, isWritable, maxSize, data);
  }
}
