import 'dart:typed_data';

import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_android/pigeon.g.dart';

/// The class providing access to tag operations for Android.
///
/// Acquire an instance using [from(NfcTag)].
final class NfcTagAndroid {
  const NfcTagAndroid._({required this.id, required this.techList});

  /// Creates an instance of this class for the given tag.
  ///
  /// Returns null if the tag is not compatible.
  static NfcTagAndroid? from(NfcTag tag) {
    // ignore: invalid_use_of_protected_member
    final data = tag.data as TagPigeon?;
    if (data == null) return null;
    return NfcTagAndroid._(id: data.id, techList: data.techList.cast());
  }

  // TODO: DOC
  final Uint8List id;

  // TODO: DOC
  final List<String> techList;
}
