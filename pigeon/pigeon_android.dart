import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/nfc_manager_android/pigeon.g.dart',
  javaOut: 'android/src/main/kotlin/dev/flutter/plugins/nfcmanager/Pigeon.java',
  javaOptions: JavaOptions(package: 'dev.flutter.plugins.nfcmanager'),
))

@FlutterApi()
abstract class PigeonFlutterApi {
  void onTagDiscovered(PigeonTag tag);
  void onAdapterStateChanged(int state);
}

@HostApi()
abstract class PigeonHostApi {
  bool adapterIsEnabled();
  bool adapterIsSecureNfcEnabled();
  bool adapterIsSecureNfcSupported();
  void adapterEnableReaderMode(List<PigeonReaderFlag> flags);
  void adapterDisableReaderMode();
  void adapterEnableForegroundDispatch();
  void adapterDisableForegroundDispatch();
  PigeonNdefMessage? ndefGetNdefMessage(String handle);
  void ndefWriteNdefMessage(String handle, PigeonNdefMessage message);
  bool ndefMakeReadOnly(String handle);
  int nfcAGetMaxTransceiveLength(String handle);
  int nfcAGetTimeout(String handle);
  void nfcASetTimeout(String handle, int timeout);
  Uint8List nfcATransceive(String handle, Uint8List data);
  int nfcBGetMaxTransceiveLength(String handle);
  Uint8List nfcBTransceive(String handle, Uint8List data);
  int nfcFGetMaxTransceiveLength(String handle);
  int nfcFGetTimeout(String handle);
  void nfcFSetTimeout(String handle, int timeout);
  Uint8List nfcFTransceive(String handle, Uint8List data);
  int nfcVGetMaxTransceiveLength(String handle);
  Uint8List nfcVTransceive(String handle, Uint8List data);
  int isoDepGetMaxTransceiveLength(String handle);
  int isoDepGetTimeout(String handle);
  void isoDepSetTimeout(String handle, int timeout);
  Uint8List isoDepTransceive(String handle, Uint8List data);
  int mifareClassicGetMaxTransceiveLength(String handle);
  int mifareClassicGetTimeout(String handle);
  void mifareClassicSetTimeout(String handle, int timeout);
  int mifareClassicBlockToSector(String handle, int blockIndex);
  int mifareClassicGetBlockCountInSector(String handle, int sectorIndex);
  int mifareClassicSectorToBlock(String handle, int sectorIndex);
  bool mifareClassicAuthenticateSectorWithKeyA(String handle, int sectorIndex, Uint8List key);
  bool mifareClassicAuthenticateSectorWithKeyB(String handle, int sectorIndex, Uint8List key);
  void mifareClassicIncrement(String handle, int blockIndex, int value);
  void mifareClassicDecrement(String handle, int blockIndex, int value);
  Uint8List mifareClassicReadBlock(String handle, int blockIndex);
  void mifareClassicWriteBlock(String handle, int blockIndex, Uint8List data);
  void mifareClassicRestore(String handle, int blockIndex);
  void mifareClassicTransfer(String handle, int blockIndex);
  Uint8List mifareClassicTransceive(String handle, Uint8List data);
  int mifareUltralightGetMaxTransceiveLength(String handle);
  int mifareUltralightGetTimeout(String handle);
  void mifareUltralightSetTimeout(String handle, int timeout);
  Uint8List mifareUltralightReadPages(String handle, int pageOffset);
  void mifareUltralightWritePage(String handle, int pageOffset, Uint8List data);
  Uint8List mifareUltralightTransceive(String handle, Uint8List data);
  void ndefFormatableFormat(String handle, PigeonNdefMessage firstMessage);
  void ndefFormatableFormatReadOnly(String handle, PigeonNdefMessage firstMessage);
  void disposeTag(String handle);
}

class PigeonTag {
  String? handle;
  Uint8List? id;
  List<String?>? techList;
  PigeonNdef? ndef;
  PigeonNfcA? nfcA;
  PigeonNfcB? nfcB;
  PigeonNfcF? nfcF;
  PigeonNfcV? nfcV;
  PigeonIsoDep? isoDep;
  PigeonMifareClassic? mifareClassic;
  PigeonMifareUltralight? mifareUltralight;
  String? ndefFormatable;
  PigeonNfcBarcode? nfcBarcode;
}

class PigeonNdef {
  String? type;
  bool? canMakeReadOnly;
  bool? isWritable;
  int? maxSize;
  PigeonNdefMessage? cachedNdefMessage;
}

class PigeonNfcA {
  Uint8List? atqa;
  int? sak;
}

class PigeonNfcB {
  Uint8List? applicationData;
  Uint8List? protocolInfo;
}

class PigeonNfcF {
  Uint8List? manufacturer;
  Uint8List? systemCode;
}

class PigeonNfcV {
  int? dsfId;
  int? responseFlags;
}

class PigeonIsoDep {
  Uint8List? hiLayerResponse;
  Uint8List? historicalBytes;
  bool? isExtendedLengthApduSupported;
}

class PigeonMifareClassic {
  int? type;
  int? blockCount;
  int? sectorCount;
  int? size;
}

class PigeonMifareUltralight {
  int? type;
}

class PigeonNfcBarcode {
  int? type;
  Uint8List? barcode;
}

class PigeonNdefMessage {
  List<PigeonNdefRecord?>? records;
}

class PigeonNdefRecord {
  PigeonTypeNameFormat? tnf;
  Uint8List? type;
  Uint8List? id;
  Uint8List? payload;
}

enum PigeonReaderFlag {
  nfcA,
  nfcB,
  nfcBarcode,
  nfcF,
  nfcV,
  noPlatformSounds,
  skipNdefCheck,
}

enum PigeonTypeNameFormat {
  empty,
  wellKnown,
  mimeMedia,
  absoluteUri,
  externalType,
  unknown,
  unchanged,
}
