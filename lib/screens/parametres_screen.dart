import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

/// Écran des paramètres de l'application
/// Permet aux utilisateurs de personnaliser leur expérience
class ParametresScreen extends StatefulWidget {
  const ParametresScreen({Key? key}) : super(key: key);

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen>
    with SingleTickerProviderStateMixin {
  // États des paramètres
  bool _notificationsEnabled = true; // État des notifications
  bool _soundEnabled = true; // État des sons
  bool _vibrationEnabled = true; // État des vibrations
  String _selectedLanguage = 'Français'; // Langue sélectionnée
  double _textSize = 1.0; // Taille du texte (facteur d'échelle)

  // Contrôleurs d'animation
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Configuration de l'animation d'entrée
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Construit le titre d'une section de paramètres
  /// @param title: Titre de la section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Barre décorative
          Container(
            width: 4,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFBE9E7E),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          // Texte du titre
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit une carte pour regrouper des paramètres
  /// @param child: Widget enfant à afficher dans la carte
  Widget _buildCard(Widget child) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Scaffold(
      // Barre d'application
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: const Color(0xFFBE9E7E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
        ],
      ),
      // Corps de l'écran avec fond dégradé
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [const Color(0xFFFAF6F3), const Color(0xFFF5EDE6)],
          ),
        ),
        // Animation de fondu à l'entrée
        child: FadeTransition(
          opacity: _animation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Apparence
                _buildSectionTitle('Apparence'),
                _buildCard(
                  Column(
                    children: [
                      // Interrupteur du mode sombre
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
                      // Contrôle de la taille du texte
                      ListTile(
                        leading: const Icon(Icons.format_size,
                            color: Color(0xFFBE9E7E)),
                        title: const Text('Taille du texte'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Slider(
                              value: _textSize,
                              min: 0.8,
                              max: 1.4,
                              divisions: 3,
                              label: '${(_textSize * 100).round()}%',
                              activeColor: const Color(0xFFBE9E7E),
                              onChanged: (value) {
                                setState(() {
                                  _textSize = value;
                                });
                              },
                            ),
                            // Étiquettes des tailles de texte
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Petit',
                                      style: TextStyle(color: Colors.grey)),
                                  Text('Normal',
                                      style: TextStyle(color: Colors.grey)),
                                  Text('Grand',
                                      style: TextStyle(color: Colors.grey)),
                                  Text('Très grand',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Section Notifications
                _buildSectionTitle('Notifications'),
                _buildCard(
                  Column(
                    children: [
                      // Paramètres des notifications
                      AnimatedSwitchListTile(
                        title: 'Notifications',
                        subtitle: 'Recevoir des rappels d\'apprentissage',
                        icon: Icons.notifications,
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                      const Divider(height: 1),
                      // Paramètres des sons
                      AnimatedSwitchListTile(
                        title: 'Sons',
                        subtitle: 'Activer les sons de l\'application',
                        icon: Icons.volume_up,
                        value: _soundEnabled,
                        onChanged: (value) {
                          setState(() {
                            _soundEnabled = value;
                          });
                        },
                      ),
                      const Divider(height: 1),
                      // Paramètres des vibrations
                      AnimatedSwitchListTile(
                        title: 'Vibrations',
                        subtitle: 'Activer le retour haptique',
                        icon: Icons.vibration,
                        value: _vibrationEnabled,
                        onChanged: (value) {
                          setState(() {
                            _vibrationEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Section Langue et Région
                _buildSectionTitle('Langue et Région'),
                _buildCard(
                  Column(
                    children: [
                      // Sélection de la langue
                      ListTile(
                        leading: const Icon(Icons.language,
                            color: Color(0xFFBE9E7E)),
                        title: const Text('Langue de l\'application'),
                        subtitle: Text(_selectedLanguage),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _showLanguageDialog,
                      ),
                      const Divider(height: 1),
                      // Sélection du fuseau horaire
                      ListTile(
                        leading: const Icon(Icons.schedule,
                            color: Color(0xFFBE9E7E)),
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
                // Section Compte et Sécurité
                _buildSectionTitle('Compte et Sécurité'),
                _buildCard(
                  Column(
                    children: [
                      ListTile(
                        leading:
                            const Icon(Icons.person, color: Color(0xFFBE9E7E)),
                        title: const Text('Modifier le profil'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading:
                            const Icon(Icons.lock, color: Color(0xFFBE9E7E)),
                        title: const Text('Changer le mot de passe'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.security,
                            color: Color(0xFFBE9E7E)),
                        title: const Text('Confidentialité'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                _buildSectionTitle('À propos'),
                _buildCard(
                  Column(
                    children: [
                      ListTile(
                        leading:
                            const Icon(Icons.info, color: Color(0xFFBE9E7E)),
                        title: const Text('Version de l\'application'),
                        subtitle: const Text('1.0.0'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.description,
                            color: Color(0xFFBE9E7E)),
                        title: const Text('Conditions d\'utilisation'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip,
                            color: Color(0xFFBE9E7E)),
                        title: const Text('Politique de confidentialité'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {},
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
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Déconnexion',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Choisir la langue',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFBE9E7E),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('Français', '🇫🇷'),
              _buildLanguageOption('English', '🇬🇧'),
              _buildLanguageOption('Español', '🇪🇸'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, String flag) {
    return ListTile(
      title: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(language),
        ],
      ),
      leading: Radio<String>(
        value: language,
        groupValue: _selectedLanguage,
        activeColor: const Color(0xFFBE9E7E),
        onChanged: (String? value) {
          setState(() {
            _selectedLanguage = value!;
            Navigator.pop(context);
          });
        },
      ),
    );
  }
}

class AnimatedSwitchListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AnimatedSwitchListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: const Color(0xFFBE9E7E)),
      activeColor: const Color(0xFFBE9E7E),
    );
  }
}
