import CoreNFC
import Flutter

public class NfcManagerPlugin: NSObject, FlutterPlugin, PigeonHostApi {
  private var _session: Any?
  @available(iOS 13.0, *)
  private var session: NFCTagReaderSession? {
    get { return _session as? NFCTagReaderSession }
    set { _session = newValue }
  }

  private var _cachedTags: Any?
  @available(iOS 13.0, *)
  private var cachedTags: [String : NFCNDEFTag] {
    get { return _cachedTags as? [String : NFCNDEFTag] ?? [:] }
    set { _cachedTags = newValue }
  }
  
  private let flutterApi: PigeonFlutterApi

  public static func register(with registrar: FlutterPluginRegistrar) {
    PigeonHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: NfcManagerPlugin(binaryMessenger: registrar.messenger()))
  }
  
  private init(binaryMessenger: FlutterBinaryMessenger) {
    flutterApi = PigeonFlutterApi(binaryMessenger: binaryMessenger)
  }

  func tagReaderSessionReadingAvailable() throws -> Bool {
    guard #available(iOS 13.0, *) else { throw NSError() }
    return NFCTagReaderSession.readingAvailable
  }
  
  func tagReaderSessionBegin(pollingOptions: [PigeonPollingOption], alertMessage: String?) throws {
    guard #available(iOS 13.0, *) else { throw NSError() }
    if session != nil { throw NSError() }
    session = NFCTagReaderSession(pollingOption: convert(pollingOptions), delegate: self)
    if let alertMessage = alertMessage { session?.alertMessage = alertMessage }
    session?.begin()
  }
  
  func tagReaderSessionInvalidate(alertMessage: String?, errorMessage: String?) throws {
    guard #available(iOS 13.0, *) else { throw NSError() }
    guard let session = session else { throw NSError() }
    if let alertMessage = alertMessage { session.alertMessage = alertMessage }
    if let errorMessage = errorMessage { session.invalidate(errorMessage: errorMessage) } else { session.invalidate() }
    self.session = nil
  }
  
  func tagReaderSessionRestartPolling() throws {
    guard #available(iOS 13.0, *) else { throw NSError() }
    guard let session = session else { throw NSError() }
    session.restartPolling()
  }
  
  func ndefQueryNDEFStatus(handle: String, completion: @escaping (Result<PigeonNDEFQueryStatus, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] else { completion(.failure(NSError())); return }
    tag.queryNDEFStatus { status, capacity, error in
      if let error = error { completion(.failure(error)); return }
    }
  }
  
  func ndefReadNDEF(handle: String, completion: @escaping (Result<PigeonNdefMessage?, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] else { completion(.failure(NSError())); return }
    tag.readNDEF { message, error in
      if let error = error { completion(.failure(error)); return }
      guard let message = message else { completion(.success(nil)); return }
      completion(.success(convert(message)))
    }
  }
  
  func ndefWriteNDEF(handle: String, message: PigeonNdefMessage, completion: @escaping (Result<Void, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] else { completion(.failure(NSError())); return }
    tag.writeNDEF(convert(message)) { error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(()))
    }
  }
  
  func ndefWriteLock(handle: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] else { completion(.failure(NSError())); return }
    tag.writeLock { error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(()))
    }
  }
  
  func feliCaPolling(handle: String, systemCode: FlutterStandardTypedData, requestCode: PigeonFeliCaPollingRequestCode, timeSlot: PigeonFeliCaPollingTimeSlot, completion: @escaping (Result<PigeonFeliCaPollingResponse, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCFeliCaTag else { completion(.failure(NSError())); return }
    tag.polling(systemCode: systemCode.data, requestCode: convert(requestCode), timeSlot: convert(timeSlot)) { manufacturerParameter, requestData, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(PigeonFeliCaPollingResponse(
        manufacturerParameter: FlutterStandardTypedData(bytes: manufacturerParameter),
        requestData: FlutterStandardTypedData(bytes: requestData)
      )))
    }
  }
  
  func feliCaRequestService(handle: String, nodeCodeList: [FlutterStandardTypedData], completion: @escaping (Result<[FlutterStandardTypedData], Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCFeliCaTag else { completion(.failure(NSError())); return }
    tag.requestService(nodeCodeList: nodeCodeList.map { $0.data }) { nodeCodeList, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(nodeCodeList.map { FlutterStandardTypedData(bytes: $0) }))
    }
  }
  
  func feliCaRequestResponse(handle: String, completion: @escaping (Result<Int32, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCFeliCaTag else { completion(.failure(NSError())); return }
    tag.requestResponse { mode, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(Int32(mode)))
    }
  }
  
  func feliCaReadWithoutEncryption(handle: String, serviceCodeList: [FlutterStandardTypedData], blockList: [FlutterStandardTypedData], completion: @escaping (Result<PigeonFeliCaReadWithoutEncryptionResponse, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCFeliCaTag else { completion(.failure(NSError())); return }
    tag.readWithoutEncryption(serviceCodeList: serviceCodeList.map { $0.data }, blockList: blockList.map { $0.data }) { statusFlag1, statusFlag2, blockData, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(PigeonFeliCaReadWithoutEncryptionResponse(
        statusFlag1: Int32(statusFlag1),
        statusFlag2: Int32(statusFlag2),
        blockData: blockData.map { FlutterStandardTypedData(bytes: $0) }
      )))
    }
  }
  
  func feliCaWriteWithoutEncryption(handle: String, serviceCodeList: [FlutterStandardTypedData], blockList: [FlutterStandardTypedData], blockData: [FlutterStandardTypedData], completion: @escaping (Result<PigeonFeliCaStatusFlag, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCFeliCaTag else { completion(.failure(NSError())); return }
    tag.writeWithoutEncryption(serviceCodeList: serviceCodeList.map { $0.data }, blockList: blockList.map { $0.data }, blockData: blockData.map { $0.data }) { statusFlag1, statusFlag2, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(PigeonFeliCaStatusFlag(
        statusFlag1: Int32(statusFlag1),
        statusFlag2: Int32(statusFlag2)
      )))
    }
  }
  
  func feliCaRequestSystemCode(handle: String, completion: @escaping (Result<[FlutterStandardTypedData], Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCFeliCaTag else { completion(.failure(NSError())); return }
    tag.requestSystemCode() { systemCodeList, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(systemCodeList.map { FlutterStandardTypedData(bytes: $0) }))
    }
  }
  
  func feliCaRequestServiceV2(handle: String, nodeCodeList: [FlutterStandardTypedData], completion: @escaping (Result<PigeonFeliCaRequestServiceV2Response, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCFeliCaTag else { completion(.failure(NSError())); return }
    tag.requestServiceV2(nodeCodeList: nodeCodeList.map { $0.data }) { statusFlag1, statusFlag2, encryptionIdentifier, nodeKeyVersionListAes, nodeKeyVersionListDes, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(PigeonFeliCaRequestServiceV2Response(
        statusFlag1: Int32(statusFlag1),
        statusFlag2: Int32(statusFlag2),
        encryptionIdentifier: Int32(encryptionIdentifier.rawValue),
        nodeKeyVersionListAES: nodeKeyVersionListAes.map { FlutterStandardTypedData(bytes: $0) },
        nodeKeyVersionListDES: nodeKeyVersionListDes.map { FlutterStandardTypedData(bytes: $0) }
      )))
    }
  }
  
  func feliCaRequestSpecificationVersion(handle: String, completion: @escaping (Result<PigeonFeliCaRequestSpecificationVersionResponse, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCFeliCaTag else { completion(.failure(NSError())); return }
    tag.requestSpecificationVersion() { statusFlag1, statusFlag2, basicVersion, optionVersion, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(PigeonFeliCaRequestSpecificationVersionResponse(
        statusFlag1: Int32(statusFlag1),
        statusFlag2: Int32(statusFlag2),
        basicVersion: FlutterStandardTypedData(bytes: basicVersion),
        optionVersion: FlutterStandardTypedData(bytes: optionVersion)
      )))
    }
  }
  
  func feliCaResetMode(handle: String, completion: @escaping (Result<PigeonFeliCaStatusFlag, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCFeliCaTag else { completion(.failure(NSError())); return }
    tag.resetMode() { statusFlag1, statusFlag2, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(PigeonFeliCaStatusFlag(
        statusFlag1: Int32(statusFlag1),
        statusFlag2: Int32(statusFlag2)
      )))
    }
  }
  
  func feliCaSendFeliCaCommand(handle: String, commandPacket: FlutterStandardTypedData, completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCFeliCaTag else { completion(.failure(NSError())); return }
    tag.sendFeliCaCommand(commandPacket: commandPacket.data) { data, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(FlutterStandardTypedData(bytes: data)))
    }
  }
  
  func miFareSendMiFareCommand(handle: String, commandPacket: FlutterStandardTypedData, completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCMiFareTag else { completion(.failure(NSError())); return }
    tag.sendMiFareCommand(commandPacket: commandPacket.data) { data, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(FlutterStandardTypedData(bytes: data)))
    }
  }
  
  func miFareSendMiFareISO7816Command(handle: String, apdu: PigeonISO7816APDU, completion: @escaping (Result<PigeonISO7816ResponseAPDU, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCMiFareTag else { completion(.failure(NSError())); return }
    tag.sendMiFareISO7816Command(convert(apdu)) { payload, statusWord1, statusWord2, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(PigeonISO7816ResponseAPDU(
        payload: FlutterStandardTypedData(bytes: payload),
        statusWord1: Int32(statusWord1),
        statusWord2: Int32(statusWord2)
      )))
    }
  }
  
  func miFareSendMiFareISO7816CommandRaw(handle: String, data: FlutterStandardTypedData, completion: @escaping (Result<PigeonISO7816ResponseAPDU, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCMiFareTag else { completion(.failure(NSError())); return }
    tag.sendMiFareISO7816Command(NFCISO7816APDU(data: data.data)!) { payload, statusWord1, statusWord2, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(PigeonISO7816ResponseAPDU(
        payload: FlutterStandardTypedData(bytes: payload),
        statusWord1: Int32(statusWord1),
        statusWord2: Int32(statusWord2)
      )))
    }
  }
  
  func iso7816SendCommand(handle: String, apdu: PigeonISO7816APDU, completion: @escaping (Result<PigeonISO7816ResponseAPDU, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO7816Tag else { completion(.failure(NSError())); return }
    tag.sendCommand(apdu: convert(apdu)) { payload, statusWord1, statusWord2, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(PigeonISO7816ResponseAPDU(
        payload: FlutterStandardTypedData(bytes: payload),
        statusWord1: Int32(statusWord1),
        statusWord2: Int32(statusWord2)
      )))
    }
  }
  
  func iso7816SendCommandRaw(handle: String, data: FlutterStandardTypedData, completion: @escaping (Result<PigeonISO7816ResponseAPDU, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO7816Tag else { completion(.failure(NSError())); return }
    tag.sendCommand(apdu: NFCISO7816APDU(data: data.data)!) { payload, statusWord1, statusWord2, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(PigeonISO7816ResponseAPDU(
        payload: FlutterStandardTypedData(bytes: payload),
        statusWord1: Int32(statusWord1),
        statusWord2: Int32(statusWord2)
      )))
    }
  }
  
  func iso15693StayQuiet(handle: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.stayQuiet() { error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(()))
    }
  }
  
  func iso15693ReadSingleBlock(handle: String, requestFlags: [PigeonIso15693RequestFlag], blockNumber: Int32, completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.readSingleBlock(requestFlags: convert(requestFlags), blockNumber: UInt8(blockNumber)) { dataBlock, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(FlutterStandardTypedData(bytes: dataBlock)))
    }
  }
  
  func iso15693WriteSingleBlock(handle: String, requestFlags: [PigeonIso15693RequestFlag], blockNumber: Int32, dataBlock: FlutterStandardTypedData, completion: @escaping (Result<Void, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.writeSingleBlock(requestFlags: convert(requestFlags), blockNumber: UInt8(blockNumber), dataBlock: dataBlock.data) { error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(()))
    }
  }
  
  func iso15693LockBlock(handle: String, requestFlags: [PigeonIso15693RequestFlag], blockNumber: Int32, completion: @escaping (Result<Void, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.lockBlock(requestFlags: convert(requestFlags), blockNumber: UInt8(blockNumber)) { error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(()))
    }
  }
  
  func iso15693ReadMultipleBlocks(handle: String, requestFlags: [PigeonIso15693RequestFlag], blockNumber: Int32, numberOfBlocks: Int32, completion: @escaping (Result<[FlutterStandardTypedData], Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.readMultipleBlocks(requestFlags: convert(requestFlags), blockRange: convert(blockNumber, numberOfBlocks)) { dataBlocks, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(dataBlocks.map { FlutterStandardTypedData(bytes: $0) }))
    }
  }
  
  func iso15693WriteMultipleBlocks(handle: String, requestFlags: [PigeonIso15693RequestFlag], blockNumber: Int32, numberOfBlocks: Int32, dataBlocks: [FlutterStandardTypedData], completion: @escaping (Result<Void, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.writeMultipleBlocks(requestFlags: convert(requestFlags), blockRange: convert(blockNumber, numberOfBlocks), dataBlocks: dataBlocks.map { $0.data }) { error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(()))
    }
  }
  
  func iso15693Select(handle: String, requestFlags: [PigeonIso15693RequestFlag], completion: @escaping (Result<Void, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.select(requestFlags: convert(requestFlags)) { error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(()))
    }
  }
  
  func iso15693ResetToReady(handle: String, requestFlags: [PigeonIso15693RequestFlag], completion: @escaping (Result<Void, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.resetToReady(requestFlags: convert(requestFlags)) { error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(()))
    }
  }
  
  func iso15693WriteAfi(handle: String, requestFlags: [PigeonIso15693RequestFlag], afi: Int32, completion: @escaping (Result<Void, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.writeAFI(requestFlags: convert(requestFlags), afi: UInt8(afi)) { error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(()))
    }
  }
  
  func iso15693LockAfi(handle: String, requestFlags: [PigeonIso15693RequestFlag], completion: @escaping (Result<Void, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.lockAFI(requestFlags: convert(requestFlags)) { error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(()))
    }
  }
  
  func iso15693WriteDsfId(handle: String, requestFlags: [PigeonIso15693RequestFlag], dsfId: Int32, completion: @escaping (Result<Void, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.writeDSFID(requestFlags: convert(requestFlags), dsfid: UInt8(dsfId)) { error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(()))
    }
  }
  
  func iso15693LockDsfId(handle: String, requestFlags: [PigeonIso15693RequestFlag], completion: @escaping (Result<Void, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.lockDFSID(requestFlags: convert(requestFlags)) { error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(()))
    }
  }
  
  func iso15693GetSystemInfo(handle: String, requestFlags: [PigeonIso15693RequestFlag], completion: @escaping (Result<PigeonISO15693SystemInfo, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.getSystemInfo(requestFlags: convert(requestFlags)) { dataStorageFormatIdentifier, applicationFamilyIdentifier, blockSize, totalBlocks, icReference, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(PigeonISO15693SystemInfo(
        dataStorageFormatIdentifier: Int32(dataStorageFormatIdentifier),
        applicationFamilyIdentifier: Int32(applicationFamilyIdentifier),
        blockSize: Int32(blockSize),
        totalBlocks: Int32(totalBlocks),
        icReference: Int32(icReference)
      )))
    }
  }
  
  func iso15693GetMultipleBlockSecurityStatus(handle: String, requestFlags: [PigeonIso15693RequestFlag], blockNumber: Int32, numberOfBlocks: Int32, completion: @escaping (Result<[Int32], Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.getMultipleBlockSecurityStatus(requestFlags: convert(requestFlags), blockRange: convert(blockNumber, numberOfBlocks)) { status, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(status.map { Int32(truncating: $0) }))
    }
  }
  
  func iso15693CustomCommand(handle: String, requestFlags: [PigeonIso15693RequestFlag], customCommandCode: Int32, customRequestParameters: FlutterStandardTypedData, completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void) {
    guard #available(iOS 13.0, *) else { completion(.failure(NSError())); return; }
    guard let tag = cachedTags[handle] as? NFCISO15693Tag else { completion(.failure(NSError())); return }
    tag.customCommand(requestFlags: convert(requestFlags), customCommandCode: Int(customCommandCode), customRequestParameters: customRequestParameters.data) { data, error in
      if let error = error { completion(.failure(error)); return }
      completion(.success(FlutterStandardTypedData(bytes: data)))
    }
  }
  
  func disposeTag(handle: String) throws {
    guard #available(iOS 13.0, *) else { throw NSError() }
    cachedTags.removeValue(forKey: handle)
  }
}

