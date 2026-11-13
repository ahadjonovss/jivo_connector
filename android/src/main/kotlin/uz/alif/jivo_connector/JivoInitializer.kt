package uz.alif.jivo_connector

import android.app.Application
import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import com.jivosite.sdk.Jivo

/**
 * Calls `Jivo.init` once, when the app's process starts.
 *
 * The SDK wants to be started from `Application.onCreate` and only in the main
 * process. A provider is created right before that, in the main process only,
 * so the app needs no `Application` class of its own for it. Starting it from
 * the plugin instead would run it again for every Flutter engine, including
 * the one `firebase_messaging` spins up for background pushes.
 *
 * It holds no data: every query answers nothing.
 */
class JivoInitializer : ContentProvider() {

    override fun onCreate(): Boolean {
        val context = context ?: return false
        Jivo.init(context.applicationContext)
        (context.applicationContext as? Application)?.run {
            registerActivityLifecycleCallbacks(ChatTheme)
            registerActivityLifecycleCallbacks(ChatTitle)
        }
        return true
    }

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?,
    ): Cursor? = null

    override fun getType(uri: Uri): String? = null

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0

    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<out String>?,
    ): Int = 0
}
