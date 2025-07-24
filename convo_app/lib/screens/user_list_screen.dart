import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          )
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (ctx, chatProvider, _) {
          if (chatProvider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: chatProvider.users.length,
              itemBuilder: (ctx, i) {
                final user = chatProvider.users[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(user.name[0].toUpperCase())),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChatScreen(receiver: user),
                    ));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}