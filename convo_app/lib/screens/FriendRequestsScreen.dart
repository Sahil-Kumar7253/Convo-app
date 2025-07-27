import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class FriendRequestsScreen extends StatefulWidget {
  static const routeName = '/friend-requests';
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {

  @override
  void initState(){
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<ChatProvider>(context, listen: false).fetchFriendRequests(authProvider.token!);
  }

  void _acceptRequest(String senderId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.acceptFriendRequest(authProvider.token!, senderId);

  }

  void _rejectRequest(String senderId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.declineFriendRequest(authProvider.token!, senderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: Consumer<ChatProvider>(
          builder: (ctx, chatProvider, _){
            if(chatProvider.friendRequests.isEmpty){
              return const Center(child: Text("No friend requests found"));
            }
            return ListView.builder(
              itemCount: chatProvider.friendRequests.length,
              itemBuilder: (ctx, i) {
                final user = chatProvider.friendRequests[i];
                return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      subtitle: Text("${user.name} wants to be Your Friend"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _rejectRequest(user.id),
                            icon: Icon(Icons.close),
                            color: Colors.red,
                          ),
                          IconButton(
                            onPressed: () => _acceptRequest(user.id),
                            icon: Icon(Icons.check),
                            color: Colors.green,
                          ),
                        ],
                      ),
                    )
                );
              },
            );
          }
      ),
    );
  }
}
