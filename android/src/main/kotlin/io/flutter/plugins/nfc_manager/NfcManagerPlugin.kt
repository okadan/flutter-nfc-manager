package io.flutter.plugins.nfc_manager

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class NfcManagerPlugin: MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "plugins.flutter.io/nfc_manager")
            channel.setMethodCallHandler(NfcManagerPlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        result.notImplemented()
    }
}
