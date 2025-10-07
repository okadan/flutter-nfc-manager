import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager_android/nfc_manager_platform.dart';
import 'package:nfc_manager/src/nfc_manager_ios/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/nfc_manager_platform.dart';

/// Provides access to the NFC session.
abstract class NfcManager {
  static NfcManager? _instance;

  /// The default instance of [NfcManager] to use.
  static NfcManager get instance {
    return _instance ??= switch (defaultTargetPlatform) {
      TargetPlatform.android => NfcManagerAndroidPlatform(),
      TargetPlatform.iOS => NfcManagerIosPlatform(),
      _ => throw UnsupportedError(
        '${defaultTargetPlatform.name} is not supported',
      ),
    };
  }

  /// Whether the NFC session is available.
  @Deprecated('Use `checkAvailability` instead')
  Future<bool> isAvailable();

  /// Checks the availability of NFC on the current device.
  Future<NfcAvailability> checkAvailability();

  /// Starts the NFC session and register callbacks.
  ///
  /// [pollingOptions] is used to specify which tag types to discover.
  ///
  /// [onDiscovered] is called when the session discovers the tag.
  ///
  /// (iOS only) [alertMessageIos] is used to display the message on the popup.
  ///
  /// (iOS only) [invalidateAfterFirstReadIos] is used to specify whether the session should be invalidated after the
  /// first tag discovery. Default is true.
  ///
  /// (iOS only) [onSessionErrorIos] is called when the session is invalidated for some reason after the session has started.
  ///
  /// (Android only) [noPlatformSoundsAndroid] is used to disable platform sounds at the tag discovery. Default is false.
  Future<void> startSession({
    required Set<NfcPollingOption> pollingOptions,
    required void Function(NfcTag tag) onDiscovered,
    String? alertMessageIos,
    bool invalidateAfterFirstReadIos = true,
    void Function(NfcReaderSessionErrorIos)? onSessionErrorIos,
    bool noPlatformSoundsAndroid = false,
  });

  /// Stops the NFC session and unregister callbacks.
  ///
  /// (iOS only) [alertMessageIos] and [errorMessageIos] are used to display success or error message on the popup.
  /// If both are used, [errorMessageIos] is used.
  Future<void> stopSession({String? alertMessageIos, String? errorMessageIos});
}

/// Represents the tag discovered by the NFC session.
///
/// When the session discovers a tag, [onDiscovered] callback is called with an instance of this class. Use this
/// generic instance to instantiate a specific tag class and perform tag-specific operations.
final class NfcTag {
  /// Constructs an instance of this class for given data for testing.
  ///
  /// The instances constructed by this way are not valid in the production environment. Only instances obtained
  /// from the `onDiscovered` callback are valid.
  @visibleForTesting
  const NfcTag({required this.data});

  /// The raw data obtained from the native platform.
  ///
  /// You don't need to use this property directly. Instead, access it by instantiating a specific-tag classes.
  @protected
  final Object data;
}

/// Represents the availability of NFC on the current device.
enum NfcAvailability {
  /// NFC is suppported and currently enabled.
  enabled,

  /// NFC is supported but currently disabled.
  disabled,

  /// NFC is not supported.
  unsupported,
}

/// Represents the tag types which the NFC session will discover.
enum NfcPollingOption {
  /// The session will discover ISO 14443 tags.
  iso14443,

  /// The session will discover ISO 15693 tags.
  iso15693,

  /// The session will discover ISO 18092 tags.
  iso18092,
}
