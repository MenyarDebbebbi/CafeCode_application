import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final String firstName;
  final String lastName;

  const AppDrawer({
    Key? key,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('$firstName $lastName'),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                firstName.isNotEmpty ? firstName[0].toUpperCase() : '',
                style: const TextStyle(
                  fontSize: 32,
                  color: Color(0xFFBE9E7E),
                ),
              ),
            ),
            decoration: const BoxDecoration(color: Color(0xFFBE9E7E)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Commencer à étudier'),
            onTap: () => Navigator.pushReplacementNamed(context, '/languages'),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Traduction par caméra'),
            onTap: () => Navigator.pushReplacementNamed(
              context,
              '/camera-translation',
              arguments: {'targetLanguage': 'fr'},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text('Podcast'),
            subtitle: const Text('Écoutez et apprenez'),
            onTap: () => Navigator.pushReplacementNamed(context, '/podcast'),
          ),
          ListTile(
            leading: const Icon(Icons.games),
            title: const Text('Jeux'),
            subtitle: const Text('Apprenez en vous amusant'),
            onTap: () => Navigator.pushReplacementNamed(context, '/games'),
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('ChatBot'),
            subtitle: const Text('Assistant linguistique'),
            onTap: () {
              Navigator.pop(context); // Ferme le drawer
              Navigator.pushReplacementNamed(context, '/chatbot');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () => Navigator.pushReplacementNamed(context, '/parametres'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final authService = AuthService();
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/auth');
              }
            },
          ),
        ],
      ),
    );
  }
}
