import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class CrosswordsGame extends StatefulWidget {
  const CrosswordsGame({Key? key}) : super(key: key);

  @override
  State<CrosswordsGame> createState() => _CrosswordsGameState();
}

class _CrosswordsGameState extends State<CrosswordsGame> {
  int score = 0;
  List<CrosswordWord> words = [
    CrosswordWord(
      word: 'CHAT',
      clue: 'Animal domestique qui miaule',
      startX: 0,
      startY: 0,
      isHorizontal: true,
    ),
    CrosswordWord(
      word: 'CHIEN',
      clue: 'Meilleur ami de l\'homme',
      startX: 0,
      startY: 0,
      isHorizontal: false,
    ),
    CrosswordWord(
      word: 'MAISON',
      clue: 'Lieu où l\'on habite',
      startX: 2,
      startY: 1,
      isHorizontal: true,
    ),
    CrosswordWord(
      word: 'SOLEIL',
      clue: 'Il brille dans le ciel',
      startX: 4,
      startY: 0,
      isHorizontal: false,
    ),
  ];

  List<List<String>> grid =
      List.generate(8, (i) => List.generate(8, (j) => ''));
  List<List<TextEditingController>> controllers = List.generate(
    8,
    (i) => List.generate(8, (j) => TextEditingController()),
  );
  List<List<FocusNode>> focusNodes = List.generate(
    8,
    (i) => List.generate(8, (j) => FocusNode()),
  );

  @override
  void initState() {
    super.initState();
    initializeGrid();
  }

  void initializeGrid() {
    // Placer les mots dans la grille
    for (var word in words) {
      for (int i = 0; i < word.word.length; i++) {
        int x = word.isHorizontal ? word.startX + i : word.startX;
        int y = word.isHorizontal ? word.startY : word.startY + i;
        grid[y][x] = word.word[i];
      }
    }
  }

  void checkWord(CrosswordWord word) {
    String enteredWord = '';
    for (int i = 0; i < word.word.length; i++) {
      int x = word.isHorizontal ? word.startX + i : word.startX;
      int y = word.isHorizontal ? word.startY : word.startY + i;
      enteredWord += controllers[y][x].text.toUpperCase();
    }

    if (enteredWord == word.word) {
      setState(() {
        word.isCompleted = true;
        score += word.word.length * 10;
      });
      showSuccessMessage(word);
    }
  }

  void showSuccessMessage(CrosswordWord word) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bravo ! Vous avez trouvé "${word.word}" !'),
        backgroundColor: Colors.green,
      ),
    );

    if (words.every((w) => w.isCompleted)) {
      showGameCompleteDialog();
    }
  }

  void showGameCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Félicitations !',
          style: TextStyle(color: Colors.green),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score final : $score',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            const Text('Vous avez complété tous les mots croisés !'),
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
      for (var word in words) {
        word.isCompleted = false;
      }
      for (var row in controllers) {
        for (var controller in row) {
          controller.clear();
        }
      }
    });
  }

  @override
  void dispose() {
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    for (var row in focusNodes) {
      for (var node in row) {
        node.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mots Croisés',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Grille de mots croisés
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          childAspectRatio: 1,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemCount: 64,
                        itemBuilder: (context, index) {
                          int row = index ~/ 8;
                          int col = index % 8;
                          bool isActive = grid[row][col].isNotEmpty;

                          return Container(
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.grey[300],
                              border: Border.all(
                                color: const Color(0xFFBE9E7E),
                                width: 0.5,
                              ),
                            ),
                            child: isActive
                                ? TextField(
                                    controller: controllers[row][col],
                                    focusNode: focusNodes[row][col],
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        // Vérifier les mots après chaque entrée
                                        for (var word in words) {
                                          checkWord(word);
                                        }
                                        // Déplacer le focus vers la case suivante
                                        if (row < 7) {
                                          focusNodes[row + 1][col]
                                              .requestFocus();
                                        }
                                      }
                                    },
                                  )
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Liste des définitions
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Définitions :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...words.map((word) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      '${word.isHorizontal ? "→" : "↓"} ${word.clue}',
                                      style: TextStyle(
                                        decoration: word.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: word.isCompleted
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CrosswordWord {
  final String word;
  final String clue;
  final int startX;
  final int startY;
  final bool isHorizontal;
  bool isCompleted;

  CrosswordWord({
    required this.word,
    required this.clue,
    required this.startX,
    required this.startY,
    required this.isHorizontal,
    this.isCompleted = false,
  });
}
