

/*
    Translates Web-NFC NDEFRecord to Native-NFC NDEFRecord and vice versa
    See W3C Specifications for the mapping: https://w3c.github.io/web-nfc/#data-mapping
*/
class Translator {

    static URI_PREFIX_LIST = [
        '',
        'http://www.',
        'https://www.',
        'http://',
        'https://',
        'tel:',
        'mailto:',
        'ftp://anonymous:anonymous@',
        'ftp://ftp.',
        'ftps://',
        'sftp://',
        'smb://',
        'nfs://',
        'ftp://',
        'dav://',
        'news:',
        'telnet://',
        'imap:',
        'rtsp://',
        'urn:',
        'pop:',
        'sip:',
        'sips:',
        'tftp:',
        'btspp://',
        'btl2cap://',
        'btgoep://',
        'tcpobex://',
        'irdaobex://',
        'file://',
        'urn:epc:id:',
        'urn:epc:tag:',
        'urn:epc:pat:',
        'urn:epc:raw:',
        'urn:epc:',
        'urn:nfc:',
    ];

    static WEB_TO_NATIVE_TNF = {
        "empty": 0x00,
        "text": 0x01,
        "url": 0x01,
        //"smart-poster": 0x01,
        "mime": 0x02,
        //"absolute-uri": 0x03,
        "external": 0x04,
        //"unknown": 0x05
    }

    static WEB_TO_NATIVE_TYPE = {
        //"empty": null,
        "text": "T",
        "url": "U",
        //"smart-poster": "Sp",
        //"unknown": null
    }

    static NATIVE_TO_WEB_TNF = {
        //0x00 : "empty",
        0x01 : {
            "T": "text",
            "U": "url",
           // "Sp": "smart-poster"
        },
        0x02: "mime",
        //0x03: "absolute-url",
        //0x05: "unknown"
    }

    static getWebfromNativeNDEFRecord(typeNameFormat, type, identifier, payload){
        let id, recordType, mediaType, data, encoding, lang;
        let decoder = new TextDecoder();
        // Identifier
        id = identifier;
        // RecordType
        switch(typeNameFormat) {
            case 0x01: // Well-Known (Text / URL)
                recordType = this.NATIVE_TO_WEB_TNF[typeNameFormat][decoder.decode(type)];
                break;
            case 0x04: // External
                recordType = decoder.decode(type);
                break;
            default: // MIME
                recordType = this.NATIVE_TO_WEB_TNF[typeNameFormat];
        }
        if (recordType == null) throw TypeError("TypeNameFormat " + typeNameFormat + " with Type " + type + " not supported from nfc_manager_web");
        // MediaType
        if (typeNameFormat == 0x02) {
            mediaType = decoder.decode(type);
        }
        // Data, Encoding, Lang
        if (payload != null) {
            switch (recordType) {
                //case "empty":
                //    // No Data
                //    data = null;
                //    break;
                case "text":
                    // String
                    encoding = "utf-8";
                    let languageByteLength = payload.slice(0,1)[0]; 
                    lang = decoder.decode(payload.slice(1, 1 + languageByteLength));
                    data = decoder.decode(payload.slice(1 + languageByteLength));
                    break;
                case "url":
                //case "absolute-uri":
                    // String with URI Prefix
                    data = (Translator.URI_PREFIX_LIST[payload.slice(0,1)] ?? "") + decoder.decode(payload.slice(1));
                    break;
                //case "unknown":
                //case "smart-poster":
                    //break;
                default: // mime, external
                    data = payload;
                    // local oder sonst wat
            }
        }

        return {
            recordType: recordType,
            mediaType: mediaType,
            id: id,
            data: data,
            encoding: encoding,
            lang: lang
        };
    }

