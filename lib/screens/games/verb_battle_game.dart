import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/custom_app_bar.dart';

/// Jeu de conjugaison "Bataille de Verbes" qui teste la connaissance des verbes
/// français. Le joueur doit conjuguer correctement les verbes au temps et à la
/// personne demandés, avec un système de score basé sur la rapidité et la précision.
class VerbBattleGame extends StatefulWidget {
  const VerbBattleGame({Key? key}) : super(key: key);

  @override
  State<VerbBattleGame> createState() => _VerbBattleGameState();
}

/// État du jeu qui gère :
/// - La progression à travers les questions de conjugaison
/// - Le chronomètre et le score
/// - La validation des réponses
/// - L'affichage des résultats et des indices
class _VerbBattleGameState extends State<VerbBattleGame> {
  /// Liste des questions de conjugaison
  /// Chaque question contient :
  /// - verb: Le verbe à conjuguer
  /// - tense: Le temps demandé
  /// - pronoun: Le pronom personnel
  /// - correctAnswer: La forme conjuguée correcte
  /// - hint: Un indice sur l'utilisation du verbe
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

  // Variables d'état du jeu
  int currentQuestionIndex = 0; // Index de la question actuelle
  int score = 0; // Score du joueur
  int timeLeft = 30; // Temps restant en secondes
  Timer? timer; // Chronomètre du jeu
  final TextEditingController _answerController =
      TextEditingController(); // Contrôleur pour le champ de réponse
  bool showResult = false; // Indique si le résultat est affiché
  bool? isCorrect; // Indique si la dernière réponse était correcte

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  /// Démarre le chronomètre du jeu
  /// Décompte le temps et déclenche la vérification automatique
  /// quand le temps est écoulé
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

  /// Vérifie la réponse donnée par l'utilisateur
  /// - Compare avec la forme conjuguée correcte
  /// - Calcule le score en fonction du temps restant
  /// - Affiche le résultat et passe à la question suivante
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
        // Attribution des points : (temps restant × 2) + 20 points de base
        score += (timeLeft * 2) + 20;
      }
    });

    // Délai avant de passer à la question suivante
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

  /// Affiche le dialogue de fin de partie avec le score final
  /// et les options pour rejouer ou quitter
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

  /// Réinitialise toutes les variables du jeu pour une nouvelle partie
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
      // Barre d'application personnalisée avec le score
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
      // Corps du jeu avec fond dégradé
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
              // Barre de progression
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFBE9E7E)),
              ),
              const SizedBox(height: 24),
              // Affichage du temps restant
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
              // Carte contenant la question de conjugaison
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
                        'au ${currentQuestion.tense} avec "${currentQuestion.pronoun}"',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Champ de saisie pour la réponse
                      TextField(
                        controller: _answerController,
                        onSubmitted: (_) => checkAnswer(),
                        decoration: InputDecoration(
                          hintText: 'Votre réponse...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      // Indice pour aider à la conjugaison
                      Text(
                        'Indice : ${currentQuestion.hint}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Bouton de validation
              ElevatedButton(
                onPressed: checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBE9E7E),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Valider',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              if (showResult)
                // Affichage du résultat
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCorrect! ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isCorrect!
                        ? 'Correct ! +${(timeLeft * 2) + 20} points'
                        : 'Incorrect. La bonne réponse était : ${currentQuestion.correctAnswer}',
                    style: TextStyle(
                      fontSize: 16,
                      color: isCorrect! ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Classe représentant une question de conjugaison
/// Contient toutes les informations nécessaires pour poser
/// la question et vérifier la réponse
class VerbQuestion {
  final String verb; // Verbe à conjuguer
  final String tense; // Temps demandé
  final String pronoun; // Pronom personnel
  final String correctAnswer; // Forme conjuguée correcte
  final String hint; // Indice sur l'utilisation du verbe

  VerbQuestion({
    required this.verb,
    required this.tense,
    required this.pronoun,
    required this.correctAnswer,
    required this.hint,
  });
}
