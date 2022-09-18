import CoreNFC
import Flutter

public class SwiftNfcManagerPlugin: NSObject, FlutterPlugin {
  private let channel: FlutterMethodChannel

  private var _session: Any?
  @available(iOS 13.0, *)
  private var session: NFCTagReaderSession? {
    get { return _session as? NFCTagReaderSession }
    set { _session = newValue }
  }

  private var _tags: Any?
  @available(iOS 13.0, *)
  private var tags: [String : NFCNDEFTag] {
    get { return _tags as? [String : NFCNDEFTag] ?? [:] }
    set { _tags = newValue }
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plugins.flutter.io/nfc_manager", binaryMessenger: registrar.messenger())
    let instance = SwiftNfcManagerPlugin(channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  private init(_ channel: FlutterMethodChannel) {
    self.channel = channel
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 13.0, *) else {
      result(FlutterError(code: "unavailable", message: "Only available in iOS 13.0 or newer", details: nil))
      return
    }

    switch call.method {
    case "Nfc#isAvailable": handleNfcIsAvailable(call.arguments, result: result)
    case "Nfc#startSession": handleNfcStartSession(call.arguments as! [String : Any?], result: result)
    case "Nfc#stopSession": handleNfcStopSession(call.arguments as! [String : Any?], result: result)
    case "Nfc#disposeTag": handleNfcDisposeTag(call.arguments as! [String : Any?], result: result)
    case "Ndef#read": handleNdefRead(call.arguments as! [String : Any?], result: result)
    case "Ndef#write": handleNdefWrite(call.arguments as! [String : Any?], result: result)
    case "Ndef#writeLock": handleNdefWriteLock(call.arguments as! [String : Any?], result: result)
    case "FeliCa#polling": handleFeliCaPolling(call.arguments as! [String : Any?], result: result)
    case "FeliCa#requestResponse": handleFeliCaRequestResponse(call.arguments as! [String : Any?], result: result)
    case "FeliCa#requestSystemCode": handleFeliCaRequestSystemCode(call.arguments as! [String : Any?], result: result)
    case "FeliCa#requestService": handleFeliCaRequestService(call.arguments as! [String : Any?], result: result)
    case "FeliCa#requestServiceV2": handleFeliCaRequestServiceV2(call.arguments as! [String : Any?], result: result)
    case "FeliCa#readWithoutEncryption": handleFeliCaReadWithoutEncryption(call.arguments as! [String : Any?], result: result)
    case "FeliCa#writeWithoutEncryption": handleFeliCaWriteWithoutEncryption(call.arguments as! [String : Any?], result: result)
    case "FeliCa#requestSpecificationVersion": handleFeliCaRequestSpecificationVersion(call.arguments as! [String : Any?], result: result)
    case "FeliCa#resetMode": handleFeliCaResetMode(call.arguments as! [String : Any?], result: result)
    case "FeliCa#sendFeliCaCommand": handleFeliCaSendFeliCaCommand(call.arguments as! [String : Any?], result: result)
    case "Iso15693#readSingleBlock": handleIso15693ReadSingleBlock(call.arguments as! [String : Any?], result: result)
    case "Iso15693#writeSingleBlock": handleIso15693WriteSingleBlock(call.arguments as! [String : Any?], result: result)
    case "Iso15693#lockBlock": handleIso15693LockBlock(call.arguments as! [String : Any?], result: result)
    case "Iso15693#readMultipleBlocks": handleIso15693ReadMultipleBlocks(call.arguments as! [String : Any?], result: result)
    case "Iso15693#writeMultipleBlocks": handleIso15693WriteMultipleBlocks(call.arguments as! [String : Any?], result: result)
    case "Iso15693#getMultipleBlockSecurityStatus": handleIso15693GetMultipleBlockSecurityStatus(call.arguments as! [String : Any?], result: result)
    case "Iso15693#writeAfi": handleIso15693WriteAfi(call.arguments as! [String : Any?], result: result)
    case "Iso15693#lockAfi": handleIso15693LockAfi(call.arguments as! [String : Any?], result: result)
    case "Iso15693#writeDsfId": handleIso15693WriteDsfId(call.arguments as! [String : Any?], result: result)
    case "Iso15693#lockDsfId": handleIso15693LockDsfId(call.arguments as! [String : Any?], result: result)
    case "Iso15693#resetToReady": handleIso15693ResetToReady(call.arguments as! [String : Any?], result: result)
    case "Iso15693#select": handleIso15693Select(call.arguments as! [String : Any?], result: result)
    case "Iso15693#stayQuiet": handleIso15693StayQuiet(call.arguments as! [String : Any?], result: result)
    case "Iso15693#extendedReadSingleBlock": handleIso15693ExtendedReadSingleBlock(call.arguments as! [String : Any?], result: result)
    case "Iso15693#extendedWriteSingleBlock": handleIso15693ExtendedWriteSingleBlock(call.arguments as! [String : Any?], result: result)
    case "Iso15693#extendedLockBlock": handleIso15693ExtendedLockBlock(call.arguments as! [String : Any?], result: result)
    case "Iso15693#extendedReadMultipleBlocks": handleIso15693ExtendedReadMultipleBlocks(call.arguments as! [String : Any?], result: result)
    case "Iso15693#getSystemInfo": handleIso15693GetSystemInfo(call.arguments as! [String : Any?], result: result)
    case "Iso15693#customCommand": handleIso15693CustomCommand(call.arguments as! [String : Any?], result: result)
    case "Iso7816#sendCommand": handleIso7816SendCommand(call.arguments as! [String : Any?], result: result)
    case "Iso7816#sendCommandRaw": handleIso7816SendCommandRaw(call.arguments as! [String : Any?], result: result)
    case "MiFare#sendMiFareCommand": handleMiFareSendMiFareCommand(call.arguments as! [String : Any?], result: result)
    case "MiFare#sendMiFareIso7816Command": handleMiFareSendMiFareIso7816Command(call.arguments as! [String : Any?], result: result)
    case "MiFare#sendMiFareIso7816CommandRaw": handleMiFareSendMiFareIso7816CommandRaw(call.arguments as! [String : Any?], result: result)
    default: result(FlutterMethodNotImplemented)
    }
  }

  @available(iOS 13.0, *)
  private func handleNfcIsAvailable(_ arguments: Any?, result: @escaping FlutterResult) {
    result(NFCTagReaderSession.readingAvailable)
  }

  @available(iOS 13.0, *)
  private func handleNfcStartSession(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    session = NFCTagReaderSession(pollingOption: getPollingOption(arguments["pollingOptions"] as! [String]), delegate: self)
    if let alertMessage = arguments["alertMessage"] as? String { session?.alertMessage = alertMessage }
    session?.begin()
    result(nil)
  }

  @available(iOS 13.0, *)
  private func handleNfcStopSession(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    guard let session = session else {
      result(nil)
      return
    }

    if let errorMessage = arguments["errorMessage"] as? String {
      session.invalidate(errorMessage: errorMessage)
      self.session = nil
      result(nil)
    }

    if let alertMessage = arguments["alertMessage"] as? String { session.alertMessage = alertMessage }
    session.invalidate()
    self.session = nil
    result(nil)
  }

  @available(iOS 13.0, *)
  private func handleNfcDisposeTag(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tags.removeValue(forKey: arguments["handle"] as! String)
    result(nil)
  }

  @available(iOS 13.0, *)
  private func handleNdefRead(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCNDEFTag.self, arguments, result) { tag in
      tag.readNDEF { message, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(message == nil ? nil : getNDEFMessageMap(message!))
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleNdefWrite(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCNDEFTag.self, arguments, result) { tag in
      let message = getNDEFMessage(arguments["message"] as! [String : Any?])
      tag.writeNDEF(message) { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleNdefWriteLock(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCNDEFTag.self, arguments, result) { tag in
      tag.writeLock { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleFeliCaPolling(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCFeliCaTag.self, arguments, result) { tag in
      let systemCode = (arguments["systemCode"] as! FlutterStandardTypedData).data
      let requestCode = PollingRequestCode(rawValue: arguments["requestCode"] as! Int)!
      let timeSlot = PollingTimeSlot(rawValue: arguments["timeSlot"] as! Int)!
      tag.polling(systemCode: systemCode, requestCode: requestCode, timeSlot: timeSlot) { manufacturerParameter, requestData, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result([
            "manufacturerParameter": manufacturerParameter,
            "requestData": requestData,
          ])
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleFeliCaRequestResponse(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCFeliCaTag.self, arguments, result) { tag in
      tag.requestResponse { mode, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(mode)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleFeliCaRequestSystemCode(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCFeliCaTag.self, arguments, result) { tag in
      tag.requestSystemCode { systemCodeList, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(systemCodeList)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleFeliCaRequestService(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCFeliCaTag.self, arguments, result) { tag in
      let nodeCodeList = (arguments["nodeCodeList"] as! [FlutterStandardTypedData]).map { $0.data }
      tag.requestService(nodeCodeList: nodeCodeList) { nodeKeyVersionList, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nodeKeyVersionList)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleFeliCaRequestServiceV2(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCFeliCaTag.self, arguments, result) { tag in
      let nodeCodeList = (arguments["nodeCodeList"] as! [FlutterStandardTypedData]).map { $0.data }
      tag.requestServiceV2(nodeCodeList: nodeCodeList) { statusFlag1, statusFlag2, encryptionIdentifier, nodeKeyVersionListAes, nodeKeyVersionListDes, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result([
            "statusFlag1": statusFlag1,
            "statusFlag2": statusFlag2,
            "encryptionIdentifier": encryptionIdentifier.rawValue,
            "nodeKeyVersionListAes": nodeKeyVersionListAes,
            "nodeKeyVersionListDes": nodeKeyVersionListDes,
          ])
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleFeliCaReadWithoutEncryption(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCFeliCaTag.self, arguments, result) { tag in
      let serviceCodeList = (arguments["serviceCodeList"] as! [FlutterStandardTypedData]).map { $0.data }
      let blockList = (arguments["blockList"] as! [FlutterStandardTypedData]).map { $0.data }
      tag.readWithoutEncryption(serviceCodeList: serviceCodeList, blockList: blockList) { statusFlag1, statusFlag2, blockData, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result([
            "statusFlag1": statusFlag1,
            "statusFlag2": statusFlag2,
            "blockData": blockData,
          ])
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleFeliCaWriteWithoutEncryption(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCFeliCaTag.self, arguments, result) { tag in
      let serviceCodeList = (arguments["serviceCodeList"] as! [FlutterStandardTypedData]).map { $0.data }
      let blockList = (arguments["blockList"] as! [FlutterStandardTypedData]).map { $0.data }
      let blockData = (arguments["blockData"] as! [FlutterStandardTypedData]).map { $0.data }
      tag.writeWithoutEncryption(serviceCodeList: serviceCodeList, blockList: blockList, blockData: blockData) { statusFlag1, statusFlag2, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result([
            "statusFlag1": statusFlag1,
            "statusFlag2": statusFlag2,
          ])
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleFeliCaRequestSpecificationVersion(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCFeliCaTag.self, arguments, result) { tag in
      tag.requestSpecificationVersion { statusFlag1, statusFlag2, basicVersion, optionVersion, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result([
            "statusFlag1": statusFlag1,
            "statusFlag2": statusFlag2,
            "basicVersion": basicVersion,
            "optionVersion": optionVersion,
          ])
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleFeliCaResetMode(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCFeliCaTag.self, arguments, result) { tag in
      tag.resetMode { statusFlag1, statusFlag2, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result([
            "statusFlag1": statusFlag1,
            "statusFlag2": statusFlag2,
          ])
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleFeliCaSendFeliCaCommand(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCFeliCaTag.self, arguments, result) { tag in
      let commandPacket = (arguments["commandPacket"] as! FlutterStandardTypedData).data
      tag.sendFeliCaCommand(commandPacket: commandPacket) { data, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(data)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693ReadSingleBlock(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let blockNumber = arguments["blockNumber"] as! UInt8
      tag.readSingleBlock(requestFlags: requestFlags, blockNumber: blockNumber) { dataBlock, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(dataBlock)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693WriteSingleBlock(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let blockNumber = arguments["blockNumber"] as! UInt8
      let dataBlock = (arguments["dataBlock"] as! FlutterStandardTypedData).data
      tag.writeSingleBlock(requestFlags: requestFlags, blockNumber: blockNumber, dataBlock: dataBlock) { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693LockBlock(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let blockNumber = arguments["blockNumber"] as! UInt8
      tag.lockBlock(requestFlags: requestFlags, blockNumber: blockNumber) { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693ReadMultipleBlocks(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let blockNumber = arguments["blockNumber"] as! Int
      let numberOfBlocks = arguments["numberOfBlocks"] as! Int
      tag.readMultipleBlocks(requestFlags: requestFlags, blockRange: NSMakeRange(blockNumber, numberOfBlocks)) { dataBlocks, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(dataBlocks)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693WriteMultipleBlocks(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let blockNumber = arguments["blockNumber"] as! Int
      let numberOfBlocks = arguments["numberOfBlocks"] as! Int
      let dataBlocks = (arguments["dataBlocks"] as! [FlutterStandardTypedData]).map { $0.data }
      tag.writeMultipleBlocks(requestFlags: requestFlags, blockRange: NSMakeRange(blockNumber, numberOfBlocks), dataBlocks: dataBlocks) { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693GetMultipleBlockSecurityStatus(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let blockNumber = arguments["blockNumber"] as! Int
      let numberOfBlocks = arguments["numberOfBlocks"] as! Int
      tag.getMultipleBlockSecurityStatus(requestFlags: requestFlags, blockRange: NSMakeRange(blockNumber, numberOfBlocks)) { status, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(status)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693WriteAfi(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let afi = arguments["afi"] as! UInt8
      tag.writeAFI(requestFlags: requestFlags, afi: afi) { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693LockAfi(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      tag.lockAFI(requestFlags: requestFlags) { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693WriteDsfId(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let dsfId = arguments["dsfId"] as! UInt8
      tag.writeDSFID(requestFlags: requestFlags, dsfid: dsfId) { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693LockDsfId(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      tag.lockDFSID(requestFlags: requestFlags) { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693ResetToReady(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      tag.resetToReady(requestFlags: requestFlags) { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693Select(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      tag.select(requestFlags: requestFlags) { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693StayQuiet(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      tag.stayQuiet { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693ExtendedReadSingleBlock(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let blockNumber = arguments["blockNumber"] as! Int
      tag.extendedReadSingleBlock(requestFlags: requestFlags, blockNumber: blockNumber) { dataBlock, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(dataBlock)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693ExtendedWriteSingleBlock(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let blockNumber = arguments["blockNumber"] as! Int
      let dataBlock = (arguments["dataBlock"] as! FlutterStandardTypedData).data
      tag.extendedWriteSingleBlock(requestFlags: requestFlags, blockNumber: blockNumber, dataBlock: dataBlock) { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693ExtendedLockBlock(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let blockNumber = arguments["blockNumber"] as! Int
      tag.extendedLockBlock(requestFlags: requestFlags, blockNumber: blockNumber) { error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(nil)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693ExtendedReadMultipleBlocks(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let blockNumber = arguments["blockNumber"] as! Int
      let numberOfBlocks = arguments["numberOfBlocks"] as! Int
      tag.extendedReadMultipleBlocks(requestFlags: requestFlags, blockRange: NSMakeRange(blockNumber, numberOfBlocks)) { dataBlocks, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(dataBlocks)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693GetSystemInfo(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      tag.getSystemInfo(requestFlags: requestFlags) { dataStorageFormatIdentifier, applicationFamilyIdentifier, blockSize, totalBlocks, icReference, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result([
            "dataStorageFormatIdentifier": dataStorageFormatIdentifier,
            "applicationFamilyIdentifier": applicationFamilyIdentifier,
            "blockSize": blockSize,
            "totalBlocks": totalBlocks,
            "icReference": icReference,
          ])
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso15693CustomCommand(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
      let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
      let customCommandCode = arguments["customCommandCode"] as! Int
      let customRequestParameters = (arguments["customRequestParameters"] as! FlutterStandardTypedData).data
      tag.customCommand(requestFlags: requestFlags, customCommandCode: customCommandCode, customRequestParameters: customRequestParameters) { data, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(data)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso7816SendCommand(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO7816Tag.self, arguments, result) { tag in
      let apdu = NFCISO7816APDU(
        instructionClass: arguments["instructionClass"] as! UInt8,
        instructionCode: arguments["instructionCode"] as! UInt8,
        p1Parameter: arguments["p1Parameter"] as! UInt8,
        p2Parameter: arguments["p2Parameter"] as! UInt8,
        data: (arguments["data"] as! FlutterStandardTypedData).data,
        expectedResponseLength: arguments["expectedResponseLength"] as! Int
      )
      tag.sendCommand(apdu: apdu) { payload, statusWord1, statusWord2, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result([
            "payload": payload,
            "statusWord1": statusWord1,
            "statusWord2": statusWord2,
          ])
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleIso7816SendCommandRaw(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCISO7816Tag.self, arguments, result) { tag in
      guard let apdu = NFCISO7816APDU(data: (arguments["data"] as! FlutterStandardTypedData).data) else {
        result(FlutterError(code: "invalid_parameter", message: nil, details: nil))
        return
      }
      tag.sendCommand(apdu: apdu) { payload, statusWord1, statusWord2, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result([
            "payload": payload,
            "statusWord1": statusWord1,
            "statusWord2": statusWord2,
          ])
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleMiFareSendMiFareCommand(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCMiFareTag.self, arguments, result) { tag in
      let commandPacket = (arguments["commandPacket"] as! FlutterStandardTypedData).data
      tag.sendMiFareCommand(commandPacket: commandPacket) { data, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result(data)
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleMiFareSendMiFareIso7816Command(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCMiFareTag.self, arguments, result) { tag in
      let apdu = NFCISO7816APDU(
        instructionClass: arguments["instructionClass"] as! UInt8,
        instructionCode: arguments["instructionCode"] as! UInt8,
        p1Parameter: arguments["p1Parameter"] as! UInt8,
        p2Parameter: arguments["p2Parameter"] as! UInt8,
        data: (arguments["data"] as! FlutterStandardTypedData).data,
        expectedResponseLength: arguments["expectedResponseLength"] as! Int
      )
      tag.sendMiFareISO7816Command(apdu) { payload, statusWord1, statusWord2, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result([
            "payload": payload,
            "statusWord1": statusWord1,
            "statusWord2": statusWord2,
          ])
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func handleMiFareSendMiFareIso7816CommandRaw(_ arguments: [String : Any?], result: @escaping FlutterResult) {
    tagHandler(NFCMiFareTag.self, arguments, result) { tag in
      guard let apdu = NFCISO7816APDU(data: (arguments["data"] as! FlutterStandardTypedData).data) else {
        result(FlutterError(code: "invalid_parameter", message: nil, details: nil))
        return
      }
      tag.sendMiFareISO7816Command(apdu) { payload, statusWord1, statusWord2, error in
        if let error = error {
          result(getFlutterError(error))
        } else {
          result([
            "payload": payload,
            "statusWord1": statusWord1,
            "statusWord2": statusWord2,
          ])
        }
      }
    }
  }

  @available(iOS 13.0, *)
  private func tagHandler<T>(_ dump: T.Type, _ arguments: [String : Any?], _ result: FlutterResult, callback: ((T) -> Void)) {
    if let tag = tags[arguments["handle"] as! String] as? T {
      callback(tag)
    } else {
      result(FlutterError(code: "invalid_parameter", message: "Tag is not found", details: nil))
    }
  }
}

@available(iOS 13.0, *)
extension SwiftNfcManagerPlugin: NFCTagReaderSessionDelegate {
  public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
    // no op
  }

  public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
    channel.invokeMethod("onError", arguments: getErrorMap(error))
  }

  public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
    let handle = NSUUID().uuidString

    session.connect(to: tags.first!) { error in
      if let error = error {
        // skip tag detection
        print(error)
        return
      }

      getNFCTagMapAsync(tags.first!) { tag, data, error in
        if let error = error {
          // skip tag detection
          print(error)
          return
        }

        self.tags[handle] = tag
        self.channel.invokeMethod("onDiscovered", arguments: data.merging(["handle": handle]) { cur, _ in cur })
      }
    }
  }
}

