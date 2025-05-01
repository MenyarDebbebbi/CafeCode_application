import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../widgets/custom_app_bar.dart';

class WordRaceGame extends StatefulWidget {
  const WordRaceGame({Key? key}) : super(key: key);

  @override
  State<WordRaceGame> createState() => _WordRaceGameState();
}

class _WordRaceGameState extends State<WordRaceGame> {
  final TextEditingController _controller = TextEditingController();
  final List<String> words = [
    'bonjour',
    'merci',
    'au revoir',
    'chat',
    'chien',
    'maison',
    'école',
    'livre',
    'table',
    'chaise',
    'fenêtre',
    'porte',
    'jardin',
    'arbre',
    'fleur',
    'soleil',
    'lune',
    'étoile',
    'mer',
    'montagne',
  ];

  String currentWord = '';
  int score = 0;
  int timeLeft = 60;
  Timer? timer;
  bool isGameActive = false;
  List<WordAttempt> attempts = [];

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void startGame() {
    setState(() {
      score = 0;
      timeLeft = 60;
      isGameActive = true;
      attempts = [];
      _selectNewWord();
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          endGame();
        }
      });
    });
  }

  void endGame() {
    timer?.cancel();
    setState(() {
      isGameActive = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          score > 200 ? 'Félicitations !' : 'Fin du jeu',
          style: TextStyle(
            color: score > 200 ? Colors.green : Colors.orange,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score final : $score',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              'Mots corrects : ${attempts.where((a) => a.isCorrect).length}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Vitesse moyenne : ${_calculateAverageSpeed().toStringAsFixed(2)} mots/min',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
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

  double _calculateAverageSpeed() {
    if (attempts.isEmpty) return 0;
    return (attempts.where((a) => a.isCorrect).length / 60) * 60;
  }

  void _selectNewWord() {
    final random = Random();
    String newWord;
    do {
      newWord = words[random.nextInt(words.length)];
    } while (newWord == currentWord);

    setState(() {
      currentWord = newWord;
    });
  }

  void _checkWord(String input) {
    if (!isGameActive) return;

    final attempt = WordAttempt(
      word: currentWord,
      userInput: input,
      isCorrect: input.trim().toLowerCase() == currentWord.toLowerCase(),
      timeStamp: DateTime.now(),
    );

    setState(() {
      attempts.add(attempt);
      if (attempt.isCorrect) {
        score += (currentWord.length * 5);
        _selectNewWord();
      } else {
        score = max(0, score - 5);
      }
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Course aux Mots',
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (!isGameActive)
                Center(
                  child: ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBE9E7E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Commencer',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBE9E7E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer, color: Color(0xFFBE9E7E)),
                          const SizedBox(width: 8),
                          Text(
                            'Temps restant: $timeLeft s',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFBE9E7E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          currentWord,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      onSubmitted: _checkWord,
                      decoration: InputDecoration(
                        hintText: 'Tapez le mot ici...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: attempts.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final attempt = attempts[attempts.length - 1 - index];
                      return ListTile(
                        leading: Icon(
                          attempt.isCorrect ? Icons.check_circle : Icons.close,
                          color: attempt.isCorrect ? Colors.green : Colors.red,
                        ),
                        title: Text(attempt.word),
                        subtitle: Text(attempt.userInput),
                        trailing: Text(
                          attempt.isCorrect
                              ? '+${attempt.word.length * 5}'
                              : '-5',
                          style: TextStyle(
                            color:
                                attempt.isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
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

class WordAttempt {
  final String word;
  final String userInput;
  final bool isCorrect;
  final DateTime timeStamp;

  WordAttempt({
    required this.word,
    required this.userInput,
    required this.isCorrect,
    required this.timeStamp,
  });
}
