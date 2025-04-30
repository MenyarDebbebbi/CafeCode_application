import 'package:flutter/material.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<GameCard> games = [
      GameCard(
        title: 'Memory',
        description: 'Associez les mots à leurs traductions',
        icon: Icons.grid_on,
        color: const Color(0xFF7E57C2),
        onTap: () {
          // TODO: Implémenter le jeu Memory
        },
      ),
      GameCard(
        title: 'Mots Croisés',
        description: 'Testez votre vocabulaire',
        icon: Icons.apps,
        color: const Color(0xFF26A69A),
        onTap: () {
          // TODO: Implémenter les mots croisés
        },
      ),
      GameCard(
        title: 'Quiz Rapide',
        description: 'Questions à choix multiples',
        icon: Icons.quiz,
        color: const Color(0xFFEF5350),
        onTap: () {
          // TODO: Implémenter le quiz rapide
        },
      ),
      GameCard(
        title: 'Phrases Mélangées',
        description: 'Remettez les mots dans le bon ordre',
        icon: Icons.shuffle,
        color: const Color(0xFF66BB6A),
        onTap: () {
          // TODO: Implémenter le jeu de phrases mélangées
        },
      ),
      GameCard(
        title: 'Images et Mots',
        description: 'Associez les images aux mots',
        icon: Icons.image,
        color: const Color(0xFFFFCA28),
        onTap: () {
          // TODO: Implémenter le jeu d'association image-mot
        },
      ),
      GameCard(
        title: 'Course Contre la Montre',
        description: 'Traduisez le plus de mots possible',
        icon: Icons.timer,
        color: const Color(0xFF42A5F5),
        onTap: () {
          // TODO: Implémenter le jeu de rapidité
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mini-Jeux',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFBE9E7E),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE8E1D9),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFBE9E7E),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Points XP: 1250',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 6,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.grey[300],
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.75,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: const Color(0xFFBE9E7E),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return _buildGameCard(game);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(GameCard game) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: game.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                game.color,
                game.color.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                game.icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                game.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                game.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameCard {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
