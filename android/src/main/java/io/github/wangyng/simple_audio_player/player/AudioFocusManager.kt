package io.github.wangyng.simple_audio_player.player

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager

class AudioFocusManager(private val context: Context) {

    private var mAudioManager: AudioManager? = null
    private var mFocusChangeCallback: AudioFocusChangeCallback? = null
    private var mNoisyAudioStreamReceiver: BroadcastReceiver? = null

    private val mOnAudioFocusChangeListener =
        AudioManager.OnAudioFocusChangeListener { focusChange ->
            when (focusChange) {
                AudioManager.AUDIOFOCUS_GAIN -> mFocusChangeCallback?.onAudioFocused()
                AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK,
                AudioManager.AUDIOFOCUS_LOSS_TRANSIENT,
                AudioManager.AUDIOFOCUS_LOSS -> mFocusChangeCallback?.onAudioNoFocus()
            }
        }

    init {
        this.mAudioManager =
            context.applicationContext?.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }

    fun tryToGetAudioFocus(focusChangeCallback: AudioFocusChangeCallback): Boolean {
        val result = mAudioManager?.requestAudioFocus(
            mOnAudioFocusChangeListener,
            AudioManager.STREAM_MUSIC,
            AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
        )

        if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
            this.mFocusChangeCallback = focusChangeCallback

            if (mNoisyAudioStreamReceiver != null) {
                context.unregisterReceiver(mNoisyAudioStreamReceiver)
            }
            mNoisyAudioStreamReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (intent?.action == AudioManager.ACTION_AUDIO_BECOMING_NOISY) {
                        // Pause the playback
                        mFocusChangeCallback?.onAudioBecomingNoisy()
                    }
                }
            }
            context.registerReceiver(mNoisyAudioStreamReceiver, IntentFilter(AudioManager.ACTION_AUDIO_BECOMING_NOISY))
        }

        return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    }

    fun giveUpAudioFocus() {
        mAudioManager?.abandonAudioFocus(mOnAudioFocusChangeListener)
        mFocusChangeCallback = null

        context.unregisterReceiver(mNoisyAudioStreamReceiver)
        mNoisyAudioStreamReceiver = null
    }

    interface AudioFocusChangeCallback {
        fun onAudioFocused()

        fun onAudioNoFocus()

        fun onAudioBecomingNoisy()
    }
}