import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ndef/ndef_platform_android.dart';
import 'package:nfc_manager/src/nfc_manager_ndef/ndef_platform_ios.dart';
import 'package:nfc_manager/src/nfc_manager_ndef_record/ndef_record.dart';

abstract class NdefPlatform {
  static NdefPlatform? from(NfcTag tag) {
    if (defaultTargetPlatform == TargetPlatform.android)
      return NdefAndroidPlatform.from(tag);
    if (defaultTargetPlatform == TargetPlatform.iOS)
      return NdefIOSPlatform.from(tag);
    return null;
  }

  int get maxSize;

  bool get isWritable;

  NdefMessage? get cachedMessage;

  Map<String, dynamic> get additionalData;

  Future<NdefMessage?> read();

  Future<void> write({required NdefMessage message});

  Future<void> writeLock();
}