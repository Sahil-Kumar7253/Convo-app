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

  void _deleteMessage(String messageId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to permanently delete this message?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close the dialog
              try {
                final token = Provider.of<AuthProvider>(context, listen: false).token!;
                await Provider.of<ChatProvider>(context, listen: false).deletedMessage(token, messageId);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
          ),
        ],
      ),
    );
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
                  print("the message id is : ${message.id}");
                  return MessageBubble(
                    onLongPress: () => _deleteMessage(message.id),
                    message: message.content,
                    isMe: message.senderId == authProvider.userId,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xD8F1DAFF),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.fromLTRB(20, 0, 5, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Send a message...',
                      ),
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
          ),
        ],
      ),
    );
  }
}