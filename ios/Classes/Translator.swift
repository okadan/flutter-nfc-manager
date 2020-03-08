import CoreNFC

@available(iOS 13.0, *)
func serialize(_ tag: NFCTag, _ completionHandler: @escaping (NFCNDEFTag, [String:Any?], Error?) -> Void) {
    switch (tag) {
    case .feliCa(let tech):
        serialize(tech) { data, error in completionHandler(tech, data, error) }
    case .miFare(let tech):
        serialize(tech) { data, error in completionHandler(tech, data, error) }
    case .iso7816(let tech):
        serialize(tech) { data, error in completionHandler(tech, data, error) }
    case .iso15693(let tech):
        serialize(tech) { data, error in completionHandler(tech, data, error) }
    @unknown default:
        print("Unknown tag cannot be serialized")
    }
}

@available(iOS 13.0, *)
func serialize(_ tech: NFCNDEFTag, _ completionHandler: @escaping ([String:Any?], Error?) -> Void) {
    var data: [String:Any?] = serialize(tech)

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
                ndefData["cachedMessage"] = serialize(message)
            }

            data["ndef"] = ndefData

            completionHandler(data, nil)
        }
    }
}

@available(iOS 13.0, *)
func serialize(_ tech: NFCNDEFTag) -> [String:Any?] {
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
func serialize(_ message: NFCNDEFMessage) -> [String:Any?] {
    return [
        "records": message.records.map { serialize($0) }
    ]
}

@available(iOS 11.0, *)
func serialize(_ payload: NFCNDEFPayload) -> [String:Any?] {
    return [
        "typeNameFormat": payload.typeNameFormat.rawValue,
        "type": payload.type,
        "identifier": payload.identifier,
        "payload": payload.payload,
    ]
}

@available(iOS 11.0, *)
func serialize(_ error: Error) -> [String:Any?] {
    if let error = error as? NFCReaderError {
        return [
            "type": sessionErrorTypeStringFromCode(error.code),
            "message": error.localizedDescription,
            "details": error.userInfo,
        ]
    }
    return [
        "type": nil,
        "message": error.localizedDescription,
        "details": nil,
    ]
}

@available(iOS 13.0, *)
func ndefMessageFrom(_ data: [String:Any?]) -> NFCNDEFMessage {
    return NFCNDEFMessage.init(records: (data["records"] as! Array).map { ndefPayloadFrom($0) })
}

@available(iOS 13.0, *)
func ndefPayloadFrom(_ data: [String:Any?]) -> NFCNDEFPayload {
    return NFCNDEFPayload.init(
        format: NFCTypeNameFormat.init(rawValue: data["typeNameFormat"] as! UInt8)!,
        type: (data["type"] as! FlutterStandardTypedData).data,
        identifier: (data["identifier"] as! FlutterStandardTypedData).data,
        payload: (data["payload"] as! FlutterStandardTypedData).data
    )
}

// Sync with `NfcTagPollingOption` enum on Dart side
@available(iOS 13.0, *)
func pollingOptionFrom(_ options: [Int]) -> NFCTagReaderSession.PollingOption {
    var option: NFCTagReaderSession.PollingOption = []

    if options.contains(0) {
        option.insert(NFCTagReaderSession.PollingOption.iso14443)
    }

    if options.contains(1) {
        option.insert(NFCTagReaderSession.PollingOption.iso15693)
    }

    if options.contains(2) {
        option.insert(NFCTagReaderSession.PollingOption.iso18092)
    }

    return option
}

@available(iOS 13.0, *)
func requestFlagFrom(_ flags: [Int]) -> RequestFlag {
    var flag: RequestFlag = []

    if flags.contains(0) {
        flag.insert(.dualSubCarriers)
    }

    if flags.contains(1) {
        flag.insert(.highDataRate)
    }

    if flags.contains(2) {
        flag.insert(.protocolExtension)
    }

    if flags.contains(3) {
        flag.insert(.select)
    }

    if flags.contains(4) {
        flag.insert(.address)
    }

    if flags.contains(5) {
        flag.insert(.option)
    }

    return flag
}

@available(iOS 13.0, *)
func apduFrom(_ arguments: [String:Any?]) -> NFCISO7816APDU? {
    if arguments.count == 1, let data = (arguments["data"] as? FlutterStandardTypedData)?.data {
        return NFCISO7816APDU(data: data)
    }

    if
        let instructionClassInt = arguments["instructionClass"] as? Int,
        let instructionClass = UInt8(exactly: instructionClassInt),
        let instructionCodeInt = arguments["instructionCode"] as? Int,
        let instructionCode = UInt8(exactly: instructionCodeInt),
        let p1ParameterInt = arguments["p1Parameter"] as? Int,
        let p1Parameter = UInt8(exactly: p1ParameterInt),
        let p2ParameterInt = arguments["p2Parameter"] as? Int,
        let p2Parameter = UInt8(exactly: p2ParameterInt),
        let data = (arguments["data"] as? FlutterStandardTypedData)?.data,
        let expectedResponseLength = arguments["expectedResponseLength"] as? Int
    {
        return NFCISO7816APDU(
            instructionClass: instructionClass,
            instructionCode: instructionCode,
            p1Parameter: p1Parameter,
            p2Parameter: p2Parameter,
            data: data,
            expectedResponseLength: expectedResponseLength
        )
    }

    return nil
}

@available(iOS 11.0, *)
func sessionErrorTypeStringFromCode(_ code: NFCReaderError.Code) -> String? {
    // TODO: add more cases
    switch code {
    case .readerSessionInvalidationErrorSessionTimeout:
        return "sessionTimeout"
    case .readerSessionInvalidationErrorUserCanceled:
        return "userCanceled"
    default:
        return nil
    }
}
