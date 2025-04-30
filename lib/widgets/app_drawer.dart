import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String firstName;
  final String lastName;

  const AppDrawer({
    Key? key,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue cible'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇫🇷'),
              title: const Text('Français'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/camera-translation',
                  arguments: {'targetLanguage': 'fr'},
                );
              },
            ),
            ListTile(
              leading: const Text('🇬🇧'),
              title: const Text('Anglais'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/camera-translation',
                  arguments: {'targetLanguage': 'en'},
                );
              },
            ),
            ListTile(
              leading: const Text('🇪🇸'),
              title: const Text('Espagnol'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/camera-translation',
                  arguments: {'targetLanguage': 'es'},
                );
              },
            ),
            ListTile(
              leading: const Text('🇮🇹'),
              title: const Text('Italien'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/camera-translation',
                  arguments: {'targetLanguage': 'it'},
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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
                style: const TextStyle(fontSize: 32),
              ),
            ),
            decoration: const BoxDecoration(color: Color(0xFFBE9E7E)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          ExpansionTile(
            leading: const Icon(Icons.school),
            title: const Text('Commencer à étudier'),
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Choisir une langue'),
                contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/languages'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Traduction par caméra'),
                contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
                onTap: () => _showLanguageSelectionDialog(context),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Tableau de bord'),
            onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('Parcours'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, '/learning-path'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () => Navigator.pushReplacementNamed(context, '/parametres'),
          ),
        ],
      ),
    );
  }
}
