import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class FindUsersScreen extends StatefulWidget {
  static const routeName = '/find-users';

  const FindUsersScreen({super.key});
  @override
  State<FindUsersScreen> createState() => _FindUsersScreenState();
}

class _FindUsersScreenState extends State<FindUsersScreen> {
  final Set<String> _sentRequests = {};

  @override
  void initState(){
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<ChatProvider>(context, listen: false).fetchDiscoverableUsers(authProvider.token!);
  }

  void _sendFriendRequest(String receiverId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendFriendRequest(authProvider.token!, receiverId);
    setState(() {
      _sentRequests.add(receiverId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Friends'),
      ),
      body: Consumer<ChatProvider>(
        builder: (ctx, chatProvider, _){
          if(chatProvider.discoverableUsers.isEmpty){
            return const Center(child: Text("You Are Firends With All the Users"));
          }

          return ListView.builder(
            itemCount: chatProvider.discoverableUsers.length,
            itemBuilder: (ctx, i) {
              final user = chatProvider.discoverableUsers[i];
              final isPending = _sentRequests.contains(user.id);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
                    child: user.image == null ? Text(user.name[0]) : null,
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(user.email),
                  trailing: isPending
                  ? const Icon(Icons.check, color: Colors.green)
                  : ElevatedButton(
                    onPressed: () => _sendFriendRequest(user.id),
                    child: const Text('Send Request'),
                  )
                ),
              );
            }
          );
        }
      ),
    );
  }
}
