import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/userModel.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final UserModel receiver;
  const ChatScreen({required this.receiver, super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // THE FIX: Get the authProvider to pass the token
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<ChatProvider>(context, listen: false)
        .fetchChatHistory(authProvider.token!, widget.receiver.id);
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    // THE FIX: Get the authProvider to pass the sender's ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<ChatProvider>(context, listen: false)
        .sendMessage(authProvider.userId!, widget.receiver.id, _controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.receiver.name)),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (ctx, chatProvider, _) => ListView.builder(
                reverse: true, // Show latest messages at the bottom
                itemCount: chatProvider.messages.length,
                itemBuilder: (ctx, i) {
                  final message = chatProvider.messages.reversed.toList()[i];
                  return MessageBubble(
                    message: message.content,
                    isMe: message.senderId == authProvider.userId,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Send a message...'),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}