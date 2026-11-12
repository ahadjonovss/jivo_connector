import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:jivo_connector/src/jivo_custom_field.dart';

/// The Jivo chat, as the app sees it.
///
/// Every call goes straight to the native SDK. Both platforms get the same
/// set of calls on purpose: whatever only one SDK can do is left out rather
/// than silently ignored on the other.
class JivoConnector {
  JivoConnector();

  static const _methods = MethodChannel('jivo_connector');
  static const _unread = EventChannel('jivo_connector/unread');

  /// Whether the client has messages they have not read yet.
  ///
  /// A flag and not a count: the Android SDK only reports whether there is
  /// anything unread, so iOS, which does count, is reduced to the same.
  /// Derived once so that every listener shares one native subscription.
  late final Stream<bool> hasUnread = _unread.receiveBroadcastStream().map(
    (value) => value as bool,
  );

  /// Starts a session for the client in the channel [channelId] (Jivo's
  /// `widget_id`).
  ///
  /// [userToken] is the JWT our backend signs for this client. With it the
  /// chat history survives a reinstall and a logout; without it the client is
  /// anonymous and their history lives only as long as this session.
  Future<void> setup({required String channelId, String? userToken}) =>
      _methods.invokeMethod('setup', {
        'channelId': channelId,
        'userToken': userToken ?? '',
      });

  /// Contact details the operator sees as if the client typed them in.
  Future<void> setContactInfo({
    String? name,
    String? email,
    String? phone,
    String? brief,
  }) => _methods.invokeMethod('setContactInfo', {
    'name': name ?? '',
    'email': email ?? '',
    'phone': phone ?? '',
    'brief': brief ?? '',
  });

  /// Replaces what the operator sees in the panel next to the chat.
  Future<void> setCustomData(List<JivoCustomField> fields) =>
      _methods.invokeMethod('setCustomData', [
        for (final field in fields) field.toMap(),
      ]);

  /// Opens the chat screen over the app.
  Future<void> open() => _methods.invokeMethod('open');

  /// Ends the session, drops the local history and unsubscribes the device
  /// from Jivo pushes. Call on logout.
  Future<void> clear() => _methods.invokeMethod('clear');

  /// Hands the device's FCM token to Jivo.
  ///
  /// Android only in effect: on iOS Jivo sends pushes through APNs itself and
  /// the plugin picks the APNs token up natively, so this does nothing there.
  Future<void> setPushToken(String token) =>
      _methods.invokeMethod('setPushToken', token);

  /// Gives a push's data to the SDK, which draws the notification itself.
  ///
  /// Answers whether the push was Jivo's. Android only in effect, for the
  /// same reason as [setPushToken]: iOS delivers Jivo pushes to the plugin
  /// natively and this answers `false` there.
  Future<bool> handlePush(Map<String, dynamic> data) async {
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
}
