import 'package:flutter/material.dart';

/// Jeu de conversation "Dialogue Virtuel" qui simule des interactions en français
/// dans des situations quotidiennes. Le joueur doit choisir des réponses appropriées
/// dans différents contextes, avec un système de score basé sur la pertinence des réponses
/// et un support de traduction pour l'apprentissage.
class VirtualDialogueGame extends StatefulWidget {
  const VirtualDialogueGame({Key? key}) : super(key: key);

  @override
  State<VirtualDialogueGame> createState() => _VirtualDialogueGameState();
}

/// État du jeu qui gère :
/// - La progression à travers les dialogues
/// - Le score du joueur
/// - L'historique de la conversation
/// - L'affichage des traductions
/// - Les réponses sélectionnées
class _VirtualDialogueGameState extends State<VirtualDialogueGame> {
  // Variables d'état du jeu
  int currentDialogue = 0; // Index du dialogue actuel
  int score = 0; // Score du joueur
  bool showTranslation = false; // Indique si les traductions sont affichées
  List<String> conversation = []; // Historique des échanges
  String? selectedResponse; // Réponse actuellement sélectionnée

  /// Liste des scénarios de dialogue
  /// Chaque dialogue contient :
  /// - character: Informations sur l'interlocuteur (nom, rôle, avatar)
  /// - context: Description du lieu/situation (en français et anglais)
  /// - message: Message de l'interlocuteur (en français et anglais)
  /// - responses: Liste des réponses possibles avec leurs points et feedback
  /// - vocabulary: Liste de vocabulaire utile pour le dialogue
  final List<Map<String, dynamic>> dialogues = [
    {
      'character': {
        'name': 'Marie',
        'role': 'Serveuse',
        'avatar': '👩‍🍳',
      },
      'context': {
        'fr': 'Dans un café parisien',
        'en': 'In a Parisian café',
      },
      'message': {
        'fr': 'Bonjour ! Que puis-je vous servir aujourd\'hui ?',
        'en': 'Hello! What can I get you today?',
      },
      'responses': [
        {
          'fr': 'Je voudrais un café, s\'il vous plaît',
          'en': 'I would like a coffee, please',
          'points': 10,
          'feedback': {
            'fr': 'Excellent choix ! Votre français est très bon.',
            'en': 'Excellent choice! Your French is very good.',
          }
        },
        {
          'fr': 'Un thé avec du lait',
          'en': 'A tea with milk',
          'points': 8,
          'feedback': {
            'fr': 'Bien ! C\'est une commande claire.',
            'en': 'Good! That\'s a clear order.',
          }
        },
        {
          'fr': 'Euh... Je ne sais pas',
          'en': 'Uh... I don\'t know',
          'points': 5,
          'feedback': {
            'fr': 'Pas de problème, prenez votre temps.',
            'en': 'No problem, take your time.',
          }
        }
      ],
      'vocabulary': [
        {'fr': 'servir', 'en': 'to serve'},
        {'fr': 'aujourd\'hui', 'en': 'today'},
        {'fr': 'voudrais', 'en': 'would like'},
      ]
    },
    {
      'character': {
        'name': 'Pierre',
        'role': 'Libraire',
        'avatar': '👨‍💼',
      },
      'context': {
        'fr': 'Dans une librairie',
        'en': 'In a bookstore',
      },
      'message': {
        'fr': 'Puis-je vous aider à trouver un livre particulier ?',
        'en': 'Can I help you find a specific book?',
      },
      'responses': [
        {
          'fr': 'Je cherche un roman français',
          'en': 'I\'m looking for a French novel',
          'points': 10,
          'feedback': {
            'fr': 'Je peux vous montrer notre sélection de classiques.',
            'en': 'I can show you our selection of classics.',
          }
        },
        {
          'fr': 'Je regarde juste',
          'en': 'I\'m just looking',
          'points': 7,
          'feedback': {
            'fr': 'D\'accord, n\'hésitez pas si vous avez besoin d\'aide.',
            'en': 'Okay, don\'t hesitate if you need help.',
          }
        },
        {
          'fr': 'Où sont les livres en anglais ?',
          'en': 'Where are the English books?',
          'points': 8,
          'feedback': {
            'fr': 'Suivez-moi, je vais vous montrer.',
            'en': 'Follow me, I\'ll show you.',
          }
        }
      ],
      'vocabulary': [
        {'fr': 'librairie', 'en': 'bookstore'},
        {'fr': 'chercher', 'en': 'to look for'},
        {'fr': 'roman', 'en': 'novel'},
      ]
    },
  ];

