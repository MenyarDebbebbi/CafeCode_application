import 'package:flutter/material.dart';

/// Écran principal des mini-jeux éducatifs
/// Affiche une grille de jeux disponibles avec leurs descriptions et permet
/// aux utilisateurs de naviguer vers différents jeux éducatifs pour pratiquer
/// la langue de manière interactive et ludique.
class GamesScreen extends StatefulWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

/// État de l'écran des jeux qui gère :
/// - L'affichage de la grille des jeux disponibles
/// - La navigation entre les jeux
/// - Le suivi des points XP et de la progression
class _GamesScreenState extends State<GamesScreen> {
  /// Gère le comportement du bouton retour
  /// Redirige vers l'écran d'accueil au lieu de simplement revenir en arrière
  /// pour maintenir une navigation cohérente dans l'application
  Future<bool> _onWillPop() async {
    Navigator.of(context).pushReplacementNamed('/home');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Liste des jeux disponibles avec leurs configurations
    // Chaque jeu est représenté par un objet GameCard contenant :
    // - Un titre
    // - Une description
    // - Une icône
    // - Une couleur distinctive
    // - Une action de navigation
    final List<GameCard> games = [
      // Jeu Memory - Association de mots et images
      GameCard(
        title: 'Memory',
        description: 'Associez les mots à leurs traductions et images',
        icon: Icons.grid_on,
        color: const Color(0xFF7E57C2),
        onTap: () {
          Navigator.pushNamed(context, '/games/memory');
        },
      ),

      // Quiz Rapide - Questions à choix multiples
      GameCard(
        title: 'Quiz Rapide',
        description: 'Testez vos connaissances avec des questions rapides',
        icon: Icons.quiz,
        color: Colors.orange,
        onTap: () => Navigator.pushNamed(context, '/quiz_game'),
      ),

      // Autres jeux éducatifs...
      GameCard(
        title: 'Mots Mêlés',
        description: 'Trouvez les mots cachés par thème',
        icon: Icons.search,
        color: const Color(0xFF26A69A),
        onTap: () {
          Navigator.pushNamed(context, '/games/word-search');
        },
      ),
      GameCard(
        title: 'Phrases à Trous',
        description: 'Complétez les phrases avec le bon mot',
        icon: Icons.edit,
        color: const Color(0xFF66BB6A),
        onTap: () {
          Navigator.pushNamed(context, '/games/fill-blanks');
        },
      ),
      GameCard(
        title: 'Images et Mots',
        description: 'Prenez des photos et apprenez le vocabulaire',
        icon: Icons.image,
        color: const Color(0xFFFFCA28),
        onTap: () {
          Navigator.pushNamed(context, '/games/image-word');
        },
      ),
      GameCard(
        title: 'Course aux Mots',
        description: 'Tapez les mots le plus vite possible',
        icon: Icons.timer,
        color: const Color(0xFF42A5F5),
        onTap: () {
          Navigator.pushNamed(context, '/games/word-race');
        },
      ),
      GameCard(
        title: 'Dialogue Virtuel',
        description: 'Pratiquez des conversations avec un personnage virtuel',
        icon: Icons.chat_bubble,
        color: const Color(0xFF9C27B0),
        onTap: () {
          Navigator.pushNamed(context, '/games/virtual-dialogue');
        },
      ),
      GameCard(
        title: 'Mots Croisés',
        description: 'Résolvez des mots croisés thématiques',
        icon: Icons.apps,
        color: const Color(0xFF795548),
        onTap: () {
          Navigator.pushNamed(context, '/games/crosswords');
        },
      ),
      GameCard(
        title: 'Histoire Interactive',
        description: 'Créez votre histoire en choisissant les bonnes options',
        icon: Icons.auto_stories,
        color: const Color(0xFF3F51B5),
        onTap: () {
          Navigator.pushNamed(context, '/games/interactive-story');
        },
      ),
      GameCard(
        title: 'Karaoké Linguistique',
        description: 'Chantez et apprenez avec des chansons populaires',
        icon: Icons.music_note,
        color: const Color(0xFFE91E63),
        onTap: () {
          Navigator.pushNamed(context, '/games/language-karaoke');
        },
      ),
      GameCard(
        title: 'Bataille de Verbes',
        description: 'Testez vos connaissances en conjugaison',
        icon: Icons.flash_on,
        color: const Color(0xFFFF9800),
        onTap: () {
          Navigator.pushNamed(context, '/games/verb-battle');
        },
      ),
      GameCard(
        title: 'Chef Linguiste',
        description:
            'Apprenez le vocabulaire de la cuisine en préparant des recettes',
        icon: Icons.restaurant,
        color: const Color(0xFF4CAF50),
        onTap: () {
          Navigator.pushNamed(context, '/games/cooking-vocab');
        },
      ),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // Barre d'application avec navigation et titre
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/home'),
          ),
          title: const Text(
            'Mini-Jeux',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/home'),
            ),
          ],
          backgroundColor: const Color(0xFFBE9E7E),
        ),
        // Corps de l'écran avec fond dégradé et contenu
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
              // Barre de progression XP avec icône et indicateur visuel
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
                        // Affichage du score XP actuel
                        const Text(
                          'Points XP: 1250',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                        // Barre de progression visuelle
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
              // Grille scrollable des jeux disponibles
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Affichage sur deux colonnes
                    childAspectRatio: 0.85, // Ratio hauteur/largeur des cartes
                    crossAxisSpacing: 16, // Espacement horizontal
                    mainAxisSpacing: 16, // Espacement vertical
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
      ),
    );
  }

  /// Construit une carte de jeu interactive avec animation et style personnalisé
  /// @param game: Configuration du jeu à afficher (titre, description, icône, couleur)
  /// @return Widget: Carte de jeu cliquable avec effets visuels
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                game.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
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

/// Classe de configuration pour un jeu
/// Contient toutes les informations nécessaires pour afficher et interagir
/// avec un jeu dans la grille
class GameCard {
  final String title; // Titre du jeu
  final String description; // Description courte du jeu
  final IconData icon; // Icône représentative
  final Color color; // Couleur thématique
  final VoidCallback onTap; // Action de navigation

  GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
