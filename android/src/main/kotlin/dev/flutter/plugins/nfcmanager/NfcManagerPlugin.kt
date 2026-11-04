package dev.flutter.plugins.nfcmanager

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Context.RECEIVER_NOT_EXPORTED
import android.content.Intent
import android.content.IntentFilter
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
import android.nfc.tech.NfcBarcode
import android.nfc.tech.NfcF
import android.nfc.tech.NfcV
import android.nfc.tech.TagTechnology
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import java.util.*
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

private const val MAX_CACHED_TAGS = 16

class NfcManagerPlugin: FlutterPlugin, ActivityAware, HostApiPigeon, BroadcastReceiver() {
  private lateinit var flutterApi: FlutterApiPigeon
  private lateinit var applicationContext: Context
  private var adapter: NfcAdapter? = null
  //  Written by the binder thread that discovers tags, read and cleared from Dart calls, hence
  //  synchronized. Bounded: reader mode can now stay on for a whole session (screens hand NFC over
  //  without disabling it, so disable no longer clears this), and only the latest tags are still
  //  in the field to be read.
  private val cachedTags: MutableMap<String, Tag> = Collections.synchronizedMap(
    object : LinkedHashMap<String, Tag>() {
      override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, Tag>?) = size > MAX_CACHED_TAGS
    }
  )
  private var connectedTech: TagTechnology? = null
  private var receiverRegistered = false
  private val mainHandler = Handler(Looper.getMainLooper())

  //  Reader mode is switched on a background thread: the binder calls to the NFC service can block
  //  for seconds on some devices, and on the UI thread that is an ANR (see ReaderModeController).
  private val readerModeExecutor: ExecutorService = Executors.newSingleThreadExecutor { Thread(it, "nfc-reader-mode") }
  private val readerMode = ReaderModeController(readerModeExecutor, object : ReaderModeController.Backend<Activity> {
    override fun enable(activity: Activity, flags: Int) {
      getAdapter().enableReaderMode(activity, { onTagDiscovered(it) }, flags, null)
    }
    override fun disable(activity: Activity) {
      getAdapter().disableReaderMode(activity)
    }
    override fun onError(action: String, error: Throwable) {
      Log.w("NfcManagerPlugin", "Reader mode $action failed", error)
    }
  })

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    HostApiPigeon.setUp(flutterPluginBinding.binaryMessenger, this)
    flutterApi = FlutterApiPigeon(flutterPluginBinding.binaryMessenger)
    applicationContext = flutterPluginBinding.applicationContext
    adapter = NfcAdapter.getDefaultAdapter(applicationContext)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    HostApiPigeon.setUp(binding.binaryMessenger, null)
    if (receiverRegistered) {
      applicationContext.unregisterReceiver(this)
      receiverRegistered = false
    }
    readerModeExecutor.shutdown()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    readerMode.attach(binding.activity)

    //  Once per engine: it used to be registered again on every activity attach, never unregistered.
    if (receiverRegistered) return
    val intentFilter = IntentFilter(NfcAdapter.ACTION_ADAPTER_STATE_CHANGED)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      applicationContext.registerReceiver(this, intentFilter, RECEIVER_NOT_EXPORTED)
    } else {
      applicationContext.registerReceiver(this, intentFilter)
    }
    receiverRegistered = true
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    readerMode.attach(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    readerMode.detach()
  }

  override fun onDetachedFromActivity() {
    readerMode.detach()
  }

  override fun onReceive(context: Context?, intent: Intent?) {
    intent ?: run { return }
    if (intent.action != NfcAdapter.ACTION_ADAPTER_STATE_CHANGED) { return }
    val state = intent.getIntExtra(NfcAdapter.EXTRA_ADAPTER_STATE, NfcAdapter.STATE_OFF)
    flutterApi.onAdapterStateChanged(toAdapterStatePigeon(state)) { /* noop */ }
  }

  override fun nfcAdapterIsEnabled(): Boolean {
    return getAdapter().isEnabled
  }

  override fun nfcAdapterIsSecureNfcEnabled(): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      throw FlutterError("unavailable", "Required Android SDK >= ${Build.VERSION_CODES.Q}.", null)
    }
    return getAdapter().isSecureNfcEnabled
  }

  override fun nfcAdapterIsSecureNfcSupported(): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      throw FlutterError("unavailable", "Required Android SDK >= ${Build.VERSION_CODES.Q}.", null)
    }
    return getAdapter().isSecureNfcSupported
  }

  //  Both return at once: the adapter check stays synchronous (an error Dart can catch), the binder
  //  call runs on the reader-mode thread, in call order, and is skipped when it would change nothing.
  override fun nfcAdapterEnableReaderMode(flags: List<ReaderFlagPigeon>) {
    getAdapter()
    readerMode.enable(toInt(flags))
  }

  override fun nfcAdapterDisableReaderMode() {
    getAdapter()
    readerMode.disable()
    cachedTags.clear() // Consider when to remove the tag.
  }

  override fun ndefGetNdefMessage(handle: String): NdefMessagePigeon? {
    val tech = forceConnect(handle) { Ndef.get(it) }
    val message = tech.ndefMessage
    return if (message != null) toNdefMessagePigeon(message) else null
  }

  override fun ndefWriteNdefMessage(handle: String, message: NdefMessagePigeon) {
    val tech = forceConnect(handle) { Ndef.get(it) }
    tech.writeNdefMessage(toNdefMessage(message))
  }

  override fun ndefMakeReadOnly(handle: String): Boolean {
    val tech = forceConnect(handle) { Ndef.get(it) }
    return tech.makeReadOnly()
  }

  override fun nfcAGetMaxTransceiveLength(handle: String): Long {
    val tech = forceConnect(handle) { NfcA.get(it) }
    return tech.maxTransceiveLength.toLong()
  }

  override fun nfcAGetTimeout(handle: String): Long {
    val tech = forceConnect(handle) { NfcA.get(it) }
    return tech.timeout.toLong()
  }

  override fun nfcASetTimeout(handle: String, timeout: Long) {
    val tech = forceConnect(handle) { NfcA.get(it) }
    tech.timeout = timeout.toInt()
  }

  override fun nfcATransceive(handle: String, bytes: ByteArray): ByteArray {
    val tech = forceConnect(handle) { NfcA.get(it) }
    return tech.transceive(bytes)
  }

  override fun nfcBGetMaxTransceiveLength(handle: String): Long {
    val tech = forceConnect(handle) { NfcB.get(it) }
    return tech.maxTransceiveLength.toLong()
  }

  override fun nfcBTransceive(handle: String, bytes: ByteArray): ByteArray {
    val tech = forceConnect(handle) { NfcB.get(it) }
    return tech.transceive(bytes)
  }

  override fun nfcFGetMaxTransceiveLength(handle: String): Long {
    val tech = forceConnect(handle) { NfcF.get(it) }
    return tech.maxTransceiveLength.toLong()
  }

  override fun nfcFGetTimeout(handle: String): Long {
    val tech = forceConnect(handle) { NfcF.get(it) }
    return tech.timeout.toLong()
  }

  override fun nfcFSetTimeout(handle: String, timeout: Long) {
    val tech = forceConnect(handle) { NfcF.get(it) }
    tech.timeout = timeout.toInt()
  }

  override fun nfcFTransceive(handle: String, bytes: ByteArray): ByteArray {
    val tech = forceConnect(handle) { NfcF.get(it) }
    return tech.transceive(bytes)
  }

  override fun nfcVGetMaxTransceiveLength(handle: String): Long {
    val tech = forceConnect(handle) { NfcV.get(it) }
    return tech.maxTransceiveLength.toLong()
  }

  override fun nfcVTransceive(handle: String, bytes: ByteArray): ByteArray {
    val tech = forceConnect(handle) { NfcV.get(it) }
    return tech.transceive(bytes)
  }

  override fun isoDepGetMaxTransceiveLength(handle: String): Long {
    val tech = forceConnect(handle) { IsoDep.get(it) }
    return tech.maxTransceiveLength.toLong()
  }

  override fun isoDepGetTimeout(handle: String): Long {
    val tech = forceConnect(handle) { IsoDep.get(it) }
    return tech.timeout.toLong()
  }

  override fun isoDepSetTimeout(handle: String, timeout: Long) {
    val tech = forceConnect(handle) { IsoDep.get(it) }
    tech.timeout = timeout.toInt()
  }

  override fun isoDepTransceive(handle: String, bytes: ByteArray): ByteArray {
    val tech = forceConnect(handle) { IsoDep.get(it) }
    return tech.transceive(bytes)
  }

  override fun mifareClassicGetMaxTransceiveLength(handle: String): Long {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    return tech.maxTransceiveLength.toLong()
  }

  override fun mifareClassicGetTimeout(handle: String): Long {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    return tech.timeout.toLong()
  }

  override fun mifareClassicSetTimeout(handle: String, timeout: Long) {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    tech.timeout = timeout.toInt()
  }

  override fun mifareClassicAuthenticateSectorWithKeyA(handle: String, sectorIndex: Long, key: ByteArray): Boolean {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    return tech.authenticateSectorWithKeyA(sectorIndex.toInt(), key)
  }

  override fun mifareClassicAuthenticateSectorWithKeyB(handle: String, sectorIndex: Long, key: ByteArray): Boolean {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    return tech.authenticateSectorWithKeyB(sectorIndex.toInt(), key)
  }

  override fun mifareClassicGetBlockCountInSector(handle: String, sectorIndex: Long): Long {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    return tech.getBlockCountInSector(sectorIndex.toInt()).toLong()
  }

  override fun mifareClassicBlockToSector(handle: String, blockIndex: Long): Long {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    return tech.blockToSector(blockIndex.toInt()).toLong()
  }

  override fun mifareClassicSectorToBlock(handle: String, sectorIndex: Long): Long {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    return tech.sectorToBlock(sectorIndex.toInt()).toLong()
  }

  override fun mifareClassicIncrement(handle: String, blockIndex: Long, value: Long) {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    tech.increment(blockIndex.toInt(), value.toInt())
  }

  override fun mifareClassicDecrement(handle: String, blockIndex: Long, value: Long) {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    tech.decrement(blockIndex.toInt(), value.toInt())
  }

  override fun mifareClassicRestore(handle: String, blockIndex: Long) {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    tech.restore(blockIndex.toInt())
  }

  override fun mifareClassicTransfer(handle: String, blockIndex: Long) {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    tech.transfer(blockIndex.toInt())
  }

  override fun mifareClassicReadBlock(handle: String, blockIndex: Long): ByteArray {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    return tech.readBlock(blockIndex.toInt())
  }

  override fun mifareClassicWriteBlock(handle: String, blockIndex: Long, data: ByteArray) {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    tech.writeBlock(blockIndex.toInt(), data)
  }

  override fun mifareClassicTransceive(handle: String, bytes: ByteArray): ByteArray {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    return tech.transceive(bytes)
  }

  override fun mifareUltralightGetMaxTransceiveLength(handle: String): Long {
    val tech = forceConnect(handle) { MifareUltralight.get(it) }
    return tech.maxTransceiveLength.toLong()
  }

  override fun mifareUltralightGetTimeout(handle: String): Long {
    val tech = forceConnect(handle) { MifareUltralight.get(it) }
    return tech.timeout.toLong()
  }

  override fun mifareUltralightSetTimeout(handle: String, timeout: Long) {
    val tech = forceConnect(handle) { MifareUltralight.get(it) }
    tech.timeout = timeout.toInt()
  }

  override fun mifareUltralightReadPages(handle: String, pageOffset: Long): ByteArray {
    val tech = forceConnect(handle) { MifareUltralight.get(it) }
    return tech.readPages(pageOffset.toInt())
  }

  override fun mifareUltralightWritePage(handle: String, pageOffset: Long, data: ByteArray) {
    val tech = forceConnect(handle) { MifareUltralight.get(it) }
    tech.writePage(pageOffset.toInt(), data)
  }

  override fun mifareUltralightTransceive(handle: String, bytes: ByteArray): ByteArray {
    val tech = forceConnect(handle) { MifareUltralight.get(it) }
    return tech.transceive(bytes)
  }

  override fun ndefFormatableFormat(handle: String, firstMessage: NdefMessagePigeon) {
    val tech = forceConnect(handle) { NdefFormatable.get(it) }
    tech.format(toNdefMessage(firstMessage))
  }

  override fun ndefFormatableFormatReadOnly(handle: String, firstMessage: NdefMessagePigeon) {
    val tech = forceConnect(handle) { NdefFormatable.get(it) }
    tech.formatReadOnly(toNdefMessage(firstMessage))
  }

  private fun onTagDiscovered(tag: Tag) {
    val handle = UUID.randomUUID().toString()
    val pigeonTag = try {
      toTagPigeon(tag, handle)
    } catch (e: Exception) {
      // The tag can leave the NFC field between reader-mode detecting it and this translation
      // step (e.g. a quick tap-and-withdraw). Tag#getTagService() then throws
      // SecurityException("... is out of date"), and some tag types can throw a
      // RuntimeException while a TagTechnology enumerates (e.g. MifareClassic). Both are
      // benign - the tag is simply gone - so drop this discovery instead of crashing; reader
      // mode keeps polling for the next tag.
      Log.w("NfcManagerPlugin", "Dropped tag discovery: tag went out of range mid-translation", e)
      return
    }
    Log.d("NfcManagerPlugin", "Tag discovered and translated OK, handle=$handle")
    cachedTags[handle] = tag
    mainHandler.post { flutterApi.onTagDiscovered(pigeonTag) { /* no op */ } }
  }

  private fun getAdapter(): NfcAdapter {
    return adapter ?: run { throw FlutterError("not_supported", "NFC is not supported on this device.", null) }
  }

  private inline fun <reified T: TagTechnology> forceConnect(handle: String, getMethod: (Tag) -> T?): T {
    val tag = cachedTags[handle] ?: run {
      throw FlutterError("tag_not_found", "You may have disable the session.", null)
    }
    val tech = getMethod(tag) ?: run {
      throw FlutterError("tag_not_found", "The tag cannot be converted to ${T::class.java.name}.", null)
    }
    val connectedTech = connectedTech ?: run {
      tech.connect()
      connectedTech = tech
      return tech
    }
    if (connectedTech.tag != tech.tag || connectedTech::class.java.name != tech::class.java.name) {
      try {
        connectedTech.close()
      } catch (e: Exception) {
        /* no op */
      }
      tech.connect()
      this.connectedTech = tech
    }
    return tech
  }
}

