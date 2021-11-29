let abortController = new AbortController();

async function startNDEFReaderJS() {
    try {
        const ndef = new NDEFReader();
        await ndef.scan({signal: abortController.signal});
        ndef.onreadingerror = (event) => raiseErrorEvent("readErrorJS", event);
        ndef.onreading = event => {
            let jsRecords = [];
            let encoder = new TextEncoder(); 

            event.message.records.forEach(function(record) {
                // only allow utf-8 encoding
                if (record.encoding != null && record.encoding != "utf-8") return;
                var payloadEncoded = new Uint8Array(record.data.byteLength)
                for (var i = 0; i < payloadEncoded.length; i++) {
                    payloadEncoded[i] = record.data.getUint8(i);
                }
                jsRecords.push({
                    typeNameFormat: 0x03, // ?
                    type: encoder.encode(record.recordType), 
                    identifier: '', // ?
                    payload: payloadEncoded 
                });
            });
            let recordsJS = { 
                handle: event.serialNumber,
                ndef: {
                  isWritable: true,
                  maxSize: 0,
                  cachedMessage: {
                    records: jsRecords
                  }
                }
            };

            // dispatch event to dart
            var customEvent = new CustomEvent("readSuccessJS", {detail: recordsJS});
            document.dispatchEvent(customEvent);
            return;
        };
    } catch(error) {
        raiseErrorEvent("readErrorJS", error.message);
    }
}

function stopNDEFReaderJS() {
    return abortController.abort();
}

async function startNDEFWriterJS(records) {
    try {
        const ndef = new NDEFReader();
        // TODO: first stop the reader, then write ??
        const ndefRecords = [];
        records.forEach(function(record) {
            var ndefObject = JSON.parse(record);
            ndefObject = Object.entries(ndefObject).reduce((a,[k,v]) => (v ? (a[k]=v, a) : a), {})
            ndefRecords.push(ndefObject);
        });
        await ndef.write({records: ndefRecords});
        var customEvent = new CustomEvent("writeSuccessJS");
        document.dispatchEvent(customEvent);
    } catch(error) {
        console.log(error);
        raiseErrorEvent("writeErrorJS", error);
    };
}

function raiseErrorEvent(errEvent, errMessage) {
    var customEvent = new CustomEvent(errEvent);
    document.dispatchEvent(customEvent, {detail: errMessage});
    return;
}

function removeNullProperties(obj) {
    Object.keys(obj).forEach(key => {
      let value = obj[key];
      let hasProperties = value && Object.keys(value).length > 0;
      if (value === null) {
        delete obj[key];
      }
      else if ((typeof value !== "string") && hasProperties) {
        removeNullProperties(value);
      }
    });
    return obj;
  }

class JsNdefRecord {
    constructor({data, encoding, id, lang, mediaType, recordType}) {
        this.data = data;
        this.encoding = encoding;
        this.id = id;
        this.lang = lang;
        this.mediaType = mediaType;
        this.recordType = recordType;
    }
    
    toJSON() {
        return {
            "data": this.data,
            "encoding": this.encoding,
            "id": this.id,
            "lang": this.lang,
            "mediaType": this.mediaType,
            "recordType": this.recordType
        };
    }
}