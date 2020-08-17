import CoreNFC

@available(iOS 13.0, *)
func getPollingOption(_ arg: [String]) -> NFCTagReaderSession.PollingOption {
  var option = NFCTagReaderSession.PollingOption()
  if arg.contains("iso14443") { option.insert(NFCTagReaderSession.PollingOption.iso14443) }
  if arg.contains("iso15693") { option.insert(NFCTagReaderSession.PollingOption.iso15693) }
  if arg.contains("iso18092") { option.insert(NFCTagReaderSession.PollingOption.iso18092) }
  return option
}

@available(iOS 13.0, *)
func getRequestFlags(_ arg: [String]) -> RequestFlag {
  var flag = RequestFlag()
  if arg.contains("address") { flag.insert(RequestFlag.address) }
  if arg.contains("dualSubCarriers") { flag.insert(RequestFlag.dualSubCarriers) }
  if arg.contains("highDataRate") { flag.insert(RequestFlag.highDataRate) }
  if arg.contains("option") { flag.insert(RequestFlag.option) }
  if arg.contains("protocolExtension") { flag.insert(RequestFlag.protocolExtension) }
  if arg.contains("select") { flag.insert(RequestFlag.select) }
  return flag
}

@available(iOS 11.0, *)
func getErrorTypeString(_ arg: NFCReaderError.Code) -> String? {
  // TODO: add more cases
  switch arg {
  case .readerSessionInvalidationErrorSessionTimeout: return "sessionTimeout"
  case .readerSessionInvalidationErrorSystemIsBusy: return "systemIsBusy"
  case .readerSessionInvalidationErrorUserCanceled: return "userCanceled"
  default: return nil
  }
}

@available(iOS 13.0, *)
func getNDEFMessage(_ arg: [String : Any?]) -> NFCNDEFMessage {
  return NFCNDEFMessage(records: (arg["records"] as! Array<[String : Any?]>).map {
    NFCNDEFPayload(
      format: NFCTypeNameFormat(rawValue: $0["typeNameFormat"] as! UInt8)!,
      type: ($0["type"] as! FlutterStandardTypedData).data,
      identifier: ($0["identifier"] as! FlutterStandardTypedData).data,
      payload: ($0["payload"] as! FlutterStandardTypedData).data
    )
  })
}

@available(iOS 11.0, *)
func getNDEFMessageMap(_ arg: NFCNDEFMessage) -> [String : Any?] {
  return ["records": arg.records.map {
    [
      "typeNameFormat": $0.typeNameFormat.rawValue,
      "type": $0.type,
      "identifier": $0.identifier,
      "payload": $0.payload,
    ]
  }]
}

@available(iOS 13.0, *)
func getNFCTagMapAsync(_ arg: NFCTag, _ completionHandler: @escaping (NFCNDEFTag, [String:Any?], Error?) -> Void) {
  switch (arg) {
  case .feliCa(let tag): getNDEFTagMapAsync(tag) { data, error in completionHandler(tag, data, error) }
  case .miFare(let tag): getNDEFTagMapAsync(tag) { data, error in completionHandler(tag, data, error) }
  case .iso7816(let tag): getNDEFTagMapAsync(tag) { data, error in completionHandler(tag, data, error) }
  case .iso15693(let tag): getNDEFTagMapAsync(tag) { data, error in completionHandler(tag, data, error) }
  @unknown default: print("Unknown tag cannot be serialized")
  }
}

@available(iOS 13.0, *)
func getNDEFTagMapAsync(_ arg: NFCNDEFTag, _ completionHandler: @escaping ([String : Any?], Error?) -> Void) {
  var data = getNDEFTagMap(arg)

  arg.queryNDEFStatus { status, capacity, error in
    if let error = error {
      completionHandler(data, error)
      return
    }

    if status == .notSupported {
      completionHandler(data, nil)
      return
    }

    var ndefData: [String : Any?] = [
      "isWritable": (status == .readWrite),
      "maxSize": capacity,
    ]

    arg.readNDEF { message, _ in

      if let message = message {
        ndefData["cachedMessage"] = getNDEFMessageMap(message)
      }

      data["ndef"] = ndefData

      completionHandler(data, nil)
    }
  }
}

@available(iOS 13.0, *)
func getNDEFTagMap(_ arg: NFCNDEFTag) -> [String : [String : Any?]] {
  if let arg = arg as? NFCFeliCaTag {
    return [
      "felica": [
        "currentIDm": arg.currentIDm,
        "currentSystemCode": arg.currentSystemCode
      ]
    ]
  } else if let arg = arg as? NFCISO15693Tag {
    return [
      "iso15693": [
        "icManufacturerCode": arg.icManufacturerCode,
        "icSerialNumber": arg.icSerialNumber,
        "identifier": arg.identifier
      ]
    ]
  } else if let arg = arg as? NFCISO7816Tag {
    return [
      "iso7816": [
        "applicationData": arg.applicationData,
        "historicalBytes": arg.historicalBytes,
        "identifier": arg.identifier,
        "initialSelectedAID": arg.initialSelectedAID,
        "proprietaryApplicationDataCoding": arg.proprietaryApplicationDataCoding
      ]
    ]
  } else if let arg = arg as? NFCMiFareTag {
    return [
      "mifare": [
        "historicalBytes": arg.historicalBytes,
        "identifier": arg.identifier,
        "mifareFamily": arg.mifareFamily.rawValue
      ]
    ]
  } else {
    return [:]
  }
}

@available(iOS 11.0, *)
func getErrorMap(_ arg: Error) -> [String : Any?] {
  if let arg = arg as? NFCReaderError {
    return [
      "type": getErrorTypeString(arg.code),
      "message": arg.localizedDescription,
      "details": nil,
    ]
  }
  return [
    "type": nil,
    "message": arg.localizedDescription,
    "details": nil,
  ]
}

func getFlutterError(_ arg: Error) -> FlutterError {
  return FlutterError(code: "\((arg as NSError).code)", message:arg.localizedDescription, details: nil)
}
