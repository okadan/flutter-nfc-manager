import Flutter
import CoreNFC

public class SwiftNfcManagerPlugin: NSObject, FlutterPlugin {

    private let channel: FlutterMethodChannel

    @available(iOS 11.0, *)
    private lazy var session: NFCReaderSession? = nil

    @available(iOS 13.0, *)
    private lazy var cachedTags: [String: NFCTag] = [:]

    @available(iOS 13.0, *)
    private lazy var cachedTechs: [String: NFCNDEFTag] = [:]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plugins.flutter.io/nfc_manager", binaryMessenger: registrar.messenger())
        let instance = SwiftNfcManagerPlugin(channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private init(_ channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isAvailable":
            handleIsAvailable(result, call.arguments as! [String:Any?])
            break
        case "startNdefSession":
            handleStartNdefSession(result, call.arguments as! [String:Any?])
            break
        case "startTagSession":
            handleStartTagSession(result, call.arguments as! [String:Any?])
            break
        case "stopSession":
            handleStopSession(result, call.arguments as! [String:Any?])
            break
        case "writeNdef":
            handleWriteNdef(result, call.arguments as! [String:Any?])
            break
        case "writeLock":
            handleWriteLock(result, call.arguments as! [String:Any?])
            break
        case "dispose":
            handleDispose(result, call.arguments as! [String:Any?])
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleIsAvailable(_ result: FlutterResult, _ arguments: [String:Any?]) {
        let type = arguments["type"] as! String

        switch type {
        case "NDEF":
            guard #available(iOS 11.0, *) else {
                result(FlutterError(code: "", message: "Only available on iOS 11.0 or newer", details: nil))
                return
            }
            result(NFCNDEFReaderSession.readingAvailable)
            break
        case "TAG":
            guard #available(iOS 13.0, *) else {
                result(FlutterError(code: "", message: "Only available on iOS 13.0 or newer", details: nil))
                return
            }
            result(NFCTagReaderSession.readingAvailable)
            break
        default:
            result(FlutterError(code: "", message: "Invalid argument: type=\(type)", details: nil))
        }
    }