extension NfcManagerPlugin: NFCTagReaderSessionDelegate {
  @available(iOS 13.0, *)
  public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
    flutterApi.tagReaderSessionDidBecomeActive { /* no op */ }
  }
  
  @available(iOS 13.0, *)
  public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
    flutterApi.tagReaderSessionDidInvalidateWithError(error: "\(error)") { /* no op */ }
  }
  
  @available(iOS 13.0, *)
  public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
    session.connect(to: tags.first!) { error in
      if let error = error {
        // skip tag detection
        print(error)
        return
      }
      convert(tags.first!) { tag, pigeon, error in
        if let error = error {
          // skip tag detection
          print(error)
          return
        }
        guard let pigeon = pigeon else {
          // skip tag detection
          return
        }
        self.cachedTags[pigeon.handle!] = tag
        self.flutterApi.tagReaderSessionDidDetect(tag: pigeon) { /* no op */ }
      }
    }
  }
}

@available(iOS 13.0, *)
private func convert(_ value: NFCTag, _ completionHandler: @escaping (NFCNDEFTag, PigeonTag?, Error?) -> Void) {
  switch (value) {
  case .feliCa(let tag): convert(tag) { pigeon, error in completionHandler(tag, pigeon, error) }
  case .iso15693(let tag): convert(tag) { pigeon, error in completionHandler(tag, pigeon, error) }
  case .iso7816(let tag): convert(tag) { pigeon, error in completionHandler(tag, pigeon, error) }
  case .miFare(let tag): convert(tag) { pigeon, error in completionHandler(tag, pigeon, error) }
  @unknown default: print("Unknown tag cannot be serialized")
  }
}

