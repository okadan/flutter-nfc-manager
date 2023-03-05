import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager_ndef/src/ndef.dart';

final class NdefPlatformAndroid implements Ndef {
  const NdefPlatformAndroid._(this._tech);

  final NdefAndroid _tech;

  static NdefPlatformAndroid? from(NfcTag tag) {
    final tech = NdefAndroid.from(tag);
    return tech == null ? null : NdefPlatformAndroid._(tech);
  }

  @override
  bool get isWritable => _tech.isWritable;

  @override
  int get maxSize => _tech.maxSize;

  @override
  NdefMessage? get cachedMessage => _tech.cachedNdefMessage;

  @override
  Map<String, dynamic> get additionalData => {
    'canMakeReadOnly': _tech.canMakeReadOnly,
    'type': _tech.type,
  };

  @override
  Future<NdefMessage?> read() {
    return _tech.getNdefMessage();
  }

  @override
  Future<void> write({required NdefMessage message}) {
    return _tech.writeNdefMessage(message);
  }

  @override
  Future<void> writeLock() {
    return _tech.makeReadOnly();
  }
}
