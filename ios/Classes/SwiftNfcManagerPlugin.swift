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
            handleIsAvailable(result)
            break
        case "startSession":
            handleStartSession(result)
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

    private func handleIsAvailable(_ result: FlutterResult) {
        guard #available(iOS 11.0, *) else {
            result(FlutterError(code: "", message: "Only available on iOS 11.0 or newer", details: nil))
            return
        }

        guard #available(iOS 13.0, *) else {
            result(NFCNDEFReaderSession.readingAvailable)
            return
        }

        result(NFCTagReaderSession.readingAvailable)
    }

    private func handleStartSession(_ result: FlutterResult) {
        guard #available(iOS 11.0, *) else {
            result(FlutterError(code: "", message: "Only available on iOS 11.0 or newer", details: nil))
            return
        }

        guard #available(iOS 13.0, *) else {
            session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            session!.begin()
            result(true)
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

        guard let session = session as? NFCTagReaderSession else {
            result(FlutterError(code: "", message: "No active NFCTagReaderSession", details: nil))
            return
        }

        let key = arguments["key"] as! String
        let message = arguments["message"] as! [String:Any?]

        guard let tag = cachedTags[key], let tech = cachedTechs[key] else {
            result(FlutterError(code: "", message: "Tag is not found", details: nil))
            return
        }

        session.connect(to: tag) { error in
            if let error = error {
                result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                return
            }

            tech.writeNDEF(self.deserializeNDEFMessage(message)) { error in
                if let error = error {
                    result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                    return
                }
                result(true)
            }
        }
    }

    private func handleWriteLock(_ result: @escaping FlutterResult, _ arguments: [String:Any?]) {
        guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "", message: "Only available on iOS 13.0 or newer", details: nil))
            return
        }

        guard let session = session as? NFCTagReaderSession else {
            result(FlutterError(code: "", message: "No active NFCTagReaderSession", details: nil))
            return
        }

        let key = arguments["key"] as! String

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
}

@available(iOS 11.0, *)
extension SwiftNfcManagerPlugin: NFCNDEFReaderSessionDelegate {
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {}

    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        let key = NSUUID().uuidString
        let arguments: [String:Any?] = ["key": key, "ndef": ["cachedNdef": serializeNDEFMessage(messages.first!)]]
        channel.invokeMethod("onTagDiscovered", arguments: arguments)
    }
}

@available(iOS 13.0, *)
extension SwiftNfcManagerPlugin: NFCTagReaderSessionDelegate {
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}

    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {}

    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        let tag = tags.first!
        let key = NSUUID().uuidString

        cachedTags[key] = tag

        func invokeMethod(_ data: [String:Any?], _ error: Error?) {
            // TODO: error handing
            let arguments = data.merging(["key": key]) { cur, _ in cur }
            channel.invokeMethod("onTagDiscovered", arguments: arguments)
        }

        switch tag {
        case .feliCa(let tech):
            cachedTechs[key] = tech
            serializeTag(tag, tech, invokeMethod)
            break
        case .iso15693(let tech):
            cachedTechs[key] = tech
            serializeTag(tag, tech, invokeMethod)
            break
        case .iso7816(let tech):
            cachedTechs[key] = tech
            serializeTag(tag, tech, invokeMethod)
            break
        case .miFare(let tech):
            cachedTechs[key] = tech
            serializeTag(tag, tech, invokeMethod)
            break
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
    private func serializeTag(_ tag: NFCTag, _ tech: NFCNDEFTag, _ completionHandler: @escaping ([String:Any?], Error?) -> Void) {
        var data: [String:Any?] = serializeNDEFTag(tech)

        guard let session = session as? NFCTagReaderSession else {
            completionHandler(data, nil) // TODO: passing error object
            return
        }

        session.connect(to: tag) { error in
            if let error = error {
                completionHandler(data, error)
                return
            }

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

                    data["ndef"] = [
                        "cachedNdef": self.serializeNDEFMessage(message!),
                        "isWritable": (status == .readWrite),
                        "maxSize": capacity
                    ]

                    completionHandler(data, nil)
                }
            }
        }
    }

    @available(iOS 13.0, *)
    private func serializeNDEFTag(_ tag: NFCNDEFTag) -> [String:Any?] {
        if let tag = tag as? NFCFeliCaTag {
            return [
                "type": "feliCa",
                "currentIDm": tag.currentIDm,
                "currentSystemCode": tag.currentSystemCode
            ]
        } else if let tag = tag as? NFCISO15693Tag {
            return [
                "type": "iso15693",
                "icManufacturerCode": tag.icManufacturerCode,
                "icSerialNumber": tag.icSerialNumber,
                "identifier": tag.identifier
            ]
        } else if let tag = tag as? NFCISO7816Tag {
            return [
                "type": "iso7816",
                "applicationData": tag.applicationData,
                "historicalBytes": tag.historicalBytes,
                "identifier": tag.identifier,
                "initialSelectedAID": tag.initialSelectedAID,
                "proprietaryApplicationDataCoding": tag.proprietaryApplicationDataCoding
            ]
        } else if let tag = tag as? NFCMiFareTag {
            return [
                "type": "miFare",
                "historicalBytes": tag.historicalBytes,
                "identifier": tag.identifier,
                "mifareFamily": tag.mifareFamily.rawValue
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