    private func handleStartNdefSession(_ result: FlutterResult, _ arguments: [String:Any?]) {
        guard #available(iOS 11.0, *) else {
            result(FlutterError(code: "", message: "Only available on iOS 11.0 or newer", details: nil))
            return
        }

        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session!.begin()
        result(true)
    }

    private func handleStartTagSession(_ result: FlutterResult, _ arguments: [String:Any?]) {
        guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "", message: "Only available on iOS 13.0 or newer", details: nil))
            return
        }

        session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693, .iso18092], delegate: self)
        session!.begin()
        result(true)
    }

    private func handleStopSession(_ result: FlutterResult, _ arguments: [String:Any?]) {
        guard #available(iOS 11.0, *) else {
            result(FlutterError(code: "", message: "Only available on iOS 11.0 or newer", details: nil))
            return
        }

        guard let session = session else {
            result(true)
            return
        }

        guard #available(iOS 13.0, *), let errorMessage = arguments["errorMessageIOS"] as? String else {
            session.invalidate()
            self.session = nil
            result(true)
            return
        }

        session.invalidate(errorMessage: errorMessage)
        self.session = nil
        result(true)
    }

    private func handleWriteNdef(_ result: @escaping FlutterResult, _ arguments: [String:Any?]) {
        guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "", message: "Only available on iOS 13.0 or newer", details: nil))
            return
        }

        let key = arguments["key"] as! String
        let message = deserializeNDEFMessage(arguments["message"] as! [String:Any?])

        switch session {
        case let session as NFCNDEFReaderSession:
            handleWriteNdef__Ndef(result, session, key, message)
            break
        case let session as NFCTagReaderSession:
            handleWriteNdef__Tag(result, session, key, message)
            break
        default:
            result(FlutterError(code: "", message: "No valid session", details: nil))
        }
    }

    private func handleWriteLock(_ result: @escaping FlutterResult, _ arguments: [String:Any?]) {
        guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "", message: "Only available on iOS 13.0 or newer", details: nil))
            return
        }

        let key = arguments["key"] as! String

        switch session {
        case let session as NFCNDEFReaderSession:
            handleWriteLock__Ndef(result, session, key)
            break
        case let session as NFCTagReaderSession:
            handleWriteLock__Tag(result, session, key)
            break
        default:
            result(FlutterError(code: "", message: "No valid session", details: nil))
        }
    }

    private func handleDispose(_ result: FlutterResult, _ arguments: [String:Any?]) {
        guard #available(iOS 11.0, *) else {
            result(FlutterError(code: "", message: "Only available on iOS 11.0 or newer", details: nil))
            return
        }

        guard #available(iOS 13.0, *) else {
            result(true)
            return
        }

        let key = arguments["key"] as! String

        cachedTags.removeValue(forKey: key)
        cachedTechs.removeValue(forKey: key)
        result(true)
    }

    @available(iOS 13.0, *)
    private func handleWriteNdef__Ndef(_ result: @escaping FlutterResult, _ session: NFCNDEFReaderSession, _ key: String, _ message: NFCNDEFMessage) {
        guard let tech = cachedTechs[key] else {
            result(FlutterError(code: "", message: "Tag is not found", details: nil))
            return
        }

        session.connect(to: tech) { error in
            if let error = error {
                result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                return
            }

            tech.writeNDEF(message) { error in
                if let error = error {
                    result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                    return
                }
                result(true)
            }
        }
    }

    @available(iOS 13.0, *)
    private func handleWriteNdef__Tag(_ result: @escaping FlutterResult, _ session: NFCTagReaderSession, _ key: String, _ message: NFCNDEFMessage) {
        guard let tag = cachedTags[key], let tech = cachedTechs[key] else {
            result(FlutterError(code: "", message: "Tag is not found", details: nil))
            return
        }

        session.connect(to: tag) { error in
            if let error = error {
                result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                return
            }

            tech.writeNDEF(message) { error in
                if let error = error {
                    result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                    return
                }
                result(true)
            }
        }
    }

    @available(iOS 13.0, *)
    private func handleWriteLock__Ndef(_ result: @escaping FlutterResult, _ session: NFCNDEFReaderSession, _ key: String) {
        guard let tech = cachedTechs[key] else {
            result(FlutterError(code: "", message: "Tag is not found", details: nil))
            return
        }

        session.connect(to: tech) { error in
            if let error = error {
                result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                return
            }

            tech.writeLock { error in
                if let error = error {
                    result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                    return
                }
                result(true)
            }
        }
    }

    @available(iOS 13.0, *)
    private func handleWriteLock__Tag(_ result: @escaping FlutterResult, _ session: NFCTagReaderSession, _ key: String) {
        guard let tag = cachedTags[key], let tech = cachedTechs[key] else {
            result(FlutterError(code: "", message: "Tag is not found", details: nil))
            return
        }

        session.connect(to: tag) { error in
            if let error = error {
                result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                return
            }

            tech.writeLock { error in
                if let error = error {
                    result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                    return
                }
                result(true)
            }
        }
    }
}

extension SwiftNfcManagerPlugin: NFCNDEFReaderSessionDelegate {
    @available(iOS 13.0, *)
    public func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
    }

    @available(iOS 11.0, *)
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {}

    @available(iOS 11.0, *)
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        let key = NSUUID().uuidString
        let arguments: [String:Any?] = ["key": key, "ndef": ["cachedNdef": serializeNDEFMessage(messages.first!)]]
        channel.invokeMethod("onNdefDiscovered", arguments: arguments)
    }

    @available(iOS 13.0, *)
    public func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        let key = NSUUID().uuidString
        let tech = tags.first!

        session.connect(to: tech) { error in
            if let error = error {
                print(error)
                return
            }

            self.serializeTech(tech) { data, error in
                if let error = error {
                    print(error)
                    return
                }

                self.cachedTechs[key] = tech
                self.channel.invokeMethod("onNdefDiscovered", arguments: data.merging(["key": key]) { cur, _ in cur })
            }
        }
    }
}

