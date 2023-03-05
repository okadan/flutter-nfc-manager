import 'package:flutter/foundation.dart';
import 'package:nfc_manager/src/nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.dart';
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart';

/// The class providing access to the NFC features for iOS.
final class NfcManagerIos {
  NfcManagerIos._() {
    _NfcFlutterApiIos(this);
  }

  /// The instance of the [NfcManagerIos] to use.
  static NfcManagerIos get instance => _instance ??= NfcManagerIos._();
  static NfcManagerIos? _instance;

  void Function(NfcTag)? _tagSessionDidDetectTag;
  void Function()? _tagSessionDidBecomeActive;
  void Function(NfcReaderSessionErrorIos)? _tagSessionDidInvalidateWithError;
  void Function(List<NfcVasResponseIos>)? _vasSessionDidReceive;
  void Function()? _vasSessionDidBecomeActive;
  void Function(NfcReaderSessionErrorIos)? _vasSessionDidInvalidateWithError;

  // TODO: DOC
  Future<bool> tagSessionReadingAvailable() {
    return hostApi.tagSessionReadingAvailable();
  }

  // TODO: DOC
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
      pollingOptions:
          pollingOptions
              .map((e) => PollingOptionPigeon.values.byName(e.name))
              .toList(),
      alertMessage: alertMessage,
      invalidateAfterFirstRead: invalidateAfterFirstRead,
    );
  }

  // TODO: DOC
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

  // TODO: DOC
  Future<void> tagSessionSetAlertMessage({required String alertMessage}) {
    return hostApi.tagSessionSetAlertMessage(alertMessage: alertMessage);
  }

  // TODO: DOC
  Future<void> tagSessionRestartPolling() {
    return hostApi.tagSessionRestartPolling();
  }

  // TODO: DOC
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
      configurations:
          configurations
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

  // TODO: DOC
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

  // TODO: DOC
  Future<void> vasSessionSetAlertMessage({required String alertMessage}) {
    return hostApi.vasSessionSetAlertMessage(alertMessage: alertMessage);
  }
}

class _NfcFlutterApiIos implements FlutterApiPigeon {
  _NfcFlutterApiIos(this._instance) {
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

// TODO: DOC
final class NfcVasCommandConfigurationIos {
  // TODO: DOC
  @visibleForTesting
  const NfcVasCommandConfigurationIos({
    required this.mode,
    required this.passIdentifier,
    this.url,
  });

  // TODO: DOC
  final NfcVasCommandConfigurationModeIos mode;

  // TODO: DOC
  final String passIdentifier;

  // TODO: DOC
  final Uri? url;
}

// TODO: DOC
final class NfcVasResponseIos {
  // TODO: DOC
  @visibleForTesting
  const NfcVasResponseIos({
    required this.status,
    required this.vasData,
    required this.mobileToken,
  });

  // TODO: DOC
  final NfcVasResponseErrorCodeIos status;

  // TODO: DOC
  final Uint8List vasData;

  // TODO: DOC
  final Uint8List mobileToken;
}

// TODO: DOC
final class NfcReaderSessionErrorIos {
  // TODO: DOC
  @visibleForTesting
  const NfcReaderSessionErrorIos({required this.code, required this.message});

  // TODO: DOC
  final NfcReaderErrorCodeIos code;

  // TODO: DOC
  final String message;
}

// TODO: DOC
enum NfcVasCommandConfigurationModeIos {
  // TODO: DOC
  normal,

  // TODO: DOC
  urlOnly,
}

// TODO: DOC
enum NfcReaderErrorCodeIos {
  // TODO: DOC
  readerSessionInvalidationErrorFirstNDEFTagRead,

  // TODO: DOC
  readerSessionInvalidationErrorSessionTerminatedUnexpectedly,

  // TODO: DOC
  readerSessionInvalidationErrorSessionTimeout,

  // TODO: DOC
  readerSessionInvalidationErrorSystemIsBusy,

  // TODO: DOC
  readerSessionInvalidationErrorUserCanceled,

  // TODO: DOC
  ndefReaderSessionErrorTagNotWritable,

  // TODO: DOC
  ndefReaderSessionErrorTagSizeTooSmall,

  // TODO: DOC
  ndefReaderSessionErrorTagUpdateFailure,

  // TODO: DOC
  ndefReaderSessionErrorZeroLengthMessage,

  // TODO: DOC
  readerTransceiveErrorRetryExceeded,

  // TODO: DOC
  readerTransceiveErrorTagConnectionLost,

  // TODO: DOC
  readerTransceiveErrorTagNotConnected,

  // TODO: DOC
  readerTransceiveErrorTagResponseError,

  // TODO: DOC
  readerTransceiveErrorSessionInvalidated,

  // TODO: DOC
  readerTransceiveErrorPacketTooLong,

  // TODO: DOC
  tagCommandConfigurationErrorInvalidParameters,

  // TODO: DOC
  readerErrorUnsupportedFeature,

  // TODO: DOC
  readerErrorInvalidParameter,

  // TODO: DOC
  readerErrorInvalidParameterLength,

  // TODO: DOC
  readerErrorParameterOutOfBound,

  // TODO: DOC
  readerErrorRadioDisabled,

  // TODO: DOC
  readerErrorSecurityViolation,
}

// TODO: DOC
enum NfcVasResponseErrorCodeIos {
  // TODO: DOC
  success,

  // TODO: DOC
  userIntervention,

  // TODO: DOC
  dataNotActivated,

  // TODO: DOC
  dataNotFound,

  // TODO: DOC
  incorrectData,

  // TODO: DOC
  unsupportedApplicationVersion,

  // TODO: DOC
  wrongLCField,

  // TODO: DOC
  wrongParameters,
}
