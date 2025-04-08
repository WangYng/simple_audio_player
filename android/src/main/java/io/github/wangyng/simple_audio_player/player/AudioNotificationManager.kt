package io.github.wangyng.simple_audio_player.player

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.*
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.IBinder
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.PlaybackStateCompat
import android.util.Base64
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import io.github.wangyng.simple_audio_player.R


class AudioNotificationManager(private val context: Context) : BroadcastReceiver() {

    private var mNotificationManager: NotificationManager? = null
    private var mCallback: AudioNotificationEventCallback? = null

    private var mPlayer: PlayerManager? = null
    private var mSong: Song? = null

    private val mPlayIntent: PendingIntent
    private val mPauseIntent: PendingIntent
    private val mPreviousIntent: PendingIntent
    private val mNextIntent: PendingIntent
    private val mStopIntent: PendingIntent
    private val mOpenAppIntent: PendingIntent
    private var mHelper = NotificationHelper()

    private var mService: AudioNotificationServer? = null;
    private val mConnection = object : ServiceConnection {

        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            val binder = service as AudioNotificationServer.LocalBinder
            mService = binder.service

            val filter = IntentFilter().apply {
                addAction(ACTION_NEXT)
                addAction(ACTION_PAUSE)
                addAction(ACTION_PLAY)
                addAction(ACTION_PREV)
                addAction(ACTION_STOP)
            }
            if (mPlayer != null && mSong != null) {
                binder.service.registerReceiver(this@AudioNotificationManager, filter)
                binder.service.startForeground(
                    NOTIFICATION_ID,
                    mHelper.generateNotification(mPlayer!!, mSong!!)
                )
            }
        }

