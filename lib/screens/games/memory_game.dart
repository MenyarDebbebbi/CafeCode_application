import 'package:flutter/material.dart';
import 'dart:async';

class MemoryGame extends StatefulWidget {
  const MemoryGame({Key? key}) : super(key: key);

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
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
    {'fr': 'Maison', 'en': 'House'},
    {'fr': 'Voiture', 'en': 'Car'},
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
        setState(() {
          selectedCard!.isMatched = true;
          cards[index].isMatched = true;
          score += 10;
        });
        selectedCard = null;
        isProcessing = false;

        if (cards.every((card) => card.isMatched)) {
          timer?.cancel();
          showWinDialog();
        }
      } else {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScoreCard('Score', score.toString()),
                    _buildScoreCard('Essais', attempts.toString()),
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
                  itemBuilder: (context, index) => _buildCard(index),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: resetGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recommencer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE9E7E),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFBE9E7E),
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
