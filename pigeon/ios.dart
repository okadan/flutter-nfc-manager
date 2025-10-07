import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartPackageName: 'nfc_manager',
    dartOut: 'lib/src/nfc_manager_ios/pigeon.g.dart',
    swiftOut: 'ios/Classes/Pigeon.swift',
  ),
)

@FlutterApi()
abstract final class FlutterApiPigeon {
  void tagSessionDidBecomeActive();
  void tagSessionDidDetect(TagPigeon tag);
  void tagSessionDidInvalidateWithError(NfcReaderSessionErrorPigeon error);
  void vasSessionDidBecomeActive();
  void vasSessionDidReceive(List<NfcVasResponsePigeon> responses);
  void vasSessionDidInvalidateWithError(NfcReaderSessionErrorPigeon error);
}

@HostApi()
abstract final class HostApiPigeon {
  bool tagSessionReadingAvailable();
  void tagSessionBegin({required List<PollingOptionPigeon> pollingOptions, required String? alertMessage, required bool invalidateAfterFirstRead});
  void tagSessionInvalidate({required String? alertMessage, required String? errorMessage});
  void tagSessionRestartPolling();
  void tagSessionSetAlertMessage({required String alertMessage});
  bool vasSessionReadingAvailable();
  void vasSessionBegin({required List<NfcVasCommandConfigurationPigeon> configurations, required String? alertMessage});
  void vasSessionInvalidate({required String? alertMessage, required String? errorMessage});
  void vasSessionSetAlertMessage({required String alertMessage});
  @async NdefQueryStatusPigeon ndefQueryNdefStatus({required String handle});
  @async NdefMessagePigeon? ndefReadNdef({required String handle});
  @async void ndefWriteNdef({required String handle, required NdefMessagePigeon message});
  @async void ndefWriteLock({required String handle});
  @async FeliCaPollingResponsePigeon feliCaPolling({required String handle, required Uint8List systemCode, required FeliCaPollingRequestCodePigeon requestCode, required FeliCaPollingTimeSlotPigeon timeSlot});
  @async List<Uint8List> feliCaRequestService({required String handle, required List<Uint8List> nodeCodeList});
  @async int feliCaRequestResponse({required String handle});
  @async FeliCaReadWithoutEncryptionResponsePigeon feliCaReadWithoutEncryption({required String handle, required List<Uint8List> serviceCodeList, required List<Uint8List> blockList});
  @async FeliCaStatusFlagPigeon feliCaWriteWithoutEncryption({required String handle, required List<Uint8List> serviceCodeList, required List<Uint8List> blockList, required List<Uint8List> blockData});
  @async List<Uint8List> feliCaRequestSystemCode({required String handle});
  @async FeliCaRequestServiceV2ResponsePigeon feliCaRequestServiceV2({required String handle, required List<Uint8List> nodeCodeList});
  @async FeliCaRequestSpecificationVersionResponsePigeon feliCaRequestSpecificationVersion({required String handle});
  @async FeliCaStatusFlagPigeon feliCaResetMode({required String handle});
  @async Uint8List feliCaSendFeliCaCommand({required String handle, required Uint8List commandPacket});
  @async Uint8List miFareSendMiFareCommand({required String handle, required Uint8List commandPacket});
  @async Iso7816ResponseApduPigeon miFareSendMiFareISO7816Command({required String handle, required Iso7816ApduPigeon apdu});
  @async Iso7816ResponseApduPigeon miFareSendMiFareISO7816CommandRaw({required String handle, required Uint8List data});
  @async Iso7816ResponseApduPigeon iso7816SendCommand({required String handle, required Iso7816ApduPigeon apdu});
  @async Iso7816ResponseApduPigeon iso7816SendCommandRaw({required String handle, required Uint8List data});
  @async void iso15693StayQuiet({required String handle});
  @async Uint8List iso15693ReadSingleBlock({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags, required int blockNumber});
  @async void iso15693WriteSingleBlock({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags, required int blockNumber, required Uint8List dataBlock});
  @async void iso15693LockBlock({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags, required int blockNumber});
  @async List<Uint8List> iso15693ReadMultipleBlocks({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags, required int blockNumber, required int numberOfBlocks});
  @async void iso15693WriteMultipleBlocks({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags, required int blockNumber, required int numberOfBlocks, required List<Uint8List> dataBlocks});
  @async void iso15693Select({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags});
  @async void iso15693ResetToReady({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags});
  @async void iso15693WriteAfi({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags, required int afi});
  @async void iso15693LockAfi({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags});
  @async void iso15693WriteDsfId({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags, required int dsfId});
  @async void iso15693LockDsfId({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags});
  @async Iso15693SystemInfoPigeon iso15693GetSystemInfo({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags});
  @async List<int> iso15693GetMultipleBlockSecurityStatus({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags, required int blockNumber, required int numberOfBlocks});
  @async Uint8List iso15693CustomCommand({required String handle, required List<Iso15693RequestFlagPigeon> requestFlags, required int customCommandCode, required Uint8List customRequestParameters});
}

