import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  swiftOut: 'ios/Classes/Pigeon.swift',
  dartOut: 'lib/src/nfc_manager_ios/pigeon.g.dart',
))
@FlutterApi()
abstract final class PigeonFlutterApi {
  void tagReaderSessionDidBecomeActive();
  void tagReaderSessionDidDetect(PigeonTag tag);
  void tagReaderSessionDidInvalidateWithError(PigeonNfcReaderSessionError error);
  void vasReaderSessionDidBecomeActive();
  void vasReaderSessionDidReceive(List<PigeonNfcVasResponse> responses);
  void vasReaderSessionDidInvalidateWithError(PigeonNfcReaderSessionError error);
}

@HostApi()
abstract final class PigeonHostApi {
  bool tagReaderSessionReadingAvailable();
  void tagReaderSessionBegin({required List<String> pollingOptions, required String? alertMessage, required bool invalidateAfterFirstRead});
  void tagReaderSessionInvalidate({required String? alertMessage, required String? errorMessage});
  void tagReaderSessionRestartPolling();
  void tagReaderSessionSetAlertMessage({required String alertMessage});
  bool vasReaderSessionReadingAvailable();
  void vasReaderSessionBegin({required List<PigeonNfcVasCommandConfiguration> configurations, required String? alertMessage});
  void vasReaderSessionInvalidate({required String? alertMessage, required String? errorMessage});
  void vasReaderSessionSetAlertMessage({required String alertMessage});
  @async PigeonNDEFQueryStatus ndefQueryNDEFStatus({required String handle});
  @async PigeonNdefMessage? ndefReadNDEF({required String handle});
  @async void ndefWriteNDEF({required String handle, required PigeonNdefMessage message});
  @async void ndefWriteLock({required String handle});
  @async PigeonFeliCaPollingResponse feliCaPolling({required String handle, required Uint8List systemCode, required PigeonFeliCaPollingRequestCode requestCode, required PigeonFeliCaPollingTimeSlot timeSlot});
  @async List<Uint8List> feliCaRequestService({required String handle, required List<Uint8List> nodeCodeList});
  @async int feliCaRequestResponse({required String handle});
  @async PigeonFeliCaReadWithoutEncryptionResponse feliCaReadWithoutEncryption({required String handle, required List<Uint8List> serviceCodeList, required List<Uint8List> blockList});
  @async PigeonFeliCaStatusFlag feliCaWriteWithoutEncryption({required String handle, required List<Uint8List> serviceCodeList, required List<Uint8List> blockList, required List<Uint8List> blockData});
  @async List<Uint8List> feliCaRequestSystemCode({required String handle});
  @async PigeonFeliCaRequestServiceV2Response feliCaRequestServiceV2({required String handle, required List<Uint8List> nodeCodeList});
  @async PigeonFeliCaRequestSpecificationVersionResponse feliCaRequestSpecificationVersion({required String handle});
  @async PigeonFeliCaStatusFlag feliCaResetMode({required String handle});
  @async Uint8List feliCaSendFeliCaCommand({required String handle, required Uint8List commandPacket});
  @async Uint8List miFareSendMiFareCommand({required String handle, required Uint8List commandPacket});
  @async PigeonISO7816ResponseAPDU miFareSendMiFareISO7816Command({required String handle, required PigeonISO7816APDU apdu});
  @async PigeonISO7816ResponseAPDU miFareSendMiFareISO7816CommandRaw({required String handle, required Uint8List data});
  @async PigeonISO7816ResponseAPDU iso7816SendCommand({required String handle, required PigeonISO7816APDU apdu});
  @async PigeonISO7816ResponseAPDU iso7816SendCommandRaw({required String handle, required Uint8List data});
  @async void iso15693StayQuiet({required String handle});
  @async Uint8List iso15693ReadSingleBlock({required String handle, required List<String> requestFlags, required int blockNumber});
  @async void iso15693WriteSingleBlock({required String handle, required List<String> requestFlags, required int blockNumber, required Uint8List dataBlock});
  @async void iso15693LockBlock({required String handle, required List<String> requestFlags, required int blockNumber});
  @async List<Uint8List> iso15693ReadMultipleBlocks({required String handle, required List<String> requestFlags, required int blockNumber, required int numberOfBlocks});
  @async void iso15693WriteMultipleBlocks({required String handle, required List<String> requestFlags, required int blockNumber, required int numberOfBlocks, required List<Uint8List> dataBlocks});
  @async void iso15693Select({required String handle, required List<String> requestFlags});
  @async void iso15693ResetToReady({required String handle, required List<String> requestFlags});
  @async void iso15693WriteAfi({required String handle, required List<String> requestFlags, required int afi});
  @async void iso15693LockAfi({required String handle, required List<String> requestFlags});
  @async void iso15693WriteDsfId({required String handle, required List<String> requestFlags, required int dsfId});
  @async void iso15693LockDsfId({required String handle, required List<String> requestFlags});
  @async PigeonISO15693SystemInfo iso15693GetSystemInfo({required String handle, required List<String> requestFlags});
  @async List<int> iso15693GetMultipleBlockSecurityStatus({required String handle, required List<String> requestFlags, required int blockNumber, required int numberOfBlocks});
  @async Uint8List iso15693CustomCommand({required String handle, required List<String> requestFlags, required int customCommandCode, required Uint8List customRequestParameters});
}