        override fun onServiceDisconnected(classname: ComponentName) {
            mService = null
        }
    }

    init {
        mNotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        mPauseIntent = PendingIntent.getBroadcast(
            context,
            NOTIFICATION_REQUEST_CODE,
            Intent(ACTION_PAUSE).setPackage(context.packageName),
            PendingIntent.FLAG_IMMUTABLE
        )
        mPlayIntent = PendingIntent.getBroadcast(
            context,
            NOTIFICATION_REQUEST_CODE,
            Intent(ACTION_PLAY).setPackage(context.packageName),
            PendingIntent.FLAG_IMMUTABLE
        )
        mPreviousIntent = PendingIntent.getBroadcast(
            context,
            NOTIFICATION_REQUEST_CODE,
            Intent(ACTION_PREV).setPackage(context.packageName),
            PendingIntent.FLAG_IMMUTABLE
        )
        mNextIntent = PendingIntent.getBroadcast(
            context,
            NOTIFICATION_REQUEST_CODE,
            Intent(ACTION_NEXT).setPackage(context.packageName),
            PendingIntent.FLAG_IMMUTABLE
        )
        mStopIntent = PendingIntent.getBroadcast(
            context,
            NOTIFICATION_REQUEST_CODE,
            Intent(ACTION_STOP).setPackage(context.packageName),
            PendingIntent.FLAG_IMMUTABLE
        )
        mOpenAppIntent = PendingIntent.getActivity(
            context,
            NOTIFICATION_REQUEST_CODE,
            context.packageManager.getLaunchIntentForPackage(context.packageName),
            PendingIntent.FLAG_IMMUTABLE
        )
        mNotificationManager?.cancelAll()
    }

    fun showNotification(player: PlayerManager, song: Song) {
        mPlayer = player;
        mSong = song
        val intent = Intent(context, AudioNotificationServer::class.java)
        context.bindService(intent, mConnection, Context.BIND_AUTO_CREATE)
    }

    fun updateNotification(player: PlayerManager, song: Song) {
        mPlayer = player;
        mSong = song
        if (mService != null) {
            val notification = mHelper.generateNotification(player, song)
            mNotificationManager?.notify(NOTIFICATION_ID, notification)
        }
    }

    fun cancelNotification() {
        if (mService != null) {
            context.unbindService(mConnection)
            mService?.unregisterReceiver(this@AudioNotificationManager)
            mService?.stopForeground(true)
            mPlayer?.getMediaSession()?.isActive = false
        }
    }

    fun setCallback(callback: AudioNotificationEventCallback) {
        mCallback = callback
    }

    override fun onReceive(context: Context?, intent: Intent) {
        when (intent.action) {
            ACTION_PAUSE -> mCallback?.onReceivePause()
            ACTION_PLAY -> mCallback?.onReceivePlay()
            ACTION_NEXT -> mCallback?.onReceiveSkipToNext()
            ACTION_PREV -> mCallback?.onReceiveSkipToPrevious()
            ACTION_STOP -> mCallback?.onReceiveStop()
        }
    }

    inner class NotificationHelper {
        private var mNotificationBuilder: NotificationCompat.Builder? = null

        private var mSong: Song? = null

        fun generateNotification(player: PlayerManager, song: Song): Notification? {
            if (mNotificationBuilder == null) {

                val style = androidx.media.app.NotificationCompat.MediaStyle()
                if (player.getMediaSession() != null) {
                    style.setMediaSession(player.getMediaSession()?.sessionToken)
                    mPlayer?.getMediaSession()?.isActive = true
                }
                style.setShowActionsInCompactView(0, 1, 2)

                mNotificationBuilder = NotificationCompat.Builder(context, CHANNEL_ID)
                mNotificationBuilder?.apply {
                    setSmallIcon(R.drawable.ic_launcher)
                    setDeleteIntent(mStopIntent)
                    setContentIntent(mOpenAppIntent)
                    setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                    setCategory(NotificationCompat.CATEGORY_TRANSPORT)
                    setOnlyAlertOnce(true)
                    setStyle(style)
                }

                // Notification channels are only supported on Android O+.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    createNotificationChannel()
                }
            }

            mNotificationBuilder?.apply {
                if (mSong?.title != song.title) {
                    setContentTitle(song.title ?: "")
                }
                if (mSong?.artist != song.artist) {
                    setContentText(song.artist ?: "")
                }
                // 更新音频时长
                val metadata = MediaMetadataCompat.Builder().apply {
                    putLong(
                        MediaMetadataCompat.METADATA_KEY_DURATION,
                        player.getDuration().toLong()
                    )
                }
                player.getMediaSession()?.setMetadata(metadata.build())

                // 更新播放进度
                val playBackState = PlaybackStateCompat.Builder().apply {
                    setActions(PlaybackStateCompat.ACTION_PLAY or PlaybackStateCompat.ACTION_PAUSE)
                    if (player.isPlaying()) {
                        setState(
                            PlaybackStateCompat.STATE_PLAYING,
                            player.getCurrentPosition().toLong(),
                            player.getPlaybackRate().toFloat(),
                        )
                    } else {
                        setState(
                            PlaybackStateCompat.STATE_PAUSED,
                            player.getCurrentPosition().toLong(),
                            player.getPlaybackRate().toFloat(),
                        )
                    }

                }
                player.getMediaSession()?.setPlaybackState(playBackState.build())

                // 更新封面图片
                if (mSong?.clipArt != song.clipArt) {
                    var bitmap: Bitmap? = null
                    try {
                        val data = Base64.decode(song.clipArt ?: "", Base64.DEFAULT)
                        bitmap = BitmapFactory.decodeByteArray(data, 0, data.size)
                    } finally {
                        setLargeIcon(
                            bitmap ?: BitmapFactory.decodeResource(
                                context.resources,
                                R.drawable.ic_launcher
                            )
                        )
                    }
                }

                // 更新按钮
                clearActions()
                addAction(android.R.drawable.ic_media_previous, "previous", mPreviousIntent)
                if (player.isPlaying()) {
                    addAction(android.R.drawable.ic_media_pause, "pause", mPauseIntent)
                } else {
                    addAction(android.R.drawable.ic_media_play, "play", mPlayIntent)
                }
                addAction(android.R.drawable.ic_media_next, "next", mNextIntent);
            }

            mSong = song

            return mNotificationBuilder?.build()
        }

        @RequiresApi(Build.VERSION_CODES.O)
        fun createNotificationChannel() {
            if (mNotificationManager?.getNotificationChannel(CHANNEL_ID) == null) {
                val notificationChannel = NotificationChannel(
                    CHANNEL_ID, "PlayerChannel",
                    NotificationManager.IMPORTANCE_LOW
                )
                notificationChannel.description = "PlayerChannel"
                mNotificationManager?.createNotificationChannel(notificationChannel)
            }
        }


    }

    companion object {
        private const val ACTION_PAUSE = "app.pause"
        private const val ACTION_PLAY = "app.play"
        private const val ACTION_PREV = "app.prev"
        private const val ACTION_NEXT = "app.next"
        private const val ACTION_STOP = "app.stop"

        private const val CHANNEL_ID = "app.MUSIC_CHANNEL_ID"

        private const val NOTIFICATION_ID = 618
        private const val NOTIFICATION_REQUEST_CODE = 1618
    }

    interface AudioNotificationEventCallback {
        fun onReceivePlay()

        fun onReceivePause()

        fun onReceiveSkipToNext()

        fun onReceiveSkipToPrevious()

        fun onReceiveStop()
    }
}