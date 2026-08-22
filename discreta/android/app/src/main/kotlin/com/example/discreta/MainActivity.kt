package com.example.discreta

import android.content.Intent
import android.os.Bundle
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "discreta/flic"

    companion object {
        var flutterChannel: MethodChannel? = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Start background service ONCE (good)
        ContextCompat.startForegroundService(
            this,
            Intent(this, FlicKeepaliveService::class.java)
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        channel.setMethodCallHandler { call, result ->

            when (call.method) {

                "setUserId" -> {
                    val userId = call.argument<String>("userId")
                    val serviceIntent = Intent(this, FlicKeepaliveService::class.java)
                    serviceIntent.action = "SET_USER_ID"
                    serviceIntent.putExtra("userId", userId)
                    startService(serviceIntent)
                    result.success(null)
                }

                "clearUserId" -> {
                    val serviceIntent = Intent(this, FlicKeepaliveService::class.java)
                    serviceIntent.action = "CLEAR_USER_ID"
                    startService(serviceIntent)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        flutterChannel = channel
    }

    override fun onDestroy() {
        flutterChannel = null
        super.onDestroy()
    }
}