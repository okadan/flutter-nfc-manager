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

  override fun adapterEnableReaderMode(flags: List<Pigeon.PigeonReaderFlag>) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) { throw Exception("TODO") }
    val adapter = adapter ?: run { throw Exception("TODO") }
    adapter.enableReaderMode(activity, { onTagDiscovered(it) }, convert(flags), null)
  }

  override fun adapterDisableReaderMode() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) { throw Exception("TODO") }
    val adapter = adapter ?: run { throw Exception("TODO") }
    adapter.disableReaderMode(activity)
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
    return if (message != null) convert(message) else null
  }

  override fun ndefWriteNdefMessage(handle: String, message: Pigeon.PigeonNdefMessage) {
    val tech = forceConnect(handle) { Ndef.get(it) }
    tech.writeNdefMessage(convert(message))
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

  override fun nfcATransceive(handle: String, data: ByteArray): ByteArray {
    val tech = forceConnect(handle) { NfcA.get(it) }
    return tech.transceive(data)
  }

  override fun nfcBGetMaxTransceiveLength(handle: String): Long {
    val tech = forceConnect(handle) { NfcB.get(it) }
    return tech.maxTransceiveLength.toLong()
  }

  override fun nfcBTransceive(handle: String, data: ByteArray): ByteArray {
    val tech = forceConnect(handle) { NfcB.get(it) }
    return tech.transceive(data)
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

  override fun nfcFTransceive(handle: String, data: ByteArray): ByteArray {
    val tech = forceConnect(handle) { NfcF.get(it) }
    return tech.transceive(data)
  }

  override fun nfcVGetMaxTransceiveLength(handle: String): Long {
    val tech = forceConnect(handle) { NfcV.get(it) }
    return tech.maxTransceiveLength.toLong()
  }

  override fun nfcVTransceive(handle: String, data: ByteArray): ByteArray {
    val tech = forceConnect(handle) { NfcV.get(it) }
    return tech.transceive(data)
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

  override fun isoDepTransceive(handle: String, data: ByteArray): ByteArray {
    val tech = forceConnect(handle) { IsoDep.get(it) }
    return tech.transceive(data)
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

  override fun mifareClassicTransceive(handle: String, data: ByteArray): ByteArray {
    val tech = forceConnect(handle) { MifareClassic.get(it) }
    return tech.transceive(data)
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

  override fun mifareUltralightTransceive(handle: String, data: ByteArray): ByteArray {
    val tech = forceConnect(handle) { MifareUltralight.get(it) }
    return tech.transceive(data)
  }

  override fun ndefFormatableFormat(handle: String, firstMessage: Pigeon.PigeonNdefMessage) {
    val tech = forceConnect(handle) { NdefFormatable.get(it) }
    tech.format(convert(firstMessage))
  }

  override fun ndefFormatableFormatReadOnly(handle: String, firstMessage: Pigeon.PigeonNdefMessage) {
    val tech = forceConnect(handle) { NdefFormatable.get(it) }
    tech.formatReadOnly(convert(firstMessage))
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
    val pigeonTag = convert(tag).apply { this.handle = handle }
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
      try { connectedTech.close() } catch (e: IOException) { /* no op */ }
      tech.connect()
      this.connectedTech = tech
      return tech
    }
    return tech
  }
}

@RequiresApi(Build.VERSION_CODES.KITKAT)
private fun convert(pigeon: List<Pigeon.PigeonReaderFlag>): Int {
  return pigeon.fold(0) { p, e -> p or convert(e)}
}

@RequiresApi(Build.VERSION_CODES.KITKAT)
private fun convert(pigeon: Pigeon.PigeonReaderFlag): Int {
  return when (pigeon) {
    Pigeon.PigeonReaderFlag.NFC_A -> NfcAdapter.FLAG_READER_NFC_A
    Pigeon.PigeonReaderFlag.NFC_B -> NfcAdapter.FLAG_READER_NFC_B
    Pigeon.PigeonReaderFlag.NFC_BARCODE -> NfcAdapter.FLAG_READER_NFC_BARCODE
    Pigeon.PigeonReaderFlag.NFC_F -> NfcAdapter.FLAG_READER_NFC_F
    Pigeon.PigeonReaderFlag.NFC_V -> NfcAdapter.FLAG_READER_NFC_V
    Pigeon.PigeonReaderFlag.NO_PLATFORM_SOUNDS -> NfcAdapter.FLAG_READER_NO_PLATFORM_SOUNDS
    Pigeon.PigeonReaderFlag.SKIP_NDEF_CHECK -> NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK
  }
}

private fun convert(message: Pigeon.PigeonNdefMessage): NdefMessage {
  return NdefMessage(
          message.records!!.map { convert(it) }.toTypedArray(),
  )
}

private fun convert(message: NdefMessage): Pigeon.PigeonNdefMessage {
  return Pigeon.PigeonNdefMessage().apply {
    records = message.records.map { convert(it) }
  }
}

private fun convert(record: Pigeon.PigeonNdefRecord): NdefRecord {
  return NdefRecord(
          convert(record.tnf!!),
          record.type!!,
          record.id!!,
          record.payload!!,
  )
}

private fun convert(record: NdefRecord): Pigeon.PigeonNdefRecord {
  return Pigeon.PigeonNdefRecord().apply {
    tnf = convert(record.tnf)
    type = record.type
    id = record.id
    payload = record.payload
  }
}

private fun convert(tag: Tag): Pigeon.PigeonTag {
  return Pigeon.PigeonTag().apply {
    id = tag.id
    techList = tag.techList.toMutableList()
    Ndef.get(tag).also { ndef = convert(it) }
    NfcA.get(tag).also { nfcA = convert(it) }
    NfcB.get(tag).also { nfcB = convert(it) }
    NfcF.get(tag).also { nfcF = convert(it) }
    NfcV.get(tag).also { nfcV = convert(it) }
    IsoDep.get(tag).also { isoDep = convert(it) }
    MifareClassic.get(tag).also { mifareClassic = convert(it) }
    MifareUltralight.get(tag).also { mifareUltralight = convert(it) }
    NdefFormatable.get(tag).also { ndefFormatable = "" }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1)
      NfcBarcode.get(tag).also { nfcBarcode = convert(it) }
  }
}

private fun convert(tech: Ndef): Pigeon.PigeonNdef {
  return Pigeon.PigeonNdef().apply {
    type = tech.type
    isWritable = tech.isWritable
    maxSize = tech.maxSize.toLong()
    canMakeReadOnly = tech.canMakeReadOnly()
    tech.cachedNdefMessage?.let { cachedNdefMessage = convert(it) }
  }
}

private fun convert(tech: NfcA): Pigeon.PigeonNfcA {
  return Pigeon.PigeonNfcA().apply {
    atqa = tech.atqa
    sak = tech.sak.toLong()
  }
}

private fun convert(tech: NfcB): Pigeon.PigeonNfcB {
  return Pigeon.PigeonNfcB().apply {
    applicationData = tech.applicationData
    protocolInfo = tech.protocolInfo
  }
}

private fun convert(tech: NfcF): Pigeon.PigeonNfcF {
  return Pigeon.PigeonNfcF().apply {
    manufacturer = tech.manufacturer
    systemCode = tech.systemCode
  }
}

private fun convert(tech: NfcV): Pigeon.PigeonNfcV {
  return Pigeon.PigeonNfcV().apply {
    dsfId = tech.dsfId.toLong()
    responseFlags = tech.responseFlags.toLong()
  }
}

private fun convert(tech: IsoDep): Pigeon.PigeonIsoDep {
  return Pigeon.PigeonIsoDep().apply {
    hiLayerResponse = tech.hiLayerResponse
    historicalBytes = tech.historicalBytes
    isExtendedLengthApduSupported = tech.isExtendedLengthApduSupported
  }
}

private fun convert(tech: MifareClassic): Pigeon.PigeonMifareClassic {
  return Pigeon.PigeonMifareClassic().apply {
    type = tech.type.toLong()
    blockCount = tech.blockCount.toLong()
    sectorCount = tech.sectorCount.toLong()
    size = tech.size.toLong()
  }
}

private fun convert(tech: MifareUltralight): Pigeon.PigeonMifareUltralight {
  return Pigeon.PigeonMifareUltralight().apply {
    type = tech.type.toLong()
  }
}

@RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
private fun convert(tech: NfcBarcode): Pigeon.PigeonNfcBarcode {
  return Pigeon.PigeonNfcBarcode().apply {
    type = tech.type.toLong()
    barcode = tech.barcode
  }
}

private fun convert(tnf: Pigeon.PigeonTypeNameFormat): Short {
  return when (tnf) {
    Pigeon.PigeonTypeNameFormat.EMPTY -> NdefRecord.TNF_EMPTY
    Pigeon.PigeonTypeNameFormat.WELL_KNOWN -> NdefRecord.TNF_WELL_KNOWN
    Pigeon.PigeonTypeNameFormat.MIME_MEDIA -> NdefRecord.TNF_MIME_MEDIA
    Pigeon.PigeonTypeNameFormat.ABSOLUTE_URI -> NdefRecord.TNF_ABSOLUTE_URI
    Pigeon.PigeonTypeNameFormat.EXTERNAL_TYPE -> NdefRecord.TNF_EXTERNAL_TYPE
    Pigeon.PigeonTypeNameFormat.UNKNOWN -> NdefRecord.TNF_UNKNOWN
    Pigeon.PigeonTypeNameFormat.UNCHANGED -> NdefRecord.TNF_UNCHANGED
  }
}

private fun convert(tnf: Short): Pigeon.PigeonTypeNameFormat {
  return when (tnf) {
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