    static getNativefromWebNDEFRecord(record) {
        let encoder = new TextEncoder();
        let typeNameFormat, identifier, payload, type;
        // Identifier
        identifier = record.id;
        // Payload
        payload = new Uint8Array(record.data.byteLength);
        for (let i = 0; i < payload.length; i++) {
            payload[i] = record.data.getUint8(i);
        }
        // Type Name Format
        typeNameFormat = this.WEB_TO_NATIVE_TNF[record.recordType];
        if (typeNameFormat == null && /^(\w+):(\w+)$/.test(record.recordType)) typeNameFormat = 0x03;// External
        if (typeNameFormat == null) throw TypeError("RecordType " + record.recordType + " not supported from nfc_manager_web");
        if (typeNameFormat != 0x02 && record.mediaType != null) throw TypeError("MediaType not allowed for this RecordType");
        // Type
        switch (typeNameFormat) {
            case 0x02: // MIME
                type = record.mediaType;
                break;
          //  case "absolute-uri":
          //      type = payload;
          //      break;
            case 0x03: // External
                if (type == null && /^(\w+):(\w+)$/.test(record.recordType)) type = record.recordType;
                break; 
            default: // Well-Known
                type = this.WEB_TO_NATIVE_TYPE[record.recordType];
        }
        if (type == null) throw TypeError("RecordType " + record.recordType + " not supported from nfc_manager_web");
        type = encoder.encode(type);
        // Encoding TODO:
        if (record.encoding != null && record.encoding != "utf-8") throw TypeError("Encoding " + record.encoding + " not supported from nfc_manager_web");
        // Return as Map
        return {
            typeNameFormat: typeNameFormat,
            type: type, 
            identifier: identifier, 
            payload: payload 
        };
    }

    static getNativefromWebNDEFMessage(records) {
        return { 
            handle: event.serialNumber,
            ndef: {
                //identifier
                //isWritable,
                //maxSize,
                //canMakeReadOnly
                cachedMessage: {
                    records: records
                }
            }
        };
    }

    static getNativeFromWebNDEFError(errMessage) {
        return {
            type: "webNfcError",
            message: errMessage
        }
    }
}

/*
    Script for Web-NFC Support in NFC_Manager Plugin
    For changes to take effect, this file has to be minified and replace flutter_nfc_min.js
*/

var abortController = new AbortController();
var ndef;

async function isNDEFReaderAvailable() {
    try {
        let tempNDEFReader = new NDEFReader();
        let nfcPermissions = await navigator.permissions.query({name:'nfc'});
        return nfcPermissions.state == "granted" || nfcPermissions.state == 'prompt';
    } catch(_) {
        return false;
    }
}

async function startNDEFReaderJS() {
    try {
        ndef = new NDEFReader();
    } catch(error) {
        raiseErrorEvent("Web-NFC is not available");
        return;
    }
    try {
        abortController = new AbortController();
        await ndef.scan({signal: abortController.signal});
        ndef.onreadingerror = (event) => raiseErrorEvent("Error during NFC reading");
        ndef.onreading = event => {
            try {
                let jsNDEFRecords = event.message.records;
                let nativeNDEFRecords = [];
                // Create NDEF Records
                for (recordIdx in jsNDEFRecords) {
                    let nativeNDEFRecord = Translator.getNativefromWebNDEFRecord(jsNDEFRecords[recordIdx]);
                    nativeNDEFRecords.push(nativeNDEFRecord);
                };
                // Create NDEF Message
                let nativeNDEFMessage = Translator.getNativefromWebNDEFMessage(nativeNDEFRecords);
                // Dispatch Event to Dart
                let customEvent = new CustomEvent("readSuccessJS", {detail: nativeNDEFMessage});
                document.dispatchEvent(customEvent);
                return;
            } catch (error) {
                raiseErrorEvent(error.message);
            }
        }
    } catch(error) {
        raiseErrorEvent(error.message);
    }
}

function stopNDEFReaderJS() {
    return abortController.abort();
}

async function startNDEFWriterJS(nativeNDEFRecords) {
    try {
        let webNDEFRecords = [];
        // Create NDEF Records
        for (recordIdx in nativeNDEFRecords) {
            let webNDEFRecord = Translator.getWebfromNativeNDEFRecord(
                nativeNDEFRecords[recordIdx].typeNameFormat,
                nativeNDEFRecords[recordIdx].type,
                nativeNDEFRecords[recordIdx].identifier,
                nativeNDEFRecords[recordIdx].payload
            );
            webNDEFRecords.push(webNDEFRecord);  
        };
        ndef = new NDEFReader();
        await ndef.write({records: webNDEFRecords});
    } catch(error) {
        console.log(error);
        // raiseErrorEvent("writeErrorJS", error);
        // TODO: how to give back error on write
    };
}

function raiseErrorEvent(errMessage) {
    let ndefError = Translator.getNativeFromWebNDEFError(errMessage);
    let customEvent = new CustomEvent("readErrorJS", {detail: ndefError});
    document.dispatchEvent(customEvent, );
}

var NdefRecord = function(typeNameFormat, type, identifier, payload) {
    this.typeNameFormat = typeNameFormat;
    this.type = type;
    this.identifier = identifier;
    this.payload = payload;
};