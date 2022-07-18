package io.github.wangyng.simple_audio_player.player

import android.net.Uri

interface PlayerManager {

    fun prepare(uri: Uri)

    fun play()

    fun pause()

    fun stop()

    fun seekTo(position: Long)

    fun setVolume(volume: Double)

    fun getCurrentPosition(): Long

    fun getDuration(): Long

    fun setCallback(callback: SongStateCallback)

    interface SongStateCallback {

        fun onReady()

        fun onPlayEnd()

        fun onError(message: String)

        fun onPositionChange(position: Long, duration: Long)
    }
}

