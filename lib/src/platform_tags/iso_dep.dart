import 'dart:typed_data';

import '../channel.dart';
import '../nfc_manager/nfc_manager.dart';
import '../translator.dart';

/// The class provides access to IsoDep API for Android.
///
/// Acquire `IsoDep` instance using `IsoDep.from`.
class IsoDep {
  /// Constructs an instance with the given values for testing.
  ///
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `IsoDep.from` are valid.
  const IsoDep({
    required NfcTag tag,
    required this.identifier,
    required this.hiLayerResponse,
    required this.historicalBytes,
    required this.isExtendedLengthApduSupported,
    required this.maxTransceiveLength,
    required this.initialTimeout,
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from Tag#id on Android.
  final Uint8List identifier;

  /// The value from IsoDep#hiLayerResponse on Android.
  final Uint8List? hiLayerResponse;

  /// The value from IsoDep#historicalBytes on Android.
  final Uint8List? historicalBytes;

  /// The value from IsoDep#isExtendedLengthApduSupported on Android.
  final bool isExtendedLengthApduSupported;

  /// The value from IsoDep#maxTransceiveLength on Android.
  final int maxTransceiveLength;

  /// The value from IsoDep#timeout on Android in initialize.
  final int initialTimeout;

  /// Get an instance of `IsoDep` for the given tag.
  ///
  /// Returns null if the tag is not compatible with IsoDep.
  static IsoDep? from(NfcTag tag) => $GetIsoDep(tag);

  /// Sends the IsoDep command to the tag.
  ///
  /// This uses IsoDep#transceive API on Android.
  Future<Uint8List> transceive({
    required Uint8List data,
  }) async {
    return channel.invokeMethod('IsoDep#transceive', {
      'handle': _tag.handle,
      'data': data,
    }).then((value) => value!);
  }

  /// This uses IsoDep#setTimeout API on Android.
  Future<int> setTimeout({
    required int time,
  }) async {
    return channel.invokeMethod('IsoDep#setTimeout', {
      'handle': _tag.handle,
      'time': time,
    }).then((value) => value!);
  }

  /// This uses IsoDep#getTimeout API on Android.
  Future<int> getTimeout() async {
    return channel.invokeMethod('IsoDep#getTimeout', {
      'handle': _tag.handle,
    }).then((value) => value!);
  }
}