final class TagPigeon {
  const TagPigeon({
    required this.handle,
    required this.ndef,
    required this.feliCa,
    required this.iso15693,
    required this.iso7816,
    required this.miFare,
  });
  final String handle;
  final NdefPigeon? ndef;
  final FeliCaPigeon? feliCa;
  final Iso15693Pigeon? iso15693;
  final Iso7816Pigeon? iso7816;
  final MiFarePigeon? miFare;
}

final class NdefPigeon {
  const NdefPigeon({
    required this.status,
    required this.capacity,
    required this.cachedNdefMessage,
  });
  final NdefStatusPigeon status;
  final int capacity;
  final NdefMessagePigeon? cachedNdefMessage;
}

final class FeliCaPigeon {
  const FeliCaPigeon({
    required this.currentSystemCode,
    required this.currentIDm,
  });
  final Uint8List currentSystemCode;
  final Uint8List currentIDm;
}

final class Iso15693Pigeon {
  const Iso15693Pigeon({
    required this.icManufacturerCode,
    required this.icSerialNumber,
    required this.identifier,
  });
  final int icManufacturerCode;
  final Uint8List icSerialNumber;
  final Uint8List identifier;
}

final class Iso7816Pigeon {
  const Iso7816Pigeon({
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

final class MiFarePigeon {
  const MiFarePigeon({
    required this.mifareFamily,
    required this.identifier,
    required this.historicalBytes,
  });
  final MiFareFamilyPigeon mifareFamily;
  final Uint8List identifier;
  final Uint8List? historicalBytes;
}

final class NdefQueryStatusPigeon {
  const NdefQueryStatusPigeon({
    required this.status,
    required this.capacity,
  });
  final NdefStatusPigeon status;
  final int capacity;
}

final class NdefMessagePigeon {
  const NdefMessagePigeon({
    required this.records,
  });
  final List<NdefPayloadPigeon> records;
}

final class NdefPayloadPigeon {
  const NdefPayloadPigeon({
    required this.typeNameFormat,
    required this.type,
    required this.identifier,
    required this.payload,
  });
  final TypeNameFormatPigeon typeNameFormat;
  final Uint8List type;
  final Uint8List identifier;
  final Uint8List payload;
}

final class FeliCaPollingResponsePigeon {
  const FeliCaPollingResponsePigeon({
    required this.manufacturerParameter,
    required this.requestData,
  });
  final Uint8List manufacturerParameter;
  final Uint8List? requestData;
}

final class FeliCaReadWithoutEncryptionResponsePigeon {
  const FeliCaReadWithoutEncryptionResponsePigeon({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.blockData,
  });
  final int statusFlag1;
  final int statusFlag2;
  final List<Uint8List> blockData;
}

final class FeliCaRequestServiceV2ResponsePigeon {
  const FeliCaRequestServiceV2ResponsePigeon({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.encryptionIdentifier,
    required this.nodeKeyVersionListAES,
    required this.nodeKeyVersionListDES,
  });
  final int statusFlag1;
  final int statusFlag2;
  final int encryptionIdentifier;
  final List<Uint8List>? nodeKeyVersionListAES;
  final List<Uint8List>? nodeKeyVersionListDES;
}

final class FeliCaRequestSpecificationVersionResponsePigeon {
  const FeliCaRequestSpecificationVersionResponsePigeon({
    required this.statusFlag1,
    required this.statusFlag2,
    required this.basicVersion,
    required this.optionVersion,
  });
  final int statusFlag1;
  final int statusFlag2;
  final Uint8List? basicVersion;
  final Uint8List? optionVersion;
}

final class FeliCaStatusFlagPigeon {
  const FeliCaStatusFlagPigeon({
    required this.statusFlag1,
    required this.statusFlag2,
  });
  final int statusFlag1;
  final int statusFlag2;
}

final class Iso7816ApduPigeon {
  const Iso7816ApduPigeon({
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

final class Iso7816ResponseApduPigeon {
  const Iso7816ResponseApduPigeon({
    required this.payload,
    required this.statusWord1,
    required this.statusWord2,
  });
  final Uint8List payload;
  final int statusWord1;
  final int statusWord2;
}

final class Iso15693SystemInfoPigeon {
  const Iso15693SystemInfoPigeon({
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

final class NfcReaderSessionErrorPigeon {
  const NfcReaderSessionErrorPigeon({
    required this.code,
    required this.message,
  });
  final NfcReaderErrorCodePigeon code;
  final String message;
}

final class NfcVasCommandConfigurationPigeon {
  const NfcVasCommandConfigurationPigeon({
    required this.mode,
    required this.passIdentifier,
    required this.url,
  });
  final NfcVasCommandConfigurationModePigeon mode;
  final String passIdentifier;
  final String? url;
}

final class NfcVasResponsePigeon {
  const NfcVasResponsePigeon({
    required this.status,
    required this.vasData,
    required this.mobileToken,
  });
  final NfcVasResponseErrorCodePigeon status;
  final Uint8List vasData;
  final Uint8List mobileToken;
}

enum PollingOptionPigeon {
  iso14443,
  iso15693,
  iso18092,
}

enum NdefStatusPigeon {
  notSupported,
  readWrite,
  readOnly,
}

enum TypeNameFormatPigeon {
  empty,
  wellKnown,
  media,
  absoluteUri,
  external,
  unknown,
  unchanged,
}

enum FeliCaPollingRequestCodePigeon {
  noRequest,
  systemCode,
  communicationPerformance,
}

enum FeliCaPollingTimeSlotPigeon {
  max1,
  max2,
  max4,
  max8,
  max16,
}

enum MiFareFamilyPigeon {
  unknown,
  ultralight,
  plus,
  desfire,
}

enum Iso15693RequestFlagPigeon {
  address,
  dualSubCarriers,
  highDataRate,
  option,
  protocolExtension,
  select,
}

enum NfcVasCommandConfigurationModePigeon {
  normal,
  urlOnly,
}

enum NfcReaderErrorCodePigeon {
  readerSessionInvalidationErrorFirstNdefTagRead,
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
  readerErrorAccessNotAccepted,
  readerErrorIneligible,
  readerErrorUnsupportedFeature,
  readerErrorInvalidParameter,
  readerErrorInvalidParameterLength,
  readerErrorParameterOutOfBound,
  readerErrorRadioDisabled,
  readerErrorSecurityViolation,
}

enum NfcVasResponseErrorCodePigeon {
  success,
  userIntervention,
  dataNotActivated,
  dataNotFound,
  incorrectData,
  unsupportedApplicationVersion,
  wrongLCField,
  wrongParameters,
}
