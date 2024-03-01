package io.github.wangyng.simple_audio_player.player

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import com.google.android.exoplayer2.C.CONTENT_TYPE_MUSIC
import com.google.android.exoplayer2.C.USAGE_MEDIA
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.PlaybackException
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.audio.AudioAttributes
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.Util

class ExoPlayerManager(private val context: Context) : PlayerManager {

    private val mEventListener = ExoPlayerEventListener()
    private var mExoSongStateCallback: PlayerManager.SongStateCallback? = null
    private var mCurrentUri: Uri? = null
    private var mExoPlayer: SimpleExoPlayer? = null
    private var mMediaSession: MediaSessionCompat? = null

    private var mRate: Double = 1.0;

    private val mUpdateProgressHandler = object : Handler(Looper.getMainLooper()) {
        override fun handleMessage(msg: Message) {
            if (mExoPlayer?.isPlaying == true) {
                val duration: Long = mExoPlayer?.duration ?: 0
                val position: Long = mExoPlayer?.currentPosition ?: 0
                mExoSongStateCallback?.onPositionChange(position.toInt(), duration.toInt())
            }

            removeMessages(0)
            sendEmptyMessageDelayed(0, UPDATE_PROGRESS_DELAY)
        }
    }

    override fun setCallback(callback: PlayerManager.SongStateCallback) {
        mExoSongStateCallback = callback
    }

    override fun getCurrentPosition(): Int {
        return mExoPlayer?.currentPosition?.toInt() ?: 0
    }

    override fun getDuration(): Int {
        return mExoPlayer?.duration?.toInt() ?: 0
    }

    override fun getPlaybackRate(): Double {
        return mRate
    }

    override fun isPlaying(): Boolean {
        return mExoPlayer?.isPlaying ?: false
    }

    override fun prepare(uri: Uri) {

        val songHasChanged = uri != mCurrentUri
        if (songHasChanged) {
            mCurrentUri = uri
        }

        if (songHasChanged || mExoPlayer == null) {
            val source = mCurrentUri
            if (mExoPlayer == null) {
                mExoPlayer = SimpleExoPlayer.Builder(context).build()
                mExoPlayer?.addListener(mEventListener)
            }

            // Android "O" makes much greater use of AudioAttributes, especially
            // with regards to AudioFocus. All of tracks are music, but
            // if your content includes spoken word such as audio books or pod casts
            // then the content type should be set to CONTENT_TYPE_SPEECH for those
            // tracks.
            val audioAttributes = AudioAttributes.Builder()
                .setContentType(CONTENT_TYPE_MUSIC)
                .setUsage(USAGE_MEDIA)
                .build()
            mExoPlayer?.setAudioAttributes(audioAttributes, false)

            // Produces DataSource instances through which media data is loaded.
            val dataSourceFactory = buildDataSourceFactory(context)

            val mediaSource = ProgressiveMediaSource.Factory(dataSourceFactory)
                .createMediaSource(MediaItem.Builder().setUri(source).build())

            // Prepares media to play (happens on background thread) and triggers
            // {@code onPlayerStateChanged} callback when the stream is ready to play.
            mExoPlayer?.setMediaSource(mediaSource)
            mExoPlayer?.prepare()
        }
    }

    override fun play() {
        mExoPlayer?.playWhenReady = true
    }

    override fun pause() {
        mExoPlayer?.playWhenReady = false
    }

    override fun stop() {
        mExoPlayer?.release()
        mExoPlayer?.removeListener(mEventListener)
        mExoPlayer = null
    }

    override fun seekTo(position: Int) {
        mExoPlayer?.seekTo(position.toLong())
    }

    override fun setVolume(volume: Double) {
        mExoPlayer?.volume = volume.toFloat();
    }

    override fun setRate(rate: Double) {
        mRate = rate;
        mExoPlayer?.setPlaybackSpeed(rate.toFloat());
    }

    override fun getMediaSession(): MediaSessionCompat? {
        if (mExoPlayer != null && mMediaSession == null) {
            val playBackStateBuilder = PlaybackStateCompat.Builder().setActions(
                PlaybackStateCompat.ACTION_PLAY or PlaybackStateCompat.ACTION_PAUSE
            )

            mMediaSession = MediaSessionCompat(context, context.packageName)
            mMediaSession?.setPlaybackState(playBackStateBuilder.build())
            mMediaSession?.setCallback(SimpleSessionCallback(mExoPlayer!!))
        }

        return mMediaSession
    }

    // ---------- utility ----------
    private fun buildDataSourceFactory(context: Context): DataSource.Factory {
        val bandwidthMeter = DefaultBandwidthMeter.Builder(context).build()
        val dataSourceFactory = DefaultDataSourceFactory(
            context,
            Util.getUserAgent(context, ""),
            bandwidthMeter
        )
        return DefaultDataSourceFactory(context, bandwidthMeter, dataSourceFactory)
    }

    private inner class ExoPlayerEventListener : Player.Listener {

        override fun onPlaybackStateChanged(playbackState: Int) {
            when (playbackState) {
                Player.STATE_READY -> {
                    mExoSongStateCallback?.onReady()
                    mUpdateProgressHandler.sendEmptyMessage(0)
                }
                Player.STATE_ENDED -> {
                    mUpdateProgressHandler.removeMessages(0)
                    mExoSongStateCallback?.onPlayEnd()
                }
                else -> {}
            }
        }

        override fun onPlayerError(error: PlaybackException) {
            mExoSongStateCallback?.onError(error.message ?: "onPlayerError")
            stop()
        }
    }

    private inner class SimpleSessionCallback(val simpleExoPlayer: SimpleExoPlayer) :
        MediaSessionCompat.Callback() {
        override fun onPlay() {
            simpleExoPlayer.playWhenReady = true
        }

        override fun onPause() {
            simpleExoPlayer.playWhenReady = false
        }
    }

    companion object {
        const val UPDATE_PROGRESS_DELAY = 500L
    }
}