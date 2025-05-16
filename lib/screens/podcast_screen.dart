import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class PodcastScreen extends StatefulWidget {
  final bool isAdmin;

  const PodcastScreen({
    Key? key,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentlyPlayingTitle;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;

  List<Map<String, dynamic>> _podcasts = [
    {
      'title': 'Les Habits Neufs de L\'Empereur',
      'description': 'Un conte classique sur la vanité et la vérité',
      'duration': '05:21',
      'author': 'Parlez-Vous French',
      'audioUrl':
          'assets/audio/Les-Habits-Neufs-de-L-Empereur-Parlez-Vous-French.com_.mp3',
      'category': 'Contes Classiques'
    },
    {
      'title': 'L\'Âne Merveille',
      'description': 'Une histoire magique pleine de surprises',
      'duration': '06:22',
      'author': 'Parlez-Vous French',
      'audioUrl': 'assets/audio/Ane-Merveille-Parlez-Vous-French.com_.mp3',
      'category': 'Contes Magiques'
    },
    {
      'title': 'La Conquête',
      'description': 'Une histoire de Louis Hémon',
      'duration': '10:03',
      'author': 'Louis Hémon',
      'audioUrl':
          'assets/audio/La-Conquete-Louis-Hémon-Parlez-Vous-French.com_.mp3',
      'category': 'Littérature'
    },
    {
      'title': 'L\'Amour D\'Une Mère',
      'description': 'Une touchante histoire sur l\'amour maternel',
      'duration': '04:37',
      'author': 'Parlez-Vous French',
      'audioUrl': 'assets/audio/LAmour-DUne-Mère-Parlez-Vous-French.com_.mp3',
      'category': 'Histoires de Vie'
    },
    {
      'title': 'Le Vrai Héritier',
      'description': 'Une histoire sur la justice et la vérité',
      'duration': '03:48',
      'author': 'Parlez-Vous French',
      'audioUrl': 'assets/audio/Le-Vrai-Héritier-Parlez-vous-French.mp3',
      'category': 'Contes Moraux'
    },
    {
      'title': 'La Vérité et le Mensonge',
      'description': 'Un conte africain de Souleymane Mbodj',
      'duration': '01:43',
      'author': 'Souleymane Mbodj',
      'audioUrl':
          'assets/audio/La-Vérité-et-le-Mensonge-Souleymane-Mbodj-Parlez-Vous-French.com_.mp3',
      'category': 'Contes Africains'
    },
    {
      'title': 'Le Secret',
      'description': 'Une histoire mystérieuse de Souleymane Mbodj',
      'duration': '05:34',
      'author': 'Souleymane Mbodj',
      'audioUrl':
          'assets/audio/Le-Secret-Souleymane-Mbodj-Parlez-Vous-French.com_.mp3',
      'category': 'Contes Africains'
    },
  ];

  @override
  void initState() {
    super.initState();

    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
        _currentlyPlayingTitle = null;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _playPause(String audioUrl, String title) async {
    try {
      if (_currentlyPlayingTitle == title && _isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        if (_currentlyPlayingTitle != title) {
          await _audioPlayer.stop();

          print('Tentative de lecture du fichier: $audioUrl');

          // Check if the audio is from assets or URL
          if (audioUrl.startsWith('assets/')) {
            try {
              await rootBundle.load(audioUrl);
              await _audioPlayer
                  .play(AssetSource(audioUrl.replaceAll('assets/', '')));
            } catch (e) {
              throw Exception('Le fichier audio n\'existe pas dans les assets');
            }
          } else {
            // Handle URL audio source
            try {
              await _audioPlayer.play(UrlSource(audioUrl));
            } catch (e) {
              throw Exception('Impossible de lire l\'URL audio: $e');
            }
          }

          setState(() {
            _currentlyPlayingTitle = title;
            _position = Duration.zero;
            _isPlaying = true;
          });
        } else {
          await _audioPlayer.resume();
          setState(() {
            _isPlaying = true;
          });
        }
      }
    } catch (e) {
      print('Erreur de lecture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de lecture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddPodcastDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final audioUrlController = TextEditingController();
    final authorController = TextEditingController();
    final categoryController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un podcast'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    labelText: 'Titre', hintText: 'Entrez le titre du podcast'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Entrez la description du podcast'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: audioUrlController,
                decoration: const InputDecoration(
                    labelText: 'URL Audio',
                    hintText: 'Entrez l\'URL du fichier audio'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(
                    labelText: 'Auteur',
                    hintText: 'Entrez le nom de l\'auteur'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    hintText: 'Entrez la catégorie du podcast'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                    labelText: 'Durée', hintText: 'Format: MM:SS (ex: 05:30)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  audioUrlController.text.isEmpty ||
                  authorController.text.isEmpty ||
                  categoryController.text.isEmpty ||
                  durationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir tous les champs'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Add the new podcast to the list
              setState(() {
                _podcasts.add({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'audioUrl': audioUrlController.text,
                  'author': authorController.text,
                  'category': categoryController.text,
                  'duration': durationController.text,
                });
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Podcast ajouté avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
        ),
        title: const Text(
          'Histoires Audio',
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
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _showAddPodcastDialog,
              backgroundColor: const Color(0xFFBE9E7E),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          if (_currentlyPlayingTitle != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFBE9E7E).withOpacity(0.1),
              child: Column(
                children: [
                  Text(
                    _currentlyPlayingTitle!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_formatDuration(_position)),
                      Expanded(
                        child: Slider(
                          value: _position.inSeconds.toDouble(),
                          min: 0,
                          max: _duration.inSeconds.toDouble(),
                          onChanged: (value) async {
                            final position = Duration(seconds: value.toInt());
                            await _audioPlayer.seek(position);
                            setState(() {
                              _position = position;
                            });
                          },
                        ),
                      ),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: _podcasts.length,
              itemBuilder: (context, index) {
                final podcast = _podcasts[index];
                final bool isPlaying =
                    _isPlaying && _currentlyPlayingTitle == podcast['title'];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBE9E7E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: const Color(0xFFBE9E7E),
                            size: 30,
                          ),
                        ),
                        title: Text(
                          podcast['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(podcast['description']),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBE9E7E)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    podcast['category'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFBE9E7E),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${podcast['duration']} • ${podcast['author']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => _playPause(
                          podcast['audioUrl'],
                          podcast['title'],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
