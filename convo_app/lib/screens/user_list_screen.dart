import 'package:convo_app/screens/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import 'FindUserScreen.dart';
import 'FriendRequestsScreen.dart';
import 'chat_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {


  @override
  Widget build(BuildContext context) {
    Provider.of<ChatProvider>(context, listen: false).fetchFriends(
      Provider.of<AuthProvider>(context, listen: false).token!,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a Conversation'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => Navigator.of(context).pushNamed(FriendRequestsScreen.routeName),
          ),
          GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed(ProfileScreen.routeName);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: Provider.of<AuthProvider>(context, listen: false).userImage != null
                    ? NetworkImage(Provider.of<AuthProvider>(context, listen: false).userImage!)
                    : null,
                child: (Provider.of<AuthProvider>(context, listen: false).userImage == null)
                    ? Text(
                  Provider.of<AuthProvider>(context, listen: false).userName?[0].toUpperCase() ?? 'U',
                  style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (ctx, chatProvider, _) {
          if (chatProvider.friends.isEmpty) {
            return const Center(child: Text("Add Some Friend To Chat"));
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                await chatProvider.fetchUsers(Provider.of<AuthProvider>(context, listen: false).token!);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListView.builder(
                  itemCount: chatProvider.friends.length,
                  itemBuilder: (ctx, i) {
                    final user = chatProvider.friends[i];
                    return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        leading: CircleAvatar(
                          radius: 25,
                          // --- THE FIX IS HERE ---
                          // Use backgroundImage for network images.
                          backgroundImage: user.image != null
                              ? NetworkImage(user.image!)
                              : null,
                          // Provide a fallback child if the image is null.
                          child: (user.image == null)
                              ? Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                              : null,
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(user.email),
                        trailing: Icon(
                          Icons.chat_bubble_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ChatScreen(receiver: user),
                          ));
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(FindUsersScreen.routeName),
        child: const Icon(Icons.search),
      ),
    );
  }
}