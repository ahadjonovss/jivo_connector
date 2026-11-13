## 0.7.0

* `JivoAppearance.showOperatorInTitle`: `false` keeps `title` in the chat
  header for good. Both SDKs replace it with the operator's name once one
  joins and neither can be told not to, so the plugin watches the header and
  puts the title back. On iOS the plugin now takes the header over from the
  SDK for this, and sets it up as the same opaque bar the SDK would.

## 0.6.0

* **Breaking:** `Jivo.hasUnread` is a `ValueListenable<bool>` holding the last
  value the SDK reported, so a widget built after the message came shows it at
  once. Before, a new listener of the stream saw nothing until the next change.
* **Breaking:** `Jivo.unreadCount` and `Jivo.countsUnread` are gone. The iOS
  SDK, too, only ever reports 1 or 0, so there was no count to show.
* `logout` clears the flag.

## 0.5.1

* README: an app needs data binding on, or its release build stops at R8
  on a missing `com.jivosite.sdk.BR`.

## 0.5.0

* `Jivo.unreadCount`: the number of unread messages, exact on iOS. The Android
  SDK only knows whether there are any, so there it is 1 or 0;
  `Jivo.countsUnread` says which of the two the platform gives.

## 0.4.0

* `JivoAppearance`, passed to `Jivo.setup(appearance:)` or later to
  `Jivo.setAppearance`: the chat's title, subtitle, welcome and offline
  messages on both platforms; the input hint, colours, header icon and
  language on iOS; the notification's title, icon, colour, sound and the
  bot label on Android.
* `Jivo.setTheme` changes the theme after `setup`.

## 0.3.0

* `Jivo.setup` takes a `theme`: `JivoTheme.light` or `JivoTheme.dark` keeps
  the chat screen in that look whatever the device is set to. The default,
  `JivoTheme.system`, follows the device as before.

## 0.2.0

* Simpler API, all static on `Jivo`: `setup(channelId:)` once, then
  `open(user:)` starts the session and opens the chat in one call.
* `JivoUser` carries the token, contact details and custom fields.
* `setUser` starts a session without opening the chat, for the unread flag
  and pushes; `logout` replaces `clear`.
* Breaking: `JivoConnector`, `setContactInfo` and `setCustomData` are gone.

## 0.1.0

* First version: session setup, contact info, custom data, chat screen,
  unread flag and pushes, on Android (Jivo SDK 3.0.0-rc01) and iOS (JivoSDK 5.3).