private fun toInt(value: List<ReaderFlagPigeon>): Int {
  return value.fold(0) { p, e -> p or toInt(e)}
}

private fun toInt(value: ReaderFlagPigeon): Int {
  return when (value) {
    ReaderFlagPigeon.NFC_A-> NfcAdapter.FLAG_READER_NFC_A
    ReaderFlagPigeon.NFC_B -> NfcAdapter.FLAG_READER_NFC_B
    ReaderFlagPigeon.NFC_BARCODE -> NfcAdapter.FLAG_READER_NFC_BARCODE
    ReaderFlagPigeon.NFC_F -> NfcAdapter.FLAG_READER_NFC_F
    ReaderFlagPigeon.NFC_V -> NfcAdapter.FLAG_READER_NFC_V
    ReaderFlagPigeon.NO_PLATFORM_SOUNDS -> NfcAdapter.FLAG_READER_NO_PLATFORM_SOUNDS
    ReaderFlagPigeon.SKIP_NDEF_CHECK -> NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK
  }
}

private fun toNdefMessage(value: NdefMessagePigeon): NdefMessage {
  return NdefMessage(value.records.map { toNdefRecord(it) }.toTypedArray())
}

private fun toNdefMessagePigeon(value: NdefMessage): NdefMessagePigeon {
  return NdefMessagePigeon(
    records = value.records.map { toNdefRecordPigeon(it) }
  )
}

