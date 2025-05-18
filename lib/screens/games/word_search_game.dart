import 'package:flutter/material.dart';
import 'dart:math';
import '../../widgets/custom_app_bar.dart';

/// Jeu de mots mêlés qui permet aux utilisateurs de trouver des mots cachés
/// dans une grille de lettres. Les mots peuvent être placés horizontalement,
/// verticalement ou en diagonale.
class WordSearchGame extends StatefulWidget {
  const WordSearchGame({Key? key}) : super(key: key);

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

/// État du jeu de mots mêlés qui gère :
/// - La génération de la grille
/// - Le placement des mots
/// - La sélection des lettres
/// - Le suivi du score et des mots trouvés
class _WordSearchGameState extends State<WordSearchGame> {
  // Liste des mots à trouver dans la grille
  final List<String> words = [
    'BONJOUR',
    'MERCI',
    'SALUT',
    'OUI',
    'NON',
    'CHAT',
    'CHIEN',
    'MAISON',
  ];

  late List<List<String>> grid; // Grille de lettres
  late List<bool> foundWords; // État des mots (trouvés ou non)
  int score = 0; // Score du joueur
  String selectedWord = ''; // Mot en cours de sélection
  List<int> selectedCells = []; // Cellules sélectionnées

  @override
  void initState() {
    super.initState();
    foundWords = List.generate(words.length, (index) => false);
    grid = _generateGrid();
    _placeWords();
  }

  /// Génère une grille vide remplie de lettres aléatoires
  /// @return Liste 2D de chaînes représentant la grille
  List<List<String>> _generateGrid() {
    const int size = 10;
    return List.generate(
      size,
      (i) => List.generate(
        size,
        (j) => String.fromCharCode(Random().nextInt(26) + 65),
      ),
    );
  }

  /// Place les mots dans la grille de manière aléatoire
  /// Les mots peuvent être placés horizontalement, verticalement ou en diagonale
  void _placeWords() {
    final random = Random();
    for (String word in words) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 100) {
        int direction =
            random.nextInt(3); // 0: horizontal, 1: vertical, 2: diagonal
        int row = random.nextInt(grid.length);
        int col = random.nextInt(grid[0].length);

        if (_canPlaceWord(word, row, col, direction)) {
          _placeWord(word, row, col, direction);
          placed = true;
        }
        attempts++;
      }
    }
  }

  /// Vérifie si un mot peut être placé à une position donnée dans une direction spécifique
  /// @param word: Mot à placer
  /// @param row: Ligne de départ
  /// @param col: Colonne de départ
  /// @param direction: Direction du placement (0: horizontal, 1: vertical, 2: diagonal)
  /// @return bool: True si le mot peut être placé, False sinon
  bool _canPlaceWord(String word, int row, int col, int direction) {
    if (direction == 0) {
      // Vérification horizontale
      if (col + word.length > grid[0].length) return false;
      for (int i = 0; i < word.length; i++) {
        if (grid[row][col + i] != word[i] &&
            grid[row][col + i] !=
                String.fromCharCode(Random().nextInt(26) + 65)) {
          return false;
        }
      }
    } else if (direction == 1) {
      // Vérification verticale
      if (row + word.length > grid.length) return false;
      for (int i = 0; i < word.length; i++) {
        if (grid[row + i][col] != word[i] &&
            grid[row + i][col] !=
                String.fromCharCode(Random().nextInt(26) + 65)) {
          return false;
        }
      }
    } else {
      // Vérification diagonale
      if (row + word.length > grid.length || col + word.length > grid[0].length)
        return false;
      for (int i = 0; i < word.length; i++) {
        if (grid[row + i][col + i] != word[i] &&
            grid[row + i][col + i] !=
                String.fromCharCode(Random().nextInt(26) + 65)) {
          return false;
        }
      }
    }
    return true;
  }

  /// Place un mot dans la grille à la position spécifiée
  /// @param word: Mot à placer
  /// @param row: Ligne de départ
  /// @param col: Colonne de départ
  /// @param direction: Direction du placement (0: horizontal, 1: vertical, 2: diagonal)
  void _placeWord(String word, int row, int col, int direction) {
    if (direction == 0) {
      // Placement horizontal
      for (int i = 0; i < word.length; i++) {
        grid[row][col + i] = word[i];
      }
    } else if (direction == 1) {
      // Placement vertical
      for (int i = 0; i < word.length; i++) {
        grid[row + i][col] = word[i];
      }
    } else {
      // Placement diagonal
      for (int i = 0; i < word.length; i++) {
        grid[row + i][col + i] = word[i];
      }
    }
  }

  /// Gère la sélection d'une cellule dans la grille
  /// Met à jour le mot en cours de sélection et vérifie s'il correspond à un mot à trouver
  /// @param row: Ligne de la cellule sélectionnée
  /// @param col: Colonne de la cellule sélectionnée
  void _onCellSelected(int row, int col) {
    setState(() {
      if (selectedCells.isEmpty) {
        // Première lettre sélectionnée
        selectedCells = [row * grid.length + col];
        selectedWord = grid[row][col];
      } else {
        // Ajout d'une nouvelle lettre
        selectedCells.add(row * grid.length + col);
        selectedWord += grid[row][col];

        // Vérification si le mot est dans la liste
        if (words.contains(selectedWord)) {
          int wordIndex = words.indexOf(selectedWord);
          if (!foundWords[wordIndex]) {
            // Mot trouvé pour la première fois
            foundWords[wordIndex] = true;
            score += selectedWord.length * 10;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Mot trouvé: $selectedWord! +${selectedWord.length * 10} points'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        // Réinitialisation si la sélection est trop longue
        if (selectedWord.length >= 8) {
          selectedWord = '';
          selectedCells.clear();
        }
      }
    });
  }

  /// Vérifie si une cellule est actuellement sélectionnée
  /// @param row: Ligne de la cellule
  /// @param col: Colonne de la cellule
  /// @return bool: True si la cellule est sélectionnée, False sinon
  bool _isSelected(int row, int col) {
    return selectedCells.contains(row * grid.length + col);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mots Mêlés',
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
      body: Column(
        children: [
          // Grille de jeu interactive
          Expanded(
            flex: 2,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: grid.length,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: grid.length * grid.length,
              itemBuilder: (context, index) {
                int row = index ~/ grid.length;
                int col = index % grid.length;
                return GestureDetector(
                  onTap: () => _onCellSelected(row, col),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isSelected(row, col)
                          ? const Color(0xFFBE9E7E)
                          : Colors.white,
                      border: Border.all(color: const Color(0xFFBE9E7E)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        grid[row][col],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isSelected(row, col)
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Liste des mots à trouver
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mots à trouver:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: words.asMap().entries.map((entry) {
                    int index = entry.key;
                    String word = entry.value;
                    return Chip(
                      label: Text(
                        word,
                        style: TextStyle(
                          decoration: foundWords[index]
                              ? TextDecoration.lineThrough
                              : null,
                          color: foundWords[index] ? Colors.grey : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