@available(iOS 13.0, *)
private func convert(_ value: NFCNDEFTag, _ completionHandler: @escaping (PigeonTag?, Error?) -> Void) {
  var pigeon = PigeonTag()
  
  pigeon.handle = NSUUID().uuidString
  
  if let value = value as? NFCFeliCaTag {
    pigeon.feliCa = PigeonFeliCa(
      currentSystemCode: FlutterStandardTypedData(bytes: value.currentSystemCode),
      currentIDm: FlutterStandardTypedData(bytes: value.currentIDm)
    )
  }
  if let value = value as? NFCISO15693Tag {
    pigeon.iso15693 = PigeonISO15693(
      icManufacturerCode: Int32(value.icManufacturerCode),
      icSerialNumber: FlutterStandardTypedData(bytes: value.icSerialNumber),
      identifier: FlutterStandardTypedData(bytes: value.identifier)
    )
  }
  if let value = value as? NFCISO7816Tag {
    pigeon.iso7816 = PigeonISO7816(
      initialSelectedAID: value.initialSelectedAID,
      identifier: FlutterStandardTypedData(bytes: value.identifier),
      historicalBytes: value.historicalBytes != nil ? FlutterStandardTypedData(bytes: value.historicalBytes!) : nil,
      applicationData: value.applicationData != nil ? FlutterStandardTypedData(bytes: value.applicationData!) : nil,
      proprietaryApplicationDataCoding: value.proprietaryApplicationDataCoding
    )
  }
  if let value = value as? NFCMiFareTag {
    pigeon.miFare = PigeonMiFare(
      mifareFamily: convert(value.mifareFamily),
      identifier: FlutterStandardTypedData(bytes: value.identifier),
      historicalBytes: value.historicalBytes != nil ? FlutterStandardTypedData(bytes: value.historicalBytes!) : nil
    )
  }

  value.queryNDEFStatus { status, capacity, error in
    if let error = error {
      completionHandler(nil, error)
      return
    }
    pigeon.ndef = PigeonNdef()
    pigeon.ndef?.status = convert(status)
    pigeon.ndef?.capacity = Int32(capacity)
    if status == .notSupported {
      completionHandler(pigeon, nil)
      return
    }
    value.readNDEF { message, error in
      if let error = error {
        completionHandler(nil, error)
        return
      }
      if let message = message {
        pigeon.ndef?.cachedNdefMessage = convert(message)
      }
      completionHandler(pigeon, nil)
    }
  }
}

