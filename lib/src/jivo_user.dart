import 'package:jivo_connector/src/jivo_custom_field.dart';

/// The client the chat is with.
///
/// Everything but [token] is what the operator sees about the client, as if
/// they typed it in themselves.
class JivoUser {
  const JivoUser({
    this.token,
    this.name,
    this.email,
    this.phone,
    this.brief,
    this.fields = const [],
  });

  /// The JWT your backend signs for this client with the channel's secret.
  ///
  /// With it the chat history survives a reinstall and a logout; without it
  /// the client is anonymous and their history lives only as long as this
  /// session.
  final String? token;

  final String? name;
  final String? email;
  final String? phone;

  /// A free-form note for the operator.
  final String? brief;

  /// Lines in the panel the operator sees next to the chat.
  final List<JivoCustomField> fields;
}
