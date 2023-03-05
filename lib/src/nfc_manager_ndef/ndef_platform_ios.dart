import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/tags/ndef.dart';
import 'package:nfc_manager/src/nfc_manager_ndef/ndef_platform.dart';
import 'package:nfc_manager/src/nfc_manager_ndef_record/ndef_record.dart';

class NdefIOSPlatform extends NdefPlatform {
  NdefIOSPlatform(this._tech);

  static NdefIOSPlatform? from(NfcTag tag) {
    final tech = NdefIOS.from(tag);
    return tech == null ? null : NdefIOSPlatform(tech);
  }

  final NdefIOS _tech;

  @override
  bool get isWritable => _tech.status == NdefStatusIOS.readWrite;

  @override
  int get maxSize => _tech.capacity;

  @override
  NdefMessage? get cachedMessage => _tech.cachedNdefMessage;

  @override
  Map<String, dynamic> get additionalData => {};

  @override
  Future<NdefMessage?> read() {
    return _tech.readNdef();
  }

  @override
  Future<void> write({required NdefMessage message}) {
    return _tech.writeNdef(message);
  }

  @override
  Future<void> writeLock() {
    return _tech.writeLock();
  }
}
