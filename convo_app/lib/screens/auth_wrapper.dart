import 'package:convo_app/screens/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import 'authScreen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      Provider.of<ChatProvider>(context, listen: false).connectSocket();
      return const UserListScreen();
    } else {
      return const AuthScreen();
    }
  }
}