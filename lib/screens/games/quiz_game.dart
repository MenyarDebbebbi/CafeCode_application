import 'package:flutter/material.dart';

/// Écran du jeu de quiz qui teste les connaissances linguistiques des utilisateurs
/// à travers une série de questions à choix multiples avec feedback immédiat
/// et calcul du score final.
class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({Key? key}) : super(key: key);

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

/// État du jeu de quiz qui gère :
/// - La progression à travers les questions
/// - Le score du joueur
/// - L'affichage des résultats
/// - Les transitions entre les questions
class _QuizGameScreenState extends State<QuizGameScreen> {
  // Variables d'état du jeu
  int currentQuestionIndex = 0; // Index de la question actuelle
  int score = 0; // Score total du joueur
  bool? selectedAnswer; // Réponse sélectionnée par le joueur
  bool showResult = false; // Indique si le résultat doit être affiché

  /// Liste des questions du quiz avec leurs options et réponses correctes
  /// Chaque question contient :
  /// - Un énoncé en français
  /// - Quatre options de réponse
  /// - L'index de la réponse correcte
  final List<QuizQuestion> questions = [
    QuizQuestion(
      question: "Que signifie 'Hello' en français ?",
      options: ["Bonjour", "Au revoir", "Merci", "S'il vous plaît"],
      correctAnswerIndex: 0,
    ),
    QuizQuestion(
      question: "Comment dit-on 'chat' en anglais ?",
      options: ["Dog", "Cat", "Bird", "Fish"],
      correctAnswerIndex: 1,
    ),
    QuizQuestion(
      question: "Quelle est la traduction de 'Thank you' ?",
      options: ["S'il vous plaît", "Au revoir", "Bonjour", "Merci"],
      correctAnswerIndex: 3,
    ),
    QuizQuestion(
      question: "Comment dit-on 'Good morning' en français ?",
      options: ["Bonsoir", "Bonne nuit", "Bonjour", "Au revoir"],
      correctAnswerIndex: 2,
    ),
    QuizQuestion(
      question: "Que signifie 'Please' en français ?",
      options: ["Merci", "S'il vous plaît", "De rien", "Au revoir"],
      correctAnswerIndex: 1,
    ),
  ];

  /// Vérifie la réponse sélectionnée par l'utilisateur
  /// Met à jour le score et gère la transition vers la question suivante
  /// @param selectedIndex: Index de la réponse sélectionnée par l'utilisateur
  void checkAnswer(int selectedIndex) {
    if (selectedAnswer != null) return; // Évite les réponses multiples

    setState(() {
      // Vérifie si la réponse est correcte
      selectedAnswer =
          selectedIndex == questions[currentQuestionIndex].correctAnswerIndex;
      showResult = true;
      if (selectedAnswer!) {
        score++; // Incrémente le score si la réponse est correcte
      }
    });

    // Délai avant de passer à la question suivante
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (currentQuestionIndex < questions.length - 1) {
            // Passe à la question suivante
            currentQuestionIndex++;
            selectedAnswer = null;
            showResult = false;
          } else {
            // Affiche le score final si c'était la dernière question
            showFinalScore();
          }
        });
      }
    });
  }

  /// Affiche une boîte de dialogue avec le score final
  /// et les options pour rejouer ou quitter
  void showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          score > (questions.length / 2) ? 'Félicitations !' : 'Fin du quiz',
          style: TextStyle(
            color:
                score > (questions.length / 2) ? Colors.green : Colors.orange,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Votre score : $score/${questions.length}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              score > (questions.length / 2)
                  ? 'Excellent travail !'
                  : 'Continuez à pratiquer !',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetQuiz(); // Réinitialise le quiz pour une nouvelle partie
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

  /// Réinitialise toutes les variables d'état pour recommencer le quiz
  void resetQuiz() {
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

    return Scaffold(
      // Barre d'application avec le score actuel
      appBar: AppBar(
        title: const Text('Quiz Rapide'),
        backgroundColor: const Color(0xFFBE9E7E),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Score: $score/${questions.length}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      // Corps du quiz avec fond dégradé
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
              // Barre de progression du quiz
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFBE9E7E)),
              ),
              const SizedBox(height: 24),
              // Numéro de la question actuelle
              Text(
                'Question ${currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 16),
              // Carte contenant la question
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Liste des options de réponse
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index) {
                    // Détermine si l'option est sélectionnée et correcte
                    bool isSelected = selectedAnswer != null &&
                        index == currentQuestion.correctAnswerIndex;
                    bool isWrong = showResult &&
                        selectedAnswer == false &&
                        index ==
                            currentQuestion.options.indexOf(currentQuestion
                                .options[currentQuestion.correctAnswerIndex]);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: selectedAnswer != null
                            ? null
                            : () => checkAnswer(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: showResult
                              ? (isSelected || isWrong)
                                  ? (isSelected ? Colors.green : Colors.red)
                                  : const Color(0xFFBE9E7E)
                              : const Color(0xFFBE9E7E),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          currentQuestion.options[index],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
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

/// Classe représentant une question du quiz
/// Contient l'énoncé, les options de réponse et l'index de la réponse correcte
class QuizQuestion {
  final String question; // Énoncé de la question
  final List<String> options; // Liste des options de réponse
  final int correctAnswerIndex; // Index de la réponse correcte

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}
