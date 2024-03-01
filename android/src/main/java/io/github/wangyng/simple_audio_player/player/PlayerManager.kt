package io.github.wangyng.simple_audio_player.player

import android.net.Uri
import android.support.v4.media.session.MediaSessionCompat

interface PlayerManager {

    fun prepare(uri: Uri)

    fun play()

    fun pause()

    fun stop()

    fun seekTo(position: Int)

    fun setVolume(volume: Double)

    fun setRate(rate: Double)

    fun getCurrentPosition(): Int

    fun getDuration(): Int

    fun getPlaybackRate(): Double

    fun isPlaying(): Boolean

    fun setCallback(callback: SongStateCallback)

    fun getMediaSession(): MediaSessionCompat?

    interface SongStateCallback {

        fun onReady()

        fun onPlayEnd()

        fun onError(message: String)

        fun onPositionChange(position: Int, duration: Int)
    }
}

