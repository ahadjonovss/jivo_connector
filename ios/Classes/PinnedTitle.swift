import JivoSDK
import UIKit

/// Keeps the first line of the chat header on the app's title.
///
/// The SDK writes the operator's name there once one joins, and has no
/// setting against it. It does hand the header over before the chat opens,
/// and the line is a plain `UILabel`, so its text is watched and put back
/// whenever the SDK changes it.
final class PinnedTitle {
    static let shared = PinnedTitle()

    /// The text to keep, or `nil` to leave the line to the SDK.
    var text: String?

    private var observation: NSKeyValueObservation?

    private init() {}

    /// Once, at registration: the SDK keeps a single header callback.
    func install() {
        Jivo.display.listenToNavigation { [weak self] _, item in
            // Taking the header over skips the SDK's own opaque bar, so it is
            // set up here the way the SDK would have.
            Self.configureOpaque(item)
            self?.watch(item)
        }
    }

    private func watch(_ item: UINavigationItem) {
        // The SDK puts its header in `subtitleView` where the app is designed
        // for Liquid Glass, and in `titleView` everywhere else.
        var header = item.titleView
        #if compiler(>=6.2)
        if #available(iOS 26.0, *), header == nil {
            header = item.subtitleView
        }
        #endif
        // Laid out as icon, title, subtitle: the first label is the title.
        guard let label = header?.subviews.lazy.compactMap({ $0 as? UILabel }).first
        else { return }

        observation = label.observe(\.text, options: [.initial, .new]) { [weak self] label, _ in
            guard let text = self?.text, label.text != text else { return }
            label.text = text
        }
    }

    private static func configureOpaque(_ item: UINavigationItem) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        item.standardAppearance = appearance
        item.compactAppearance = appearance
        item.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            item.compactScrollEdgeAppearance = appearance
        }
    }
}
