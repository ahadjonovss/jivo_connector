package uz.alif.jivo_connector

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.jivosite.sdk.Jivo
import com.jivosite.sdk.model.pojo.CustomData
import com.jivosite.sdk.push.JivoPushProvider
import com.jivosite.sdk.support.builders.ContactInfo
import com.jivosite.sdk.ui.chat.JivoChatActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * The Android half of `JivoConnector`.
 *
 * The SDK is already started by [JivoInitializer]; this only passes calls on.
 * Pushes come in from Dart rather than from a messaging service of our own, so
 * the app's single FCM service (`firebase_messaging`'s) stays the only one.
 */
class JivoConnectorPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {

    private lateinit var methods: MethodChannel
    private lateinit var unread: EventChannel
    private lateinit var context: Context
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methods = MethodChannel(binding.binaryMessenger, "jivo_connector")
        methods.setMethodCallHandler(this)
        unread = EventChannel(binding.binaryMessenger, "jivo_connector/unread")
        unread.setStreamHandler(UnreadStream())
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methods.setMethodCallHandler(null)
        unread.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setup" -> {
                Jivo.setData(
                    widgetId = call.argument<String>("channelId").orEmpty(),
                    userToken = call.argument<String>("userToken").orEmpty(),
                )
                result.success(null)
            }

            "setContactInfo" -> {
                Jivo.setContactInfo(
                    ContactInfo(
                        name = call.argument<String>("name"),
                        email = call.argument<String>("email").orEmpty(),
                        phone = call.argument<String>("phone").orEmpty(),
                        description = call.argument<String>("brief"),
                    ),
                )
                result.success(null)
            }

            "setCustomData" -> {
                val fields = call.arguments<List<Map<String, String>>>().orEmpty()
                Jivo.setCustomData(
                    fields.map {
                        CustomData(
                            content = it["content"].orEmpty(),
                            title = it["title"].orEmpty(),
                            link = it["link"].orEmpty(),
                            key = it["key"].orEmpty(),
                        )
                    },
                )
                result.success(null)
            }

            "open" -> {
                open()
                result.success(null)
            }

            "clear" -> {
                Jivo.clear()
                result.success(null)
            }

            "setPushToken" -> {
                val token = call.arguments<String>()
                if (!token.isNullOrBlank()) {
                    Jivo.subscribeToPush(token, JivoPushProvider.FCM)
                }
                result.success(null)
            }

            "handlePush" -> {
                val data = call.arguments<Map<String, String>>().orEmpty()
                result.success(Jivo.handleRemoteMessage(data))
            }

            else -> result.notImplemented()
        }
    }

    /**
     * The SDK's own chat activity, started from the app's activity when there
     * is one so it lands in the same task and "back" returns to the app.
     */
    private fun open() {
        val from = activity
        if (from != null) {
            from.startActivity(Intent(from, JivoChatActivity::class.java))
        } else {
            context.startActivity(
                Intent(context, JivoChatActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        }
    }
}
