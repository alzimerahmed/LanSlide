package com.alzimerahmed.lanslide

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log

/**
 * Foreground service that keeps the LanSlide receive server alive while the app is
 * in the background, so incoming transfers survive aggressive OEM battery savers
 * (see https://dontkillmyapp.com/ for per-vendor behavior).
 *
 * The Dart side starts this service when the HTTP server starts and stops it when
 * the server stops (see MainActivity channel methods "startReceiveForegroundService"
 * / "stopReceiveForegroundService").
 *
 * The service itself does not run the server; the server lives in the Dart isolate
 * inside the main process. The foreground service only raises the process priority
 * and shows a persistent notification while receiving is enabled.
 *
 * FOSS note: plain Android Service, no GMS/proprietary dependencies.
 */
class ReceiveForegroundService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }

        startAsForeground()
        // START_STICKY: if the system kills us anyway, try to come back so the
        // notification (and the elevated process priority) is restored.
        return START_STICKY
    }

    private fun startAsForeground() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun buildNotification(): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val contentIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        // Plain literals on purpose: i18n files are owned elsewhere; strings are
        // minimal and language-neutral enough for a status notification.
        return builder
            .setSmallIcon(R.mipmap.ic_launcher_quicktile_foreground)
            .setContentTitle("LanSlide")
            .setContentText("Ready to receive files")
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "File transfer",
                NotificationManager.IMPORTANCE_LOW,
            )
            channel.description = "Shows when LanSlide is ready to receive files"
            channel.setShowBadge(false)
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    companion object {
        private const val TAG = "ReceiveForegroundSvc"
        const val ACTION_START = "com.alzimerahmed.lanslide.action.START_RECEIVE_SERVICE"
        const val ACTION_STOP = "com.alzimerahmed.lanslide.action.STOP_RECEIVE_SERVICE"
        private const val CHANNEL_ID = "lanslide_receive"
        private const val NOTIFICATION_ID = 4711

        fun start(context: android.content.Context) {
            val intent = Intent(context, ReceiveForegroundService::class.java).setAction(ACTION_START)
            try {
                context.startForegroundService(intent)
            } catch (e: Exception) {
                // Can happen when the app is in the background on Android 12+.
                Log.w(TAG, "Could not start foreground service", e)
            }
        }

        fun stop(context: android.content.Context) {
            val intent = Intent(context, ReceiveForegroundService::class.java).setAction(ACTION_STOP)
            context.startService(intent)
        }
    }
}
