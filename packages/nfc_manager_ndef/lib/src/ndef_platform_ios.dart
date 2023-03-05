import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
import 'package:nfc_manager_ndef/src/ndef.dart';

final class NdefPlatformIos implements Ndef {
  const NdefPlatformIos._(this._tech);

  final NdefIos _tech;

  static NdefPlatformIos? from(NfcTag tag) {
    final tech = NdefIos.from(tag);
    return tech == null ? null : NdefPlatformIos._(tech);
  }

  @override
  bool get isWritable => _tech.status == NdefStatusIos.readWrite;

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