private fun toNdefRecord(value: NdefRecordPigeon): NdefRecord {
  return NdefRecord(
    toShort(value.tnf),
    value.type,
    value.id,
    value.payload,
  )
}

private fun toNdefRecordPigeon(value: NdefRecord): NdefRecordPigeon {
  return NdefRecordPigeon(
    tnf = toTypeNameFormatPigeon(value.tnf),
    type = value.type,
    id = value.id,
    payload = value.payload,
  )
}

private fun toTagPigeon(value: Tag, handle: String): TagPigeon {
  return TagPigeon(
    handle = handle,
    id = value.id,
    techList = value.techList.toMutableList(),
    ndef = Ndef.get(value)?.let { toNdefPigeon(it) },
    nfcA = NfcA.get(value)?.let { toNfcAPigeon(it) },
    nfcB = NfcB.get(value)?.let { toNfcBPigeon(it) },
    nfcF = NfcF.get(value)?.let { toNfcFPigeon(it) },
    nfcV = NfcV.get(value)?.let { toNfcVPigeon(it) },
    isoDep = IsoDep.get(value)?.let { toIsoDepPigeon(it) },
    mifareClassic = MifareClassic.get(value)?.let { toMifareClassicPigeon(it) },
    mifareUltralight = MifareUltralight.get(value)?.let { toMifareUltralightPigeon(it) },
    ndefFormatable = NdefFormatable.get(value)?.let { "" },
    nfcBarcode = NfcBarcode.get(value)?.let { toNfcBarcodePigeon(it) },
  )
}

