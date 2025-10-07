import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

/// Provides access to the NFC session for iOS.
final class NfcManagerIos {
  NfcManagerIos._() {
    _FlutterApiIos(this);
  }

  /// The default instance of [NfcManagerIos] to use.
  static NfcManagerIos get instance => _instance ??= NfcManagerIos._();
  static NfcManagerIos? _instance;

  void Function(NfcTag)? _tagSessionDidDetectTag;
  void Function()? _tagSessionDidBecomeActive;
  void Function(NfcReaderSessionErrorIos)? _tagSessionDidInvalidateWithError;
  void Function(List<NfcVasResponseIos>)? _vasSessionDidReceive;
  void Function()? _vasSessionDidBecomeActive;
  void Function(NfcReaderSessionErrorIos)? _vasSessionDidInvalidateWithError;

  // DOC:
  Future<bool> tagSessionReadingAvailable() {
    return hostApi.tagSessionReadingAvailable();
  }

  // DOC:
  Future<void> tagSessionBegin({
    required Set<NfcPollingOption> pollingOptions,
    required void Function(NfcTag)? didDetectTag,
    void Function()? didBecomeActive,
    void Function(NfcReaderSessionErrorIos)? didInvalidateWithError,
    String? alertMessage,
    bool invalidateAfterFirstRead = true,
  }) {
    _tagSessionDidDetectTag = didDetectTag;
    _tagSessionDidBecomeActive = didBecomeActive;
    _tagSessionDidInvalidateWithError = didInvalidateWithError;
    return hostApi.tagSessionBegin(
      pollingOptions: pollingOptions
          .map((e) => PollingOptionPigeon.values.byName(e.name))
          .toList(),
      alertMessage: alertMessage,
      invalidateAfterFirstRead: invalidateAfterFirstRead,
    );
  }

  // DOC:
  Future<void> tagSessionInvalidate({
    String? alertMessage,
    String? errorMessage,
  }) {
    _tagSessionDidDetectTag = null;
    _tagSessionDidBecomeActive = null;
    _tagSessionDidInvalidateWithError = null;
    return hostApi.tagSessionInvalidate(
      alertMessage: alertMessage,
      errorMessage: errorMessage,
    );
  }

  // DOC:
  Future<void> tagSessionSetAlertMessage({required String alertMessage}) {
    return hostApi.tagSessionSetAlertMessage(alertMessage: alertMessage);
  }

  // DOC:
  Future<void> tagSessionRestartPolling() {
    return hostApi.tagSessionRestartPolling();
  }

  // DOC:
  Future<void> vasSessionBegin({
    required List<NfcVasCommandConfigurationIos> configurations,
    required void Function(List<NfcVasResponseIos> configurations) didReceive,
    void Function()? didBecomeActive,
    void Function(NfcReaderSessionErrorIos error)? didInvalidateWithError,
    String? alertMessage,
  }) {
    _vasSessionDidBecomeActive = didBecomeActive;
    _vasSessionDidInvalidateWithError = didInvalidateWithError;
    _vasSessionDidReceive = didReceive;
    return hostApi.vasSessionBegin(
      configurations: configurations
          .map(
            (e) => NfcVasCommandConfigurationPigeon(
              mode: NfcVasCommandConfigurationModePigeon.values.byName(
                e.mode.name,
              ),
              passIdentifier: e.passIdentifier,
              url: e.url?.toString(),
            ),
          )
          .toList(),
      alertMessage: alertMessage,
    );
  }

  // DOC:
  Future<void> vasSessionInvalidate({
    String? alertMessage,
    String? errorMessage,
  }) {
    _vasSessionDidBecomeActive = null;
    _vasSessionDidInvalidateWithError = null;
    _vasSessionDidReceive = null;
    return hostApi.vasSessionInvalidate(
      alertMessage: alertMessage,
      errorMessage: errorMessage,
    );
  }

  // DOC:
  Future<void> vasSessionSetAlertMessage({required String alertMessage}) {
    return hostApi.vasSessionSetAlertMessage(alertMessage: alertMessage);
  }
}

final class _FlutterApiIos implements FlutterApiPigeon {
  _FlutterApiIos(this._instance) {
    FlutterApiPigeon.setUp(this);
  }

  final NfcManagerIos _instance;

  @override
  void tagSessionDidBecomeActive() {
    _instance._tagSessionDidBecomeActive?.call();
  }

