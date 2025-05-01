import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/custom_app_bar.dart';

class VerbBattleGame extends StatefulWidget {
  const VerbBattleGame({Key? key}) : super(key: key);

  @override
  State<VerbBattleGame> createState() => _VerbBattleGameState();
}

class _VerbBattleGameState extends State<VerbBattleGame> {
  final List<VerbQuestion> questions = [
    VerbQuestion(
      verb: 'être',
      tense: 'présent',
      pronoun: 'je',
      correctAnswer: 'suis',
      hint: 'Utilisé pour exprimer l\'état',
    ),
    VerbQuestion(
      verb: 'avoir',
      tense: 'présent',
      pronoun: 'tu',
      correctAnswer: 'as',
      hint: 'Verbe de possession',
    ),
    VerbQuestion(
      verb: 'aller',
      tense: 'présent',
      pronoun: 'nous',
      correctAnswer: 'allons',
      hint: 'Verbe de mouvement',
    ),
    VerbQuestion(
      verb: 'faire',
      tense: 'présent',
      pronoun: 'vous',
      correctAnswer: 'faites',
      hint: 'Action de réaliser',
    ),
    VerbQuestion(
      verb: 'prendre',
      tense: 'présent',
      pronoun: 'ils',
      correctAnswer: 'prennent',
      hint: 'Action de saisir',
    ),
  ];

  int currentQuestionIndex = 0;
  int score = 0;
  int timeLeft = 30;
  Timer? timer;
  final TextEditingController _answerController = TextEditingController();
  bool showResult = false;
  bool? isCorrect;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          checkAnswer();
        }
      });
    });
  }

  void checkAnswer() {
    timer?.cancel();
    final currentQuestion = questions[currentQuestionIndex];
    final userAnswer = _answerController.text.trim().toLowerCase();
    final isAnswerCorrect =
        userAnswer == currentQuestion.correctAnswer.toLowerCase();

    setState(() {
      showResult = true;
      isCorrect = isAnswerCorrect;
      if (isAnswerCorrect) {
        score += (timeLeft * 2) + 20;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (currentQuestionIndex < questions.length - 1) {
            currentQuestionIndex++;
            timeLeft = 30;
            showResult = false;
            isCorrect = null;
            _answerController.clear();
            startTimer();
          } else {
            showGameCompleteDialog();
          }
        });
      }
    });
  }

  void showGameCompleteDialog() {
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
              score > 200
                  ? 'Excellent ! Vous maîtrisez bien la conjugaison !'
                  : 'Continuez à pratiquer pour vous améliorer.',
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
      timeLeft = 30;
      showResult = false;
      isCorrect = null;
      _answerController.clear();
      startTimer();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bataille de Verbes',
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
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFBE9E7E)),
              ),
              const SizedBox(height: 24),
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
                  child: Column(
                    children: [
                      Text(
                        'Conjuguez le verbe "${currentQuestion.verb}"',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Temps: ${currentQuestion.tense}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pronom: ${currentQuestion.pronoun}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _answerController,
                        decoration: InputDecoration(
                          hintText: 'Votre réponse...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.help_outline),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(currentQuestion.hint),
                                  backgroundColor: const Color(0xFFBE9E7E),
                                ),
                              );
                            },
                          ),
                        ),
                        onSubmitted: (_) => checkAnswer(),
                      ),
                      const SizedBox(height: 16),
                      if (showResult)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isCorrect!
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isCorrect!
                                ? 'Correct ! +${(timeLeft * 2) + 20} points'
                                : 'Incorrect. La bonne réponse était : ${currentQuestion.correctAnswer}',
                            style: TextStyle(
                              color: isCorrect! ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: showResult ? null : checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBE9E7E),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Valider',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerbQuestion {
  final String verb;
  final String tense;
  final String pronoun;
  final String correctAnswer;
  final String hint;

  VerbQuestion({
    required this.verb,
    required this.tense,
    required this.pronoun,
    required this.correctAnswer,
    required this.hint,
  });
}