private fun toNdefPigeon(value: Ndef): NdefPigeon {
  return NdefPigeon(
    type = value.type,
    isWritable = value.isWritable,
    maxSize = value.maxSize.toLong(),
    canMakeReadOnly = value.canMakeReadOnly(),
    cachedNdefMessage = value.cachedNdefMessage?.let { toNdefMessagePigeon(it) },
  )
}

private fun toNfcAPigeon(value: NfcA): NfcAPigeon {
  return NfcAPigeon(
    atqa = value.atqa,
    sak = value.sak.toLong(),
  )
}

private fun toNfcBPigeon(value: NfcB): NfcBPigeon {
  return NfcBPigeon(
    applicationData = value.applicationData,
    protocolInfo = value.protocolInfo,
  )
}

private fun toNfcFPigeon(value: NfcF): NfcFPigeon {
  return NfcFPigeon(
    manufacturer = value.manufacturer,
    systemCode = value.systemCode,
  )
}

private fun toNfcVPigeon(value: NfcV): NfcVPigeon {
  return NfcVPigeon(
    dsfId = value.dsfId.toLong(),
    responseFlags = value.responseFlags.toLong(),
  )
}

private fun toIsoDepPigeon(value: IsoDep): IsoDepPigeon {
  return IsoDepPigeon(
    hiLayerResponse = value.hiLayerResponse,
    historicalBytes = value.historicalBytes,
    isExtendedLengthApduSupported = value.isExtendedLengthApduSupported,
  )
}

