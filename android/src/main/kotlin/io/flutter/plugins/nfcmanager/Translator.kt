package io.flutter.plugins.nfcmanager

import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.nfc.tech.MifareClassic
import android.nfc.tech.MifareUltralight
import android.nfc.tech.Ndef
import android.nfc.tech.NfcA
import android.nfc.tech.NfcB
import android.nfc.tech.NfcF
import android.nfc.tech.NfcV
import android.os.Build
import androidx.annotation.RequiresApi
import java.util.*

@RequiresApi(Build.VERSION_CODES.KITKAT)
fun getFlags(options: List<String> = listOf()): Int {
  var flags = 0

  if (options.contains("iso14443")) {
    flags = flags or NfcAdapter.FLAG_READER_NFC_A or NfcAdapter.FLAG_READER_NFC_B
  }

  if (options.contains("iso15693")) {
    flags = flags or NfcAdapter.FLAG_READER_NFC_V
  }

  if (options.contains("iso18092")) {
    flags = flags or NfcAdapter.FLAG_READER_NFC_F
  }

  return flags
}

fun getTagMap(arg: Tag): Map<String, Any?> {
  val data = mutableMapOf<String, Any?>()

  arg.techList.forEach { tech ->
    // normalize tech string (e.g. "android.nfc.tech.NfcA" => "nfca"
    data[tech.toLowerCase(Locale.ROOT).split(".").last()] = when (tech) {
      NfcA::class.java.name -> NfcA.get(arg).let {
        mapOf(
          "identifier" to arg.id,
          "atqa" to it.atqa,
          "maxTransceiveLength" to it.maxTransceiveLength,
          "sak" to it.sak,
          "timeout" to it.timeout
        )
      }
      NfcB::class.java.name -> NfcB.get(arg).let {
        mapOf(
          "identifier" to arg.id,
          "applicationData" to it.applicationData,
          "maxTransceiveLength" to it.maxTransceiveLength,
          "protocolInfo" to it.protocolInfo
        )
      }
      NfcF::class.java.name -> NfcF.get(arg).let {
        mapOf(
          "identifier" to arg.id,
          "manufacturer" to it.manufacturer,
          "maxTransceiveLength" to it.maxTransceiveLength,
          "systemCode" to it.systemCode,
          "timeout" to it.timeout
        )
      }
      NfcV::class.java.name -> NfcV.get(arg).let {
        mapOf(
          "identifier" to arg.id,
          "dsfId" to it.dsfId,
          "responseFlags" to it.responseFlags,
          "maxTransceiveLength" to it.maxTransceiveLength
        )
      }
      IsoDep::class.java.name -> IsoDep.get(arg).let {
        mapOf(
          "identifier" to arg.id,
          "hiLayerResponse" to it.hiLayerResponse,
          "historicalBytes" to it.historicalBytes,
          "isExtendedLengthApduSupported" to it.isExtendedLengthApduSupported,
          "maxTransceiveLength" to it.maxTransceiveLength,
          "timeout" to it.timeout
        )
      }
      MifareClassic::class.java.name -> MifareClassic.get(arg).let {
        mapOf(
          "identifier" to arg.id,
          "blockCount" to it.blockCount,
          "maxTransceiveLength" to it.maxTransceiveLength,
          "sectorCount" to it.sectorCount,
          "size" to it.size,
          "timeout" to it.timeout,
          "type" to it.type
        )
      }
      MifareUltralight::class.java.name -> MifareUltralight.get(arg).let {
        mapOf(
          "identifier" to arg.id,
          "maxTransceiveLength" to it.maxTransceiveLength,
          "timeout" to it.timeout,
          "type" to it.type
        )
      }
      Ndef::class.java.name -> Ndef.get(arg).let {
        mapOf(
          "identifier" to arg.id,
          "isWritable" to it.isWritable,
          "maxSize" to it.maxSize,
          "canMakeReadOnly" to it.canMakeReadOnly(),
          "cachedMessage" to if (it.cachedNdefMessage == null) null else getNdefMessageMap(it.cachedNdefMessage),
          "type" to it.type
        )
      }
      // NdefFormatable or NfcBarcode
      else -> mapOf(
        "identifier" to arg.id
      )
    }
  }

  return data
}

fun getNdefMessage(arg: Map<String, Any?>): NdefMessage {
  val records = (arg["records"] as List<*>).filterIsInstance<Map<String, Any?>>()
  return NdefMessage(records.map {
    NdefRecord(
      (it["typeNameFormat"] as Int).toShort(),
      it["type"] as ByteArray,
      it["identifier"] as? ByteArray,
      it["payload"] as ByteArray
    )
  }.toTypedArray())
}

fun getNdefMessageMap(arg: NdefMessage): Map<String, Any?> {
  return mapOf(
    "records" to arg.records.map {
      mapOf(
        "typeNameFormat" to it.tnf,
        "type" to it.type,
        "identifier" to it.id,
        "payload" to it.payload
      )
    }.toList()
  )
}
