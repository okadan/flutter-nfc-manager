package dev.flutter.plugins.nfcmanager

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.*
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import java.io.IOException
import java.util.*

class NfcManagerPlugin: FlutterPlugin, ActivityAware, Pigeon.PigeonHostApi, BroadcastReceiver() {
  private lateinit var flutterApi: Pigeon.PigeonFlutterApi
  private lateinit var activity: Activity
  private var adapter: NfcAdapter? = null
  private var cachedTags: MutableMap<String, Tag> = mutableMapOf()
  private var connectedTech: TagTechnology? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Pigeon.PigeonHostApi.setup(flutterPluginBinding.binaryMessenger, this)
    flutterApi = Pigeon.PigeonFlutterApi(flutterPluginBinding.binaryMessenger)
    adapter = NfcAdapter.getDefaultAdapter(flutterPluginBinding.applicationContext)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Pigeon.PigeonHostApi.setup(binding.binaryMessenger, null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    activity.applicationContext.registerReceiver(this, null)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // no op
  }

  override fun onDetachedFromActivity() {
    // no op
  }

  override fun onReceive(context: Context?, intent: Intent?) {
    intent ?: run { return }
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR2) { return }
    if (intent.action != NfcAdapter.ACTION_ADAPTER_STATE_CHANGED) { return }
    val state = intent.getIntExtra(NfcAdapter.EXTRA_ADAPTER_STATE, NfcAdapter.STATE_OFF)
    flutterApi.onAdapterStateChanged(state.toLong()) { /* no op */ }
  }

  override fun adapterIsEnabled(): Boolean {
    val adapter = adapter ?: run { throw Exception("TODO") }
    return adapter.isEnabled
  }

  override fun adapterIsSecureNfcEnabled(): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) { throw Exception("TODO") }
    val adapter = adapter ?: run { throw Exception("TODO") }
    return adapter.isSecureNfcEnabled
  }

  override fun adapterIsSecureNfcSupported(): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) { throw Exception("TODO") }
    val adapter = adapter ?: run { throw Exception("TODO") }
    return adapter.isSecureNfcSupported
  }

  override fun adapterEnableReaderMode(flags: List<String>) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) { throw Exception("TODO") }
    val adapter = adapter ?: run { throw Exception("TODO") }
    adapter.enableReaderMode(activity, { onTagDiscovered(it) }, toInt(flags), null)
  }

  override fun adapterDisableReaderMode() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) { throw Exception("TODO") }
    val adapter = adapter ?: run { throw Exception("TODO") }
    adapter.disableReaderMode(activity)
    cachedTags.clear() // FIXME: Consider when to remove the tag.
  }

  override fun adapterEnableForegroundDispatch() {
    val adapter = adapter ?: run { throw Exception("TODO") }
    val intent = Intent(activity.applicationContext, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
    val pendingIntent = PendingIntent.getActivity(activity.applicationContext, 0, intent, 0)
    adapter.enableForegroundDispatch(activity, pendingIntent, null, null)
  }

  override fun adapterDisableForegroundDispatch() {
    val adapter = adapter ?: run { throw Exception("TODO") }
    adapter.disableForegroundDispatch(activity)
  }

  override fun ndefGetNdefMessage(handle: String): Pigeon.PigeonNdefMessage? {
    val tech = forceConnect(handle) { Ndef.get(it) }
    val message = tech.ndefMessage
    return if (message != null) toPigeonNdefMessage(message) else null
  }

  override fun ndefWriteNdefMessage(handle: String, message: Pigeon.PigeonNdefMessage) {
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

  override fun ndefFormatableFormat(handle: String, firstMessage: Pigeon.PigeonNdefMessage) {
    val tech = forceConnect(handle) { NdefFormatable.get(it) }
    tech.format(toNdefMessage(firstMessage))
  }

  override fun ndefFormatableFormatReadOnly(handle: String, firstMessage: Pigeon.PigeonNdefMessage) {
    val tech = forceConnect(handle) { NdefFormatable.get(it) }
    tech.formatReadOnly(toNdefMessage(firstMessage))
  }

  override fun disposeTag(handle: String) {
    val tag = cachedTags.remove(handle) ?: run { return }
    val tech = connectedTech ?: run { return }
    connectedTech = null
    if (tech.tag != tag || !tech.isConnected) return
    try { tech.close() } catch (e: IOException) { /* no op */ }
  }

  private fun onTagDiscovered(tag: Tag) {
    val handle = UUID.randomUUID().toString()
    val pigeonTag = toPigeonTag(tag).apply { this.handle = handle }
    cachedTags[handle] = tag
    activity.runOnUiThread { flutterApi.onTagDiscovered(pigeonTag) { /* no op */ } }
  }

  private fun <T: TagTechnology> forceConnect(handle: String, getMethod: (Tag) -> T?): T {
    val tag = cachedTags[handle] ?: run { throw Exception("TODO") }
    val tech = getMethod(tag) ?: run { throw Exception("TODO") }
    val connectedTech = connectedTech ?: run {
      tech.connect()
      connectedTech = tech
      return tech
    }
    if (connectedTech.tag != tech.tag || connectedTech::class.java.name != tech::class.java.name) {
      try { connectedTech.close() } catch (e: Exception) { /* no op */ }
      tech.connect()
      this.connectedTech = tech
      return tech
    }
    return tech
  }
}

@RequiresApi(Build.VERSION_CODES.KITKAT)
private fun toInt(value: List<String>): Int {
  return value.fold(0) { p, e -> p or toInt(e)}
}

@RequiresApi(Build.VERSION_CODES.KITKAT)
private fun toInt(value: String): Int {
  return when (value) {
    "nfcA" -> NfcAdapter.FLAG_READER_NFC_A
    "nfcB" -> NfcAdapter.FLAG_READER_NFC_B
    "nfcBarcode" -> NfcAdapter.FLAG_READER_NFC_BARCODE
    "nfcF" -> NfcAdapter.FLAG_READER_NFC_F
    "nfcV" -> NfcAdapter.FLAG_READER_NFC_V
    "noPlatformSounds" -> NfcAdapter.FLAG_READER_NO_PLATFORM_SOUNDS
    "skipNdefCheck" -> NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK
    else -> throw IllegalArgumentException("$value is Unknown")
  }
}

private fun toNdefMessage(value: Pigeon.PigeonNdefMessage): NdefMessage {
  return NdefMessage(
          value.records!!.map { toNdefRecord(it) }.toTypedArray(),
  )
}

private fun toPigeonNdefMessage(value: NdefMessage): Pigeon.PigeonNdefMessage {
  return Pigeon.PigeonNdefMessage().apply {
    records = value.records.map { toPigeonNdefRecord(it) }
  }
}

private fun toNdefRecord(value: Pigeon.PigeonNdefRecord): NdefRecord {
  return NdefRecord(
          toShort(value.tnf!!),
          value.type!!,
          value.id!!,
          value.payload!!,
  )
}

private fun toPigeonNdefRecord(value: NdefRecord): Pigeon.PigeonNdefRecord {
  return Pigeon.PigeonNdefRecord().apply {
    tnf = toPigeonTypeNameFormat(value.tnf)
    type = value.type
    id = value.id
    payload = value.payload
  }
}

private fun toPigeonTag(value: Tag): Pigeon.PigeonTag {
  return Pigeon.PigeonTag().apply {
    id = value.id
    techList = value.techList.toMutableList()
    Ndef.get(value)?.also { ndef = toPigeonNdef(it) }
    NfcA.get(value)?.also { nfcA = toPigeonNfcA(it) }
    NfcB.get(value)?.also { nfcB = toPigeonNfcB(it) }
    NfcF.get(value)?.also { nfcF = toPigeonNfcF(it) }
    NfcV.get(value)?.also { nfcV = toPigeonNfcV(it) }
    IsoDep.get(value)?.also { isoDep = toPigeonIsoDep(it) }
    MifareClassic.get(value)?.also { mifareClassic = toPigeonMifareClassic(it) }
    MifareUltralight.get(value)?.also { mifareUltralight = toPigeonMifareUltralight(it) }
    NdefFormatable.get(value)?.also { ndefFormatable = "" }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1)
      NfcBarcode.get(value)?.also { nfcBarcode = toPigeonNfcBarcode(it) }
  }
}