private fun toMifareClassicPigeon(value: MifareClassic): MifareClassicPigeon {
  return MifareClassicPigeon(
    type = toMifareClassicTypePigeon(value.type),
    blockCount = value.blockCount.toLong(),
    sectorCount = value.sectorCount.toLong(),
    size = value.size.toLong(),
  )
}

private fun toMifareUltralightPigeon(value: MifareUltralight): MifareUltralightPigeon {
  return MifareUltralightPigeon(
    type = toMifareUltralightTypePigeon(value.type)
  )
}

private fun toNfcBarcodePigeon(value: NfcBarcode): NfcBarcodePigeon {
  return NfcBarcodePigeon(
    type = toNfcBarcodeTypePigeon(value.type),
    barcode = value.barcode,
  )
}

private fun toShort(value: TypeNameFormatPigeon): Short {
  return when (value) {
    TypeNameFormatPigeon.EMPTY -> NdefRecord.TNF_EMPTY
    TypeNameFormatPigeon.WELL_KNOWN -> NdefRecord.TNF_WELL_KNOWN
    TypeNameFormatPigeon.MEDIA -> NdefRecord.TNF_MIME_MEDIA
    TypeNameFormatPigeon.ABSOLUTE_URI -> NdefRecord.TNF_ABSOLUTE_URI
    TypeNameFormatPigeon.EXTERNAL -> NdefRecord.TNF_EXTERNAL_TYPE
    TypeNameFormatPigeon.UNKNOWN -> NdefRecord.TNF_UNKNOWN
    TypeNameFormatPigeon.UNCHANGED -> NdefRecord.TNF_UNCHANGED
  }
}

