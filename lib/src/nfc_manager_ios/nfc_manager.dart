import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

// The entry point for accessing the NFC session on iOS.
final class NfcManagerIOS {
  NfcManagerIOS._() {
    _NfcManagerIOSFlutterApi(this);
  }

  /// The instance of the [NfcManagerIOS] to use.
  static NfcManagerIOS get instance => _instance ??= NfcManagerIOS._();
  static NfcManagerIOS? _instance;

  void Function(NfcTag)? _tagReaderSessionDidDetectTag;
  void Function()? _tagReaderSessionDidBecomeActive;
  void Function(NfcReaderSessionErrorIOS)?
      _tagReaderSessionDidInvalidateWithError;
  void Function(List<NfcVasResponseIOS>)? _vasReaderSessionDidReceive;
  void Function()? _vasReaderSessionDidBecomeActive;
  void Function(NfcReaderSessionErrorIOS)?
      _vasReaderSessionDidInvalidateWithError;

  /// DOC:
  Future<bool> tagReaderSessionReadingAvailable() {
    return hostApi.tagReaderSessionReadingAvailable();
  }

  /// DOC:
  Future<void> tagReaderSessionBegin({
    required Set<NfcPollingOption> pollingOptions,
    required void Function(NfcTag)? didDetectTag,
    void Function()? didBecomeActive,
    void Function(NfcReaderSessionErrorIOS)? didInvalidateWithError,
    String? alertMessage,
    bool invalidateAfterFirstRead = true,
  }) {
    _tagReaderSessionDidDetectTag = didDetectTag;
    _tagReaderSessionDidBecomeActive = didBecomeActive;
    _tagReaderSessionDidInvalidateWithError = didInvalidateWithError;
    return hostApi.tagReaderSessionBegin(
      pollingOptions: pollingOptions.map((e) => e.name).toList(),
      alertMessage: alertMessage,
      invalidateAfterFirstRead: invalidateAfterFirstRead,
    );
  }

  /// DOC:
  Future<void> tagReaderSessionInvalidate({
    String? alertMessage,
    String? errorMessage,
  }) {
    _tagReaderSessionDidDetectTag = null;
    _tagReaderSessionDidBecomeActive = null;
    _tagReaderSessionDidInvalidateWithError = null;
    return hostApi.tagReaderSessionInvalidate(
      alertMessage: alertMessage,
      errorMessage: errorMessage,
    );
  }

  /// DOC:
  Future<void> tagReaderSessionSetAlertMessage({required String alertMessage}) {
    return hostApi.tagReaderSessionSetAlertMessage(
      alertMessage: alertMessage,
    );
  }

  /// DOC:
  Future<void> tagReaderSessionRestartPolling() {
    return hostApi.tagReaderSessionRestartPolling();
  }

  /// DOC:
  Future<void> vasReaderSessionBegin({
    required List<NfcVasCommandConfigurationIOS> configurations,
    required void Function(List<NfcVasResponseIOS> configurations) didReceive,
    void Function()? didBecomeActive,
    void Function(NfcReaderSessionErrorIOS error)? didInvalidateWithError,
    String? alertMessage,
  }) {
    _vasReaderSessionDidBecomeActive = didBecomeActive;
    _vasReaderSessionDidInvalidateWithError = didInvalidateWithError;
    _vasReaderSessionDidReceive = didReceive;
    return hostApi.vasReaderSessionBegin(
      configurations: configurations
          .map((e) => PigeonNfcVasCommandConfiguration(
                mode: PigeonNfcVasCommandConfigurationMode.values.byName(
                  e.mode.name,
                ),
                passIdentifier: e.passIdentifier,
                url: e.url?.toString(),
              ))
          .toList(),
      alertMessage: alertMessage,
    );
  }

  /// DOC:
  Future<void> vasReaderSessionInvalidate({
    String? alertMessage,
    String? errorMessage,
  }) {
    _vasReaderSessionDidBecomeActive = null;
    _vasReaderSessionDidInvalidateWithError = null;
    _vasReaderSessionDidReceive = null;
    return hostApi.vasReaderSessionInvalidate(
      alertMessage: alertMessage,
      errorMessage: errorMessage,
    );
  }

  /// DOC:
  Future<void> vasReaderSessionSetAlertMessage({required String alertMessage}) {
    return hostApi.vasReaderSessionSetAlertMessage(
      alertMessage: alertMessage,
    );
  }
}

class _NfcManagerIOSFlutterApi implements PigeonFlutterApi {
  _NfcManagerIOSFlutterApi(this._instance) {
    PigeonFlutterApi.setup(this);
  }

  final NfcManagerIOS _instance;

  @override
  void tagReaderSessionDidBecomeActive() {
    _instance._tagReaderSessionDidBecomeActive?.call();
  }