private fun toPigeonNdef(value: Ndef): Pigeon.PigeonNdef {
  return Pigeon.PigeonNdef().apply {
    type = value.type
    isWritable = value.isWritable
    maxSize = value.maxSize.toLong()
    canMakeReadOnly = value.canMakeReadOnly()
    value.cachedNdefMessage?.let { cachedNdefMessage = toPigeonNdefMessage(it) }
  }
}

private fun toPigeonNfcA(value: NfcA): Pigeon.PigeonNfcA {
  return Pigeon.PigeonNfcA().apply {
    atqa = value.atqa
    sak = value.sak.toLong()
  }
}

private fun toPigeonNfcB(value: NfcB): Pigeon.PigeonNfcB {
  return Pigeon.PigeonNfcB().apply {
    applicationData = value.applicationData
    protocolInfo = value.protocolInfo
  }
}

private fun toPigeonNfcF(value: NfcF): Pigeon.PigeonNfcF {
  return Pigeon.PigeonNfcF().apply {
    manufacturer = value.manufacturer
    systemCode = value.systemCode
  }
}

private fun toPigeonNfcV(value: NfcV): Pigeon.PigeonNfcV {
  return Pigeon.PigeonNfcV().apply {
    dsfId = value.dsfId.toLong()
    responseFlags = value.responseFlags.toLong()
  }
}

