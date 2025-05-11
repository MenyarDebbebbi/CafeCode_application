import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/phrase_of_day_service.dart';
import '../widgets/app_drawer.dart';
import '../styles/home_styles.dart';
import 'pointage_screen.dart';
import 'parametres_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camera_translation_screen.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final bool isAdmin;

  const HomeScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _firstName;
  late String _lastName;
  late bool _isAdmin;
  bool _isLoading = false;
  Map<String, dynamic>? _userData;
  late Map<String, String> _phraseOfTheDay;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  // Données simulées pour le développement
  final Map<String, dynamic> _dailyProgress = {
    'wordsLearned': 25,
    'lessonsCompleted': 3,
    'streakDays': 7,
    'dailyGoalProgress': 0.75,
  };

  @override
  void initState() {
    super.initState();
    _firstName = widget.firstName;
    _lastName = widget.lastName;
    _isAdmin = widget.isAdmin;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    _updatePhraseOfTheDay();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('firstName', isEqualTo: _firstName)
          .where('lastName', isEqualTo: _lastName)
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

  void _updatePhraseOfTheDay() {
    setState(() {
      _phraseOfTheDay = PhraseOfDayService.getRandomPhrase();
    });
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
    final isDarkMode = context.watch<ThemeService>().isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      color.withOpacity(0.2),
                      const Color(0xFF2C2C2C),
                    ]
                  : [
                      color.withOpacity(0.1),
                      Colors.white,
                    ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhraseOfTheDay() {
    final isDarkMode = context.watch<ThemeService>().isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Card(
        elevation: 8,
        shadowColor: const Color(0xFFBE9E7E).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      const Color(0xFF3C3C3C),
                      const Color(0xFF2C2C2C),
                    ]
                  : [
                      const Color(0xFFBE9E7E).withOpacity(0.1),
                      Colors.white,
                    ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBE9E7E)
                          .withOpacity(isDarkMode ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Color(0xFFBE9E7E),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Phrase du jour',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF4A4A4A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: Color(0xFFBE9E7E),
                    ),
                    onPressed: _updatePhraseOfTheDay,
                    tooltip: 'Nouvelle phrase',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _phraseOfTheDay['phrase']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4A4A),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBE9E7E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _phraseOfTheDay['meaning']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                          height: 1.4,
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
        elevation: 0,
        backgroundColor: HomeStyles.primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: const Row(
          children: [
            Text(
              'Echo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            Text(
              'Lang',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Aucune nouvelle notification'),
                  backgroundColor: HomeStyles.primaryColor,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              context.watch<ThemeService>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeService>().toggleTheme();
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        firstName: _firstName,
        lastName: _lastName,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: HomeStyles.getBackgroundGradient(
              context.watch<ThemeService>().isDarkMode),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Bonjour, $_firstName 👋',
                    style: HomeStyles.getTitleStyle(
                        context.watch<ThemeService>().isDarkMode),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isAdmin
                        ? 'Dashboard Administrateur'
                        : 'Prêt à continuer votre apprentissage ?',
                    style: HomeStyles.getSubtitleStyle(
                        context.watch<ThemeService>().isDarkMode),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24),
                    decoration: HomeStyles.mainButtonDecoration(),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Commencer à étudier',
                                style: HomeStyles.getCardTitleStyle(
                                    context.watch<ThemeService>().isDarkMode),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Continuez votre apprentissage',
                                style: HomeStyles.getCardSubtitleStyle(
                                    context.watch<ThemeService>().isDarkMode),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/languages');
                          },
                        ),
                      ],
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
                                Icon(Icons.school, color: Color(0xFFBE9E7E)),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatbotScreen(),
            ),
          );
        },
        backgroundColor: HomeStyles.primaryColor,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text(
          'Assistant',
          style: TextStyle(color: Colors.white),
        ),
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
