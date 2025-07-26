import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/messageModel.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class MessageBubble extends StatelessWidget {

  final Message message;
  final bool isMe;
  final VoidCallback onLongPress;

  const MessageBubble({required this.message, required this.isMe,required this.onLongPress, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: isMe ? onLongPress : null,
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: isMe ? Colors.green[300] : Colors.blue[300],
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: message.messageType == "image" ? const EdgeInsets.all(5) : const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: message.messageType == "image" ?  ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                message.imageUrl!,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ) :Text(
              message.content!,
              style: TextStyle(
                color: isMe ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}