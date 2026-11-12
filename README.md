# jivo_connector

Jivo support chat for Flutter apps: a thin bridge to the native Jivo Mobile SDK
on Android and iOS. Written instead of Jivo's own `jvsdk_plugin`, which pins
old Firebase versions and registers an FCM service of its own.

## Installation

```bash
flutter pub add jivo_connector
```

Then wire it into the app as described in
[Wiring it into an app](#wiring-it-into-an-app).

## Usage

```dart
// Once, at start: the widget_id of a "Mobile SDK" channel in Jivo.
Jivo.setup(channelId: 'widget_id');

// On the chat button.
await Jivo.open(
  user: JivoUser(
    token: jwtFromBackend, // optional, keeps the history across devices
    name: 'Ali',
    phone: '+92...',
    fields: [JivoCustomField(title: 'Merchant ID', content: '123')],
  ),
);

// On logout.
await Jivo.logout();
```

`user` is optional: without it the chat opens for an anonymous client.

The unread flag and Jivo's pushes need a session before the chat is first
opened. If they matter, start it on login instead of on `open`:

```dart
await Jivo.setUser(JivoUser(token: jwtFromBackend, name: 'Ali'));
Jivo.hasUnread.listen((hasUnread) { /* badge */ });

await Jivo.open(); // later, with no user
```

## Wiring it into an app

**Android**

- `jitpack.io` in the app's repositories (`android/settings.gradle.kts` /
  `build.gradle.kts`): one of the SDK's dependencies lives only there.
- The SDK declares `com.google.firebase.messaging.default_notification_icon`
  and `..._color` in its manifest. If the app declares them too, add
  `tools:replace="android:resource"` to the app's entries.
- The SDK starts itself (a provider calls `Jivo.init`); no `Application`
  class is needed.
- Pushes go through the app's existing `firebase_messaging` handling, both in
  the foreground and in the background handler:

  ```dart
  if (Jivo.isJivoPush(message.data)) {
    await Jivo.handlePush(message.data); // the SDK draws it
    return;
  }
  ```

  and the FCM token goes to `Jivo.setPushToken(token)` on start and on
  `onTokenRefresh`.

**iOS**

- In `ios/Podfile`, above the targets:

  ```ruby
  source 'https://cdn.cocoapods.org/'
  source 'https://github.com/jivochat/cocoapods-repo'
  ```

- `UNUserNotificationCenter.current().delegate = self` in `AppDelegate`
  before plugins are registered, so foreground notifications reach plugins.
- `JV_MESSAGE_TITLE` and `JV_MESSAGE` keys in `Localizable.strings`: Jivo's
  APNs pushes are localized on the device.
- APNs token, launch from a push and incoming pushes are handled by the
  plugin itself.

**Jivo side**

A "Mobile SDK" channel with the FCM service account JSON and the APNs `.p8`
key uploaded; its `widget_id` is the `channelId` above. The JWT is signed by
your backend with the channel's secret, payload `{"id": "<client id>"}`.
