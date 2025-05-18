import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/language_service.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final bool isAdmin;

  const LanguageSelectionScreen({
    super.key,
    required this.isAdmin,
  });

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final LanguageService _languageService = LanguageService();
  bool _isLoading = false;

  void _showAddLanguageDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController flagController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une langue'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la langue',
                  hintText: 'Ex: Français, English, etc.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: flagController,
                decoration: const InputDecoration(
                  labelText: 'Emoji drapeau',
                  hintText: 'Ex: 🇫🇷, 🇬🇧, etc.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description de la langue et des cours disponibles',
                  border: OutlineInputBorder(),
                ),
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
              if (nameController.text.trim().isEmpty ||
                  flagController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Veuillez remplir tous les champs requis')),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance.collection('languages').add({
                  'name': nameController.text.trim(),
                  'flag': flagController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'createdAt': Timestamp.now(),
                  'categories': [],
                  'skills': [
                    {'name': 'Débutant', 'level': 'A1'},
                    {'name': 'Élémentaire', 'level': 'A2'},
                    {'name': 'Intermédiaire', 'level': 'B1'},
                    {'name': 'Avancé', 'level': 'B2'},
                  ],
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Langue ajoutée avec succès'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBE9E7E),
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(String languageId) {
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
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description de la catégorie',
                  border: OutlineInputBorder(),
                ),
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
                    .doc(languageId)
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBE9E7E),
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(Map<String, dynamic> language, String languageId) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/studies',
            arguments: {
              'languageId': languageId,
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
                  Text(
                    language['flag'] ?? '🌐',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    language['name'] ?? 'Sans nom',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (language['description'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      language['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
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
                  onPressed: () => _showAddCategoryDialog(languageId),
                  tooltip: 'Ajouter une catégorie',
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélection de la langue'),
        backgroundColor: const Color(0xFFBE9E7E),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('languages').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final languages = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index].data() as Map<String, dynamic>;
              final languageId = languages[index].id;
              return _buildLanguageCard(language, languageId);
            },
          );
        },
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _showAddLanguageDialog,
              backgroundColor: const Color(0xFFBE9E7E),
              child: const Icon(Icons.add),
              tooltip: 'Ajouter une langue',
            )
          : null,
    );
  }
}
