import Flutter
import JivoSDK

/// Feeds `unreadCount` and `hasUnread` on the Dart side with the SDK's count
/// of unread messages. The SDK keeps a single counter callback, so a new
/// listener simply replaces the old one.
final class UnreadStream: NSObject, FlutterStreamHandler {
    private var sink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        Jivo.session.listenToUnreadCounter { [weak self] number in
            DispatchQueue.main.async {
                self?.sink?(number)
            }
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}