private fun toPigeonIsoDep(value: IsoDep): Pigeon.PigeonIsoDep {
  return Pigeon.PigeonIsoDep().apply {
    hiLayerResponse = value.hiLayerResponse
    historicalBytes = value.historicalBytes
    isExtendedLengthApduSupported = value.isExtendedLengthApduSupported
  }
}

private fun toPigeonMifareClassic(value: MifareClassic): Pigeon.PigeonMifareClassic {
  return Pigeon.PigeonMifareClassic().apply {
    type = toPigeonMifareClassicType(value.type)
    blockCount = value.blockCount.toLong()
    sectorCount = value.sectorCount.toLong()
    size = value.size.toLong()
  }
}

private fun toPigeonMifareUltralight(value: MifareUltralight): Pigeon.PigeonMifareUltralight {
  return Pigeon.PigeonMifareUltralight().apply {
    type = toPigeonMifareUltralightType(value.type)
  }
}

@RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
private fun toPigeonNfcBarcode(value: NfcBarcode): Pigeon.PigeonNfcBarcode {
  return Pigeon.PigeonNfcBarcode().apply {
    type = value.type.toLong()
    barcode = value.barcode
  }
}

private fun toShort(value: Pigeon.PigeonTypeNameFormat): Short {
  return when (value) {
    Pigeon.PigeonTypeNameFormat.EMPTY -> NdefRecord.TNF_EMPTY
    Pigeon.PigeonTypeNameFormat.WELL_KNOWN -> NdefRecord.TNF_WELL_KNOWN
    Pigeon.PigeonTypeNameFormat.MIME_MEDIA -> NdefRecord.TNF_MIME_MEDIA
    Pigeon.PigeonTypeNameFormat.ABSOLUTE_URI -> NdefRecord.TNF_ABSOLUTE_URI
    Pigeon.PigeonTypeNameFormat.EXTERNAL_TYPE -> NdefRecord.TNF_EXTERNAL_TYPE
    Pigeon.PigeonTypeNameFormat.UNKNOWN -> NdefRecord.TNF_UNKNOWN
    Pigeon.PigeonTypeNameFormat.UNCHANGED -> NdefRecord.TNF_UNCHANGED
  }
}

private fun toPigeonTypeNameFormat(value: Short): Pigeon.PigeonTypeNameFormat {
  return when (value) {
    NdefRecord.TNF_EMPTY -> Pigeon.PigeonTypeNameFormat.EMPTY
    NdefRecord.TNF_WELL_KNOWN -> Pigeon.PigeonTypeNameFormat.WELL_KNOWN
    NdefRecord.TNF_MIME_MEDIA -> Pigeon.PigeonTypeNameFormat.MIME_MEDIA
    NdefRecord.TNF_ABSOLUTE_URI -> Pigeon.PigeonTypeNameFormat.ABSOLUTE_URI
    NdefRecord.TNF_EXTERNAL_TYPE -> Pigeon.PigeonTypeNameFormat.EXTERNAL_TYPE
    NdefRecord.TNF_UNKNOWN -> Pigeon.PigeonTypeNameFormat.UNKNOWN
    NdefRecord.TNF_UNCHANGED -> Pigeon.PigeonTypeNameFormat.UNCHANGED
    else -> error("TODO:")
  }
}

private fun toPigeonMifareClassicType(value: Int): Pigeon.PigeonMifareClassicType {
  return when (value) {
    MifareClassic.TYPE_CLASSIC -> Pigeon.PigeonMifareClassicType.CLASSIC
    MifareClassic.TYPE_PLUS -> Pigeon.PigeonMifareClassicType.PLUS
    MifareClassic.TYPE_PRO -> Pigeon.PigeonMifareClassicType.PRO
    MifareClassic.TYPE_UNKNOWN -> Pigeon.PigeonMifareClassicType.UNKNOWN
    else -> error("TODO:")
  }
}

private fun toPigeonMifareUltralightType(value: Int): Pigeon.PigeonMifareUltralightType {
  return when (value) {
    MifareUltralight.TYPE_ULTRALIGHT -> Pigeon.PigeonMifareUltralightType.ULTRALIGHT
    MifareUltralight.TYPE_ULTRALIGHT_C -> Pigeon.PigeonMifareUltralightType.ULTRALIGHT_C
    MifareUltralight.TYPE_UNKNOWN -> Pigeon.PigeonMifareUltralightType.UNKNOWN
    else -> error("TODO:")
  }
}
