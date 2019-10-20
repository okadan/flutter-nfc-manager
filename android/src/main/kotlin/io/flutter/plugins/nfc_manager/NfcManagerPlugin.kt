package io.flutter.plugins.nfc_manager

import android.annotation.TargetApi
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
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.IOException
import java.util.*

class NfcManagerPlugin(private val registrar: Registrar, private val channel: MethodChannel): MethodCallHandler {
    private val adapter = NfcAdapter.getDefaultAdapter(registrar.context())
    private val cachedTags = mutableMapOf<String, Tag>()
    private var connectedTech: TagTechnology? = null

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "plugins.flutter.io/nfc_manager")
            channel.setMethodCallHandler(NfcManagerPlugin(registrar, channel))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        println("=== ${call.method} ===")
        when (call.method) {
            "isAvailable" -> handleIsAvailable(result)
            "startNdefSession" -> handleStartNdefSession(result)
            "startTagSession" -> handleStartTagSession(result, call)
            "stopSession" -> handleStopSession(result)
            "writeNdef" -> handleWriteNdef(result, call)
            "writeLock" -> handleWriteLock(result, call)
            "dispose" -> handleDispose(result, call)
            else -> result.notImplemented()
        }
    }

    private fun handleIsAvailable(result: Result) {
        result.success(adapter != null && adapter.isEnabled)
    }

    private fun handleStartNdefSession(result: Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            result.error("", "Requires API level KITKAT", null)
        } else {
            adapter.enableReaderMode(
                registrar.activity(), {
                if (!it.techList.contains(Ndef::class.java.name)) { return@enableReaderMode }
                val key = UUID.randomUUID().toString()
                cachedTags[key] = it
                registrar.activity().runOnUiThread { channel.invokeMethod("onNdefDiscovered", serializeTag(key, it)) }
            }, getFlags(), null)
        }
    }

    private fun handleStartTagSession(result: Result, call: MethodCall) {
        val options = call.argument<List<Int>>("pollingOptions")!!

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            result.error("", "Requires API level KITKAT", null)
        } else {
            adapter.enableReaderMode(registrar.activity(), {
                val key = UUID.randomUUID().toString()
                cachedTags[key] = it
                registrar.activity().runOnUiThread { channel.invokeMethod("onTagDiscovered", serializeTag(key, it)) }
            }, getFlags(options), null)
            result.success(true)
        }
    }

    private fun handleStopSession(result: Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            result.error("", "Requires API level KITKAT", null)
        } else {
            adapter.disableReaderMode(registrar.activity())
            result.success(true)
        }
    }

    private fun handleWriteNdef(result: Result, call: MethodCall) {
        val key = call.argument<String>("key")!!
        val message = deserializeNdefMessage(call.argument<Map<String, Any?>>("message")!!)

        val tag = cachedTags[key] ?: run {
            result.error("", "Tag is not found", null)
            return
        }

        val tech = Ndef.get(tag) ?: run {
            result.error("", "Tag is not ndef", null)
            return
        }

        try {
            forceConnect(tech)
            tech.writeNdefMessage(message)
            result.success(true)
        } catch (e: IOException) {
            result.error("", e.localizedMessage, null)
        }
    }

    private fun handleWriteLock(result: Result, call: MethodCall) {
        val key = call.argument<String>("key")!!

        val tag = cachedTags[key] ?: run {
            result.error("", "Tag is not found", null)
            return
        }

        val tech = Ndef.get(tag) ?: run {
            result.error("", "Tag is not ndef", null)
            return
        }

        try {
            forceConnect(tech)
            tech.makeReadOnly()
            result.success(true)
        } catch (e: IOException) {
            result.error("", e.localizedMessage, null)
        }
    }

    private fun handleDispose(result: Result, call: MethodCall) {
        val key = call.argument<String>("key")!!

        val tag = cachedTags.remove(key) ?: run {
            result.success(true)
            return
        }

        connectedTech?.let {
            if (it.tag == tag && it.isConnected) {
                try { it.close() } catch (e: IOException) { /* Do nothing */ }
                connectedTech = null
            }
        }

        result.success(true)
    }

    // Sync with `NfcTagPollingOption` enum on Dart side.
    @TargetApi(Build.VERSION_CODES.KITKAT)
    private fun getFlags(options: List<Int> = listOf(0, 1, 2)): Int {
        var flag = 0

        // iso14443
        if (options.contains(0)) {
            flag = flag or NfcAdapter.FLAG_READER_NFC_A or NfcAdapter.FLAG_READER_NFC_B
        }

        // iso15693
        if (options.contains(1)) {
            flag = flag or NfcAdapter.FLAG_READER_NFC_V
        }

        // iso18092
        if (options.contains(2)) {
            flag = flag or NfcAdapter.FLAG_READER_NFC_F
        }

        return flag
    }

    private fun getTechFromTag(tag: Tag, tech: String): TagTechnology? {
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

    @Throws(IOException::class)
    private fun forceConnect(tech: TagTechnology) {
        connectedTech?.let {
            if (it.tag == tech.tag && it::class.java.name == tech::class.java.name) return
            try { it.close() } catch (e: IOException) { /* Do nothing */ }
            tech.connect()
            connectedTech = tech
        } ?: run {
            tech.connect()
            connectedTech = tech
        }
    }

    private fun deserializeNdefMessage(data: Map<String, Any?>): NdefMessage {
        val records = (data["records"] as List<*>).filterIsInstance<Map<String, Any?>>()
        return NdefMessage(records.map { deserializeNdefRecord(it) }.toTypedArray())
    }

    private fun deserializeNdefRecord(data: Map<String, Any?>): NdefRecord {
        return NdefRecord(
            (data["typeNameFormat"] as Int).toShort(),
            data["type"] as ByteArray,
            data["identifier"] as? ByteArray,
            data["payload"] as ByteArray
        )
    }

    private fun serializeTag(key: String, tag: Tag): Map<String, Any?> {
        val data = mutableMapOf<String, Any?>(
            "key" to key,
            "id" to tag.id
        )
        tag.techList.forEach {
            // tech key will be normalized (e.g. android.nfc.tech.NfcA => nfca)
            data[it.toLowerCase(Locale.ROOT).split(".").last()] = serializeTech(getTechFromTag(tag, it)!!)
        }
        return data
    }

    private fun serializeNdefMessage(message: NdefMessage): Map<String, Any?> {
        return mapOf(
            "records" to message.records.map { serializeNdefRecord(it) }.toList()
        )
    }

    private fun serializeNdefRecord(record: NdefRecord): Map<String, Any?> {
        return mapOf(
            "typeNameFormat" to record.tnf,
            "type" to record.type,
            "identifier" to record.id,
            "payload" to record.payload
        )
    }

    private fun serializeTech(tech: TagTechnology): Map<String, Any?> {
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
                "cachedMessage" to if (tech.cachedNdefMessage == null) null else serializeNdefMessage(tech.cachedNdefMessage),
                "canMakeReadOnly" to tech.canMakeReadOnly(),
                "isWritable" to tech.isWritable,
                "maxSize" to tech.maxSize,
                "type" to tech.type
            )
            is NdefFormatable -> mapOf()
            else -> mapOf()
        }
    }
}
