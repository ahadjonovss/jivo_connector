/// One line in the panel the operator sees next to the chat.
///
/// Shown in the order it is given, as `key: content` under an optional
/// [title]; [link] makes the line clickable for the operator.
class JivoCustomField {
  const JivoCustomField({
    required this.content,
    this.title,
    this.key,
    this.link,
  });

  final String content;
  final String? title;
  final String? key;
  final String? link;

  Map<String, String> toMap() => {
    'content': content,
    'title': ?title,
    'key': ?key,
    'link': ?link,
  };
}