final class PigeonTag {
  const PigeonTag({
    required this.handle,
    required this.ndef,
    required this.feliCa,
    required this.iso15693,
    required this.iso7816,
    required this.miFare,
  });
  final String handle;
  final PigeonNdef? ndef;
  final PigeonFeliCa? feliCa;
  final PigeonISO15693? iso15693;
  final PigeonISO7816? iso7816;
  final PigeonMiFare? miFare;
}

final class PigeonNdef {
  const PigeonNdef({
    required this.status,
    required this.capacity,
    required this.cachedNdefMessage,
  });
  final PigeonNdefStatus status;
  final int capacity;
  final PigeonNdefMessage? cachedNdefMessage;
}

final class PigeonFeliCa {
  const PigeonFeliCa({
    required this.currentSystemCode,
    required this.currentIDm,
  });
  final Uint8List currentSystemCode;
  final Uint8List currentIDm;
}

final class PigeonISO15693 {
  const PigeonISO15693({
    required this.icManufacturerCode,
    required this.icSerialNumber,
    required this.identifier,
  });
  final int icManufacturerCode;
  final Uint8List icSerialNumber;
  final Uint8List identifier;
}

final class PigeonISO7816 {
  const PigeonISO7816({
    required this.initialSelectedAID,
    required this.identifier,
    required this.historicalBytes,
    required this.applicationData,
    required this.proprietaryApplicationDataCoding,
  });
  final String initialSelectedAID;
  final Uint8List identifier;
  final Uint8List? historicalBytes;
  final Uint8List? applicationData;
  final bool proprietaryApplicationDataCoding;
}

final class PigeonMiFare {
  const PigeonMiFare({
    required this.mifareFamily,
    required this.identifier,
    required this.historicalBytes,
  });
  final PigeonMiFareFamily mifareFamily;
  final Uint8List identifier;
  final Uint8List? historicalBytes;
}

final class PigeonNDEFQueryStatus {
  const PigeonNDEFQueryStatus({
    required this.status,
    required this.capacity,
  });
  final PigeonNdefStatus status;
  final int capacity;
}

final class PigeonNdefMessage {
  const PigeonNdefMessage({
    required this.records,
  });
  final List<PigeonNdefPayload?> records;
}

final class PigeonNdefPayload {
  const PigeonNdefPayload({
    required this.typeNameFormat,
    required this.type,
    required this.identifier,
    required this.payload,
  });
  final PigeonTypeNameFormat typeNameFormat;
  final Uint8List type;
  final Uint8List identifier;
  final Uint8List payload;
}

final class PigeonFeliCaPollingResponse {
  const PigeonFeliCaPollingResponse({
    required this.manufacturerParameter,
    required this.requestData,
  });
  final Uint8List manufacturerParameter;
  final Uint8List requestData;
}

final class PigeonFeliCaReadWithoutEncryptionResponse {
  const PigeonFeliCaReadWithoutEncryptionResponse({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.blockData,
  });
  final int statusFlag1;
  final int statusFlag2;
  final List<Uint8List?> blockData;
}

final class PigeonFeliCaRequestServiceV2Response {
  const PigeonFeliCaRequestServiceV2Response({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.encryptionIdentifier,
    required this.nodeKeyVersionListAES,
    required this.nodeKeyVersionListDES,
  });
  final int statusFlag1;
  final int statusFlag2;
  final int encryptionIdentifier;
  final List<Uint8List?> nodeKeyVersionListAES;
  final List<Uint8List?> nodeKeyVersionListDES;
}

