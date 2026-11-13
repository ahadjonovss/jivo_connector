package uz.alif.jivo_connector

import android.os.Handler
import android.os.Looper
import com.jivosite.sdk.Jivo
import com.jivosite.sdk.model.repository.history.NewMessageListener
import io.flutter.plugin.common.EventChannel

/**
 * Feeds `hasUnread` on the Dart side. A flag rather than a count, which is
 * all the SDK reports on Android.
 *
 * The SDK keeps its listeners as weak references and offers no way to remove
 * one, so the listener lives exactly as long as this object holds it: dropping
 * it on cancel is what unsubscribes.
 */
class UnreadStream : EventChannel.StreamHandler {

    private val main = Handler(Looper.getMainLooper())
    private var listener: NewMessageListener? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        listener = object : NewMessageListener {
            // The SDK may report from a worker thread; the sink takes the main one only.
            override fun onNewMessage(hasUnread: Boolean) {
                main.post { events.success(hasUnread) }
            }
        }.also(Jivo::addNewMessageListener)
    }

    override fun onCancel(arguments: Any?) {
        listener = null
    }
}
