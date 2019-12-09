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
        let instance = SwiftNfcManagerPlugin(channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private init(_ channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "isAvailable":
            handleIsAvailable(call.arguments as! [String:Any?], result: result)
            break
        case "startNdefSession":
            handleStartNdefSession(call.arguments as! [String:Any?], result: result)
            break
        case "startTagSession":
            handleStartTagSession(call.arguments as! [String:Any?], result: result)
            break
        case "stopSession":
            handleStopSession(call.arguments as! [String:Any?], result: result)
            break
        case "disposeTag":
            handleDisposeTag(call.arguments as! [String:Any?], result: result)
            break
        case "Ndef#write":
            handleNdefWrite(call.arguments as! [String:Any?], result: result)
            break
        case "Ndef#writeLock":
            handleNdefWriteLock(call.arguments as! [String:Any?], result: result)
            break
        case "MiFare#sendMiFareCommand":
            handleMiFareSendMiFareCommand(call.arguments as! [String:Any?], result: result)
            break
        case "FeliCa#sendFeliCaCommand":
            handleFeliCaSendFeliCaCommand(call.arguments as! [String:Any?], result: result)
            break
        case "ISO15693#customCommand":
            handleISO15693CustomCommand(call.arguments as! [String:Any?], result: result)
            break
        case "ISO7816#sendCommand":
            handleISO7816SendCommand(call.arguments as! [String:Any?], result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleIsAvailable(_ arguments: [String:Any?], result: @escaping FlutterResult) {
        guard #available(iOS 11.0, *) else {
            result(FlutterError(code: "unavailable", message: "Only available in iOS 11.0 or newer.", details: nil))
            return
        }

        result(NFCNDEFReaderSession.readingAvailable)
    }

    private func handleStartNdefSession(_ arguments: [String:Any?], result: @escaping FlutterResult) {
        guard #available(iOS 11.0, *) else {
            result(FlutterError(code: "unavailable", message: "Only available in iOS 11.0 or newer.", details: nil))
            return
        }

        let alertMessageIOS = arguments["alertMessageIOS"] as? String

        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)

        if let alertMessage = alertMessageIOS {
            session?.alertMessage = alertMessage
        }

        session?.begin()
        result(true)
    }

    private func handleStartTagSession(_ arguments: [String:Any?], result: @escaping FlutterResult) {
        guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "unavailable", message: "Only available in iOS 13.0 or newer.", details: nil))
            return
        }

        let pollingOption = pollingOptionFrom(arguments["pollingOptions"] as! [Int])
        let alertMessageIOS = arguments["alertMessageIOS"] as? String

        session = NFCTagReaderSession(pollingOption: pollingOption, delegate: self, queue: nil)
        if let alertMessage = alertMessageIOS {
            session?.alertMessage = alertMessage
        }
        session?.begin()
        result(true)
    }

    private func handleStopSession(_ arguments: [String:Any?], result: @escaping FlutterResult) {
        guard #available(iOS 11.0, *) else {
            result(FlutterError(code: "unavailable", message: "Only available in iOS 11.0 or newer.", details: nil))
            return
        }

        guard let session = session else {
            result(true)
            return
        }

        let alertMessageIOS = arguments["alertMessageIOS"] as? String
        let errorMessageIOS = arguments["errorMessageIOS"] as? String

        if #available(iOS 13.0, *), let errorMessage = errorMessageIOS {
            session.invalidate(errorMessage: errorMessage)
            self.session = nil
            result(true)
            return
        }

        if let alertMessage = alertMessageIOS {
            session.alertMessage = alertMessage
        }

        session.invalidate()
        self.session = nil
        result(true)
    }

    private func handleDisposeTag(_ arguments: [String:Any?], result: @escaping FlutterResult) {
        guard #available(iOS 11.0, *) else {
            result(FlutterError(code: "unavailable", message: "Only available in iOS 11.0 or newer.", details: nil))
            return
        }

        guard #available(iOS 13.0, *) else {
            result(true)
            return
        }

        let handle = arguments["handle"] as! String

        techs.removeValue(forKey: handle)
        result(true)
    }

    private func handleNdefWrite(_ arguments: [String:Any?], result: @escaping FlutterResult) {
        guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "unavailable", message: "Only available in iOS 13.0 or newer.", details: nil))
            return
        }

        let handle = arguments["handle"] as! String
        let ndefMessage = ndefMessageFrom(arguments["message"] as! [String:Any?])

        guard let connectedTech = techs[handle] else {
            result(FlutterError(code: "not_found", message: "Tag is not found.", details: nil))
            return
        }

        connectedTech.writeNDEF(ndefMessage) { error in
            if let error = error {
                result(error.toFlutterError())
                return
            }

            result(true)
        }
    }

    private func handleNdefWriteLock(_ arguments: [String:Any?], result: @escaping FlutterResult) {
        guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "unavailable", message: "Only available in iOS 13.0 or newer.", details: nil))
            return
        }

        let handle = arguments["handle"] as! String

        guard let connectedTech = techs[handle] else {
            result(FlutterError(code: "not_found", message: "Tag is not found.", details: nil))
            return
        }

        connectedTech.writeLock { error in
            if let error = error {
                result(error.toFlutterError())
                return
            }

            result(true)
        }
    }

    private func handleMiFareSendMiFareCommand(_ arguments: [String:Any?], result: @escaping FlutterResult) {
        guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "unavailable", message: "Only available in iOS 13.0 or newer.", details: nil))
            return
        }

        let handle = arguments["handle"] as! String

        guard let connectedTech = techs[handle] as? NFCMiFareTag else {
            result(FlutterError(code: "not_found", message: "Tag is not found.", details: nil))
            return
        }

        let commandPacket = (arguments["commandPacket"] as! FlutterStandardTypedData).data

        connectedTech.sendMiFareCommand(commandPacket: commandPacket) { data, error in
            if let error = error {
                result(error.toFlutterError())
                return
            }

            result(data)
        }
    }

    private func handleFeliCaSendFeliCaCommand(_ arguments: [String:Any?], result: @escaping FlutterResult) {
        guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "unavailable", message: "Only available in iOS 13.0 or newer.", details: nil))
            return
        }

        let handle = arguments["handle"] as! String

        guard let connectedTech = techs[handle] as? NFCFeliCaTag else {
            result(FlutterError(code: "not_found", message: "Tag is not found.", details: nil))
            return
        }

        let commandPacket = (arguments["commandPacket"] as! FlutterStandardTypedData).data

        connectedTech.sendFeliCaCommand(commandPacket: commandPacket) { data, error in
            if let error = error {
                result(error.toFlutterError())
                return
            }

            result(data)
        }
    }

    private func handleISO15693CustomCommand(_ arguments: [String:Any?], result: @escaping FlutterResult) {
        guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "unavailable", message: "Only available in iOS 13.0 or newer.", details: nil))
            return
        }

        let handle = arguments["handle"] as! String
        let requestFlags = requestFlagFrom(arguments["requestFlags"] as! [Int])
        let commandCode = arguments["commandCode"] as! Int
        let parameters = (arguments["parameters"] as! FlutterStandardTypedData).data

        guard let connectedTech = techs[handle] as? NFCISO15693Tag else {
            result(FlutterError(code: "not_found", message: "Tag is not found.", details: nil))
            return
        }

        connectedTech.customCommand(requestFlags: requestFlags, customCommandCode: commandCode, customRequestParameters: parameters) { data, error in
            if let error = error {
                result(error.toFlutterError())
                return
            }

            result(data)
        }
    }

    private func handleISO7816SendCommand(_ arguments: [String:Any?], result: @escaping FlutterResult) {
        guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "unavailable", message: "Only available in iOS 13.0 or newer.", details: nil))
            return
        }

        let handle = arguments["handle"] as! String

        guard let apdu = apduFrom(arguments) else {
            result(FlutterError(code: "invalid_arguments", message: "Apdu arguments is invalid.", details: nil))
            return
        }

        if let connectedTech = techs[handle] as? NFCISO7816Tag {
            connectedTech.sendCommand(apdu: apdu) { data, sw1, sw2, error in
                if let error = error {
                    result(error.toFlutterError())
                    return
                }

                result([
                    "data": data,
                    "sw1": sw1,
                    "sw2": sw2,
                ])
            }
        } else if let connectedTech = techs[handle] as? NFCMiFareTag {
            connectedTech.sendMiFareISO7816Command(apdu) { data, sw1, sw2, error in
                if let error = error {
                    result(error.toFlutterError())
                    return
                }

                result([:])
            }
        } else {
            result(FlutterError(code: "not_found", message: "Tag is not found.", details: nil))
        }
    }
}

@available(iOS 11.0, *)
extension SwiftNfcManagerPlugin: NFCNDEFReaderSessionDelegate {
    public func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
    }

    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
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

extension Error {
    @available(iOS 11.0, *)
    func toFlutterError() -> FlutterError {
        if let error = self as? NFCReaderError {
            return FlutterError(code: "\(error.code)", message: error.localizedDescription, details: error.userInfo)
        }

        let error = self as NSError
        return FlutterError(code: "error_\(error.code)", message: error.localizedDescription, details: error.userInfo)
    }
}
