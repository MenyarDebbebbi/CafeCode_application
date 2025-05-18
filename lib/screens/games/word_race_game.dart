import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../widgets/custom_app_bar.dart';

/// Jeu de vitesse de frappe "Course aux Mots" qui teste la rapidité et la précision
/// des utilisateurs à taper des mots en français. Le jeu propose des mots à recopier
/// dans un temps limité, avec un système de score basé sur la longueur des mots
/// et la précision des réponses.
class WordRaceGame extends StatefulWidget {
  const WordRaceGame({Key? key}) : super(key: key);

  @override
  State<WordRaceGame> createState() => _WordRaceGameState();
}

/// État du jeu qui gère :
/// - L'affichage et la validation des mots
/// - Le chronomètre et le score
/// - Les tentatives de l'utilisateur
/// - Les statistiques de performance
class _WordRaceGameState extends State<WordRaceGame> {
  // Contrôleur pour le champ de saisie
  final TextEditingController _controller = TextEditingController();

  /// Liste des mots français à recopier
  /// Vocabulaire de base couvrant différents thèmes de la vie quotidienne
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

  // Variables d'état du jeu
  String currentWord = ''; // Mot actuellement affiché
  int score = 0; // Score du joueur
  int timeLeft = 60; // Temps restant en secondes
  Timer? timer; // Chronomètre du jeu
  bool isGameActive = false; // Indique si une partie est en cours
  List<WordAttempt> attempts = []; // Liste des tentatives de l'utilisateur

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Démarre une nouvelle partie
  /// - Réinitialise le score et le temps
  /// - Sélectionne un premier mot
  /// - Lance le chronomètre
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

  /// Termine la partie en cours
  /// - Arrête le chronomètre
  /// - Affiche le dialogue de fin avec les statistiques
  /// - Propose de rejouer ou de quitter
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

  /// Calcule la vitesse moyenne de frappe en mots par minute
  /// Ne prend en compte que les mots correctement tapés
  double _calculateAverageSpeed() {
    if (attempts.isEmpty) return 0;
    return (attempts.where((a) => a.isCorrect).length / 60) * 60;
  }

  /// Sélectionne un nouveau mot aléatoire différent du mot actuel
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

  /// Vérifie le mot saisi par l'utilisateur
  /// - Compare avec le mot à recopier
  /// - Met à jour le score (+5 points par lettre si correct, -5 points si incorrect)
  /// - Enregistre la tentative dans l'historique
  /// @param input Le mot saisi par l'utilisateur
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
      // Barre d'application personnalisée avec le score
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
              // Bouton de démarrage (visible uniquement si le jeu n'est pas actif)
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
                    // Carte affichant le mot à recopier
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Champ de saisie pour taper le mot
                    TextField(
                      controller: _controller,
                      onSubmitted: _checkWord,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Tapez le mot ici...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 32),
                    // Liste des dernières tentatives
                    Expanded(
                      child: Card(
                        child: ListView.builder(
                          itemCount: attempts.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            final attempt =
                                attempts[attempts.length - 1 - index];
                            return ListTile(
                              leading: Icon(
                                attempt.isCorrect
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: attempt.isCorrect
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(attempt.word),
                              subtitle: Text(attempt.userInput),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Classe représentant une tentative de l'utilisateur
/// Stocke les informations sur le mot à recopier, la saisie de l'utilisateur,
/// si la tentative était correcte et le moment où elle a été effectuée
class WordAttempt {
  final String word; // Mot à recopier
  final String userInput; // Saisie de l'utilisateur
  final bool isCorrect; // Indique si la saisie était correcte
  final DateTime timeStamp; // Moment de la tentative

  WordAttempt({
    required this.word,
    required this.userInput,
    required this.isCorrect,
    required this.timeStamp,
  });
}
