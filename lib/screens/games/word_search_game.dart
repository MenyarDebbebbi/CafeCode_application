import 'package:flutter/material.dart';
import 'dart:math';
import '../../widgets/custom_app_bar.dart';

class WordSearchGame extends StatefulWidget {
  const WordSearchGame({Key? key}) : super(key: key);

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
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

  late List<List<String>> grid;
  late List<bool> foundWords;
  int score = 0;
  String selectedWord = '';
  List<int> selectedCells = [];

  @override
  void initState() {
    super.initState();
    foundWords = List.generate(words.length, (index) => false);
    grid = _generateGrid();
    _placeWords();
  }

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

  bool _canPlaceWord(String word, int row, int col, int direction) {
    if (direction == 0) {
      // horizontal
      if (col + word.length > grid[0].length) return false;
      for (int i = 0; i < word.length; i++) {
        if (grid[row][col + i] != word[i] &&
            grid[row][col + i] !=
                String.fromCharCode(Random().nextInt(26) + 65)) {
          return false;
        }
      }
    } else if (direction == 1) {
      // vertical
      if (row + word.length > grid.length) return false;
      for (int i = 0; i < word.length; i++) {
        if (grid[row + i][col] != word[i] &&
            grid[row + i][col] !=
                String.fromCharCode(Random().nextInt(26) + 65)) {
          return false;
        }
      }
    } else {
      // diagonal
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

  void _placeWord(String word, int row, int col, int direction) {
    if (direction == 0) {
      // horizontal
      for (int i = 0; i < word.length; i++) {
        grid[row][col + i] = word[i];
      }
    } else if (direction == 1) {
      // vertical
      for (int i = 0; i < word.length; i++) {
        grid[row + i][col] = word[i];
      }
    } else {
      // diagonal
      for (int i = 0; i < word.length; i++) {
        grid[row + i][col + i] = word[i];
      }
    }
  }

  void _onCellSelected(int row, int col) {
    setState(() {
      if (selectedCells.isEmpty) {
        selectedCells = [row * grid.length + col];
        selectedWord = grid[row][col];
      } else {
        selectedCells.add(row * grid.length + col);
        selectedWord += grid[row][col];

        if (words.contains(selectedWord)) {
          int wordIndex = words.indexOf(selectedWord);
          if (!foundWords[wordIndex]) {
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

        if (selectedWord.length >= 8) {
          selectedWord = '';
          selectedCells.clear();
        }
      }
    });
  }

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
                      backgroundColor: foundWords[index]
                          ? Colors.grey[200]
                          : const Color(0xFFBE9E7E).withOpacity(0.2),
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
