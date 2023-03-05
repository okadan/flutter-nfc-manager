import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager_android/nfc_manager_platform.dart';
import 'package:nfc_manager/src/nfc_manager_ios/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/nfc_manager_platform.dart';

/// The entry point for accessing the NFC session.
abstract class NfcManager {
  static NfcManager? _instance;

  /// The instance of the [NfcManager] to use.
  static NfcManager get instance {
    return _instance ??= switch (defaultTargetPlatform) {
      TargetPlatform.android => NfcManagerAndroidPlatform(),
      TargetPlatform.iOS => NfcManagerIOSPlatform(),
      _ => throw 'unsupported platform: $defaultTargetPlatform',
    };
  }

  /// Checks whether the NFC session is available.
  Future<bool> isAvailable();

  /// Starts the session and registers callbacks for tag discovery.
  ///
  /// Use [pollingOptions] to specify which tag types to discover.
  ///
  /// [onDiscovered] is called when the session discovers the tag.
  ///
  /// (iOS only) [alertMessageIOS] is used to display the message on popup
  /// shown when the session is started.
  ///
  /// (iOS only) [invalidateAfterFirstReadIOS] is used to specify whether the
  /// session should be invalidated after the first tag discovery. Default is true.
  ///
  /// (iOS only) [onSessionErrorIOS] is called when the session is invalidated for
  /// some reason after the session has started.
  Future<void> startSession({
    required Set<NfcPollingOption> pollingOptions,
    required void Function(NfcTag) onDiscovered,
    String? alertMessageIOS,
    bool invalidateAfterFirstReadIOS = true,
    void Function(NfcReaderSessionErrorIOS)? onSessionErrorIOS,
  });

  /// Stops the session and unregisters callbacks.
  ///
  /// (iOS only) [alertMessageIOS] and [errorMessageIOS] are used to display
  /// success or error message on the popup. If both are used, [errorMessageIOS] is used.
  Future<void> stopSession({
    String? alertMessageIOS,
    String? errorMessageIOS,
  });
}

/// The class that represents the tag discovered by the session.
///
/// When the session discovers a tag, it returns an instance of this class. Use
/// this generic instance to instantiate a specific tag class and retrieve
/// tag-specific operations.
///
/// ```dart
/// import 'package:nfc_manager/nfc_manager.dart';
/// import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
///
///
/// NfcManager.instance.startSession(
///   pollingOptions: ...,
///   onDiscovered: (NfcTag tag) async {
///     final ndef = Ndef.from(tag);
///     if (ndef == null) {
///       print('The tag is not compatible with NDEF.');
///       return;
///     }
///     // Do something with NDEF instance...
///   },
/// );
/// ```
final class NfcTag {
  /// Constructs an instance of this class for given data for testing.
  ///
  /// The instances constructed by this way are not valid in the production
  /// environment. Only instances obtained from the `onDiscovered` callback of
  /// the session are valid.
  @visibleForTesting
  const NfcTag({required this.data});

  /// The raw values about this tag obtained from the native platform.
  ///
  /// Don't use this values directly. Instead, access it via the specific tag classes.
  @protected
  final Object data;
}

/// The values that specify which tag types to discover when calling [NfcManager.startSession].
enum NfcPollingOption {
  /// The value indicating that the session will discover ISO 14443 tags.
  iso14443,

  /// The value indicating that the session will discover ISO 15693 tags.
  iso15693,

  /// The value indicating that the session will discover ISO 18092 tags.
  iso18092,
}
