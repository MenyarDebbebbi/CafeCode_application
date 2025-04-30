import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/language_service.dart';

class StudyScreen extends StatefulWidget {
  final String languageId;

  const StudyScreen({super.key, required this.languageId});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _languageService.getLanguageStream(widget.languageId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Chargement...');
            }
            final language = snapshot.data!.data() as Map<String, dynamic>;
            return Row(
              children: [
                Text(language['flag'] as String),
                const SizedBox(width: 8),
                Text(language['name'] as String),
              ],
            );
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thèmes'),
            Tab(text: 'Compétences'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThemesTab(),
          _buildSkillsTab(),
        ],
      ),
    );
  }

  Widget _buildThemesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _languageService.getThemesStream(widget.languageId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur : ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final themes = snapshot.data!.docs;

        if (themes.isEmpty) {
          return const Center(
            child: Text('Aucun thème disponible'),
          );
        }

        return ListView.builder(
          itemCount: themes.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final theme = themes[index].data() as Map<String, dynamic>;
            final themeId = themes[index].id;

            return Card(
              child: ListTile(
                leading: Icon(
                  IconData(
                    theme['iconCodePoint'] as int,
                    fontFamily: 'MaterialIcons',
                  ),
                ),
                title: Text(theme['title'] as String),
                subtitle: Text(theme['description'] as String),
                trailing: CircularProgressIndicator(
                  value: (theme['progress'] as num?)?.toDouble() ?? 0.0,
                  backgroundColor: Colors.grey[200],
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/lessons',
                    arguments: {
                      'languageId': widget.languageId,
                      'themeId': themeId,
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkillsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _languageService.getSkillsStream(widget.languageId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur : ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final skills = snapshot.data!.docs;

        if (skills.isEmpty) {
          return const Center(
            child: Text('Aucune compétence disponible'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: skills.length,
          itemBuilder: (context, index) {
            final skill = skills[index].data() as Map<String, dynamic>;

            return Card(
              child: InkWell(
                onTap: () {
                  // TODO: Naviguer vers l'écran de la compétence
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconData(
                          skill['iconCodePoint'] as int,
                          fontFamily: 'MaterialIcons',
                        ),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        skill['name'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (skill['progress'] as num?)?.toDouble() ?? 0.0,
                        backgroundColor: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
