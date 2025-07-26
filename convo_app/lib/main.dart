import 'package:convo_app/providers/auth_provider.dart';
import 'package:convo_app/providers/chat_provider.dart';
import 'package:convo_app/screens/auth_wrapper.dart';
import 'package:convo_app/screens/edit_profile_screen.dart';
import 'package:convo_app/screens/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Convo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: const AuthWrapper(),
        routes: {
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          EditProfileScreen.routeName : (_) => const EditProfileScreen()
        },
      ),
    );
  }
}