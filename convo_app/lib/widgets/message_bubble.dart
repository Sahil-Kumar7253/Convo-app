import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class MessageBubble extends StatelessWidget {

  final String message;
  final bool isMe;
  final VoidCallback onLongPress;

  const MessageBubble({required this.message, required this.isMe,required this.onLongPress, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.green[300] : Colors.blue[300],
            borderRadius: BorderRadius.circular(12),
          ),
          width: 140,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: GestureDetector(
            onLongPress: isMe ? onLongPress : null,
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}