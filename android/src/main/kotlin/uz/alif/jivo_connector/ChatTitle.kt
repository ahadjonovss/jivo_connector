package uz.alif.jivo_connector

import android.app.Activity
import android.app.Application
import android.os.Bundle
import androidx.appcompat.widget.Toolbar
import com.jivosite.sdk.ui.chat.JivoChatActivity

/**
 * Keeps the chat toolbar's title on the app's one.
 *
 * The SDK swaps it for the operator's name once one joins, and has no setting
 * against it. So the toolbar is checked before each frame and its title put
 * back whenever the SDK has changed it.
 */
internal object ChatTitle : Application.ActivityLifecycleCallbacks {

    /** The title to keep, or `null` to leave the toolbar to the SDK. */
    var text: String? = null

    /**
     * Resumed rather than created: the toolbar lives in the SDK's fragment,
     * whose view is there by now, and a chat brought back to the front has
     * kept its listener — the tag says so.
     */
    override fun onActivityResumed(activity: Activity) {
        if (activity !is JivoChatActivity) return
        val toolbar = activity.findViewById<Toolbar>(com.jivosite.sdk.R.id.toolbar) ?: return
        if (toolbar.getTag(R.id.jivo_connector_title_kept) != null) return
        toolbar.setTag(R.id.jivo_connector_title_kept, true)
        toolbar.viewTreeObserver.addOnPreDrawListener { keep(toolbar) }
    }

    /** Skips the frame that would show the SDK's title, and draws ours. */
    private fun keep(toolbar: Toolbar): Boolean {
        val text = text ?: return true
        if (toolbar.title?.toString() == text) return true
        toolbar.title = text
        return false
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) = Unit
    override fun onActivityStarted(activity: Activity) = Unit
    override fun onActivityPaused(activity: Activity) = Unit
    override fun onActivityStopped(activity: Activity) = Unit
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) = Unit
    override fun onActivityDestroyed(activity: Activity) = Unit
}
