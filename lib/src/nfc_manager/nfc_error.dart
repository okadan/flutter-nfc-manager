import 'package:meta/meta.dart';

enum NfcSessionErrorType {
  sessionTimeout,
  systemIsBusy,
  userCanceled,
  unknown,
}

class NfcSessionError {
  NfcSessionError({
    @required this.type,
    @required this.message,
    @required this.details,
  });

  final NfcSessionErrorType type;
  final String message;
  final dynamic details;
}
