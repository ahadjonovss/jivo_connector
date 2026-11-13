import 'dart:ui';

/// What the chat screen and Jivo's notifications say and look like.
///
/// Every field is optional: whatever is left `null` stays as the SDK has it,
/// which for texts means what is set for the channel in Jivo's panel.
///
/// The two SDKs can be told different things. The fields both of them take
/// come first; the rest say which platform they are for and do nothing on
/// the other.
class JivoAppearance {
  const JivoAppearance({
    this.title,
    this.subtitle,
    this.welcomeMessage,
    this.offlineMessage,
    this.inputPlaceholder,
    this.titleColor,
    this.subtitleColor,
    this.accentColor,
    this.headerIcon,
    this.locale,
    this.notificationTitle,
    this.notificationIcon,
    this.notificationColor,
    this.notificationSound,
    this.showBotLabel,
    this.showOperatorInTitle = true,
  });

  /// The first line of the chat screen's header.
  final String? title;

  /// The second line of the chat screen's header.
  final String? subtitle;

  /// The message the chat greets the client with.
  final String? welcomeMessage;

  /// The message shown while no operator is online.
  final String? offlineMessage;

  /// The hint in the empty message field. iOS only.
  final String? inputPlaceholder;

  /// The colour of [title]. iOS only.
  final Color? titleColor;

  /// The colour of [subtitle]. iOS only.
  final Color? subtitleColor;

  /// The colour of the client's own messages and controls. iOS only.
  final Color? accentColor;

  /// The picture in the header, as a Flutter asset path declared in the
  /// app's `pubspec.yaml`, like `assets/images/support.png`. iOS only.
  final String? headerIcon;

  /// The language of the SDK's own captions. iOS only: on Android they
  /// follow the app's language.
  final Locale? locale;

  /// The title of the notification about a new message. Android only: on
  /// iOS it is `JV_MESSAGE_TITLE` in the app's `Localizable.strings`.
  final String? notificationTitle;

  /// The notification's small icon, as the name of a drawable in the app's
  /// Android resources, like `ic_notification`. Android only.
  final String? notificationIcon;

  /// The tint of the notification's icon, as the name of a colour in the
  /// app's Android resources, like `notification`. Android only.
  final String? notificationColor;

  /// The notification's sound, as the name of a file in the app's
  /// `res/raw`, without the extension. Android only.
  final String? notificationSound;

  /// Whether replies from Jivo's bot carry a "bot" label. Android only.
  final bool? showBotLabel;

  /// Whether the header's first line turns into the operator's name once one
  /// joins, which both SDKs do and neither lets you switch off. `false` keeps
  /// [title] there for good; it needs [title] to keep.
  ///
  /// Done around the SDKs rather than through them: the plugin watches the
  /// header and puts the title back whenever the SDK changes it.
  final bool showOperatorInTitle;

  Map<String, Object?> toMap() => {
    'title': title,
    'subtitle': subtitle,
    'welcomeMessage': welcomeMessage,
    'offlineMessage': offlineMessage,
    'inputPlaceholder': inputPlaceholder,
    'titleColor': titleColor?.toARGB32(),
    'subtitleColor': subtitleColor?.toARGB32(),
    'accentColor': accentColor?.toARGB32(),
    'headerIcon': headerIcon,
    'locale': locale?.toLanguageTag(),
    'notificationTitle': notificationTitle,
    'notificationIcon': notificationIcon,
    'notificationColor': notificationColor,
    'notificationSound': notificationSound,
    'showBotLabel': showBotLabel,
    'showOperatorInTitle': showOperatorInTitle,
  };
}