extension SwiftNfcManagerPlugin: NFCTagReaderSessionDelegate {
    @available(iOS 13.0, *)
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}

    @available(iOS 13.0, *)
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {}

    @available(iOS 13.0, *)
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        let key = NSUUID().uuidString

        var tech: NFCNDEFTag?

        switch tags.first! {
        case .feliCa(let tag):
            tech = tag
        case .iso7816(let tag):
            tech = tag
        case .iso15693(let tag):
            tech = tag
        case .miFare(let tag):
            tech = tag
        }

        session.connect(to: tags.first!) { error in
            if let error = error {
                print(error)
                return
            }

            self.serializeTech(tech!) { data, error in
                if let error = error {
                    print(error)
                    return
                }
                self.channel.invokeMethod("onTagDiscovered", arguments: data.merging(["key": key]) { cur, _ in cur })
            }
        }
    }
}

extension SwiftNfcManagerPlugin {
    @available(iOS 13.0, *)
    private func deserializeNDEFMessage(_ data: [String:Any?]) -> NFCNDEFMessage {
        return NFCNDEFMessage.init(records: (data["records"] as! Array).map { deserializeNDEFPayload($0) })
    }

    @available(iOS 13.0, *)
    private func deserializeNDEFPayload(_ data: [String:Any?]) -> NFCNDEFPayload {
        return NFCNDEFPayload.init(
            format: NFCTypeNameFormat.init(rawValue: data["typeNameFormat"] as! UInt8)!,
            type: (data["type"] as! FlutterStandardTypedData).data,
            identifier: (data["identifier"] as! FlutterStandardTypedData).data,
            payload: (data["payload"] as! FlutterStandardTypedData).data
        )
    }

    @available(iOS 13.0, *)
    private func serializeTech(_ tech: NFCNDEFTag, _ completionHandler: @escaping ([String:Any?], Error?) -> Void) {
        var data: [String:Any?] = serializeTech(tech)

        tech.queryNDEFStatus { status, capacity, error in
            if let error = error {
                completionHandler(data, error)
                return
            }

            if status == .notSupported {
                completionHandler(data, nil)
                return
            }

            tech.readNDEF { message, error in
                if let error = error {
                    completionHandler(data, error)
                    return
                }

                var ndefData: [String:Any?] = [
                    "isWritable": (status == .readWrite),
                    "maxSize": capacity
                ]

                if let message = message {
                    ndefData["cachedNdef"] = self.serializeNDEFMessage(message)
                }

                data["ndef"] = ndefData

                completionHandler(data, nil)
            }
        }
    }

    @available(iOS 13.0, *)
    private func serializeTech(_ tech: NFCNDEFTag) -> [String:Any?] {
        if let tech = tech as? NFCFeliCaTag {
            return [
                "type": "feliCa",
                "currentIDm": tech.currentIDm,
                "currentSystemCode": tech.currentSystemCode
            ]
        } else if let tech = tech as? NFCISO15693Tag {
            return [
                "type": "iso15693",
                "icManufacturerCode": tech.icManufacturerCode,
                "icSerialNumber": tech.icSerialNumber,
                "identifier": tech.identifier
            ]
        } else if let tech = tech as? NFCISO7816Tag {
            return [
                "type": "iso7816",
                "applicationData": tech.applicationData,
                "historicalBytes": tech.historicalBytes,
                "identifier": tech.identifier,
                "initialSelectedAID": tech.initialSelectedAID,
                "proprietaryApplicationDataCoding": tech.proprietaryApplicationDataCoding
            ]
        } else if let tech = tech as? NFCMiFareTag {
            return [
                "type": "miFare",
                "historicalBytes": tech.historicalBytes,
                "identifier": tech.identifier,
                "mifareFamily": tech.mifareFamily.rawValue
            ]
        } else {
            return [:]
        }
    }

    @available(iOS 11.0, *)
    private func serializeNDEFMessage(_ message: NFCNDEFMessage) -> [String:Any?] {
        return [
            "records": message.records.map { serializeNDEFPayload($0) }
        ]
    }

    @available(iOS 11.0, *)
    private func serializeNDEFPayload(_ payload: NFCNDEFPayload) -> [String:Any?] {
        return [
            "identifier": payload.identifier,
            "payload": payload.payload,
            "type": payload.type,
            "typeNameFormat": payload.typeNameFormat.rawValue
        ]
    }
}
