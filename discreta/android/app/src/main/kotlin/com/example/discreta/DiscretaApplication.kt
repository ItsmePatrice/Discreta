package com.example.discreta

import android.app.Application
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat
import android.content.Intent
import io.flic.flic2libandroid.Flic2Manager

class DiscretaApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        Flic2Manager.initAndGetInstance(applicationContext, Handler(Looper.getMainLooper()))
        ContextCompat.startForegroundService(
            applicationContext,
            Intent(applicationContext, FlicKeepaliveService::class.java)
        )
    }
}