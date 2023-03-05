import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ndef/ndef_platform.dart';
import 'package:nfc_manager/src/nfc_manager_ndef_record/ndef_record.dart';

class Ndef {
  const Ndef._(this._platform);

  final NdefPlatform _platform;

  static Ndef? from(NfcTag tag) {
    final platform = NdefPlatform.from(tag);
    return platform == null ? null : Ndef._(platform);
  }

  bool get isWritable => _platform.isWritable;

  int get maxSize => _platform.maxSize;

  NdefMessage? get cachedMessage => _platform.cachedMessage;

  Map<String, dynamic> get additionalData => _platform.additionalData;

  Future<NdefMessage?> read() {
    return _platform.read();
  }

  Future<void> write({required NdefMessage message}) {
    return _platform.write(message: message);
  }

  Future<void> writeLock() {
    return _platform.writeLock();
  }
}
