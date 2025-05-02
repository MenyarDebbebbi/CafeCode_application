import 'package:flutter/material.dart';

class InteractiveStoryGame extends StatefulWidget {
  const InteractiveStoryGame({Key? key}) : super(key: key);

  @override
  State<InteractiveStoryGame> createState() => _InteractiveStoryGameState();
}

class _InteractiveStoryGameState extends State<InteractiveStoryGame> {
  int currentScene = 0;
  int score = 0;
  bool showTranslation = false;
  List<String> choices = [];

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
                      const Text(
                        'Vos choix:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...currentSceneData['choices'].map<Widget>((choice) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(choice['fr']),
                            subtitle:
                                showTranslation ? Text(choice['en']) : null,
                            trailing: Text('+${choice['points']} pts'),
                            onTap: () => makeChoice(choice),
                          ),
                        );
                      }).toList(),
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
                              ...currentSceneData['vocabulary']
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
                      onPressed: resetStory,
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
