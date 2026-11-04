package dev.flutter.plugins.nfcmanager

import java.util.concurrent.Executor

/**
 * Owns the reader-mode state of one plugin instance.
 *
 * `NfcAdapter.enableReaderMode` / `disableReaderMode` are synchronous binder calls to the system NFC
 * service. On some devices (Blackview BV5300 Pro, MediaTek MT6765) that service answers slowly enough
 * to trigger ANRs when the calls are made on the UI thread, and an app that hands NFC from screen to
 * screen makes many of them. This class therefore:
 * - runs every call on [executor] (one background thread in production), in the order they were made;
 * - skips the calls that would change nothing: enabling the same flags on the same activity again, or
 *   disabling when reader mode is off. Handing the tag callback from one Dart listener to another then
 *   costs no binder call at all;
 * - re-applies reader mode on the new activity when Flutter reattaches one (configuration change,
 *   activity recreated), since Android drops reader mode together with the old activity.
 *
 * Android itself still makes one call on each activity pause and resume while reader mode is on.
 *
 * [A] is the activity type, generic so that the logic can be unit tested without Android.
 */
internal class ReaderModeController<A : Any>(
  private val executor: Executor,
  private val backend: Backend<A>,
) {

  interface Backend<A> {
    fun enable(activity: A, flags: Int)
    fun disable(activity: A)
    fun onError(action: String, error: Throwable)
  }

  //  All the fields below are only read and written on the executor thread.

  private var activity: A? = null

  /** What Dart asked for: kept while no activity is attached, re-applied on the next one. */
  private var wantedFlags: Int? = null

  /** What is actually applied, and on which activity. */
  private var appliedOn: A? = null
  private var appliedFlags: Int? = null

  fun attach(activity: A) = executor.execute {
    this.activity = activity
    wantedFlags?.let { applyFlags(it) }
  }

  /** The activity goes away: Android drops its reader-mode state with it, so there is nothing to disable. */
  fun detach() = executor.execute {
    activity = null
    appliedOn = null
    appliedFlags = null
  }

  fun enable(flags: Int) = executor.execute {
    wantedFlags = flags
    applyFlags(flags)
  }

  fun disable() = executor.execute {
    wantedFlags = null
    val on = appliedOn ?: return@execute
    appliedOn = null
    appliedFlags = null
    try {
      backend.disable(on)
    } catch (e: Throwable) {
      backend.onError("disable", e)
    }
  }

  private fun applyFlags(flags: Int) {
    val target = activity ?: return
    if (appliedOn === target && appliedFlags == flags) return
    try {
      backend.enable(target, flags)
      appliedOn = target
      appliedFlags = flags
    } catch (e: Throwable) {
      backend.onError("enable", e)
    }
  }
}
