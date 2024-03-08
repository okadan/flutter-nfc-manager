package io.flutter.plugins.nfcmanager

import android.app.Activity
import androidx.lifecycle.*
import android.content.Intent
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
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import java.io.IOException
import java.lang.Exception
import java.util.*

class NfcManagerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, LifecycleObserver {
  private lateinit var channel : MethodChannel
  private lateinit var activity: Activity
  private lateinit var tags: MutableMap<String, Tag>
  private lateinit var lifecycle: Lifecycle

  private var tagFromIntent: Tag? = null
  private var sinkTagDiscoveredEvents = ArrayList<EventSink>()

  private var adapter: NfcAdapter? = null
  private var connectedTech: TagTechnology? = null

  private lateinit var enableActivityReaderMode : () -> Unit
  private lateinit var disableActivityReaderMode : () -> Unit

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    val baseChannelName = "plugins.flutter.io/nfc_manager"
    
    channel = MethodChannel(binding.binaryMessenger, baseChannelName)
    channel.setMethodCallHandler(this)

    EventChannel(binding.binaryMessenger,
      baseChannelName + "/stream").setStreamHandler(
         object : StreamHandler {
            private lateinit var currentEvents : EventSink

            override fun onListen(arguments: Any?, events: EventSink) {
              if (sinkTagDiscoveredEvents.isEmpty()) {
                enableActivityReaderMode = {
                  if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
                    events.error("unavailable", "Requires API level 19.", null)
                  } else {
                    val adapter = adapter
                    
                    if (adapter != null) {
                      var argMaps = arguments as HashMap<String,Any?>
                      adapter.enableReaderMode(activity, NfcAdapter.ReaderCallback {
                        activity.runOnUiThread { broadcastPreparedTag(it) }
                      }, getFlags(argMaps["pollingOptions"] as List<String>), null)
                    } else {
                      events.error("unavailable", "NFC is not available for device.", null)
                    }
                  }
                }

                disableActivityReaderMode = {
                  if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
                    events.error("unavailable", "Requires API level 19.", null)
                  } else {
                    adapter?.disableReaderMode(activity)
                  }
                }

                enableActivityReaderMode()
              }

              currentEvents = events
              sinkTagDiscoveredEvents.add(currentEvents)

              tagFromIntent?.let {
                currentEvents.success(prepareTag(it))
                tagFromIntent = null
              }              
            }

            override fun onCancel(arguments: Any?) {
              sinkTagDiscoveredEvents.remove(currentEvents)

              if (sinkTagDiscoveredEvents.isEmpty()) {
                disableActivityReaderMode()
              }
            }
         }
      )

    adapter = NfcAdapter.getDefaultAdapter(binding.applicationContext)
    tags = mutableMapOf()
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    initBinding(binding)
    processIntent(activity.intent)
  }

  override fun onDetachedFromActivity() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    initBinding(binding)
    autoEnableReaderMode()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // autoDisableReaderMode()
    // lifecycle.removeObserver(this)
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
  private fun autoEnableReaderMode() {
    // For some device (OnePlus for example),
    // the readerMode is not reenabled after paused
    if (sinkTagDiscoveredEvents.isNotEmpty()) {
      enableActivityReaderMode()
    }
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
  private fun autoDisableReaderMode() {
    if (sinkTagDiscoveredEvents.isNotEmpty()) {
      disableActivityReaderMode()
    }
  }

  private fun initBinding(binding: ActivityPluginBinding) {
    activity = binding.activity
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)

    lifecycle.addObserver(this)

    binding.addOnNewIntentListener(fun(intent: Intent?): Boolean {
        var tagProcessed = false

        if (intent != null) {
          val tag = processIntent(intent)
        

          if (tag != null) {
            broadcastPreparedTag(tag)
            tagProcessed = true
          }
        }

        return tagProcessed
    }) 
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
    result.success(adapter?.isEnabled == true)
  }

  private fun handleNfcStartSession(call: MethodCall, result: Result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
      result.error("unavailable", "Requires API level 19.", null)
    } else {
      val adapter = adapter ?: run {
        result.error("unavailable", "NFC is not available for device.", null)
        return
      }
      
      adapter.enableReaderMode(activity, NfcAdapter.ReaderCallback {
        activity.runOnUiThread { channel.invokeMethod("onDiscovered", prepareTag(it)) }
      }, getFlags(call.argument<List<String>>("pollingOptions")!!), null)

      result.success(null)
    }
  }

  private fun handleNfcStopSession(call: MethodCall, result: Result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
      result.error("unavailable", "Requires API level 19.", null)
    } else {
      val adapter = adapter ?: run {
        result.error("unavailable", "NFC is not available for device.", null)
        return
      }
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

  private fun processIntent(intent: Intent) : Tag? {
    tagFromIntent = intent?.getParcelableExtra(NfcAdapter.EXTRA_TAG)

    return tagFromIntent
  }

  private fun broadcastPreparedTag(tag: Tag) {
    sinkTagDiscoveredEvents.forEach {
      val preparedTag = prepareTag(tag)
      it.success(preparedTag)
    }
  }

  private fun prepareTag(tag: Tag): MutableMap<String, Any?> {
    val handle = UUID.randomUUID().toString()
    tags[handle] = tag

    return getTagMap(tag).toMutableMap().apply { put("handle", handle) }
  } 
}