@available(iOS 13.0, *)
private func convert(_ value: PigeonNdefMessage) -> NFCNDEFMessage {
  return NFCNDEFMessage(
    records: value.records!.map { NFCNDEFPayload(
      format: convert($0!.typeNameFormat!),
      type: $0!.type!.data,
      identifier: $0!.identifier!.data,
      payload: $0!.payload!.data
    ) }
  )
}

@available(iOS 13.0, *)
private func convert(_ value: NFCNDEFMessage) -> PigeonNdefMessage {
  return PigeonNdefMessage(records: value.records.map { convert($0) })
}

private func convert(_ value: NFCNDEFPayload) -> PigeonNdefPayload {
  return PigeonNdefPayload(
    typeNameFormat: convert(value.typeNameFormat),
    type: FlutterStandardTypedData(bytes: value.type),
    identifier: FlutterStandardTypedData(bytes: value.identifier),
    payload: FlutterStandardTypedData(bytes: value.payload)
  )
}

@available(iOS 13.0, *)
private func convert(_ value: [PigeonPollingOption]) -> NFCTagReaderSession.PollingOption {
  var option = NFCTagReaderSession.PollingOption()
  value.forEach { option.insert(convert($0)) }
  return option
}

@available(iOS 13.0, *)
private func convert(_ value: PigeonPollingOption) -> NFCTagReaderSession.PollingOption {
  switch (value) {
  case .iso14443: return .iso14443
  case .iso15693: return .iso15693
  case .iso18092: return .iso18092
  }
}

