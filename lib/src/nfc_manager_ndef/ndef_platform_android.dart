import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/tags/ndef.dart';
import 'package:nfc_manager/src/nfc_manager_ndef/ndef_platform.dart';
import 'package:nfc_manager/src/nfc_manager_ndef_record/ndef_record.dart';

class NdefAndroidPlatform extends NdefPlatform {
  NdefAndroidPlatform._(this._tech);

  static NdefAndroidPlatform? from(NfcTag tag) {
    final tech = NdefAndroid.from(tag);
    return tech == null ? null : NdefAndroidPlatform._(tech);
  }

  final NdefAndroid _tech;

  @override
  bool get isWritable => _tech.isWritable;

  @override
  int get maxSize => _tech.maxSize;

  @override
  NdefMessage? get cachedMessage => _tech.cachedNdefMessage;

  @override
  Map<String, dynamic> get additionalData => {'canMakeReadOnly': _tech.canMakeReadOnly, 'type': _tech.type};

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
