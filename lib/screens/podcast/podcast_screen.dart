import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isPlaying = false;
  String? _currentlyPlayingTitle;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;

  List<Map<String, dynamic>> _podcasts = [
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

  // Méthode pour sauvegarder un podcast dans Firebase
  Future<void> _savePodcastToFirebase(Map<String, dynamic> podcast) async {
    try {
      await _firestore.collection('podcasts').add({
        ...podcast,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la sauvegarde du podcast: $e');
      throw Exception('Erreur lors de la sauvegarde du podcast: $e');
    }
  }

  // Méthode pour charger les podcasts depuis Firebase
  Future<void> _loadPodcasts() async {
    setState(() => _isLoading = true);
    try {
      final QuerySnapshot podcastsSnapshot = await _firestore
          .collection('podcasts')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _podcasts = podcastsSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Erreur lors du chargement des podcasts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des podcasts: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPodcasts(); // Charger les podcasts au démarrage

    _audioPlayer.durationStream.listen((newDuration) {
      setState(() {
        _duration = newDuration ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
          _currentlyPlayingTitle = null;
        });
      }
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

  Future<void> _playPause(String title, String source) async {
    try {
      if (_currentlyPlayingTitle == title && _isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        setState(() {
          _isLoading = true;
        });

        if (_currentlyPlayingTitle != title) {
          // Si c'est un nouveau podcast, charger la nouvelle source
          if (source.startsWith('assets/')) {
            await _audioPlayer.setAsset(source);
          } else {
            await _audioPlayer.setUrl(source);
          }
          _currentlyPlayingTitle = title;
        }

        await _audioPlayer.play();
        setState(() {
          _isPlaying = true;
        });

        // Écouter la position
        _audioPlayer.positionStream.listen((position) {
          setState(() {
            _position = position;
          });
        });

        // Écouter l'état de lecture
        _audioPlayer.playerStateStream.listen((playerState) {
          final isPlaying = playerState.playing;
          final processingState = playerState.processingState;
          setState(() {
            _isPlaying = isPlaying && processingState == ProcessingState.ready;
          });
        });
      }
    } catch (e) {
      print('Erreur de lecture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la lecture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            onPressed: () async {
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

              // Créer l'objet podcast
              final newPodcast = {
                'title': titleController.text,
                'description': descriptionController.text,
                'audioUrl': audioUrlController.text,
                'author': authorController.text,
                'category': categoryController.text,
                'duration': durationController.text,
              };

              try {
                // Sauvegarder dans Firebase
                await _savePodcastToFirebase(newPodcast);

                // Ajouter à la liste locale
                setState(() {
                  _podcasts.add(newPodcast);
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Podcast ajouté avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de l\'ajout du podcast: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadPodcasts,
          ),
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE9E7E)),
              ),
            )
          : Column(
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
                                  final position =
                                      Duration(seconds: value.toInt());
                                  await _audioPlayer.seek(position);
                                  setState(() {
                                    _position = position;
                                  });
                                },
                                activeColor: const Color(0xFFBE9E7E),
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
                    padding: const EdgeInsets.all(8),
                    itemCount: _podcasts.length,
                    itemBuilder: (context, index) {
                      final podcast = _podcasts[index];
                      final bool isPlaying =
                          _currentlyPlayingTitle == podcast['title'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(podcast['title']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(podcast['description']),
                              const SizedBox(height: 4),
                              Text(
                                'Auteur: ${podcast['author']} • Durée: ${podcast['duration']} • Catégorie: ${podcast['category']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: const Color(0xFFBE9E7E),
                            ),
                            onPressed: () => _playPause(
                              podcast['title'],
                              podcast['audioUrl'],
                            ),
                          ),
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
