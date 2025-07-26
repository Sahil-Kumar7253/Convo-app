import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the user data from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.of(context).pushNamed(EditProfileScreen.routeName);
              },
              icon: Icon(Icons.edit)
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: authProvider.userImage != null
                  ? NetworkImage(authProvider.userImage!)
                  : null,
              child: (authProvider.userImage == null)
                  ? Text(
                authProvider.userName?[0].toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              )
                  : null,
            ),
            const SizedBox(height: 30),
            // User details in cards
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Name', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                  authProvider.userName ?? 'Not available',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                  authProvider.userEmail ?? 'Not available',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const Spacer(), // Pushes the logout button to the bottom
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () {
                  // Pop the profile screen before logging out
                  Navigator.of(context).pop();
                  authProvider.logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}