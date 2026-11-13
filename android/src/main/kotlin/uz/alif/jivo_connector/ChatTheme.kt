package uz.alif.jivo_connector

import android.app.Activity
import android.app.Application
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import com.jivosite.sdk.ui.chat.JivoChatActivity

/**
 * Gives the SDK's chat screen the night mode the app asked for.
 *
 * The SDK has no setting for it and follows the device. The mode is set on the
 * chat activity alone, so the app's own screens and any other AppCompat
 * activity keep theirs.
 */
internal object ChatTheme : Application.ActivityLifecycleCallbacks {

    var nightMode = AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM

    /** Before `onCreate`, so the screen is drawn in the right mode at once. */
    override fun onActivityPreCreated(activity: Activity, savedInstanceState: Bundle?) {
        apply(activity)
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        apply(activity)
    }

    private fun apply(activity: Activity) {
        if (activity is JivoChatActivity) {
            (activity as AppCompatActivity).delegate.localNightMode = nightMode
        }
    }

    override fun onActivityStarted(activity: Activity) = Unit
    override fun onActivityResumed(activity: Activity) = Unit
    override fun onActivityPaused(activity: Activity) = Unit
    override fun onActivityStopped(activity: Activity) = Unit
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) = Unit
    override fun onActivityDestroyed(activity: Activity) = Unit
}
