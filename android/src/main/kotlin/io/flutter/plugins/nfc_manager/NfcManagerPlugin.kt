package io.flutter.plugins.nfc_manager

import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.nfc.tech.Ndef
import android.nfc.tech.NfcA
import android.nfc.tech.NfcB
import android.nfc.tech.NfcF
import android.nfc.tech.NfcV
import android.nfc.tech.TagTechnology
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.IOException
import java.lang.reflect.InvocationTargetException
import java.util.*
import kotlin.concurrent.thread

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

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        // Send results via the main thread
        val _result = MethodResultWrapper(result)

        when (call.method) {
            "isAvailable" -> handleIsAvailable(call, _result)
            "startNdefSession" -> handleStartNdefSession(call, _result)
            "startTagSession" -> handleStartTagSession(call, _result)
            "stopSession" -> handleStopSession(call, _result)
            "disposeTag" -> handleDisposeTag(call, _result)
            "Ndef#write" -> handleNdefWrite(call, _result)
            "Ndef#writeLock" -> handleNdefWriteLock(call, _result)
            "NfcA#transceive" -> handleTransceive(NfcA::class.java, call, _result)
            "NfcB#transceive" -> handleTransceive(NfcB::class.java, call, _result)
            "NfcF#transceive" -> handleTransceive(NfcF::class.java, call, _result)
            "NfcV#transceive" -> handleTransceive(NfcV::class.java, call, _result)
            "IsoDep#transceive" -> handleTransceive(IsoDep::class.java, call, _result)
            else -> _result.notImplemented()
        }
    }

    private fun handleIsAvailable(@NonNull call: MethodCall, @NonNull result: Result) {
        result.success(adapter != null && adapter.isEnabled)
    }

    private fun handleStartNdefSession(@NonNull call: MethodCall, @NonNull result: Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            result.error("unavailable", "Requires API level 19.", null)
        } else {
            adapter.enableReaderMode(
                registrar.activity(), {
                if (!it.techList.contains(Ndef::class.java.name)) { return@enableReaderMode }
                val handle = UUID.randomUUID().toString()
                cachedTags[handle] = it
                registrar.activity().runOnUiThread { channel.invokeMethod("onNdefDiscovered", serialize(it).toMutableMap().apply { put("handle", handle) }) }
            }, flagsFrom(), null)
        }
    }

    private fun handleStartTagSession(@NonNull call: MethodCall, @NonNull result: Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            result.error("unavailable", "Requires API level 19.", null)
        } else {
            adapter.enableReaderMode(registrar.activity(), {
                val handle = UUID.randomUUID().toString()
                cachedTags[handle] = it
                registrar.activity().runOnUiThread { channel.invokeMethod("onTagDiscovered", serialize(it).toMutableMap().apply { put("handle", handle) }) }
            }, flagsFrom(call.argument<List<Int>>("pollingOptions")!!), null)
            result.success(true)
        }
    }

    private fun handleStopSession(@NonNull call: MethodCall, @NonNull result: Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            result.error("unavailable", "Requires API level 19.", null)
        } else {
            adapter.disableReaderMode(registrar.activity())
            result.success(true)
        }
    }

    private fun handleDisposeTag(@NonNull call: MethodCall, @NonNull result: Result) {
        val handle = call.argument<String>("handle")!!

        val tag = cachedTags.remove(handle) ?: run {
            result.success(true)
            return
        }

        thread {
            connectedTech?.let { tech ->
                if (tech.tag == tag && tech.isConnected) {
                    try { tech.close() } catch (e: IOException) { /* Do nothing */ }
                }
                connectedTech = null
            }

            result.success(true)
        }
    }

    private fun handleNdefWrite(@NonNull call: MethodCall, @NonNull result: Result) {
        val handle = call.argument<String>("handle")!!
        val message = call.argument<Map<String, Any?>>("message")!!

        val tag = cachedTags[handle] ?: run {
            result.error("not_found", "Tag is not found.", null)
            return
        }

        val tech = Ndef.get(tag) ?: run {
            result.error("tech_unsupported", "Tag does not support Ndef.", null)
            return
        }

        thread {
            try {
                forceConnect(tech)
                tech.writeNdefMessage(ndefMessageFrom(message))
                result.success(true)
            } catch (e: IOException) {
                result.error("io_exception", e.localizedMessage, null)
            }
        }
    }

    private fun handleNdefWriteLock(@NonNull call: MethodCall, @NonNull result: Result) {
        val handle = call.argument<String>("handle")!!

        val tag = cachedTags[handle] ?: run {
            result.error("not_found", "Tag is not found.", null)
            return
        }

        val tech = Ndef.get(tag) ?: run {
            result.error("tech_unsupported", "Tag does not support Ndef.", null)
            return
        }

        thread {
            try {
                forceConnect(tech)
                tech.makeReadOnly()
                result.success(true)
            } catch (e: IOException) {
                result.error("io_exception", e.localizedMessage, null)
            }
        }
    }

    private fun handleTransceive(techClass: Class<out TagTechnology>, @NonNull call: MethodCall, @NonNull result: Result) {
        val handle = call.argument<String>("handle")!!
        val data = call.argument<ByteArray>("data")!!

        val tag = cachedTags[handle] ?: run {
            result.error("not_found", "Tag is not found.", null)
            return
        }

        val tech = techFrom(tag, techClass.name) ?: run {
            result.error("tech_unsupported", "Tag does not support ${techClass.name}.", null)
            return
        }

        thread {
            try {
                val transceiveMethod = techClass.getMethod("transceive", ByteArray::class.java)
                forceConnect(tech)
                result.success(transceiveMethod.invoke(tech, data))
            } catch (e: IOException) {
                result.error("io_exception", e.localizedMessage, null)
            } catch (e: IllegalAccessException) {
                result.error("illegal_access_exception", e.localizedMessage, null)
            } catch (e: InvocationTargetException) {
                result.error("invocation_target_exception", e.localizedMessage, null)
            }
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

    private class MethodResultWrapper internal constructor(private val methodResult: Result) : Result {
        private val handler: Handler = Handler(Looper.getMainLooper())

        override fun success(result: Any?) {
            handler.post { methodResult.success(result) }
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            handler.post { methodResult.error(errorCode, errorMessage, errorDetails) }
        }

        override fun notImplemented() {
            handler.post { methodResult.notImplemented() }
        }
    }
}
