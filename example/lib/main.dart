import 'package:flutter/material.dart';
import 'package:jivo_connector/jivo_connector.dart';

void main() {
  // The `widget_id` of a "Mobile SDK" channel in Jivo's panel.
  Jivo.setup(
    channelId: 'your_widget_id',
    theme: JivoTheme.light,
    appearance: const JivoAppearance(
      title: 'Support',
      showOperatorInTitle: false,
      welcomeMessage: 'Hi! How can we help?',
    ),
  );
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('jivo_connector')),
      body: const Center(child: Text('The chat is behind the button.')),
      floatingActionButton: const ChatButton(),
    );
  }
}

/// Opens the chat, with a dot while the operator has written something the
/// client has not read.
class ChatButton extends StatelessWidget {
  const ChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Jivo.hasUnread,
      builder: (context, hasUnread, _) => Badge(
        isLabelVisible: hasUnread,
        smallSize: 12,
        child: FloatingActionButton(
          onPressed: () => Jivo.open(
            user: const JivoUser(name: 'Ali', phone: '+923001234567'),
          ),
          child: const Icon(Icons.chat_bubble_outline),
        ),
      ),
    );
  }
}
