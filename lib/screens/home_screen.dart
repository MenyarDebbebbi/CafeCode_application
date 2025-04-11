import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import 'pointage_screen.dart';
import 'parametres_screen.dart';
import 'products_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'study_screen.dart';

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
      // Charger les données utilisateur depuis Firestore
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

  void _navigateToPointage(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PointageScreen(
          firstName: widget.firstName,
          lastName: widget.lastName,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    final availableHeight = size.height - safeArea.top - safeArea.bottom;

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
                        Text(
                          'Apprenant',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
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
                leading: const Icon(Icons.school),
                title: const Text('Études'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudyScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: const Text('Certificats'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/certificates');
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
                // En-tête avec statistiques
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
                      const SizedBox(height: 8),
                      const Text(
                        'Continuez votre apprentissage',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Cartes de statistiques
                      Row(
                        children: [
                          _buildStatCard(
                            'Langues',
                            '5',
                            Icons.language,
                            const Color(0xFFBE9E7E),
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            'Cours',
                            '12',
                            Icons.school,
                            const Color(0xFF8B7355),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard(
                            'Quiz',
                            '24',
                            Icons.quiz,
                            const Color(0xFFD4C4B7),
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            'Certificats',
                            '3',
                            Icons.workspace_premium,
                            const Color(0xFFA89078),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Section des langues en cours
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Continuer l\'apprentissage',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildLanguageCard(
                        'Français',
                        'Niveau Intermédiaire',
                        '75%',
                        'https://example.com/french-flag.png',
                      ),
                      _buildLanguageCard(
                        'Anglais',
                        'Niveau Débutant',
                        '45%',
                        'https://example.com/english-flag.png',
                      ),
                      _buildLanguageCard(
                        'Espagnol',
                        'Niveau Débutant',
                        '30%',
                        'https://example.com/spanish-flag.png',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Section des derniers certificats
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Derniers certificats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCertificatesList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    String language,
    String level,
    String progress,
    String flagUrl,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFBE9E7E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.language,
                color: Color(0xFFBE9E7E),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              language,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              level,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: double.parse(progress.replaceAll('%', '')) / 100,
              backgroundColor: const Color(0xFFE8E1D9),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFBE9E7E)),
            ),
            const SizedBox(height: 8),
            Text(
              progress,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFBE9E7E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFBE9E7E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Color(0xFFBE9E7E),
              ),
            ),
            title: const Text(
              'Certificat de Français',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            subtitle: const Text(
              'Niveau Intermédiaire • Obtenu le 15/03/2024',
              style: TextStyle(color: Color(0xFF666666)),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFFBE9E7E),
            ),
          ),
        );
      },
    );
  }
}