@available(iOS 13.0, *)
private func convert(_ value: NFCNDEFStatus) -> PigeonNdefStatus {
  switch (value) {
  case .notSupported: return .notSupported
  case .readWrite: return .readWrite
  case .readOnly: return .readOnly
  @unknown default: fatalError()
  }
}

@available(iOS 13.0, *)
private func convert(_ value: PigeonFeliCaPollingRequestCode) -> PollingRequestCode {
  switch (value) {
  case .noRequest: return .noRequest
  case .systemCode: return .systemCode
  case .communicationPerformance: return .communicationPerformance
  }
}

@available(iOS 13.0, *)
private func convert(_ value: PigeonFeliCaPollingTimeSlot) -> PollingTimeSlot {
  switch (value) {
  case .max1: return .max1
  case .max2: return .max2
  case .max4: return .max4
  case .max8: return .max8
  case .max16: return .max16
  }
}

@available(iOS 13.0, *)
private func convert(_ value: PigeonISO7816APDU) -> NFCISO7816APDU {
  return NFCISO7816APDU(
    instructionClass: UInt8(value.instructionClass!),
    instructionCode: UInt8(value.instructionCode!),
    p1Parameter: UInt8(value.p1Parameter!),
    p2Parameter: UInt8(value.p2Parameter!),
    data: value.data!.data,
    expectedResponseLength: Int(value.expectedResponseLength!)
  )
}

