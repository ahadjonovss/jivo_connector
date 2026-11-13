import Flutter
import JivoSDK
import UIKit
import UserNotifications

/// The iOS half of `JivoConnector`.
///
/// Besides passing calls on, it takes part in the app's lifecycle: Jivo sends
/// its pushes through APNs on its own, so the APNs token, the launch from a
/// push and the pushes themselves reach the SDK here, with no code in the
/// app's `AppDelegate` beyond what Flutter already forwards to plugins.
public final class JivoConnectorPlugin: NSObject, FlutterPlugin {
    /// Resolves the Flutter assets `setAppearance` names.
    private let registrar: FlutterPluginRegistrar

    private init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let plugin = JivoConnectorPlugin(registrar: registrar)
        let methods = FlutterMethodChannel(name: "jivo_connector", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(plugin, channel: methods)
        FlutterEventChannel(name: "jivo_connector/unread", binaryMessenger: registrar.messenger())
            .setStreamHandler(UnreadStream())
        registrar.addApplicationDelegate(plugin)
        PinnedTitle.shared.install()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setup":
            let args = call.arguments as? [String: String] ?? [:]
            let token = args["userToken"] ?? ""
            // An empty token is an anonymous client, not a JWT that is empty.
            _ = Jivo.session.setup(
                widgetID: args["channelId"] ?? "",
                clientIdentity: token.isEmpty ? .anonymous : .jwt(token)
            )
            result(nil)

        case "setContactInfo":
            let args = call.arguments as? [String: String] ?? [:]
            Jivo.session.setContactInfo(JVSessionContactInfo(
                name: args["name"],
                email: args["email"],
                phone: args["phone"],
                brief: args["brief"]
            ))
            result(nil)

        case "setCustomData":
            let fields = call.arguments as? [[String: String]] ?? []
            Jivo.session.setCustomData(fields: fields.map {
                JVSessionCustomDataField(
                    title: $0["title"],
                    key: $0["key"],
                    content: $0["content"] ?? "",
                    link: $0["link"]
                )
            })
            result(nil)

        case "setTheme":
            switch call.arguments as? String {
            case "light": Jivo.display.setTheme(.light)
            case "dark": Jivo.display.setTheme(.dark)
            default: Jivo.display.setTheme(.unspecified)
            }
            result(nil)

        case "setAppearance":
            setAppearance(call.arguments as? [String: Any] ?? [:])
            result(nil)

        case "open":
            if let top = topViewController() {
                Jivo.display.present(over: top)
            }
            result(nil)

        case "clear":
            Jivo.session.shutDown()
            result(nil)

        case "setPushToken":
            // The token here is FCM's; Jivo on iOS wants APNs', which comes in
            // through `didRegisterForRemoteNotificationsWithDeviceToken`.
            result(nil)

        case "handlePush":
            // Jivo pushes on iOS never pass through FCM, so none is Jivo's here.
            result(false)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Applies every field, `nil` included, so a field left out goes back to
    /// the SDK's own. The Android-only ones are not read here.
    private func setAppearance(_ args: [String: Any]) {
        let display = Jivo.display
        display.define(text: args["title"] as? String, forElement: .headerTitle)
        display.define(text: args["subtitle"] as? String, forElement: .headerSubtitle)
        display.define(text: args["welcomeMessage"] as? String, forElement: .messageWelcome)
        display.define(text: args["offlineMessage"] as? String, forElement: .messageOffline)
        display.define(text: args["inputPlaceholder"] as? String, forElement: .replyPlaceholder)
        display.define(color: color(args["titleColor"]), forElement: .headerTitle)
        display.define(color: color(args["subtitleColor"]), forElement: .headerSubtitle)
        display.define(color: color(args["accentColor"]), forElement: .outgoingElements)
        display.define(image: image(args["headerIcon"]), forElement: .headerIcon)
        PinnedTitle.shared.text = (args["showOperatorInTitle"] as? Bool) == false
            ? args["title"] as? String
            : nil
        // Dart sends a BCP 47 tag, `en-US`; Foundation's identifiers use `_`.
        let locale = (args["locale"] as? String)
            .map { Locale(identifier: $0.replacingOccurrences(of: "-", with: "_")) }
        display.setLocale(locale)
    }

    /// A colour Dart sent as a 32-bit ARGB number.
    private func color(_ value: Any?) -> UIColor? {
        guard let argb = (value as? NSNumber)?.uint32Value else { return nil }
        return UIColor(
            red: CGFloat((argb >> 16) & 0xFF) / 255,
            green: CGFloat((argb >> 8) & 0xFF) / 255,
            blue: CGFloat(argb & 0xFF) / 255,
            alpha: CGFloat((argb >> 24) & 0xFF) / 255
        )
    }

    /// An image from the app's Flutter assets, by the path in its pubspec.
    private func image(_ value: Any?) -> UIImage? {
        guard let asset = value as? String else { return nil }
        let key = registrar.lookupKey(forAsset: asset)
        guard let path = Bundle.main.path(forResource: key, ofType: nil) else { return nil }
        return UIImage(contentsOfFile: path)
    }

    /// The controller on top of everything, so the chat opens over whatever
    /// the app is showing, a sheet included.
    private func topViewController() -> UIViewController? {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        var top = window?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    // MARK: - Application lifecycle

    /// Always answers `true`: Flutter makes the app's own answer `false` if any
    /// plugin says so, and that would cost the app every other launch option
    /// (opening by a link, say) whenever the launch was not a Jivo push.
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]
    ) -> Bool {
        // Flutter passes the keys on as plain strings, not as `LaunchOptionsKey`.
        if let push = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification.rawValue] {
            _ = Jivo.notifications.handleLaunch(options: [.remoteNotification: push])
        }
        return true
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Jivo.notifications.setPushToken(data: deviceToken)
    }

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Jivo.notifications.setPushToken(error: error)
    }

    /// `true` only for Jivo's pushes, which the SDK then completes itself;
    /// anything else is left to the plugins after this one.
    public func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) -> Bool {
        return Jivo.notifications.handleIncoming(userInfo: userInfo, completionHandler: completionHandler)
    }

    // MARK: - User notifications
    //
    // Flutter hands these to every plugin. Each answers only for Jivo's own
    // notifications and keeps silent on the rest, so the completion handler is
    // still called exactly once, by whichever plugin the notification is for.

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if let options = Jivo.notifications.willPresent(notification: notification, preferableOptions: [.banner, .list, .sound]) {
            completionHandler(options)
        }
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if Jivo.notifications.didReceive(response: response) {
            completionHandler()
        }
    }
}
