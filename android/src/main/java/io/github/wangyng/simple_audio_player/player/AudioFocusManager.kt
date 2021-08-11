package io.github.wangyng.simple_audio_player.player

import android.content.Context
import android.media.AudioManager

class AudioFocusManager(private val context: Context) {

    private var mAudioManager: AudioManager? = null
    private var mCallback: AudioFocusChangeCallback? = null

    private val mOnAudioFocusChangeListener =
        AudioManager.OnAudioFocusChangeListener { focusChange ->
            when (focusChange) {
                AudioManager.AUDIOFOCUS_GAIN -> mCallback?.onAudioFocused()
                AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK,
                AudioManager.AUDIOFOCUS_LOSS_TRANSIENT,
                AudioManager.AUDIOFOCUS_LOSS -> mCallback?.onAudioNoFocus()
            }
        }

    init {
        this.mAudioManager =
            context.applicationContext?.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }

    fun tryToGetAudioFocus(callback: AudioFocusChangeCallback): Boolean {
        val result = mAudioManager?.requestAudioFocus(
            mOnAudioFocusChangeListener,
            AudioManager.STREAM_MUSIC,
            AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
        )

        if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
            mCallback = callback
        }

        return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    }

    fun giveUpAudioFocus() {
        mAudioManager?.abandonAudioFocus(mOnAudioFocusChangeListener)
        mCallback = null
    }

    interface AudioFocusChangeCallback {
        fun onAudioFocused()

        fun onAudioNoFocus()
    }
}