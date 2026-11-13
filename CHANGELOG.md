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
