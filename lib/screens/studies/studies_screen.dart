import 'package:flutter/material.dart';
import '../../services/language_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// StudiesScreen est l'écran principal d'apprentissage d'une langue.
/// Il affiche deux onglets principaux :
/// 1. Catégories : Affiche les différentes catégories de leçons (grammaire, vocabulaire, etc.)
/// 2. Compétences : Montre les compétences à acquérir dans la langue (lecture, écriture, etc.)
class StudiesScreen extends StatefulWidget {
  final String languageId; // Identifiant unique de la langue sélectionnée
  final bool
      isAdmin; // Détermine si l'utilisateur a des droits d'administration

  const StudiesScreen({
    Key? key,
    required this.languageId,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  State<StudiesScreen> createState() => _StudiesScreenState();
}

/// État du StudiesScreen qui gère :
/// - La navigation entre les onglets
/// - L'affichage des catégories et compétences
/// - Les fonctionnalités d'administration (ajout de catégories/leçons)
class _StudiesScreenState extends State<StudiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController
      _tabController; // Contrôleur pour la navigation entre onglets
  final LanguageService _languageService =
      LanguageService(); // Service de gestion des langues

  @override
  void initState() {
    super.initState();
    // Initialisation du contrôleur avec 2 onglets (Catégories et Compétences)
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Libération des ressources du contrôleur
    _tabController.dispose();
    super.dispose();
  }

  /// Détermine l'icône à afficher pour chaque catégorie de leçons
  /// Cette fonction associe une icône appropriée en fonction du nom de la catégorie
  /// @param category: Le nom de la catégorie à analyser
  /// @return IconData: L'icône correspondante à la catégorie
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'basics':
      case 'les bases':
        return Icons.school; // Icône d'école pour les leçons de base
      case 'food':
      case 'nourriture':
        return Icons
            .restaurant; // Icône de restaurant pour les leçons sur la nourriture
      case 'culture':
        return Icons
            .theater_comedy; // Icône de théâtre pour les leçons culturelles
      case 'work':
      case 'travail':
        return Icons.work; // Icône de travail pour les leçons professionnelles
      case 'daily life':
      case 'vie quotidienne':
        return Icons
            .home; // Icône de maison pour les leçons de la vie quotidienne
      case 'travel':
      case 'voyage':
        return Icons.flight; // Icône d'avion pour les leçons de voyage
      case 'grammar':
      case 'grammaire':
        return Icons.menu_book; // Icône de livre pour les leçons de grammaire
      default:
        return Icons.book; // Icône par défaut pour les autres catégories
    }
  }

  /// Affiche une boîte de dialogue permettant d'ajouter une nouvelle catégorie de leçons
  /// Cette fonction est accessible uniquement aux administrateurs et permet de :
  /// - Saisir le nom de la nouvelle catégorie
  /// - Ajouter une description détaillée
  /// - Sauvegarder la catégorie dans Firestore
  void _showAddCategoryDialog() {
    // Contrôleurs pour gérer les champs de saisie
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
              // Champ de saisie pour le nom de la catégorie
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie',
                  hintText: 'Ex: Grammaire, Vocabulaire, etc.',
                ),
              ),
              const SizedBox(height: 16),
              // Champ de saisie pour la description de la catégorie
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
          // Bouton pour annuler l'opération
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          // Bouton pour valider et créer la catégorie
          ElevatedButton(
            onPressed: () async {
              // Validation : le nom de la catégorie est obligatoire
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le nom est requis')),
                );
                return;
              }

              try {
                // Création de la nouvelle catégorie dans Firestore
                await FirebaseFirestore.instance
                    .collection('languages')
                    .doc(widget.languageId)
                    .collection('categories')
                    .add({
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'lessons': [], // Initialisation avec une liste vide de leçons
                  'order': Timestamp.now()
                      .millisecondsSinceEpoch, // Ordre basé sur la date de création
                });

                if (mounted) {
                  // Fermeture de la boîte de dialogue et affichage du message de succès
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Catégorie ajoutée avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Gestion des erreurs lors de la création
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

  /// Affiche une boîte de dialogue pour ajouter une nouvelle leçon à une catégorie
  /// Cette fonction permet aux administrateurs de :
  /// - Créer une nouvelle leçon avec un titre et une description
  /// - Définir la durée estimée de la leçon
  /// - Attribuer des points d'expérience (XP) pour la complétion
  /// @param categoryId: Identifiant de la catégorie parent
  /// @param currentLessons: Liste des leçons existantes dans la catégorie
  void _showAddLessonDialog(String categoryId, List<dynamic> currentLessons) {
    // Contrôleurs pour les différents champs de saisie
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    int xpPoints = 50; // Points d'expérience par défaut pour la leçon

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une leçon'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Champ pour le titre de la leçon
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de la leçon',
                  hintText: 'Ex: Les verbes du premier groupe',
                ),
              ),
              const SizedBox(height: 16),
              // Champ pour la description détaillée de la leçon
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description de la leçon',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Champ pour la durée estimée de la leçon
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Durée (en minutes)',
                  hintText: 'Ex: 15',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Slider pour ajuster les points XP de la leçon
              Row(
                children: [
                  const Text('Points XP: '),
                  Slider(
                    value: xpPoints.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 9, // Permet des incréments de 10 points
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
          // Bouton pour annuler la création
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          // Bouton pour valider et créer la leçon
          ElevatedButton(
            onPressed: () async {
              // Validation : le titre est obligatoire
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le titre est requis')),
                );
                return;
              }

              try {
                // Création de l'objet leçon avec toutes les informations
                final newLesson = {
                  'id': DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(), // ID unique basé sur le timestamp
                  'title': titleController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'duration': '${durationController.text} minutes',
                  'xp': xpPoints,
                  'completed': false, // État initial : non complété
                  'progress': 0.0, // Progression initiale : 0%
                  'createdAt': Timestamp.now(),
                };

                // Ajout de la nouvelle leçon à la liste existante
                final updatedLessons = [...currentLessons, newLesson];

                // Mise à jour de la catégorie dans Firestore avec la nouvelle liste de leçons
                await FirebaseFirestore.instance
                    .collection('languages')
                    .doc(widget.languageId)
                    .collection('categories')
                    .doc(categoryId)
                    .update({'lessons': updatedLessons});

                if (mounted) {
                  // Fermeture de la boîte de dialogue et affichage du message de succès
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Leçon ajoutée avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Gestion des erreurs lors de la création
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

  /// Construit une carte représentant une catégorie de leçons
  /// Cette carte affiche :
  /// - Une icône représentative de la catégorie
  /// - Le nom de la catégorie
  /// - Le nombre de leçons disponibles
  /// - Un bouton d'ajout de leçon pour les administrateurs
  /// @param category: Les données de la catégorie à afficher
  /// @param categoryId: L'identifiant unique de la catégorie
  /// @return Widget: La carte de catégorie construite
  Widget _buildCategoryCard(Map<String, dynamic> category, String categoryId) {
    final lessons = category['lessons'] as List<dynamic>? ?? [];
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // Navigation vers l'écran des leçons de la catégorie
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
                  // Icône de la catégorie
                  Icon(
                    _getCategoryIcon(category['name']),
                    size: 48,
                    color: const Color(0xFFBE9E7E),
                  ),
                  const SizedBox(height: 12),
                  // Nom de la catégorie
                  Text(
                    category['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Nombre de leçons dans la catégorie
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
            // Bouton d'ajout de leçon (visible uniquement pour les administrateurs)
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

  /// Construit une carte représentant une compétence linguistique
  /// Cette carte affiche :
  /// - Une icône représentant la compétence
  /// - Le nom de la compétence
  /// - Le niveau actuel de la compétence
  /// @param skill: Les données de la compétence à afficher
  /// @return Widget: La carte de compétence construite
  Widget _buildSkillCard(Map<String, dynamic> skill) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // TODO: Implémenter la navigation vers les exercices de compétence
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icône de la compétence
                  Icon(
                    Icons.school,
                    color: const Color(0xFFBE9E7E),
                  ),
                  const SizedBox(width: 12),
                  // Nom de la compétence
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
              // Niveau actuel de la compétence
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
      // Barre d'application avec le titre dynamique et les onglets
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          // Écoute des changements sur le document de la langue
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
        // Onglets pour la navigation entre Catégories et Compétences
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Catégories'),
            Tab(text: 'Compétences'),
          ],
        ),
      ),
      // Corps de l'écran avec vue à onglets
      body: TabBarView(
        controller: _tabController,
        children: [
          // Premier onglet : Liste des catégories de leçons
          StreamBuilder<QuerySnapshot>(
            // Écoute des changements sur la collection des catégories
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

              // Grille de cartes des catégories
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Affichage sur deux colonnes
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
          // Deuxième onglet : Liste des compétences
          StreamBuilder<DocumentSnapshot>(
            // Écoute des changements sur le document de la langue pour les compétences
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

              // Liste des cartes de compétences
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
      // Bouton flottant pour ajouter une catégorie (visible uniquement pour les administrateurs)
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
