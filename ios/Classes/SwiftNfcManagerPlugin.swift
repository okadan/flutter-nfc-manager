import CoreNFC
import Flutter

public class SwiftNfcManagerPlugin: NSObject, FlutterPlugin {
    private let channel: FlutterMethodChannel

    @available(iOS 11.0, *)
    private lazy var session: NFCReaderSession? = nil

    @available(iOS 13.0, *)
    private lazy var techs: [String:NFCNDEFTag] = [:]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plugins.flutter.io/nfc_manager", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(SwiftNfcManagerPlugin(channel), channel: channel)
    }

    private init(_ channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String:Any?]

        switch (call.method) {
        case "isAvailable":
            guard #available(iOS 11.0, *) else {
                result(createUnavailableError(minVersion: "11.0"))
                return
            }
            handleIsAvailable(
                result: result
            )
            break
        case "startNdefSession":
            guard #available(iOS 11.0, *) else {
                result(createUnavailableError(minVersion: "11.0"))
                return
            }
            handleStartNdefSession(
                result: result,
                alertMessage: arguments["alertMessageIOS"] as? String
            )
            break
        case "startTagSession":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleStartTagSession(
                result: result,
                alertMessage: arguments["alertMessageIOS"] as? String,
                pollingOptions: arguments["pollingOptions"] as! [Int]
            )
            break
        case "stopSession":
            guard #available(iOS 11.0, *) else {
                result(createUnavailableError(minVersion: "11.0"))
                return
            }
            handleStopSession(
                result: result,
                alertMessage: arguments["alertMessageIOS"] as? String,
                errorMessage: arguments["errorMessageIOS"] as? String
            )
            break
        case "disposeTag":
            guard #available(iOS 11.0, *) else {
                result(createUnavailableError(minVersion: "11.0"))
                return
            }
            handleDisposeTag(
                result: result,
                handle: arguments["handle"] as! String
            )
            break
        case "Ndef#write":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleNdefWrite(
                result: result,
                handle: arguments["handle"] as! String,
                message: arguments["message"] as! [String:Any?]
            )
            break
        case "Ndef#writeLock":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleNdefWriteLock(
                result: result,
                handle: arguments["handle"] as! String
            )
            break
        case "MiFare#sendMiFareCommand":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleMiFareSendMiFareCommand(
                result: result,
                handle: arguments["handle"] as! String,
                commandPacket: arguments["commandPacket"] as! FlutterStandardTypedData
            )
            break
        case "FeliCa#sendFeliCaCommand":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleFeliCaSendFeliCaCommand(
                result: result,
                handle: arguments["handle"] as! String,
                commandPacket: arguments["commandPacket"] as! FlutterStandardTypedData
            )
            break
        case "ISO15693#getSystemInfo":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693GetSystemInfo(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int]
            )
        case "ISO15693#readSingleBlock":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693ReadSingleBlock(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                blockNumber: arguments["blockNumber"] as! UInt8
            )
        case "ISO15693#writeSingleBlock":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693WriteSingleBlock(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                blockNumber: arguments["blockNumber"] as! UInt8,
                dataBlock: arguments["dataBlock"] as! FlutterStandardTypedData
            )
        case "ISO15693#lockBlock":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693LockBlock(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                blockNumber: arguments["blockNumber"] as! UInt8
            )
        case "ISO15693#readMultipleBlocks":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693ReadMultipleBlocks(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                blockNumber: arguments["blockNumber"] as! Int,
                numberOfBlocks: arguments["numberOfBlocks"] as! Int
            )
        case "ISO15693#writeMultipleBlocks":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693WriteMultipleBlocks(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                blockNumber: arguments["blockNumber"] as! Int,
                numberOfBlocks: arguments["numberOfBlocks"] as! Int,
                dataBlocks: arguments["dataBlocks"] as! [FlutterStandardTypedData]
            )
        case "ISO15693#getMultipleBlockSecurityStatus":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693GetMultipleBlockSecurityStatus(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                blockNumber: arguments["blockNumber"] as! Int,
                numberOfBlocks: arguments["numberOfBlocks"] as! Int
            )
        case "ISO15693#writeAfi":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693WriteAfi(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                afi: arguments["afi"] as! UInt8
            )
        case "ISO15693#lockAfi":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693LockAfi(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int]
            )
        case "ISO15693#writeDsfId":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693WriteDsfId(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                dsfId: arguments["dsfId"] as! UInt8
            )
        case "ISO15693#lockDsfId":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693LockDsfId(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int]
            )
        case "ISO15693#resetToReady":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693ResetToReady(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int]
            )
        case "ISO15693#select":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693Select(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int]
            )
        case "ISO15693#stayQuiet":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693StayQuiet(
                result: result,
                handle: arguments["handle"] as! String
            )
        case "ISO15693#extendedReadSingleBlock":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693ExtendedReadSingleBlock(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                blockNumber: arguments["blockNumber"] as! Int
            )
        case "ISO15693#extendedWriteSingleBlock":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693ExtendedWriteSingleBlock(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                blockNumber: arguments["blockNumber"] as! Int,
                dataBlock: arguments["dataBlock"] as! FlutterStandardTypedData
            )
        case "ISO15693#extendedLockBlock":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693ExtendedLockBlock(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                blockNumber: arguments["blockNumber"] as! Int
            )
        case "ISO15693#extendedReadMultipleBlocks":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693ExtendedReadMultipleBlocks(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                blockNumber: arguments["blockNumber"] as! Int,
                numberOfBlocks: arguments["numberOfBlocks"] as! Int
            )
        case "ISO15693#customCommand":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO15693CustomCommand(
                result: result,
                handle: arguments["handle"] as! String,
                requestFlags: arguments["requestFlags"] as! [Int],
                commandCode: arguments["commandCode"] as! Int,
                parameters: arguments["parameters"] as! FlutterStandardTypedData
            )
            break
        case "ISO7816#sendCommand":
            guard #available(iOS 13.0, *) else {
                result(createUnavailableError(minVersion: "13.0"))
                return
            }
            handleISO7816SendCommand(
                result: result,
                handle: arguments["handle"] as! String,
                apdu: arguments["apdu"] as! [String:Any?]
            )
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    @available(iOS 11.0, *)
    private func handleIsAvailable(
        result: @escaping FlutterResult
    ) {
        result(NFCNDEFReaderSession.readingAvailable)
    }

    @available(iOS 11.0, *)
    private func handleStartNdefSession(
        result: @escaping FlutterResult,
        alertMessage: String?
    ) {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = alertMessage ?? ""
        session?.begin()
        result(true)
    }

    @available(iOS 13.0, *)
    private func handleStartTagSession(
        result: @escaping FlutterResult,
        alertMessage: String?,
        pollingOptions: [Int]
    ) {
        session = NFCTagReaderSession(pollingOption: pollingOptionFrom(pollingOptions), delegate: self, queue: nil)
        session?.alertMessage = alertMessage ?? ""
        session?.begin()
        result(true)
    }

    @available(iOS 11.0, *)
    private func handleStopSession(
        result: @escaping FlutterResult,
        alertMessage: String?,
        errorMessage: String?
    ) {
        guard let session = session else {
            result(true)
            return
        }
        if #available(iOS 13.0, *), let errorMessage = errorMessage {
            session.invalidate(errorMessage: errorMessage)
            self.session = nil
            result(true)
            return
        }
        session.alertMessage = alertMessage ?? ""
        session.invalidate()
        self.session = nil
        result(true)
    }

    @available(iOS 11.0, *)
    private func handleDisposeTag(
        result: @escaping FlutterResult,
        handle: String
    ) {
        guard #available(iOS 13.0, *) else {
            result(true)
            return
        }
        techs.removeValue(forKey: handle)
        result(true)
    }

    @available(iOS 13.0, *)
    private func handleNdefWrite(
        result: @escaping FlutterResult,
        handle: String,
        message: [String:Any?]
    ) {
        guard let tech = techs[handle] else {
            result(createTagNotFoundError())
            return
        }
        tech.writeNDEF(ndefMessageFrom(message)) { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleNdefWriteLock(
        result: @escaping FlutterResult,
        handle: String
    ) {
        guard let tech = techs[handle] else {
            result(createTagNotFoundError())
            return
        }
        tech.writeLock { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleMiFareSendMiFareCommand(
        result: @escaping FlutterResult,
        handle: String,
        commandPacket: FlutterStandardTypedData
    ) {
        guard let tech = techs[handle] as? NFCMiFareTag else {
            result(createTagNotFoundError())
            return
        }
        tech.sendMiFareCommand(commandPacket: commandPacket.data) { data, error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(data)
        }
    }

    @available(iOS 13.0, *)
    private func handleFeliCaSendFeliCaCommand(
        result: @escaping FlutterResult,
        handle: String,
        commandPacket: FlutterStandardTypedData
    ) {
        guard let tech = techs[handle] as? NFCFeliCaTag else {
            result(createTagNotFoundError())
            return
        }
        tech.sendFeliCaCommand(commandPacket: commandPacket.data) { data, error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(data)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693GetSystemInfo(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int]
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.getSystemInfo(requestFlags: requestFlagFrom(requestFlags)) { p1, p2, p3, p4, p5, error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result([p1, p2, p3, p4, p5])
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693ReadSingleBlock(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        blockNumber: UInt8
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.readSingleBlock(requestFlags: requestFlagFrom(requestFlags), blockNumber: blockNumber) { data, error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(data)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693WriteSingleBlock(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        blockNumber: UInt8,
        dataBlock: FlutterStandardTypedData
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.writeSingleBlock(requestFlags: requestFlagFrom(requestFlags), blockNumber: blockNumber, dataBlock: dataBlock.data) { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693LockBlock(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        blockNumber: UInt8
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.lockBlock(requestFlags: requestFlagFrom(requestFlags), blockNumber: blockNumber) { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693ReadMultipleBlocks(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        blockNumber: Int,
        numberOfBlocks: Int
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.readMultipleBlocks(requestFlags: requestFlagFrom(requestFlags), blockRange: NSMakeRange(blockNumber, numberOfBlocks)) { data, error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(data)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693WriteMultipleBlocks(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        blockNumber: Int,
        numberOfBlocks: Int,
        dataBlocks: [FlutterStandardTypedData]
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.writeMultipleBlocks(requestFlags: requestFlagFrom(requestFlags), blockRange: NSMakeRange(blockNumber, numberOfBlocks), dataBlocks: dataBlocks.map { $0.data }) { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693GetMultipleBlockSecurityStatus(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        blockNumber: Int,
        numberOfBlocks: Int
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.getMultipleBlockSecurityStatus(requestFlags: requestFlagFrom(requestFlags), blockRange: NSMakeRange(blockNumber, numberOfBlocks)) { data, error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(data)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693WriteAfi(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        afi: UInt8
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.writeAFI(requestFlags: requestFlagFrom(requestFlags), afi: afi) { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693LockAfi(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int]
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.lockAFI(requestFlags: requestFlagFrom(requestFlags)) { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693WriteDsfId(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        dsfId: UInt8
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.writeDSFID(requestFlags: requestFlagFrom(requestFlags), dsfid: dsfId) { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693LockDsfId(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int]
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.lockDFSID(requestFlags: requestFlagFrom(requestFlags)) { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693ResetToReady(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int]
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.resetToReady(requestFlags: requestFlagFrom(requestFlags)) { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693Select(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int]
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.select(requestFlags: requestFlagFrom(requestFlags)) { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693StayQuiet(
        result: @escaping FlutterResult,
        handle: String
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.stayQuiet() { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693ExtendedReadSingleBlock(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        blockNumber: Int
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.extendedReadSingleBlock(requestFlags: requestFlagFrom(requestFlags), blockNumber: blockNumber) { data, error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(data)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693ExtendedWriteSingleBlock(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        blockNumber: Int,
        dataBlock: FlutterStandardTypedData
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.extendedWriteSingleBlock(requestFlags: requestFlagFrom(requestFlags), blockNumber: blockNumber, dataBlock: dataBlock.data) { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693ExtendedLockBlock(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        blockNumber: Int
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.extendedLockBlock(requestFlags: requestFlagFrom(requestFlags), blockNumber: blockNumber) { error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(true)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693ExtendedReadMultipleBlocks(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        blockNumber: Int,
        numberOfBlocks: Int
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.extendedReadMultipleBlocks(requestFlags: requestFlagFrom(requestFlags), blockRange: NSMakeRange(blockNumber, numberOfBlocks)) { data, error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(data)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO15693CustomCommand(
        result: @escaping FlutterResult,
        handle: String,
        requestFlags: [Int],
        commandCode: Int,
        parameters: FlutterStandardTypedData
    ) {
        guard let tech = techs[handle] as? NFCISO15693Tag else {
            result(createTagNotFoundError())
            return
        }
        tech.customCommand(requestFlags: requestFlagFrom(requestFlags), customCommandCode: commandCode, customRequestParameters: parameters.data) { data, error in
            if let error = error {
                result(createFlutterError(error: error))
                return
            }
            result(data)
        }
    }

    @available(iOS 13.0, *)
    private func handleISO7816SendCommand(
        result: @escaping FlutterResult,
        handle: String,
        apdu: [String:Any?]
    ) {
        guard let apduCommand = apduFrom(apdu) else {
            result(FlutterError(code: "invalid_arguments", message: "Apdu arguments is invalid.", details: nil))
            return
        }
        if let tech = techs[handle] as? NFCISO7816Tag {
            tech.sendCommand(apdu: apduCommand) { data, sw1, sw2, error in
                if let error = error {
                    result(createFlutterError(error: error))
                    return
                }
                result(data)
            }
        } else if let tech = techs[handle] as? NFCMiFareTag {
            tech.sendMiFareISO7816Command(apduCommand) { data, sw1, sw2, error in
                if let error = error {
                    result(createFlutterError(error: error))
                    return
                }
                result(data)
            }
        } else {
            result(createTagNotFoundError())
        }
    }
}

@available(iOS 11.0, *)
extension SwiftNfcManagerPlugin: NFCNDEFReaderSessionDelegate {
    public func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
    }

    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        channel.invokeMethod("onSessionError", arguments: serialize(error))
    }

    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        let handle = NSUUID().uuidString
        let arguments: [String:Any?] = ["handle": handle, "ndef": ["cachedMessage": serialize(messages.first!)]]
        channel.invokeMethod("onNdefDiscovered", arguments: arguments)
    }

    @available(iOS 13.0, *)
    public func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        let handle = NSUUID().uuidString
        let tech = tags.first!

        session.connect(to: tech) { error in
            if let error = error {
                // skip tag detection
                print(error)
                return
            }

            serialize(tech) { data, error in
                if let error = error {
                    // skip tag detection
                    print(error)
                    return
                }

                self.techs[handle] = tech
                self.channel.invokeMethod("onNdefDiscovered", arguments: data.merging(["handle": handle]) { cur, _ in cur })
            }
        }
    }
}

@available(iOS 13.0, *)
extension SwiftNfcManagerPlugin: NFCTagReaderSessionDelegate {
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
    }

    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        channel.invokeMethod("onSessionError", arguments: serialize(error))
    }

    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        let handle = NSUUID().uuidString
        let tag = tags.first!

        session.connect(to: tag) { error in
            if let error = error {
                // skip tag detection
                print(error)
                return
            }

            serialize(tag) { tech, data, error in
                if let error = error {
                    // skip tag detection
                    print(error)
                    return
                }

                self.techs[handle] = tech
                self.channel.invokeMethod("onTagDiscovered", arguments: data.merging(["handle": handle]) { cur, _ in cur })
            }
        }
    }
}


@available(iOS 11.0, *)
private func createFlutterError(error: Error) -> FlutterError {
    return FlutterError(code: "error", message: error.localizedDescription, details: nil)
}

private func createUnavailableError(minVersion: String) -> FlutterError {
    return FlutterError(code: "unavailable", message: "Only available in iOS \(minVersion) on newer.", details: nil)
}

private func createTagNotFoundError() -> FlutterError {
    return FlutterError(code: "not_found", message: "Tag is not found.", details: nil)
}
