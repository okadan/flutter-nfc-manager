package io.flutter.plugins.nfcmanager

import android.app.Activity
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

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.IOException
import java.lang.Exception
import java.lang.NullPointerException
import java.util.*

class NfcManagerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel : MethodChannel
  private lateinit var adapter: NfcAdapter
  private lateinit var activity: Activity
  private lateinit var tags: MutableMap<String, Tag>
  private var connectedTech: TagTechnology? = null

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    const val CHANNEL_NAME = "plugins.flutter.io/nfc_manager"

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val instance = NfcManagerPlugin()
      val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
      instance.channel = channel
      instance.adapter = NfcAdapter.getDefaultAdapter(registrar.context())
      instance.activity = registrar.activity()
      instance.tags = mutableMapOf()
      channel.setMethodCallHandler(NfcManagerPlugin())
    }
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.flutterEngine.dartExecutor, CHANNEL_NAME)
    channel.setMethodCallHandler(this)
    adapter = NfcAdapter.getDefaultAdapter(binding.applicationContext)
    tags = mutableMapOf()
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    // no op
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // no op
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "Nfc#isAvailable" -> handleNfcIsAvailable(call, result)
      "Nfc#startSession" -> handleNfcStartSession(call, result)
      "Nfc#stopSession" -> handleNfcStopSession(call, result)
      "Nfc#disposeTag" -> handleNfcDisposeTag(call, result)
      "Ndef#read" -> handleNdefRead(call, result)
      "Ndef#write" -> handleNdefWrite(call, result)
      "Ndef#writeLock" -> handleNdefWriteLock(call, result)
      "NfcA#transceive" -> handleNfcATransceive(call, result)
      "NfcB#transceive" -> handleNfcBTransceive(call, result)
      "NfcF#transceive" -> handleNfcFTransceive(call, result)
      "NfcV#transceive" -> handleNfcVTransceive(call, result)
      "IsoDep#transceive" -> handleIsoDepTransceive(call, result)
      "MifareClassic#authenticateSectorWithKeyA" -> handleMifareClassicAuthenticateSectorWithKeyA(call, result)
      "MifareClassic#authenticateSectorWithKeyB" -> handleMifareClassicAuthenticateSectorWithKeyB(call, result)
      "MifareClassic#increment" -> handleMifareClassicIncrement(call, result)
      "MifareClassic#decrement" -> handleMifareClassicDecrement(call, result)
      "MifareClassic#readBlock" -> handleMifareClassicReadBlock(call, result)
      "MifareClassic#writeBlock" -> handleMifareClassicWriteBlock(call, result)
      "MifareClassic#restore" -> handleMifareClassicRestore(call, result)
      "MifareClassic#transfer" -> handleMifareClassicTransfer(call, result)
      "MifareClassic#transceive" -> handleMifareClassicTransceive(call, result)
      "MifareUltralight#readPages" -> handleMifareUltralightReadPages(call, result)
      "MifareUltralight#writePage" -> handleMifareUltralightWritePage(call, result)
      "MifareUltralight#transceive" -> handleMifareUltralightTransceive(call, result)
      "NdefFormatable#format" -> handleNdefFormatableFormat(call, result)
      "NdefFormatable#formatReadOnly" -> handleNdefFormatableFormatReadOnly(call, result)
      else -> result.notImplemented()
    }
  }

  private fun handleNfcIsAvailable(call: MethodCall, result: Result) {
    try {
      result.success(adapter.isEnabled)
    } catch (e: NullPointerException) {
      result.success(false)
    }
  }

  private fun handleNfcStartSession(call: MethodCall, result: Result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
      result.error("unavailable", "Requires API level 19.", null)
    } else {
      adapter.enableReaderMode(activity, {
        val handle = UUID.randomUUID().toString()
        tags[handle] = it
        activity.runOnUiThread { channel.invokeMethod("onDiscovered", getTagMap(it).toMutableMap().apply { put("handle", handle) }) }
      }, getFlags(call.argument<List<String>>("pollingOptions")!!), null)
      result.success(null)
    }
  }

  private fun handleNfcStopSession(call: MethodCall, result: Result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
      result.error("unavailable", "Requires API level 19.", null)
    } else {
      adapter.disableReaderMode(activity)
      result.success(null)
    }
  }

  private fun handleNfcDisposeTag(call: MethodCall, result: Result) {
    val tag = tags.remove(call.argument<String>("handle")!!) ?: run {
      result.success(null)
      return
    }

    val tech = connectedTech ?: run {
      result.success(null)
      return
    }

    if (tech.tag == tag && tech.isConnected)
      try { tech.close() } catch (e: IOException) { /* no op */ }

    connectedTech = null

    result.success(null)
  }

  private fun handleNdefRead(call: MethodCall, result: Result) {
    tagHandler(call, result, { Ndef.get(it) }) {
      val message = it.ndefMessage
      result.success(if (message == null) null else getNdefMessageMap(message))
    }
  }

  private fun handleNdefWrite(call: MethodCall, result: Result) {
    tagHandler(call, result, { Ndef.get(it) }) {
      val message = getNdefMessage(call.argument<Map<String, Any?>>("message")!!)
      it.writeNdefMessage(message)
      result.success(null)
    }
  }

  private fun handleNdefWriteLock(call: MethodCall, result: Result) {
    tagHandler(call, result, { Ndef.get(it) }) {
      it.makeReadOnly()
      result.success(null)
    }
  }

  private fun handleNfcATransceive(call: MethodCall, result: Result) {
    tagHandler(call, result, { NfcA.get(it) }) {
      val data = call.argument<ByteArray>("data")!!
      result.success(it.transceive(data))
    }
  }

  private fun handleNfcBTransceive(call: MethodCall, result: Result) {
    tagHandler(call, result, { NfcB.get(it) }) {
      val data = call.argument<ByteArray>("data")!!
      result.success(it.transceive(data))
    }
  }

  private fun handleNfcFTransceive(call: MethodCall, result: Result) {
    tagHandler(call, result, { NfcF.get(it) }) {
      val data = call.argument<ByteArray>("data")!!
      result.success(it.transceive(data))
    }
  }

  private fun handleNfcVTransceive(call: MethodCall, result: Result) {
    tagHandler(call, result, { NfcV.get(it) }) {
      val data = call.argument<ByteArray>("data")!!
      result.success(it.transceive(data))
    }
  }

  private fun handleIsoDepTransceive(call: MethodCall, result: Result) {
    tagHandler(call, result, { IsoDep.get(it) }) {
      val data = call.argument<ByteArray>("data")!!
      result.success(it.transceive(data))
    }
  }

  private fun handleMifareClassicAuthenticateSectorWithKeyA(call: MethodCall, result: Result) {
    tagHandler(call, result, { MifareClassic.get(it) }) {
      val sectorIndex = call.argument<Int>("sectorIndex")!!
      val key = call.argument<ByteArray>("key")!!
      result.success(it.authenticateSectorWithKeyA(sectorIndex, key))
    }
  }

  private fun handleMifareClassicAuthenticateSectorWithKeyB(call: MethodCall, result: Result) {
    tagHandler(call, result, { MifareClassic.get(it) }) {
      val sectorIndex = call.argument<Int>("sectorIndex")!!
      val key = call.argument<ByteArray>("key")!!
      result.success(it.authenticateSectorWithKeyB(sectorIndex, key))
    }
  }

  private fun handleMifareClassicIncrement(call: MethodCall, result: Result) {
    tagHandler(call, result, { MifareClassic.get(it) }) {
      val blockIndex = call.argument<Int>("blockIndex")!!
      val value = call.argument<Int>("value")!!
      it.increment(blockIndex, value)
      result.success(null)
    }
  }

  private fun handleMifareClassicDecrement(call: MethodCall, result: Result) {
    tagHandler(call, result, { MifareClassic.get(it) }) {
      val blockIndex = call.argument<Int>("blockIndex")!!
      val value = call.argument<Int>("value")!!
      it.decrement(blockIndex, value)
      result.success(null)
    }
  }

  private fun handleMifareClassicReadBlock(call: MethodCall, result: Result) {
    tagHandler(call, result, { MifareClassic.get(it) }) {
      val blockIndex = call.argument<Int>("blockIndex")!!
      result.success(it.readBlock(blockIndex))
    }
  }

  private fun handleMifareClassicWriteBlock(call: MethodCall, result: Result) {
    tagHandler(call, result, { MifareClassic.get(it) }) {
      val blockIndex = call.argument<Int>("blockIndex")!!
      val data = call.argument<ByteArray>("data")!!
      it.writeBlock(blockIndex, data)
      result.success(null)
    }
  }

  private fun handleMifareClassicRestore(call: MethodCall, result: Result) {
    tagHandler(call, result, { MifareClassic.get(it) }) {
      val blockIndex = call.argument<Int>("blockIndex")!!
      it.restore(blockIndex)
      result.success(null)
    }
  }

  private fun handleMifareClassicTransfer(call: MethodCall, result: Result) {
    tagHandler(call, result, { MifareClassic.get(it) }) {
      val blockIndex = call.argument<Int>("blockIndex")!!
      it.transfer(blockIndex)
      result.success(null)
    }
  }

  private fun handleMifareClassicTransceive(call: MethodCall, result: Result) {
    tagHandler(call, result, { MifareClassic.get(it) }) {
      val data = call.argument<ByteArray>("data")!!
      result.success(it.transceive(data))
    }
  }

  private fun handleMifareUltralightReadPages(call: MethodCall, result: Result) {
    tagHandler(call, result, { MifareUltralight.get(it) }) {
      val pageOffset = call.argument<Int>("pageOffset")!!
      result.success(it.readPages(pageOffset))
    }
  }

  private fun handleMifareUltralightWritePage(call: MethodCall, result: Result) {
    tagHandler(call, result, { MifareUltralight.get(it) }) {
      val pageOffset = call.argument<Int>("pageOffset")!!
      val data = call.argument<ByteArray>("data")!!
      it.writePage(pageOffset, data)
      result.success(null)
    }
  }

  private fun handleMifareUltralightTransceive(call: MethodCall, result: Result) {
    tagHandler(call, result, { MifareUltralight.get(it) }) {
      val data = call.argument<ByteArray>("data")!!
      result.success(it.transceive(data))
    }
  }

  private fun handleNdefFormatableFormat(call: MethodCall, result: Result) {
    tagHandler(call, result, { NdefFormatable.get(it) }) {
      val firstMessage = getNdefMessage(call.argument<Map<String, Any?>>("firstMessage")!!)
      it.format(firstMessage)
      result.success(null)
    }
  }

  private fun handleNdefFormatableFormatReadOnly(call: MethodCall, result: Result) {
    tagHandler(call, result, { NdefFormatable.get(it) }) {
      val firstMessage = getNdefMessage(call.argument<Map<String, Any?>>("firstMessage")!!)
      it.formatReadOnly(firstMessage)
      result.success(null)
    }
  }

  private fun <T: TagTechnology> tagHandler(call: MethodCall, result: Result, getMethod: (Tag) -> T?, callback: (T) -> Unit) {
    val tag = tags[call.argument<String>("handle")!!] ?: run {
      result.error("invalid_parameter", "Tag is not found", null)
      return
    }

    val tech = getMethod(tag) ?: run {
      result.error("invalid_parameter", "Tech is not supported" , null)
      return
    }

    try {
      forceConnect(tech)
      callback(tech)
    } catch (e: Exception) {
      result.error("io_exception", e.localizedMessage, null)
    }
  }

  @Throws(IOException::class)
  private fun forceConnect(tech: TagTechnology) {
    connectedTech?.let {
      if (it.tag == tech.tag && it::class.java.name == tech::class.java.name) return
      try { tech.close() } catch (e: IOException) { /* no op */ }
      tech.connect()
      connectedTech = tech
    } ?: run {
      tech.connect()
      connectedTech = tech
    }
  }
}
