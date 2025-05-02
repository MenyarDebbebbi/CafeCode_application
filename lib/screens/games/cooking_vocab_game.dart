import 'package:flutter/material.dart';

class CookingVocabGame extends StatefulWidget {
  const CookingVocabGame({Key? key}) : super(key: key);

  @override
  State<CookingVocabGame> createState() => _CookingVocabGameState();
}

class _CookingVocabGameState extends State<CookingVocabGame> {
  int currentStep = 0;
  int score = 0;
  bool showTranslation = false;

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

  int currentRecipe = 0;

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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            subtitle: Text(ingredient['en']),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
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
                              const SizedBox(height: 8),
                              if (showTranslation)
                                Text(
                                  currentStepData['en'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          showTranslation = !showTranslation;
                        });
                      },
                      icon: Icon(showTranslation
                          ? Icons.visibility_off
                          : Icons.visibility),
                      label: Text(
                          showTranslation ? 'Cacher' : 'Voir la traduction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFBE9E7E),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: nextStep,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Étape suivante'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBE9E7E),
                        foregroundColor: Colors.white,
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
}