private fun toAdapterStatePigeon(value: Int): AdapterStatePigeon {
  return when (value) {
    NfcAdapter.STATE_OFF -> AdapterStatePigeon.OFF
    NfcAdapter.STATE_TURNING_ON -> AdapterStatePigeon.TURNING_ON
    NfcAdapter.STATE_ON -> AdapterStatePigeon.ON
    NfcAdapter.STATE_TURNING_OFF -> AdapterStatePigeon.TURNING_OFF
    else -> error("Unknown value: $value")
  }
}

private fun toTypeNameFormatPigeon(value: Short): TypeNameFormatPigeon {
  return when (value) {
    NdefRecord.TNF_EMPTY -> TypeNameFormatPigeon.EMPTY
    NdefRecord.TNF_WELL_KNOWN -> TypeNameFormatPigeon.WELL_KNOWN
    NdefRecord.TNF_MIME_MEDIA -> TypeNameFormatPigeon.MEDIA
    NdefRecord.TNF_ABSOLUTE_URI -> TypeNameFormatPigeon.ABSOLUTE_URI
    NdefRecord.TNF_EXTERNAL_TYPE -> TypeNameFormatPigeon.EXTERNAL
    NdefRecord.TNF_UNKNOWN -> TypeNameFormatPigeon.UNKNOWN
    NdefRecord.TNF_UNCHANGED -> TypeNameFormatPigeon.UNCHANGED
    else -> error("Unknown value: $value")
  }
}

private fun toNfcBarcodeTypePigeon(value: Int): NfcBarcodeTypePigeon {
  return when (value) {
    NfcBarcode.TYPE_KOVIO -> NfcBarcodeTypePigeon.KOVIO
    NfcBarcode.TYPE_UNKNOWN -> NfcBarcodeTypePigeon.UNKNOWN
    else -> error("Unknown value: $value")
  }
}

private fun toMifareClassicTypePigeon(value: Int): MifareClassicTypePigeon {
  return when (value) {
    MifareClassic.TYPE_CLASSIC -> MifareClassicTypePigeon.CLASSIC
    MifareClassic.TYPE_PLUS -> MifareClassicTypePigeon.PLUS
    MifareClassic.TYPE_PRO -> MifareClassicTypePigeon.PRO
    MifareClassic.TYPE_UNKNOWN -> MifareClassicTypePigeon.UNKNOWN
    else -> error("Unknown value: $value")
  }
}

private fun toMifareUltralightTypePigeon(value: Int): MifareUltralightTypePigeon {
  return when (value) {
    MifareUltralight.TYPE_ULTRALIGHT -> MifareUltralightTypePigeon.ULTRALIGHT
    MifareUltralight.TYPE_ULTRALIGHT_C -> MifareUltralightTypePigeon.ULTRALIGHT_C
    MifareUltralight.TYPE_UNKNOWN -> MifareUltralightTypePigeon.UNKNOWN
    else -> error("Unknown value: $value")
  }
}
