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

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une catégorie'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie',
                  hintText: 'Ex: Grammaire, Vocabulaire, etc.',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description de la catégorie',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le nom est requis')),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('languages')
                    .doc(widget.languageId)
                    .collection('categories')
                    .add({
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'lessons': [],
                  'order': Timestamp.now().millisecondsSinceEpoch,
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Catégorie ajoutée avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showAddLessonDialog(String categoryId, List<dynamic> currentLessons) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    int xpPoints = 50;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une leçon'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de la leçon',
                  hintText: 'Ex: Les verbes du premier groupe',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description de la leçon',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Durée (en minutes)',
                  hintText: 'Ex: 15',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Points XP: '),
                  Slider(
                    value: xpPoints.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 9,
                    label: xpPoints.toString(),
                    onChanged: (value) {
                      xpPoints = value.toInt();
                    },
                  ),
                  Text(xpPoints.toString()),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le titre est requis')),
                );
                return;
              }

              try {
                final newLesson = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': titleController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'duration': '${durationController.text} minutes',
                  'xp': xpPoints,
                  'completed': false,
                  'progress': 0.0,
                  'createdAt': Timestamp.now(),
                };

                final updatedLessons = [...currentLessons, newLesson];

                await FirebaseFirestore.instance
                    .collection('languages')
                    .doc(widget.languageId)
                    .collection('categories')
                    .doc(categoryId)
                    .update({'lessons': updatedLessons});

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Leçon ajoutée avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, String categoryId) {
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
        child: Stack(
          children: [
            Padding(
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
            if (widget.isAdmin)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFFBE9E7E),
                  onPressed: () => _showAddLessonDialog(categoryId, lessons),
                  tooltip: 'Ajouter une leçon',
                ),
              ),
          ],
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
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur: ${snapshot.error}'),
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
                  final categoryId = categories[index].id;
                  return _buildCategoryCard(category, categoryId);
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
              onPressed: _showAddCategoryDialog,
              backgroundColor: const Color(0xFFBE9E7E),
              child: const Icon(Icons.add),
              tooltip: 'Ajouter une catégorie',
            )
          : null,
    );
  }
}
