import Flutter
import JivoSDK

/// Feeds `hasUnread` on the Dart side. The SDK calls it a counter, but it
/// only ever reports 1 or 0. It keeps a single counter callback, so a new
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
