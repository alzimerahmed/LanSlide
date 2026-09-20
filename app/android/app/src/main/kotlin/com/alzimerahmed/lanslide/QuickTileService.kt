package com.alzimerahmed.lanslide

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Log
import androidx.annotation.RequiresApi

/**
 * Quick Settings tile that toggles LanSlide receive mode (the HTTP receive server).
 *
 * How it works:
 * - The Dart side reports the actual server state to this service via the
 *   "notifyServerState" platform channel method (see MainActivity), which persists
 *   it in [PREFS_NAME]. This is the single source of truth for the tile icon.
 * - On click, the tile flips the persisted state optimistically and launches
 *   MainActivity with the [EXTRA_STOP_RECEIVE] extra. The Dart side consumes
 *   that extra ("consumePendingStopReceive" channel method) and stops the server
 *   after launch. Starting needs no extra: the app auto-starts the server from
 *   settings on launch.
 *
 * Why launch the app instead of starting the server directly from the tile:
 * the server runs inside the Flutter/Dart isolate together with the Rust core
 * and its sync state (IsolateSyncServerStateAction must be published before the
 * server starts). Bootstrapping that whole stack headless from a TileService in
 * a separate process is fragile; launching the existing, singleTask activity is
 * robust and works whether or not the app process is already alive (the app
 * auto-starts the server from settings on launch, and the pending toggle is
 * applied right after).
 *
 * @see https://github.com/ProtonVPN/android-app/blob/2290b3c6b8b5ded339d69ec7c12e15acbb4b4b3d/app/src/main/java/com/protonvpn/android/components/QuickTileService.kt#L171
 */
@RequiresApi(Build.VERSION_CODES.N)
class QuickTileService : TileService() {

    override fun onClick() {
        super.onClick()

        // Flip the persisted state optimistically; Dart reports the real state
        // back via "notifyServerState" once it applied it.
        val running = isServerRunning()
        val newState = !running
        setServerRunning(newState)
        updateTile(newState)
        // Starting the server needs no extra: the app auto-starts the server
        // from settings on launch. Stopping requires the extra below.
        launchAppWithToggle(stopReceive = !newState)
    }

    override fun onStartListening() {
        super.onStartListening()
        updateTile(isServerRunning())
    }

    private fun updateTile(running: Boolean) {
        val tile = qsTile ?: return
        tile.icon = Icon.createWithResource(this, R.mipmap.ic_launcher_quicktile_foreground)
        tile.label = packageManager.getApplicationLabel(applicationInfo)
        tile.state = if (running) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        tile.updateTile()
    }

    private fun isServerRunning(): Boolean {
        return getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(PREF_SERVER_RUNNING, false)
    }

    private fun setServerRunning(running: Boolean) {
        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(PREF_SERVER_RUNNING, running)
            .apply()
    }

    /// Called from Dart (MainActivity channel method "notifyServerState") whenever
    /// the actual server state changes, so the tile always reflects reality.
    companion object {
        private const val PREFS_NAME = "lanslide_tile"
        private const val PREF_SERVER_RUNNING = "server_running"
        const val EXTRA_STOP_RECEIVE = "stop_receive"

        fun setServerState(context: Context, running: Boolean) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(PREF_SERVER_RUNNING, running)
                .apply()
            // Ask the system to re-bind the tile so the icon refreshes even when
            // the tile panel is currently visible.
            TileService.requestListeningState(
                context,
                ComponentName(context, QuickTileService::class.java),
            )
        }
    }

    @SuppressLint("StartActivityAndCollapseDeprecated")
    private fun launchAppWithToggle(stopReceive: Boolean) {
        try {
            val launchIntent = getLaunchIntent()
            if (stopReceive) {
                launchIntent.putExtra(EXTRA_STOP_RECEIVE, true)
            }
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                // Starting from `Build.VERSION_CODES.UPSIDE_DOWN_CAKE` we can
                // no longer start and collapse an Intent. We need to use a
                // PendingIntent instead.
                startActivityAndCollapse(
                    PendingIntent.getActivity(
                        this,
                        0,
                        launchIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                    )
                )
            } else {
                // For any version below `Build.VERSION_CODES.UPSIDE_DOWN_CAKE`
                // we can simply start the intent directly.
                startActivityAndCollapse(launchIntent)
            }
        } catch (e: Exception) {
            Log.w(this.javaClass.toString(), "Exception $e")
        }
    }

    private fun getLaunchIntent(): Intent {
        // Getting the launch intent from the package manager is the optimal
        // way to get the proper intent to launch the app.
        val cleanIntent = packageManager.getLaunchIntentForPackage(packageName)

        return if (cleanIntent != null) {
            cleanIntent
        } else {
            // If we can't get the launch intent from the PM, then we default
            // back to creating one by instantiating the app intent ourself.
            val dirtyIntent = MainActivity.createDefaultIntent(this)
            dirtyIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            dirtyIntent
        }
    }
}
