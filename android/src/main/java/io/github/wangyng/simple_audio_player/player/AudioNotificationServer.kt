package io.github.wangyng.simple_audio_player.player

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder

class AudioNotificationServer : Service() {

    private val binder = LocalBinder()

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }

    inner class LocalBinder : Binder() {
        val service: AudioNotificationServer
            get() = this@AudioNotificationServer
    }
}