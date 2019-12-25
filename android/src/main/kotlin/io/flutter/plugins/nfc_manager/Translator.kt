package io.flutter.plugins.nfc_manager

import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.nfc.tech.MifareClassic
import android.nfc.tech.MifareUltralight
import android.nfc.tech.Ndef
import android.nfc.tech.NdefFormatable
import android.nfc.tech.NfcA
import android.nfc.tech.NfcB
import android.nfc.tech.NfcF
import android.nfc.tech.NfcV
import android.nfc.tech.TagTechnology
import android.os.Build
import androidx.annotation.RequiresApi
import java.util.*

fun serialize(tag: Tag): Map<String, Any?> {
    val data = mutableMapOf<String, Any?>(
        "id" to tag.id
    )
    tag.techList.forEach { tech ->
        // normalize tech string (e.g. "android.nfc.tech.NfcA" => "nfca"
        data[tech.toLowerCase(Locale.ROOT).split(".").last()] = serialize(techFrom(tag, tech)!!)
    }
    return data
}

fun serialize(tech: TagTechnology): Map<String, Any?> {
    return when (tech) {
        is NfcA -> mapOf(
            "atqa" to tech.atqa,
            "maxTransceiveLength" to tech.maxTransceiveLength,
            "sak" to tech.sak,
            "timeout" to tech.timeout
        )
        is NfcB -> mapOf(
            "applicationData" to tech.applicationData,
            "maxTransceiveLength" to tech.maxTransceiveLength,
            "protocolInfo" to tech.protocolInfo
        )
        is NfcF -> mapOf(
            "manufacturer" to tech.manufacturer,
            "maxTransceiveLength" to tech.maxTransceiveLength,
            "systemCode" to tech.systemCode,
            "timeout" to tech.timeout
        )
        is NfcV -> mapOf(
            "dsfId" to tech.dsfId,
            "responseFlags" to tech.responseFlags,
            "maxTransceiveLength" to tech.maxTransceiveLength
        )
        is IsoDep -> mapOf(
            "hiLayerResponse" to tech.hiLayerResponse,
            "historicalBytes" to tech.historicalBytes,
            "isExtendedLengthApduSupported" to tech.isExtendedLengthApduSupported,
            "maxTransceiveLength" to tech.maxTransceiveLength,
            "timeout" to tech.timeout
        )
        is MifareClassic -> mapOf(
            "blockCount" to tech.blockCount,
            "maxTransceiveLength" to tech.maxTransceiveLength,
            "sectorCount" to tech.sectorCount,
            "size" to tech.size,
            "timeout" to tech.timeout,
            "type" to tech.type
        )
        is MifareUltralight -> mapOf(
            "maxTransceiveLength" to tech.maxTransceiveLength,
            "timeout" to tech.timeout,
            "type" to tech.type
        )
        is Ndef -> mapOf(
            "cachedMessage" to if (tech.cachedNdefMessage == null) null else serialize(tech.cachedNdefMessage),
            "canMakeReadOnly" to tech.canMakeReadOnly(),
            "isWritable" to tech.isWritable,
            "maxSize" to tech.maxSize,
            "type" to tech.type
        )
        is NdefFormatable -> mapOf()
        else -> mapOf()
    }
}

fun serialize(ndefMessage: NdefMessage): Map<String, Any?> {
    return mapOf(
        "records" to ndefMessage.records.map { record -> serialize(record) }.toList()
    )
}

fun serialize(ndefRecord: NdefRecord): Map<String, Any?> {
    return mapOf(
        "typeNameFormat" to ndefRecord.tnf,
        "type" to ndefRecord.type,
        "identifier" to ndefRecord.id,
        "payload" to ndefRecord.payload
    )
}

fun ndefMessageFrom(data: Map<String, Any?>): NdefMessage {
    val records = (data["records"] as List<*>).filterIsInstance<Map<String, Any?>>()
    return NdefMessage(records.map { data -> ndefRecordFrom(data) }.toTypedArray())
}

fun ndefRecordFrom(data: Map<String, Any?>): NdefRecord {
    return NdefRecord(
        (data["typeNameFormat"] as Int).toShort(),
        data["type"] as ByteArray,
        data["identifier"] as? ByteArray,
        data["payload"] as ByteArray
    )
}

fun techFrom(tag: Tag, tech: String): TagTechnology? {
    return when (tech) {
        NfcA::class.java.name -> NfcA.get(tag)
        NfcB::class.java.name -> NfcB.get(tag)
        NfcF::class.java.name -> NfcF.get(tag)
        NfcV::class.java.name -> NfcV.get(tag)
        IsoDep::class.java.name -> IsoDep.get(tag)
        MifareClassic::class.java.name -> MifareClassic.get(tag)
        MifareUltralight::class.java.name -> MifareUltralight.get(tag)
        Ndef::class.java.name -> Ndef.get(tag)
        NdefFormatable::class.java.name -> NdefFormatable.get(tag)
        else -> null
    }
}

// Sync with `TagPollingOption` enum on Dart side.
@RequiresApi(Build.VERSION_CODES.KITKAT)
fun flagsFrom(options: List<Int> = listOf(0, 1, 2)): Int {
    var flags = 0

    // iso14443
    if (options.contains(0)) {
        flags = flags or NfcAdapter.FLAG_READER_NFC_A or NfcAdapter.FLAG_READER_NFC_B
    }

    // iso15693
    if (options.contains(1)) {
        flags = flags or NfcAdapter.FLAG_READER_NFC_V
    }

    // iso18092
    if (options.contains(2)) {
        flags = flags or NfcAdapter.FLAG_READER_NFC_F
    }

    return flags
}
