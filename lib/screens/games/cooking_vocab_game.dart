import 'package:flutter/material.dart';

/// Jeu éducatif "Chef Linguiste" qui permet d'apprendre le vocabulaire culinaire
/// français à travers des recettes interactives. Les joueurs découvrent les
/// ingrédients et suivent les étapes de préparation en français, avec un support
/// de traduction et un système de score.
class CookingVocabGame extends StatefulWidget {
  const CookingVocabGame({Key? key}) : super(key: key);

  @override
  State<CookingVocabGame> createState() => _CookingVocabGameState();
}

/// État du jeu qui gère :
/// - La progression à travers les étapes des recettes
/// - Le score du joueur
/// - L'affichage des traductions
/// - La sélection des recettes
class _CookingVocabGameState extends State<CookingVocabGame> {
  // Variables d'état du jeu
  int currentStep = 0; // Index de l'étape actuelle
  int score = 0; // Score du joueur
  bool showTranslation = false; // Indique si les traductions sont affichées
  int currentRecipe = 0; // Index de la recette actuelle

  /// Liste des recettes disponibles
  /// Chaque recette contient :
  /// - name: Nom de la recette
  /// - ingredients: Liste des ingrédients avec traduction
  /// - steps: Liste des étapes de préparation avec traduction
  final List<Map<String, dynamic>> recipes = [
    {
      'name': 'Crêpes Françaises',
      'ingredients': [
        {'fr': 'Farine', 'en': 'Flour'},
        {'fr': 'Oeufs', 'en': 'Eggs'},
        {'fr': 'Lait', 'en': 'Milk'},
        {'fr': 'Beurre', 'en': 'Butter'},
        {'fr': 'Sucre', 'en': 'Sugar'},
      ],
      'steps': [
        {
          'fr': 'Mélanger la farine et les oeufs',
          'en': 'Mix flour and eggs',
        },
        {
          'fr': 'Ajouter le lait progressivement',
          'en': 'Gradually add milk',
        },
        {
          'fr': 'Faire fondre le beurre',
          'en': 'Melt the butter',
        },
        {
          'fr': 'Cuire dans une poêle chaude',
          'en': 'Cook in a hot pan',
        },
      ],
    },
    // Ajoutez d'autres recettes ici
  ];

  /// Passe à l'étape suivante de la recette
  /// - Met à jour le score (+10 points par étape)
  /// - Affiche le dialogue de fin si la recette est terminée
  void nextStep() {
    if (currentStep < recipes[currentRecipe]['steps'].length - 1) {
      setState(() {
        currentStep++;
        score += 10;
      });
    } else {
      showCompletionDialog();
    }
  }

  /// Gère l'action de retour en arrière
  /// Affiche une boîte de dialogue de confirmation avant de quitter
  /// @return Future<bool> true si l'utilisateur confirme, false sinon
  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quitter le jeu ?'),
            content: const Text(
                'Voulez-vous vraiment quitter le jeu ? Votre progression sera perdue.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Non'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Oui'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Affiche le dialogue de fin de recette avec le score
  /// et les options pour continuer ou quitter
  void showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Félicitations !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant, size: 50, color: Color(0xFFBE9E7E)),
            const SizedBox(height: 16),
            Text('Vous avez terminé la recette !\nScore: $score'),
            const SizedBox(height: 8),
            const Text(
                'Vous avez appris de nouveaux mots de vocabulaire culinaire !'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text('Nouvelle Recette'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/games');
            },
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  /// Réinitialise le jeu et passe à la recette suivante
  /// Si c'était la dernière recette, revient à la première
  void resetGame() {
    setState(() {
      currentStep = 0;
      score = 0;
      showTranslation = false;
      if (currentRecipe < recipes.length - 1) {
        currentRecipe++;
      } else {
        currentRecipe = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRecipeData = recipes[currentRecipe];
    final currentStepData = currentRecipeData['steps'][currentStep];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // Barre d'application avec titre
        appBar: AppBar(
          title: const Text('Chef Linguiste',
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFBE9E7E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _onWillPop()) {
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/games');
                }
              }
            },
          ),
        ),
        // Corps du jeu avec fond dégradé
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F5F5), Color(0xFFE8E1D9)],
            ),
          ),
          child: Column(
            children: [
              // En-tête avec nom de la recette et score
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      currentRecipeData['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFFBE9E7E),
                      ),
                    ),
                  ],
                ),
              ),
              // Contenu défilant avec ingrédients et étapes
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Liste des ingrédients
                      const Text(
                        'Ingrédients:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...currentRecipeData['ingredients']
                          .map<Widget>((ingredient) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.restaurant_menu,
                                color: Color(0xFFBE9E7E)),
                            title: Text(ingredient['fr']),
                            subtitle:
                                showTranslation ? Text(ingredient['en']) : null,
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                      // Étapes de la recette
                      const Text(
                        'Étapes:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Étape ${currentStep + 1}:',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFBE9E7E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentStepData['fr'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (showTranslation) ...[
                                const SizedBox(height: 8),
                                Text(
                                  currentStepData['en'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Bouton pour passer à l'étape suivante
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: nextStep,
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(
                            currentStep <
                                    recipes[currentRecipe]['steps'].length - 1
                                ? 'Étape suivante'
                                : 'Terminer la recette',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBE9E7E),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bouton pour afficher/masquer les traductions
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      showTranslation = !showTranslation;
                    });
                  },
                  icon: Icon(
                    showTranslation ? Icons.visibility_off : Icons.translate,
                  ),
                  label: Text(
                    showTranslation ? 'Masquer traduction' : 'Voir traduction',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE9E7E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
