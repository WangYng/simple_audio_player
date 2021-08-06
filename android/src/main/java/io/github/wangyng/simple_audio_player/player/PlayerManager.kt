package io.github.wangyng.simple_audio_player.player

interface PlayerManager {

    fun prepare(song: Song)

    fun play()

    fun pause()

    fun stop()

    fun seekTo(position: Long)

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

