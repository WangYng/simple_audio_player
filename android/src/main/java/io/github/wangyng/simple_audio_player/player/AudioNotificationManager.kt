package io.github.wangyng.simple_audio_player.player

import android.app.*
import android.content.*
import android.graphics.BitmapFactory
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import io.github.wangyng.simple_audio_player.R
import java.io.File

class AudioNotificationManager(private val context: Context) : BroadcastReceiver() {

    private var mNotificationManager: NotificationManager? = null
    private var mCallback: AudioNotificationEventCallback? = null

    private var mSong: Song? = null

    private val mPlayIntent: PendingIntent
    private val mPauseIntent: PendingIntent
    private val mPreviousIntent: PendingIntent
    private val mNextIntent: PendingIntent
    private val mStopIntent: PendingIntent
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
            binder.service.registerReceiver(this@AudioNotificationManager, filter)
            binder.service.startForeground(NOTIFICATION_ID, mHelper.generateNotification(mSong, true))
        }

        override fun onServiceDisconnected(classname: ComponentName) {
            mService = null
        }
    }

    init {
        mNotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        mPauseIntent = PendingIntent.getBroadcast(
                context, NOTIFICATION_REQUEST_CODE,
                Intent(ACTION_PAUSE).setPackage(context.packageName), PendingIntent.FLAG_CANCEL_CURRENT
        )
        mPlayIntent = PendingIntent.getBroadcast(
                context, NOTIFICATION_REQUEST_CODE,
                Intent(ACTION_PLAY).setPackage(context.packageName), PendingIntent.FLAG_CANCEL_CURRENT
        )
        mPreviousIntent = PendingIntent.getBroadcast(
                context, NOTIFICATION_REQUEST_CODE,
                Intent(ACTION_PREV).setPackage(context.packageName), PendingIntent.FLAG_CANCEL_CURRENT
        )
        mNextIntent = PendingIntent.getBroadcast(
                context, NOTIFICATION_REQUEST_CODE,
                Intent(ACTION_NEXT).setPackage(context.packageName), PendingIntent.FLAG_CANCEL_CURRENT
        )
        mStopIntent = PendingIntent.getBroadcast(
                context, NOTIFICATION_REQUEST_CODE,
                Intent(ACTION_STOP).setPackage(context.packageName), PendingIntent.FLAG_CANCEL_CURRENT
        )
        mNotificationManager?.cancelAll()
    }

    fun showNotification(song: Song?) {
        mSong = song
        val intent = Intent(context, AudioNotificationServer::class.java)
        context.bindService(intent, mConnection, Context.BIND_AUTO_CREATE)
    }

    fun updateNotification(showPlay: Boolean, song: Song?) {
        mSong = song
        if (mService != null) {
            val notification = mHelper.generateNotification(song, showPlay)
            mNotificationManager?.notify(NOTIFICATION_ID, notification)
        }
    }

    fun cancelNotification() {
        if (mService != null) {
            context.unbindService(mConnection)
            mService?.unregisterReceiver(this@AudioNotificationManager)
            mService?.stopForeground(true)
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

        fun generateNotification(song: Song?, showPlayIcon: Boolean): Notification? {
            mSong = song

            if (mNotificationBuilder == null) {
                mNotificationBuilder = NotificationCompat.Builder(context, CHANNEL_ID)
                mNotificationBuilder?.setSmallIcon(R.drawable.itunes)
                        ?.setLargeIcon(BitmapFactory.decodeResource(context.resources, R.drawable.itunes))
                        ?.setContentTitle(context.getString(R.string.app_name))
                        ?.setContentText(context.getString(R.string.app_name))
                        ?.setDeleteIntent(mStopIntent)
                        ?.setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                        ?.setCategory(NotificationCompat.CATEGORY_TRANSPORT)
                        ?.setOnlyAlertOnce(true)

                // Notification channels are only supported on Android O+.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    createNotificationChannel()
                }
            }

            val collapsedRemoteViews = RemoteViews(context.packageName, R.layout.player_collapsed_notification)
            mNotificationBuilder?.setCustomContentView(collapsedRemoteViews)
            val expandedRemoteViews = RemoteViews(context.packageName, R.layout.player_expanded_notification)
            mNotificationBuilder?.setCustomBigContentView(expandedRemoteViews)

            mNotificationBuilder?.setOngoing(true)

            createCollapsedRemoteViews(collapsedRemoteViews)
            createExpandedRemoteViews(expandedRemoteViews)

            if (showPlayIcon) {
                collapsedRemoteViews.setViewVisibility(
                        R.id.collapsed_notification_pause_image_view,
                        View.GONE
                )
                collapsedRemoteViews.setViewVisibility(
                        R.id.collapsed_notification_play_image_view,
                        View.VISIBLE
                )
                expandedRemoteViews.setViewVisibility(
                        R.id.expanded_notification_pause_image_view,
                        View.GONE
                )
                expandedRemoteViews.setViewVisibility(
                        R.id.expanded_notification_play_image_view,
                        View.VISIBLE
                )
            } else {
                collapsedRemoteViews.setViewVisibility(
                        R.id.collapsed_notification_pause_image_view,
                        View.VISIBLE
                )
                collapsedRemoteViews.setViewVisibility(
                        R.id.collapsed_notification_play_image_view,
                        View.GONE
                )
                expandedRemoteViews.setViewVisibility(
                        R.id.expanded_notification_pause_image_view,
                        View.VISIBLE
                )
                expandedRemoteViews.setViewVisibility(
                        R.id.expanded_notification_play_image_view,
                        View.GONE
                )
            }

            return mNotificationBuilder?.build()
        }

        private fun createExpandedRemoteViews(expandedRemoteViews: RemoteViews) {
            expandedRemoteViews.setOnClickPendingIntent(
                    R.id.expanded_notification_skip_back_image_view,
                    mPreviousIntent
            )
            expandedRemoteViews.setOnClickPendingIntent(
                    R.id.expanded_notification_clear_image_view,
                    mStopIntent
            )
            expandedRemoteViews.setOnClickPendingIntent(
                    R.id.expanded_notification_pause_image_view,
                    mPauseIntent
            )
            expandedRemoteViews.setOnClickPendingIntent(
                    R.id.expanded_notification_skip_next_image_view,
                    mNextIntent
            )
            expandedRemoteViews.setOnClickPendingIntent(
                    R.id.expanded_notification_play_image_view,
                    mPlayIntent
            )
            expandedRemoteViews.setImageViewResource(
                    R.id.expanded_notification_image_view,
                    R.drawable.placeholder
            )
            mSong?.clipArt?.let {
                if (it.isNotEmpty()) {
                    val bitmap = BitmapFactory.decodeFile(File(it).path)
                    expandedRemoteViews.setImageViewBitmap(R.id.expanded_notification_image_view, bitmap)
                }
            }
            expandedRemoteViews.setViewVisibility(
                    R.id.expanded_notification_skip_next_image_view,
                    View.VISIBLE
            )
            expandedRemoteViews.setViewVisibility(
                    R.id.expanded_notification_skip_back_image_view,
                    View.VISIBLE
            )
            expandedRemoteViews.setTextViewText(
                    R.id.expanded_notification_song_name_text_view,
                    mSong?.title ?: ""
            )
            expandedRemoteViews.setTextViewText(
                    R.id.expanded_notification_singer_name_text_view,
                    mSong?.artist ?: ""
            )
        }

        private fun createCollapsedRemoteViews(collapsedRemoteViews: RemoteViews) {
            collapsedRemoteViews.setOnClickPendingIntent(
                    R.id.collapsed_notification_skip_back_image_view,
                    mPreviousIntent
            )
            collapsedRemoteViews.setOnClickPendingIntent(
                    R.id.collapsed_notification_clear_image_view,
                    mStopIntent
            )
            collapsedRemoteViews.setOnClickPendingIntent(
                    R.id.collapsed_notification_pause_image_view,
                    mPauseIntent
            )
            collapsedRemoteViews.setOnClickPendingIntent(
                    R.id.collapsed_notification_skip_next_image_view,
                    mNextIntent
            )
            collapsedRemoteViews.setOnClickPendingIntent(
                    R.id.collapsed_notification_play_image_view,
                    mPlayIntent
            )
            collapsedRemoteViews.setImageViewResource(
                    R.id.collapsed_notification_image_view,
                    R.drawable.placeholder
            )
            mSong?.clipArt?.let {
                if (it.isNotEmpty()) {
                    val bitmap = BitmapFactory.decodeFile(File(it).path)
                    collapsedRemoteViews.setImageViewBitmap(R.id.collapsed_notification_image_view, bitmap)
                }
            }
            collapsedRemoteViews.setViewVisibility(
                    R.id.collapsed_notification_skip_next_image_view,
                    View.VISIBLE
            )
            collapsedRemoteViews.setViewVisibility(
                    R.id.collapsed_notification_skip_back_image_view,
                    View.VISIBLE
            )
            collapsedRemoteViews.setTextViewText(
                    R.id.collapsed_notification_song_name_text_view,
                    mSong?.title ?: ""
            )
            collapsedRemoteViews.setTextViewText(
                    R.id.collapsed_notification_singer_name_text_view,
                    mSong?.artist ?: ""
            )
        }

        @RequiresApi(Build.VERSION_CODES.O)
        fun createNotificationChannel() {
            if (mNotificationManager?.getNotificationChannel(CHANNEL_ID) == null) {
                val notificationChannel = NotificationChannel(
                        CHANNEL_ID, context.getString(R.string.notification_channel),
                        NotificationManager.IMPORTANCE_LOW
                )
                notificationChannel.description =
                        context.getString(R.string.notification_channel_description)
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