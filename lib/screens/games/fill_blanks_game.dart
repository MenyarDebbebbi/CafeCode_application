import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class FillBlanksGame extends StatefulWidget {
  const FillBlanksGame({Key? key}) : super(key: key);

  @override
  State<FillBlanksGame> createState() => _FillBlanksGameState();
}

class _FillBlanksGameState extends State<FillBlanksGame> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool showResult = false;

  final List<Map<String, dynamic>> questions = [
    {
      'sentence': 'Je ____ à la bibliothèque.',
      'options': ['vais', 'vas', 'va', 'allez'],
      'correctAnswer': 'vais',
      'explanation':
          'Avec "Je", on utilise "vais" (1ère personne du singulier).',
    },
    {
      'sentence': 'Il ____ beau aujourd\'hui.',
      'options': ['fais', 'fait', 'faire', 'faites'],
      'correctAnswer': 'fait',
      'explanation':
          'Pour la météo, on utilise "il fait" de manière impersonnelle.',
    },
    {
      'sentence': 'Nous ____ du pain.',
      'options': ['mangez', 'mangeons', 'mange', 'manges'],
      'correctAnswer': 'mangeons',
      'explanation': 'Avec "Nous", on utilise la terminaison "-ons".',
    },
    {
      'sentence': 'Tu ____ très bien français.',
      'options': ['parle', 'parles', 'parlez', 'parlons'],
      'correctAnswer': 'parles',
      'explanation': 'Avec "Tu", on ajoute un "s" à la fin du verbe.',
    },
    {
      'sentence': 'Elles ____ au cinéma.',
      'options': ['vont', 'va', 'vas', 'allons'],
      'correctAnswer': 'vont',
      'explanation':
          'Avec "Elles", on utilise "vont" (3ème personne du pluriel).',
    },
  ];

  String? selectedAnswer;

  void checkAnswer(String answer) {
    if (showResult) return;

    setState(() {
      selectedAnswer = answer;
      showResult = true;

      if (answer == questions[currentQuestionIndex]['correctAnswer']) {
        score += 20;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (currentQuestionIndex < questions.length - 1) {
            currentQuestionIndex++;
            selectedAnswer = null;
            showResult = false;
          } else {
            showFinalScore();
          }
        });
      }
    });
  }

  void showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          score > 60 ? 'Félicitations !' : 'Fin du jeu',
          style: TextStyle(
            color: score > 60 ? Colors.green : Colors.orange,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Votre score : $score/100',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              score > 60 ? 'Excellent travail !' : 'Continuez à pratiquer !',
            ),
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
      currentQuestionIndex = 0;
      score = 0;
      selectedAnswer = null;
      showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    final parts = currentQuestion['sentence'].split('____');

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Phrases à Trous',
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Score: $score/100',
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
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFBE9E7E)),
              ),
              const SizedBox(height: 24),
              Text(
                'Question ${currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF666666),
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
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(text: parts[0]),
                        const TextSpan(
                          text: '_____',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBE9E7E),
                          ),
                        ),
                        TextSpan(text: parts[1]),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (showResult && selectedAnswer != null)
                Card(
                  color: selectedAnswer == currentQuestion['correctAnswer']
                      ? Colors.green[100]
                      : Colors.red[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      currentQuestion['explanation'],
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: currentQuestion['options'].length,
                  itemBuilder: (context, index) {
                    final option = currentQuestion['options'][index];
                    final bool isSelected = selectedAnswer == option;
                    final bool isCorrect =
                        option == currentQuestion['correctAnswer'];

                    return ElevatedButton(
                      onPressed: showResult ? null : () => checkAnswer(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: showResult
                            ? (isSelected
                                ? (isCorrect ? Colors.green : Colors.red)
                                : (isCorrect
                                    ? Colors.green
                                    : const Color(0xFFBE9E7E)))
                            : const Color(0xFFBE9E7E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
