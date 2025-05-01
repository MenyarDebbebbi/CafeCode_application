import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({Key? key}) : super(key: key);

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentlyPlayingTitle;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final List<Map<String, dynamic>> _podcasts = [
    {
      'title': 'Les bases de la prononciation française',
      'description': 'Apprenez les sons fondamentaux du français',
      'duration': '10:30',
      'language': 'Français',
      'audioUrl':
          'assets/audio/french/Le-Secret-Souleymane-Mbodj-Parlez-Vous-French.com_.mp3',
    },
    {
      'title': 'English Conversation Practice',
      'description': 'Common phrases for everyday situations',
      'duration': '15:45',
      'language': 'English',
      'audioUrl': 'assets/audio/english/conversation_practice.mp3',
    },
    {
      'title': 'Deutsche Aussprache',
      'description': 'Grundlegende deutsche Aussprache',
      'duration': '12:20',
      'language': 'Deutsch',
      'audioUrl': 'assets/audio/german/pronunciation.mp3',
    },
    {
      'title': 'Vocabulario Español',
      'description': 'Palabras y frases comunes',
      'duration': '08:15',
      'language': 'Español',
      'audioUrl': 'assets/audio/spanish/vocabulary.mp3',
    },
    {
      'title': 'Pronuncia Italiana',
      'description': 'Imparare la pronuncia italiana',
      'duration': '11:30',
      'language': 'Italiano',
      'audioUrl': 'assets/audio/italian/pronunciation.mp3',
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
    if (_currentlyPlayingTitle == title && _isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (_currentlyPlayingTitle != title) {
        await _audioPlayer.play(AssetSource(audioUrl));
        setState(() {
          _currentlyPlayingTitle = title;
        });
      } else {
        await _audioPlayer.resume();
      }
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Podcasts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFBE9E7E),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFBE9E7E).withOpacity(0.1),
            child: const Row(
              children: [
                Icon(Icons.headphones, color: Color(0xFFBE9E7E)),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Écoutez nos podcasts pour améliorer votre prononciation et votre compréhension orale',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                            Icons.mic,
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
                            Text(
                              '${podcast['language']} • ${podcast['duration']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: const Color(0xFFBE9E7E),
                          ),
                          onPressed: () =>
                              _playPause(podcast['audioUrl'], podcast['title']),
                        ),
                      ),
                      if (isPlaying)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Slider(
                                value: _position.inSeconds.toDouble(),
                                min: 0,
                                max: _duration.inSeconds.toDouble(),
                                activeColor: const Color(0xFFBE9E7E),
                                onChanged: (value) async {
                                  final position =
                                      Duration(seconds: value.toInt());
                                  await _audioPlayer.seek(position);
                                  setState(() {
                                    _position = position;
                                  });
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatDuration(_position)),
                                    Text(_formatDuration(_duration)),
                                  ],
                                ),
                              ),
                            ],
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
