import Flutter
import JivoSDK

/// Feeds `hasUnread` on the Dart side.
///
/// The SDK counts unread messages, but Android can only say whether there are
/// any, so the count is reduced to that flag here too. The SDK keeps a single
/// counter callback, so a new listener simply replaces the old one.
final class UnreadStream: NSObject, FlutterStreamHandler {
    private var sink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        Jivo.session.listenToUnreadCounter { [weak self] number in
            DispatchQueue.main.async {
                self?.sink?(number > 0)
            }
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}