final class PigeonFeliCaRequestSpecificationVersionResponse {
  const PigeonFeliCaRequestSpecificationVersionResponse({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.basicVersion,
    required this.optionVersion,
  });
  final int statusFlag1;
  final int statusFlag2;
  final Uint8List basicVersion;
  final Uint8List optionVersion;
}

final class PigeonFeliCaStatusFlag {
  const PigeonFeliCaStatusFlag({
    required this.statusFlag1,
    required this.statusFlag2,
  });
  final int statusFlag1;
  final int statusFlag2;
}

final class PigeonISO7816APDU {
  const PigeonISO7816APDU({
    required this.instructionClass,
    required this.instructionCode,
    required this.p1Parameter,
    required this.p2Parameter,
    required this.data,
    required this.expectedResponseLength,
  });
  final int instructionClass;
  final int instructionCode;
  final int p1Parameter;
  final int p2Parameter;
  final Uint8List data;
  final int expectedResponseLength;
}

final class PigeonISO7816ResponseAPDU {
  const PigeonISO7816ResponseAPDU({
    required this.payload,
    required this.statusWord1,
    required this.statusWord2,
  });
  final Uint8List payload;
  final int statusWord1;
  final int statusWord2;
}

final class PigeonISO15693SystemInfo {
  const PigeonISO15693SystemInfo({
    required this.dataStorageFormatIdentifier,
    required this.applicationFamilyIdentifier,
    required this.blockSize,
    required this.totalBlocks,
    required this.icReference,
  });
  final int dataStorageFormatIdentifier;
  final int applicationFamilyIdentifier;
  final int blockSize;
  final int totalBlocks;
  final int icReference;
}

final class PigeonNfcReaderSessionError {
  const PigeonNfcReaderSessionError({
    required this.code,
    required this.message,
  });
  final PigeonNfcReaderErrorCode code;
  final String message;
}

final class PigeonNfcVasCommandConfiguration {
  const PigeonNfcVasCommandConfiguration({
    required this.mode,
    required this.passIdentifier,
    required this.url,
  });
  final PigeonNfcVasCommandConfigurationMode mode;
  final String passIdentifier;
  final String? url;
}

final class PigeonNfcVasResponse {
  const PigeonNfcVasResponse({
    required this.status,
    required this.vasData,
    required this.mobileToken,
  });
  final PigeonNfcVasResponseErrorCode status;
  final Uint8List vasData;
  final Uint8List mobileToken;
}

enum PigeonNdefStatus {
  notSupported,
  readWrite,
  readOnly,
}

enum PigeonTypeNameFormat {
  empty,
  wellKnown,
  media,
  absoluteUri,
  external,
  unknown,
  unchanged,
}

enum PigeonFeliCaPollingRequestCode {
  noRequest,
  systemCode,
  communicationPerformance,
}

enum PigeonFeliCaPollingTimeSlot {
  max1,
  max2,
  max4,
  max8,
  max16,
}

enum PigeonMiFareFamily {
  unknown,
  ultralight,
  plus,
  desfire,
}

enum PigeonNfcVasCommandConfigurationMode {
  normal,
  urlOnly,
}

enum PigeonNfcReaderErrorCode {
  readerSessionInvalidationErrorFirstNDEFTagRead,
  readerSessionInvalidationErrorSessionTerminatedUnexpectedly,
  readerSessionInvalidationErrorSessionTimeout,
  readerSessionInvalidationErrorSystemIsBusy,
  readerSessionInvalidationErrorUserCanceled,
  ndefReaderSessionErrorTagNotWritable,
  ndefReaderSessionErrorTagSizeTooSmall,
  ndefReaderSessionErrorTagUpdateFailure,
  ndefReaderSessionErrorZeroLengthMessage,
  readerTransceiveErrorRetryExceeded,
  readerTransceiveErrorTagConnectionLost,
  readerTransceiveErrorTagNotConnected,
  readerTransceiveErrorTagResponseError,
  readerTransceiveErrorSessionInvalidated,
  readerTransceiveErrorPacketTooLong,
  tagCommandConfigurationErrorInvalidParameters,
  readerErrorUnsupportedFeature,
  readerErrorInvalidParameter,
  readerErrorInvalidParameterLength,
  readerErrorParameterOutOfBound,
  readerErrorRadioDisabled,
  readerErrorSecurityViolation,
}

enum PigeonNfcVasResponseErrorCode {
  success,
  userIntervention,
  dataNotActivated,
  dataNotFound,
  incorrectData,
  unsupportedApplicationVersion,
  wrongLCField,
  wrongParameters,
}