@available(iOS 13.0, *)
private func convert(_ value: [PigeonIso15693RequestFlag]) -> RequestFlag {
  var flag = RequestFlag()
  value.forEach { flag.insert(convert($0)) }
  return flag
}

@available(iOS 13.0, *)
private func convert(_ value: PigeonIso15693RequestFlag) -> RequestFlag {
  switch (value) {
  case .address: return .address
  case .dualSubCarriers: return .dualSubCarriers
  case .highDataRate: return .highDataRate
  case .option: return .option
  case .protocolExtension: return .protocolExtension
  case .select: return .select
  }
}

@available(iOS 13.0, *)
private func convert(_ value: NFCMiFareFamily) -> PigeonMiFareFamily {
  switch (value) {
  case .unknown: return .unknown
  case .ultralight: return .ultralight
  case .plus: return .plus
  case .desfire: return .desfire
  @unknown default: fatalError()
  }
}

private func convert(_ value: PigeonTypeNameFormat) -> NFCTypeNameFormat {
  switch (value) {
  case .empty: return .empty
  case .nfcWellKnown: return .nfcWellKnown
  case .media: return .media
  case .absoluteUri: return .absoluteURI
  case .nfcExternal: return .nfcExternal
  case .unknown: return .unknown
  case .unchanged: return .unchanged
  }
}

private func convert(_ value: NFCTypeNameFormat) -> PigeonTypeNameFormat {
  switch (value) {
  case .empty: return .empty
  case .nfcWellKnown: return .nfcWellKnown
  case .media: return .media
  case .absoluteURI: return .absoluteUri
  case .nfcExternal: return .nfcExternal
  case .unknown: return .unknown
  case .unchanged: return .unchanged
  @unknown default: fatalError()
  }
}

private func convert(_ value1: Int32, _ value2: Int32) -> NSRange {
  return NSRange(location: Int(value1), length: Int(value2))
}
