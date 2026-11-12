import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:jivo_connector/src/jivo_user.dart';

/// The Jivo chat, as the app sees it.
///
/// [setup] once at start, then [open] when the client asks for the chat:
///
/// ```dart
/// Jivo.setup(channelId: 'widget_id');
/// await Jivo.open(user: JivoUser(token: jwt, name: 'Ali'));
/// ```
///
/// Both platforms get the same set of calls on purpose: whatever only one SDK
/// can do is left out rather than silently ignored on the other.
abstract final class Jivo {
  static const _methods = MethodChannel('jivo_connector');
  static const _unread = EventChannel('jivo_connector/unread');

  static String? _channelId;

  /// Whether the native SDK has a session to open the chat in.
  static bool _hasSession = false;

  /// Whether the client has messages they have not read yet.
  ///
  /// A flag and not a count: the Android SDK only reports whether there is
  /// anything unread, so iOS, which does count, is reduced to the same.
  /// Comes alive once there is a session, after [setUser] or [open].
  static final Stream<bool> hasUnread = _unread.receiveBroadcastStream().map(
    (value) => value as bool,
  );

  /// Remembers the channel the chat is in: Jivo's `widget_id` of a
  /// "Mobile SDK" channel. Call once, before anything else.
  static void setup({required String channelId}) {
    _channelId = channelId;
    _hasSession = false;
  }

  /// Starts a session for [user] without opening the chat.
  ///
  /// Optional: [open] does the same. Call it on login when the unread flag
  /// and Jivo's pushes have to work before the client first opens the chat.
  static Future<void> setUser(JivoUser user) async {
    await _methods.invokeMethod('setup', {
      'channelId': _requireChannelId(),
      'userToken': user.token ?? '',
    });
    await _methods.invokeMethod('setContactInfo', {
      'name': user.name ?? '',
      'email': user.email ?? '',
      'phone': user.phone ?? '',
      'brief': user.brief ?? '',
    });
    await _methods.invokeMethod('setCustomData', [
      for (final field in user.fields) field.toMap(),
    ]);
    _hasSession = true;
  }

  /// Opens the chat screen over the app.
  ///
  /// With [user], starts their session first, as [setUser] does. Without it,
  /// the chat continues the session there is, or opens for an anonymous
  /// client if there is none.
  static Future<void> open({JivoUser? user}) async {
    if (user != null) {
      await setUser(user);
    } else if (!_hasSession) {
      await _methods.invokeMethod('setup', {
        'channelId': _requireChannelId(),
        'userToken': '',
      });
      _hasSession = true;
    }
    await _methods.invokeMethod('open');
  }

  /// Ends the session, drops the local history and unsubscribes the device
  /// from Jivo pushes. Call on logout.
  static Future<void> logout() async {
    await _methods.invokeMethod('clear');
    _hasSession = false;
  }

  /// Hands the device's FCM token to Jivo.
  ///
  /// Android only in effect: on iOS Jivo sends pushes through APNs itself and
  /// the plugin picks the APNs token up natively, so this does nothing there.
  static Future<void> setPushToken(String token) =>
      _methods.invokeMethod('setPushToken', token);

  /// Gives a push's data to the SDK, which draws the notification itself.
  ///
  /// Answers whether the push was Jivo's. Android only in effect, for the
  /// same reason as [setPushToken]: iOS delivers Jivo pushes to the plugin
  /// natively and this answers `false` there.
  static Future<bool> handlePush(Map<String, dynamic> data) async {
    final handled = await _methods.invokeMethod<bool>('handlePush', {
      for (final entry in data.entries) entry.key: '${entry.value}',
    });
    return handled ?? false;
  }

  /// Whether a push came from Jivo, judged by its data alone.
  ///
  /// Jivo marks its pushes with a `u` field holding JSON with
  /// `"jivosdk": true`; this is the same check the Android SDK makes. Meant
  /// for the app's own push handling, so a Jivo push is not drawn twice.
  static bool isJivoPush(Map<String, dynamic> data) {
    final u = data['u'];
    if (u is! String) return false;
    try {
      final decoded = jsonDecode(u);
      return decoded is Map<String, dynamic> && decoded['jivosdk'] == true;
    } on FormatException {
      return false;
    }
  }

  static String _requireChannelId() =>
      _channelId ??
      (throw StateError('Call Jivo.setup before using the chat.'));
}
