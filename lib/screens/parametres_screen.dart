import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({Key? key}) : super(key: key);

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'Français';
  double _textSize = 1.0;

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFBE9E7E),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Apparence',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Mode sombre'),
                    subtitle: const Text('Activer le thème sombre'),
                    value: themeService.isDarkMode,
                    onChanged: (bool value) {
                      themeService.toggleTheme();
                    },
                    secondary: Icon(
                      themeService.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: const Color(0xFFBE9E7E),
                    ),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.format_size, color: Color(0xFFBE9E7E)),
                    title: const Text('Taille du texte'),
                    subtitle: Slider(
                      value: _textSize,
                      min: 0.8,
                      max: 1.4,
                      divisions: 3,
                      label: _textSize.toString(),
                      onChanged: (value) {
                        setState(() {
                          _textSize = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle:
                        const Text('Recevoir des rappels d\'apprentissage'),
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    secondary: const Icon(Icons.notifications,
                        color: Color(0xFFBE9E7E)),
                  ),
                  SwitchListTile(
                    title: const Text('Sons'),
                    subtitle: const Text('Activer les sons de l\'application'),
                    value: _soundEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                    },
                    secondary:
                        const Icon(Icons.volume_up, color: Color(0xFFBE9E7E)),
                  ),
                  SwitchListTile(
                    title: const Text('Vibrations'),
                    subtitle: const Text('Activer le retour haptique'),
                    value: _vibrationEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                    },
                    secondary:
                        const Icon(Icons.vibration, color: Color(0xFFBE9E7E)),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Langue et Région',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.language, color: Color(0xFFBE9E7E)),
                    title: const Text('Langue de l\'application'),
                    subtitle: Text(_selectedLanguage),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showLanguageDialog();
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.schedule, color: Color(0xFFBE9E7E)),
                    title: const Text('Fuseau horaire'),
                    subtitle: const Text('Europe/Paris'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implémenter la sélection du fuseau horaire
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Compte et Sécurité',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFFBE9E7E)),
                    title: const Text('Modifier le profil'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implémenter la modification du profil
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Color(0xFFBE9E7E)),
                    title: const Text('Changer le mot de passe'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implémenter le changement de mot de passe
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.security, color: Color(0xFFBE9E7E)),
                    title: const Text('Confidentialité'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implémenter les paramètres de confidentialité
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'À propos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info, color: Color(0xFFBE9E7E)),
                    title: const Text('Version de l\'application'),
                    subtitle: const Text('1.0.0'),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.description, color: Color(0xFFBE9E7E)),
                    title: const Text('Conditions d\'utilisation'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Afficher les conditions d'utilisation
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.privacy_tip, color: Color(0xFFBE9E7E)),
                    title: const Text('Politique de confidentialité'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Afficher la politique de confidentialité
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/auth');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Déconnexion'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir la langue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Français'),
                leading: Radio<String>(
                  value: 'Français',
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedLanguage = value!;
                      Navigator.pop(context);
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('English'),
                leading: Radio<String>(
                  value: 'English',
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedLanguage = value!;
                      Navigator.pop(context);
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Español'),
                leading: Radio<String>(
                  value: 'Español',
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedLanguage = value!;
                      Navigator.pop(context);
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
