import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import 'pointage_screen.dart';
import 'parametres_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camera_translation_screen.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  final String firstName;
  final String lastName;

  const HomeScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  DateTime _currentTime = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  // Données simulées pour le développement
  final Map<String, dynamic> _dailyProgress = {
    'wordsLearned': 25,
    'lessonsCompleted': 3,
    'streakDays': 7,
    'dailyGoalProgress': 0.75,
  };

  final String _phraseOfTheDay = "The early bird catches the worm";
  final String _phraseMeaning =
      "Celui qui se lève tôt accomplit plus de choses";
  final String _phraseAudioUrl = "assets/audio/phrase_of_the_day.mp3";

  @override
  void initState() {
    super.initState();
    _updateTime();
    _loadUserData();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
    });
    Future.delayed(const Duration(minutes: 1), _updateTime);
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('firstName', isEqualTo: widget.firstName)
          .where('lastName', isEqualTo: widget.lastName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _userData = querySnapshot.docs.first.data();
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de déconnexion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue cible'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Français'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraTranslationScreen(
                      targetLanguage: 'fr',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Anglais'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraTranslationScreen(
                      targetLanguage: 'en',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Espagnol'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraTranslationScreen(
                      targetLanguage: 'es',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Arabe'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraTranslationScreen(
                      targetLanguage: 'ar',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Italien'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraTranslationScreen(
                      targetLanguage: 'it',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhraseOfTheDay() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Color(0xFFBE9E7E)),
                SizedBox(width: 8),
                Text(
                  'Phrase du jour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _phraseOfTheDay,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _phraseMeaning,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Écouter'),
                  onPressed: () {
                    // TODO: Implémenter la lecture audio
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text('Pratiquer'),
                  onPressed: () {
                    // TODO: Implémenter la reconnaissance vocale
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: _showLanguageSelectionDialog,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.translate, color: Color(0xFFBE9E7E)),
                  SizedBox(width: 8),
                  Text(
                    'Choisir une langue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildLanguageChip('Français', 'FR'),
                  _buildLanguageChip('English', 'EN'),
                  _buildLanguageChip('Español', 'ES'),
                  _buildLanguageChip('Deutsch', 'DE'),
                  _buildLanguageChip('العربية', 'AR'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String language, String code) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: const Color(0xFFBE9E7E),
        child: Text(
          code,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
      label: Text(language),
      backgroundColor: const Color(0xFFBE9E7E).withOpacity(0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EchoLang',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFBE9E7E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Aucune nouvelle notification'),
                  backgroundColor: Color(0xFFBE9E7E),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(context.watch<ThemeService>().isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              context.read<ThemeService>().toggleTheme();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFBE9E7E),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                            widget.firstName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFBE9E7E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${widget.firstName} ${widget.lastName}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Niveau Intermédiaire',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                selected: true,
                selectedColor: const Color(0xFFBE9E7E),
                selectedTileColor: const Color(0xFFF5F5F5),
                leading: const Icon(Icons.home),
                title: const Text('Accueil'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Traduction par Caméra'),
                onTap: () {
                  Navigator.pop(context);
                  _showLanguageSelectionDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('ChatBot'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatBotScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Paramètres'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/parametres');
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _signOut();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE8E1D9),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, ${widget.firstName}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Ajout du bouton d'accès aux études
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/languages');
                        },
                        icon: const Icon(Icons.school),
                        label: const Text('Commencer à étudier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBE9E7E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Cartes de progression
                      Row(
                        children: [
                          Expanded(
                            child: _buildProgressCard(
                              'Mots appris',
                              _dailyProgress['wordsLearned'].toString(),
                              Icons.book,
                              const Color(0xFFBE9E7E),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildProgressCard(
                              'Leçons terminées',
                              _dailyProgress['lessonsCompleted'].toString(),
                              Icons.school,
                              const Color(0xFF8B7355),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildProgressCard(
                              'Jours de série',
                              _dailyProgress['streakDays'].toString(),
                              Icons.local_fire_department,
                              const Color(0xFFD4C4B7),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildProgressCard(
                              'Objectif quotidien',
                              '${(_dailyProgress['dailyGoalProgress'] * 100).toInt()}%',
                              Icons.stars,
                              const Color(0xFFA89078),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildPhraseOfTheDay(),
                      const SizedBox(height: 24),
                      _buildLanguageSelectionCard(),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/studies');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.school,
                                        color: Color(0xFFBE9E7E)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Mes Études',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4A4A4A),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStudyMetric('Cours en cours', '3'),
                                    _buildStudyMetric('Exercices', '12'),
                                    _buildStudyMetric('Niveau moyen', 'B1'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatBotScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFBE9E7E),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildStudyMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFBE9E7E),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