  /// Gère l'action de retour en arrière
  /// Affiche une boîte de dialogue de confirmation avant de quitter
  /// @return Future<bool> true si l'utilisateur confirme, false sinon
  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quitter le dialogue ?'),
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

  /// Gère la sélection d'une réponse par l'utilisateur
  /// - Met à jour le score
  /// - Ajoute les messages à l'historique
  /// - Passe au dialogue suivant après un délai
  /// @param response La réponse sélectionnée avec ses informations
  void selectResponse(Map<String, dynamic> response) {
    setState(() {
      selectedResponse = response['fr'];
      score += response['points'] as int;
      conversation.add('Vous: ${response['fr']}');
      conversation.add(
          '${dialogues[currentDialogue]['character']['name']}: ${response['feedback']['fr']}');
    });

    // Délai avant de passer au dialogue suivant
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (currentDialogue < dialogues.length - 1) {
            currentDialogue++;
            selectedResponse = null;
          } else {
            showCompletionDialog();
          }
        });
      }
    });
  }

  /// Affiche le dialogue de fin de partie avec le score final
  /// et les options pour rejouer ou quitter
  void showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Dialogue terminé !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat, size: 50, color: Color(0xFFBE9E7E)),
            const SizedBox(height: 16),
            Text('Score final: $score points'),
            const SizedBox(height: 8),
            const Text('Vous avez bien progressé en conversation !'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetDialogue();
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

  /// Réinitialise toutes les variables du jeu pour une nouvelle partie
  void resetDialogue() {
    setState(() {
      currentDialogue = 0;
      score = 0;
      conversation = [];
      selectedResponse = null;
      showTranslation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentDialogueData = dialogues[currentDialogue];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // Barre d'application avec score et bouton de retour
        appBar: AppBar(
          title: const Text('Dialogue Virtuel',
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
              // En-tête avec contexte et personnage
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Text(
                      currentDialogueData['character']['avatar'],
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentDialogueData['character']['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentDialogueData['character']['role'],
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentDialogueData['context']['fr'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                              if (showTranslation)
                                Text(
                                  currentDialogueData['context']['en'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
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
                                currentDialogueData['message']['fr'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (showTranslation) ...[
                                const SizedBox(height: 8),
                                Text(
                                  currentDialogueData['message']['en'],
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
                      const Text(
                        'Choisissez votre réponse:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...currentDialogueData['responses']
                          .map<Widget>((response) {
                        final isSelected = selectedResponse == response['fr'];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected
                              ? const Color(0xFFBE9E7E).withOpacity(0.1)
                              : null,
                          child: ListTile(
                            title: Text(response['fr']),
                            subtitle:
                                showTranslation ? Text(response['en']) : null,
                            trailing: Text('+${response['points']} pts'),
                            enabled: selectedResponse == null,
                            onTap: () => selectResponse(response),
                          ),
                        );
                      }).toList(),
                      if (conversation.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Conversation:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...conversation.map((message) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(message),
                            )),
                      ],
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vocabulaire:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...currentDialogueData['vocabulary']
                                  .map<Widget>((word) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        word['fr'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(' - '),
                                      Text(word['en']),
                                    ],
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
                      icon: Icon(
                        showTranslation
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      label:
                          Text(showTranslation ? 'Cacher' : 'Voir traduction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFBE9E7E),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: resetDialogue,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Recommencer'),
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