  @override
  void tagReaderSessionDidInvalidateWithError(
    PigeonNfcReaderSessionError error,
  ) {
    _instance._tagReaderSessionDidInvalidateWithError?.call(
      NfcReaderSessionErrorIOS(
        code: NfcReaderErrorCodeIOS.values.byName(error.code.name),
        message: error.message,
      ),
    );
  }

  @override
  void tagReaderSessionDidDetect(PigeonTag tag) {
    _instance._tagReaderSessionDidDetectTag?.call(
      // ignore: invalid_use_of_visible_for_testing_member
      NfcTag(data: tag),
    );
  }

  @override
  void vasReaderSessionDidBecomeActive() {
    _instance._vasReaderSessionDidBecomeActive?.call();
  }

  @override
  void vasReaderSessionDidInvalidateWithError(
    PigeonNfcReaderSessionError error,
  ) {
    _instance._vasReaderSessionDidInvalidateWithError?.call(
      NfcReaderSessionErrorIOS(
        code: NfcReaderErrorCodeIOS.values.byName(error.code.name),
        message: error.message,
      ),
    );
  }

  @override
  void vasReaderSessionDidReceive(List<PigeonNfcVasResponse?> responses) {
    _instance._vasReaderSessionDidReceive?.call(responses
        .map((e) => NfcVasResponseIOS(
              status: NfcVasResponseErrorCodeIOS.values.byName(e!.status.name),
              vasData: e.vasData,
              mobileToken: e.mobileToken,
            ))
        .toList());
  }
}

/// DOC:
final class NfcVasCommandConfigurationIOS {
  /// DOC:
  @visibleForTesting
  const NfcVasCommandConfigurationIOS({
    required this.mode,
    required this.passIdentifier,
    this.url,
  });

  /// DOC:
  final NfcVasCommandConfigurationModeIOS mode;

  /// DOC:
  final String passIdentifier;

  /// DOC:
  final Uri? url;
}

/// DOC:
final class NfcVasResponseIOS {
  /// DOC:
  @visibleForTesting
  const NfcVasResponseIOS({
    required this.status,
    required this.vasData,
    required this.mobileToken,
  });

  /// DOC:
  final NfcVasResponseErrorCodeIOS status;

  /// DOC:
  final Uint8List vasData;

  /// DOC:
  final Uint8List mobileToken;
}

/// DOC:
final class NfcReaderSessionErrorIOS {
  /// DOC:
  @visibleForTesting
  const NfcReaderSessionErrorIOS({
    required this.code,
    required this.message,
  });

  /// DOC:
  final NfcReaderErrorCodeIOS code;

  /// DOC:
  final String message;
}

/// DOC:
enum NfcVasCommandConfigurationModeIOS {
  /// DOC:
  normal,

  /// DOC:
  urlOnly,
}

/// DOC:
enum NfcReaderErrorCodeIOS {
  /// DOC:
  readerSessionInvalidationErrorFirstNDEFTagRead,

  /// DOC:
  readerSessionInvalidationErrorSessionTerminatedUnexpectedly,

  /// DOC:
  readerSessionInvalidationErrorSessionTimeout,

  /// DOC:
  readerSessionInvalidationErrorSystemIsBusy,

  /// DOC:
  readerSessionInvalidationErrorUserCanceled,

  /// DOC:
  ndefReaderSessionErrorTagNotWritable,

  /// DOC:
  ndefReaderSessionErrorTagSizeTooSmall,

  /// DOC:
  ndefReaderSessionErrorTagUpdateFailure,

  /// DOC:
  ndefReaderSessionErrorZeroLengthMessage,

  /// DOC:
  readerTransceiveErrorRetryExceeded,

  /// DOC:
  readerTransceiveErrorTagConnectionLost,

  /// DOC:
  readerTransceiveErrorTagNotConnected,

  /// DOC:
  readerTransceiveErrorTagResponseError,

  /// DOC:
  readerTransceiveErrorSessionInvalidated,

  /// DOC:
  readerTransceiveErrorPacketTooLong,

  /// DOC:
  tagCommandConfigurationErrorInvalidParameters,

  /// DOC:
  readerErrorUnsupportedFeature,

  /// DOC:
  readerErrorInvalidParameter,

  /// DOC:
  readerErrorInvalidParameterLength,

  /// DOC:
  readerErrorParameterOutOfBound,

  /// DOC:
  readerErrorRadioDisabled,

  /// DOC:
  readerErrorSecurityViolation,
}

/// DOC:
enum NfcVasResponseErrorCodeIOS {
  /// DOC:
  success,

  /// DOC:
  userIntervention,

  /// DOC:
  dataNotActivated,

  /// DOC:
  dataNotFound,

  /// DOC:
  incorrectData,

  /// DOC:
  unsupportedApplicationVersion,

  /// DOC:
  wrongLCField,

  /// DOC:
  wrongParameters,
}
