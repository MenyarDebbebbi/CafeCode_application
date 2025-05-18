import 'package:flutter/material.dart';
import 'dart:async';

/// Jeu de mémoire qui permet aux utilisateurs d'associer des mots en français
/// avec leur traduction en anglais. Le jeu utilise des cartes retournables
/// et un système de score basé sur le temps et le nombre d'essais.
class MemoryGame extends StatefulWidget {
  const MemoryGame({Key? key}) : super(key: key);

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

/// État du jeu de mémoire qui gère :
/// - L'initialisation et le mélange des cartes
/// - La logique de jeu (sélection, correspondance)
/// - Le chronomètre et le score
/// - Les dialogues de fin de partie
class _MemoryGameState extends State<MemoryGame> {
  // Variables d'état du jeu
  List<MemoryCard> cards = []; // Liste des cartes en jeu
  bool isProcessing = false; // Indique si une action est en cours
  int score = 0; // Score du joueur
  int attempts = 0; // Nombre de tentatives
  MemoryCard? selectedCard; // Carte actuellement sélectionnée
  Timer? timer; // Chronomètre
  int timeLeft = 120; // Temps restant (2 minutes)

  /// Liste des paires de mots français-anglais utilisées dans le jeu
  /// Chaque paire est représentée par une Map avec les clés 'fr' et 'en'
  final List<Map<String, String>> wordPairs = [
    {'fr': 'Bonjour', 'en': 'Hello'},
    {'fr': 'Merci', 'en': 'Thank you'},
    {'fr': 'Au revoir', 'en': 'Goodbye'},
    {'fr': 'S\'il vous plaît', 'en': 'Please'},
    {'fr': 'Oui', 'en': 'Yes'},
    {'fr': 'Non', 'en': 'No'},
    {'fr': 'Chat', 'en': 'Cat'},
    {'fr': 'Chien', 'en': 'Dog'},
    {'fr': 'Maison', 'en': 'House'},
    {'fr': 'Voiture', 'en': 'Car'},
  ];

  @override
  void initState() {
    super.initState();
    initializeCards();
    startTimer();
  }

  /// Démarre le chronomètre du jeu
  /// Met à jour le temps restant chaque seconde et déclenche la fin du jeu
  /// quand le temps est écoulé
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          showGameOverDialog();
        }
      });
    });
  }

  /// Initialise les cartes du jeu
  /// Crée deux cartes pour chaque paire de mots (français et anglais)
  /// et les mélange aléatoirement
  void initializeCards() {
    List<MemoryCard> tempCards = [];
    for (var pair in wordPairs) {
      tempCards.add(MemoryCard(
        word: pair['fr']!,
        pairId: wordPairs.indexOf(pair),
        isEnglish: false,
      ));
      tempCards.add(MemoryCard(
        word: pair['en']!,
        pairId: wordPairs.indexOf(pair),
        isEnglish: true,
      ));
    }
    tempCards.shuffle();
    setState(() {
      cards = tempCards;
    });
  }

  /// Gère le tap sur une carte
  /// Vérifie si la carte peut être retournée et gère la logique de correspondance
  /// @param index: Index de la carte sélectionnée dans la liste
  void onCardTap(int index) {
    // Vérifie si une action est possible
    if (isProcessing ||
        cards[index].isMatched ||
        cards[index] == selectedCard) {
      return;
    }

    setState(() {
      cards[index].isFlipped = true;
    });

    if (selectedCard == null) {
      // Première carte sélectionnée
      selectedCard = cards[index];
    } else {
      // Deuxième carte sélectionnée
      isProcessing = true;
      attempts++;

      if (selectedCard!.pairId == cards[index].pairId) {
        // Les cartes correspondent
        setState(() {
          selectedCard!.isMatched = true;
          cards[index].isMatched = true;
          score += 10;
        });
        selectedCard = null;
        isProcessing = false;

        // Vérifie si toutes les paires ont été trouvées
        if (cards.every((card) => card.isMatched)) {
          timer?.cancel();
          showWinDialog();
        }
      } else {
        // Les cartes ne correspondent pas
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            selectedCard!.isFlipped = false;
            cards[index].isFlipped = false;
            selectedCard = null;
            isProcessing = false;
          });
        });
      }
    }
  }

  /// Affiche le dialogue de fin de partie quand le temps est écoulé
  /// Présente le score final et les options pour rejouer ou quitter
  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Temps écoulé !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score final: $score'),
            Text('Nombre d\'essais: $attempts'),
            const SizedBox(height: 16),
            const Text('Continuez à pratiquer pour vous améliorer !'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text('Rejouer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  /// Affiche le dialogue de victoire quand toutes les paires sont trouvées
  /// Présente le score, le temps restant et les options pour continuer
  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Félicitations !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 50, color: Colors.amber),
            const SizedBox(height: 16),
            Text('Score: $score'),
            Text('Temps restant: $timeLeft secondes'),
            Text('Nombre d\'essais: $attempts'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text('Rejouer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  /// Réinitialise toutes les variables du jeu pour une nouvelle partie
  void resetGame() {
    setState(() {
      score = 0;
      attempts = 0;
      timeLeft = 120;
      selectedCard = null;
      isProcessing = false;
    });
    initializeCards();
    timer?.cancel();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // Barre d'application avec titre et chronomètre
        appBar: AppBar(
          title:
              const Text('Memory Game', style: TextStyle(color: Colors.white)),
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
                'Temps: $timeLeft s',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
              // Score et statistiques
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Essais: $attempts',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Grille des cartes
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) => _buildCard(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    return GestureDetector(
      onTap: () => onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.rotationY(cards[index].isFlipped ? 3.14 : 0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: cards[index].isMatched
              ? Colors.green[100]
              : cards[index].isFlipped
                  ? Colors.white
                  : const Color(0xFFBE9E7E),
          child: Center(
            child: cards[index].isFlipped
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      cards[index].word,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: cards[index].isEnglish
                            ? Colors.blue
                            : Colors.deepOrange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const Icon(
                    Icons.question_mark,
                    color: Colors.white,
                    size: 30,
                  ),
          ),
        ),
      ),
    );
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
}

class MemoryCard {
  final String word;
  final int pairId;
  final bool isEnglish;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.word,
    required this.pairId,
    required this.isEnglish,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