  @override
  void tagSessionDidInvalidateWithError(NfcReaderSessionErrorPigeon error) {
    _instance._tagSessionDidInvalidateWithError?.call(
      NfcReaderSessionErrorIos(
        code: NfcReaderErrorCodeIos.values.byName(error.code.name),
        message: error.message,
      ),
    );
  }

  @override
  void tagSessionDidDetect(TagPigeon tag) {
    _instance._tagSessionDidDetectTag?.call(
      // ignore: invalid_use_of_visible_for_testing_member
      NfcTag(data: tag),
    );
  }

  @override
  void vasSessionDidBecomeActive() {
    _instance._vasSessionDidBecomeActive?.call();
  }

  @override
  void vasSessionDidInvalidateWithError(NfcReaderSessionErrorPigeon error) {
    _instance._vasSessionDidInvalidateWithError?.call(
      NfcReaderSessionErrorIos(
        code: NfcReaderErrorCodeIos.values.byName(error.code.name),
        message: error.message,
      ),
    );
  }

  @override
  void vasSessionDidReceive(List<NfcVasResponsePigeon?> responses) {
    _instance._vasSessionDidReceive?.call(
      responses
          .map(
            (e) => NfcVasResponseIos(
              status: NfcVasResponseErrorCodeIos.values.byName(e!.status.name),
              vasData: e.vasData,
              mobileToken: e.mobileToken,
            ),
          )
          .toList(),
    );
  }
}

// DOC:
final class NfcVasCommandConfigurationIos {
  // DOC:
  @visibleForTesting
  const NfcVasCommandConfigurationIos({
    required this.mode,
    required this.passIdentifier,
    this.url,
  });

  // DOC:
  final NfcVasCommandConfigurationModeIos mode;

  // DOC:
  final String passIdentifier;

  // DOC:
  final Uri? url;
}

// DOC:
final class NfcVasResponseIos {
  // DOC:
  @visibleForTesting
  const NfcVasResponseIos({
    required this.status,
    required this.vasData,
    required this.mobileToken,
  });

  // DOC:
  final NfcVasResponseErrorCodeIos status;

  // DOC:
  final Uint8List vasData;

  // DOC:
  final Uint8List mobileToken;
}

// DOC:
final class NfcReaderSessionErrorIos {
  // DOC:
  @visibleForTesting
  const NfcReaderSessionErrorIos({required this.code, required this.message});

  // DOC:
  final NfcReaderErrorCodeIos code;

  // DOC:
  final String message;
}

// DOC:
enum NfcVasCommandConfigurationModeIos {
  // DOC:
  normal,

  // DOC:
  urlOnly,
}

// DOC:
enum NfcReaderErrorCodeIos {
  // DOC:
  readerSessionInvalidationErrorFirstNDEFTagRead,

  // DOC:
  readerSessionInvalidationErrorSessionTerminatedUnexpectedly,

  // DOC:
  readerSessionInvalidationErrorSessionTimeout,

  // DOC:
  readerSessionInvalidationErrorSystemIsBusy,

  // DOC:
  readerSessionInvalidationErrorUserCanceled,

  // DOC:
  ndefReaderSessionErrorTagNotWritable,

  // DOC:
  ndefReaderSessionErrorTagSizeTooSmall,

  // DOC:
  ndefReaderSessionErrorTagUpdateFailure,

  // DOC:
  ndefReaderSessionErrorZeroLengthMessage,

  // DOC:
  readerTransceiveErrorRetryExceeded,

  // DOC:
  readerTransceiveErrorTagConnectionLost,

  // DOC:
  readerTransceiveErrorTagNotConnected,

  // DOC:
  readerTransceiveErrorTagResponseError,

  // DOC:
  readerTransceiveErrorSessionInvalidated,

  // DOC:
  readerTransceiveErrorPacketTooLong,

  // DOC:
  tagCommandConfigurationErrorInvalidParameters,

  // DOC:
  readerErrorUnsupportedFeature,

  // DOC:
  readerErrorInvalidParameter,

  // DOC:
  readerErrorInvalidParameterLength,

  // DOC:
  readerErrorParameterOutOfBound,

  // DOC:
  readerErrorRadioDisabled,

  // DOC:
  readerErrorSecurityViolation,
}

// DOC:
enum NfcVasResponseErrorCodeIos {
  // DOC:
  success,

  // DOC:
  userIntervention,

  // DOC:
  dataNotActivated,

  // DOC:
  dataNotFound,

  // DOC:
  incorrectData,

  // DOC:
  unsupportedApplicationVersion,

  // DOC:
  wrongLCField,

  // DOC:
  wrongParameters,
}
