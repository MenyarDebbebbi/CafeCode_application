import 'package:flutter/material.dart';
import '../services/language_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudiesScreen extends StatefulWidget {
  final String languageId;
  final bool isAdmin;

  const StudiesScreen({
    Key? key,
    required this.languageId,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  State<StudiesScreen> createState() => _StudiesScreenState();
}

class _StudiesScreenState extends State<StudiesScreen>
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'basics':
      case 'les bases':
        return Icons.school;
      case 'food':
      case 'nourriture':
        return Icons.restaurant;
      case 'culture':
        return Icons.theater_comedy;
      case 'work':
      case 'travail':
        return Icons.work;
      case 'daily life':
      case 'vie quotidienne':
        return Icons.home;
      case 'travel':
      case 'voyage':
        return Icons.flight;
      case 'grammar':
      case 'grammaire':
        return Icons.menu_book;
      default:
        return Icons.book;
    }
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final lessons = category['lessons'] as List<dynamic>? ?? [];
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/lessons',
            arguments: {
              'theme': category['name'],
              'lessons': lessons,
              'languageId': widget.languageId,
              'isAdmin': widget.isAdmin,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(category['name']),
                size: 48,
                color: const Color(0xFFBE9E7E),
              ),
              const SizedBox(height: 12),
              Text(
                category['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${lessons.length} leçons',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> skill) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // Navigation vers les exercices de compétence
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school,
                    color: const Color(0xFFBE9E7E),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      skill['name'] ?? 'Sans titre',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Niveau ${skill['level'] ?? 'A1'}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('languages')
              .doc(widget.languageId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Chargement...');
            }
            final language = snapshot.data!.data() as Map<String, dynamic>;
            return Text(
              'Études - ${language['name']} ${language['flag']}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        backgroundColor: const Color(0xFFBE9E7E),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Catégories'),
            Tab(text: 'Compétences'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet Catégories
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('languages')
                .doc(widget.languageId)
                .collection('categories')
                .orderBy('order')
                .snapshots(),
            builder: (context, snapshot) {
              // Ajout de débogage
              print('Language ID: ${widget.languageId}');
              print('Snapshot has error: ${snapshot.hasError}');
              print('Snapshot has data: ${snapshot.hasData}');
              if (snapshot.hasData) {
                print('Number of categories: ${snapshot.data!.docs.length}');
              }
              if (snapshot.hasError) {
                print('Error details: ${snapshot.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erreur: ${snapshot.error}'),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await _languageService.initializeLanguages();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Données réinitialisées'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            print('Erreur lors de la réinitialisation: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBE9E7E),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFBE9E7E)),
                  ),
                );
              }

              final categories = snapshot.data!.docs;
              print(
                  'Categories data: ${categories.map((doc) => doc.data()).toList()}');

              if (categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucune catégorie disponible',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            print('Début de l\'initialisation des langues');
                            await _languageService.initializeLanguages();
                            print('Langues initialisées avec succès');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Données initialisées avec succès'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            print('Erreur lors de l\'initialisation: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réinitialiser les données'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBE9E7E),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category =
                      categories[index].data() as Map<String, dynamic>;
                  final lessons = category['lessons'] as List<dynamic>? ?? [];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/lessons',
                          arguments: {
                            'theme': category['name'],
                            'lessons': lessons,
                            'languageId': widget.languageId,
                            'isAdmin': widget.isAdmin,
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getCategoryIcon(category['name']),
                              size: 48,
                              color: const Color(0xFFBE9E7E),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              category['name'] ?? 'Sans titre',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${lessons.length} leçons',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (category['description'] != null)
                              Text(
                                category['description'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Onglet Compétences
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('languages')
                .doc(widget.languageId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final language = snapshot.data!.data() as Map<String, dynamic>;
              final List<dynamic> skills = language['skills'] ?? [];

              if (skills.isEmpty) {
                return const Center(
                    child: Text('Aucune compétence disponible'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: skills.length,
                itemBuilder: (context, index) {
                  final skill = skills[index] as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSkillCard(skill),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Fonctionnalité d\'ajout de catégorie à venir'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: const Color(0xFFBE9E7E),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
