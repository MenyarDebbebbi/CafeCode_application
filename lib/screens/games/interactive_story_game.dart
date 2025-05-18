import 'package:flutter/material.dart';

/// Jeu narratif "Histoire Interactive" qui permet aux utilisateurs de pratiquer
/// le français à travers une histoire où ils doivent faire des choix.
/// Le jeu propose des scènes avec plusieurs options, du vocabulaire contextuel,
/// et un système de score basé sur les décisions prises.
class InteractiveStoryGame extends StatefulWidget {
  const InteractiveStoryGame({Key? key}) : super(key: key);

  @override
  State<InteractiveStoryGame> createState() => _InteractiveStoryGameState();
}

/// État du jeu qui gère :
/// - La progression à travers les scènes de l'histoire
/// - Le score du joueur
/// - Les choix effectués
/// - L'affichage des traductions
class _InteractiveStoryGameState extends State<InteractiveStoryGame> {
  // Variables d'état du jeu
  int currentScene = 0; // Index de la scène actuelle
  int score = 0; // Score du joueur
  bool showTranslation = false; // Indique si les traductions sont affichées
  List<String> choices = []; // Liste des choix effectués par le joueur

  /// Structure de l'histoire interactive
  /// Chaque scène contient :
  /// - scene: Description de la situation (en français et anglais)
  /// - choices: Liste des choix possibles avec leurs conséquences
  /// - vocabulary: Liste de vocabulaire utile pour la scène
  final List<Map<String, dynamic>> story = [
    {
      'scene': {
        'fr':
            'Vous vous réveillez dans une petite ville française. Que faites-vous ?',
        'en': 'You wake up in a small French town. What do you do?'
      },
      'choices': [
        {
          'fr': 'Aller au café',
          'en': 'Go to the café',
          'next': 1,
          'points': 10
        },
        {
          'fr': 'Explorer la ville',
          'en': 'Explore the town',
          'next': 2,
          'points': 10
        },
        {
          'fr': 'Demander des directions',
          'en': 'Ask for directions',
          'next': 3,
          'points': 15
        }
      ],
      'vocabulary': [
        {'fr': 'se réveiller', 'en': 'to wake up'},
        {'fr': 'ville', 'en': 'town'},
        {'fr': 'petit(e)', 'en': 'small'}
      ]
    },
    {
      'scene': {
        'fr': 'Au café, le serveur vous accueille. Comment commandez-vous ?',
        'en': 'At the café, the waiter greets you. How do you order?'
      },
      'choices': [
        {
          'fr': 'Un café, s\'il vous plaît',
          'en': 'A coffee, please',
          'next': 4,
          'points': 15
        },
        {
          'fr': 'Je voudrais un croissant',
          'en': 'I would like a croissant',
          'next': 5,
          'points': 15
        },
        {
          'fr': 'L\'addition, s\'il vous plaît',
          'en': 'The bill, please',
          'next': 6,
          'points': 10
        }
      ],
      'vocabulary': [
        {'fr': 'serveur', 'en': 'waiter'},
        {'fr': 'commander', 'en': 'to order'},
        {'fr': 's\'il vous plaît', 'en': 'please'}
      ]
    },
    // Ajoutez d'autres scènes ici
  ];

  /// Gère l'action de retour en arrière
  /// Affiche une boîte de dialogue de confirmation avant de quitter
  /// @return Future<bool> true si l'utilisateur confirme, false sinon
  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quitter l\'histoire ?'),
            content: const Text(
                'Voulez-vous vraiment quitter ? Votre progression sera perdue.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Non'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Oui'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Gère le choix effectué par l'utilisateur
  /// - Met à jour le score
  /// - Enregistre le choix dans l'historique
  /// - Passe à la scène suivante ou termine l'histoire
  /// @param choice Le choix sélectionné avec ses informations
  void makeChoice(Map<String, dynamic> choice) {
    setState(() {
      score += choice['points'] as int;
      choices.add(choice['fr'] as String);
      currentScene = choice['next'] as int;
    });

    if (currentScene >= story.length) {
      showCompletionDialog();
    }
  }

  /// Affiche le dialogue de fin d'histoire avec le score final
  /// et le résumé des choix effectués
  void showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Histoire terminée !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_stories, size: 50, color: Color(0xFFBE9E7E)),
            const SizedBox(height: 16),
            Text('Score final: $score points'),
            const SizedBox(height: 8),
            const Text('Vos choix ont façonné une belle histoire !'),
            const SizedBox(height: 16),
            Text('Choix effectués: ${choices.join(" → ")}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetStory();
            },
            child: const Text('Rejouer'),
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

  /// Réinitialise toutes les variables du jeu pour une nouvelle histoire
  void resetStory() {
    setState(() {
      currentScene = 0;
      score = 0;
      choices = [];
      showTranslation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentSceneData = story[currentScene];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // Barre d'application avec score
        appBar: AppBar(
          title: const Text('Histoire Interactive',
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
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Carte de la scène actuelle
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSceneData['scene']['fr'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (showTranslation) ...[
                                const SizedBox(height: 8),
                                Text(
                                  currentSceneData['scene']['en'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Historique des choix
                      const Text(
                        'Vos choix:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (choices.isEmpty)
                        const Text(
                          'Aucun choix effectué',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        )
                      else
                        Text(
                          choices.join(' → '),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Liste des choix disponibles
                      ...currentSceneData['choices'].map<Widget>((choice) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: () => makeChoice(choice),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBE9E7E),
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  choice['fr'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                if (showTranslation) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    choice['en'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                      // Section vocabulaire
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vocabulaire utile:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...currentSceneData['vocabulary']
                                  .map<Widget>((word) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${word['fr']} - ${word['en']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                            ],
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
