import 'package:flutter/material.dart';
import 'dart:async';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({Key? key}) : super(key: key);

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<MemoryCard> cards = [];
  bool isProcessing = false;
  int score = 0;
  int attempts = 0;
  MemoryCard? selectedCard;
  Timer? timer;
  int timeLeft = 120; // 2 minutes

  final List<Map<String, String>> wordPairs = [
    {'fr': 'Bonjour', 'en': 'Hello'},
    {'fr': 'Merci', 'en': 'Thank you'},
    {'fr': 'Au revoir', 'en': 'Goodbye'},
    {'fr': 'S\'il vous plaît', 'en': 'Please'},
    {'fr': 'Oui', 'en': 'Yes'},
    {'fr': 'Non', 'en': 'No'},
    {'fr': 'Chat', 'en': 'Cat'},
    {'fr': 'Chien', 'en': 'Dog'},
  ];

  @override
  void initState() {
    super.initState();
    initializeCards();
    startTimer();
  }

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

  void initializeCards() {
    // Créer deux cartes pour chaque paire de mots
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

    // Mélanger les cartes
    tempCards.shuffle();
    setState(() {
      cards = tempCards;
    });
  }

  void onCardTap(int index) {
    if (isProcessing ||
        cards[index].isMatched ||
        cards[index] == selectedCard) {
      return;
    }

    setState(() {
      cards[index].isFlipped = true;
    });

    if (selectedCard == null) {
      selectedCard = cards[index];
    } else {
      isProcessing = true;
      attempts++;

      if (selectedCard!.pairId == cards[index].pairId) {
        // Match trouvé
        setState(() {
          selectedCard!.isMatched = true;
          cards[index].isMatched = true;
          score += 10;
        });
        selectedCard = null;
        isProcessing = false;

        // Vérifier si le jeu est terminé
        if (cards.every((card) => card.isMatched)) {
          timer?.cancel();
          showWinDialog();
        }
      } else {
        // Pas de match
        Future.delayed(const Duration(seconds: 1), () {
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

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Temps écoulé !'),
        content: Text('Score final: $score\nNombre d\'essais: $attempts'),
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

  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Félicitations !'),
        content: Text(
            'Vous avez gagné !\nScore: $score\nTemps restant: $timeLeft secondes\nNombre d\'essais: $attempts'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
        backgroundColor: const Color(0xFFBE9E7E),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Temps: $timeLeft s',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Essais: $attempts',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return _buildCard(index);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBE9E7E),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Recommencer'),
            ),
          ),
        ],
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
                : const Icon(Icons.question_mark, color: Colors.white),
          ),
        ),
      ),
    );
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
