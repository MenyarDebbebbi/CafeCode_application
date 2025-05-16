import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:just_audio/just_audio.dart';

class LessonScreen extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final String languageId;

  const LessonScreen({
    Key? key,
    required this.lesson,
    required this.languageId,
  }) : super(key: key);

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _isLoading = false;
  bool _lessonCompleted = false;
  bool _showQuiz = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _sections = ['Contenu', 'Quiz'];

  // Variables pour le quiz
  final Map<int, dynamic> _userAnswers = {};
  bool _quizSubmitted = false;
  int _score = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentAudioUrl;

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _markAsCompleted() async {
    setState(() => _isLoading = true);
    try {
      setState(() {
        _lessonCompleted = true;
        _showQuiz = true;
        _currentPage = 1; // Passer à la page du quiz
      });
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Mettre à jour le statut de la leçon dans Firestore
      await FirebaseFirestore.instance
          .collection('languages')
          .doc(widget.languageId)
          .update({
        'lessons.${widget.lesson['id']}.completed': true,
        'lessons.${widget.lesson['id']}.completedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleAnswer(int questionIndex, dynamic answer) {
    setState(() {
      _userAnswers[questionIndex] = answer;
    });
  }

  void _submitQuiz() {
    if (_userAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez répondre à au moins une question'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _quizSubmitted = true;
      _calculateScore();
    });
  }

  void _calculateScore() {
    final questions = widget.lesson['quiz']['questions'] as List<dynamic>;
    int correctAnswers = 0;

    _userAnswers.forEach((index, userAnswer) {
      final question = questions[index] as Map<String, dynamic>;
      if (question['type'] == 'multiple_choice' ||
          question['type'] == 'true_false') {
        if (userAnswer == question['correctAnswer']) {
          correctAnswers++;
        }
      } else if (question['type'] == 'fill_blank') {
        if (userAnswer.toString().toLowerCase() ==
            question['correctAnswer'].toString().toLowerCase()) {
          correctAnswers++;
        }
      }
    });

    setState(() {
      _score = ((correctAnswers / questions.length) * 100).round();
    });
  }

  Future<void> _playAudio(String audioUrl) async {
    if (_currentAudioUrl == audioUrl && _isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.setAsset(audioUrl);
      setState(() {
        _currentAudioUrl = audioUrl;
        _isPlaying = true;
      });
    }
  }

  Widget _buildContentSection(dynamic content) {
    if (content == null) {
      return const Center(
        child: Text('Aucun contenu disponible'),
      );
    }

    if (content is String) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(content),
      );
    }

    if (content is! List) {
      return const Center(
        child: Text('Format de contenu non valide'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: content.length,
      itemBuilder: (context, index) {
        final item = content[index];
        if (item is! Map<String, dynamic>) {
          return const SizedBox.shrink();
        }

        final type = item['type'] as String?;
        final data = item['data'];

        switch (type) {
          case 'text':
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                data.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            );

          case 'list':
            if (data is List) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              item.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }
            return const SizedBox.shrink();

          case 'exercise':
            return Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exercice',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(data['instructions'] ?? ''),
                    if (data['audio'] != null)
                      ListTile(
                        leading: Icon(
                          _isPlaying && _currentAudioUrl == data['audio']
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        title: const Text('Écouter l\'audio'),
                        onTap: () => _playAudio(data['audio']),
                      ),
                  ],
                ),
              ),
            );

          case 'dialogue':
            return Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data['title'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          data['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (data['conversation'] is List)
                      ...List<Widget>.from(
                        data['conversation'].map((line) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                line.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            )),
                      ),
                  ],
                ),
              ),
            );

          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildQuizSection() {
    if (widget.lesson['quiz'] == null ||
        widget.lesson['quiz']['questions'] == null ||
        (widget.lesson['quiz']['questions'] as List).isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Pas de quiz disponible pour cette leçon',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final questions = widget.lesson['quiz']['questions'] as List;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quiz',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(questions.length, (index) {
            final question = questions[index] as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${index + 1}: ${question['question']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (question['type'] == 'multiple_choice')
                      ...List.generate(
                        (question['options'] as List).length,
                        (optionIndex) => RadioListTile<int>(
                          title: Text(question['options'][optionIndex]),
                          value: optionIndex,
                          groupValue: _userAnswers[index],
                          onChanged: _quizSubmitted
                              ? null
                              : (value) => _handleAnswer(index, value),
                        ),
                      )
                    else if (question['type'] == 'true_false')
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Vrai'),
                              value: true,
                              groupValue: _userAnswers[index],
                              onChanged: _quizSubmitted
                                  ? null
                                  : (value) => _handleAnswer(index, value),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Faux'),
                              value: false,
                              groupValue: _userAnswers[index],
                              onChanged: _quizSubmitted
                                  ? null
                                  : (value) => _handleAnswer(index, value),
                            ),
                          ),
                        ],
                      )
                    else if (question['type'] == 'fill_blank')
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Votre réponse',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_quizSubmitted,
                        onChanged: (value) => _handleAnswer(index, value),
                        controller: TextEditingController(
                            text: _userAnswers[index]?.toString() ?? ''),
                      ),
                    if (_quizSubmitted) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Réponse correcte: ${question['correctAnswer']}',
                        style: TextStyle(
                          color:
                              _userAnswers[index] == question['correctAnswer']
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explication: ${question['explanation']}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          if (!_quizSubmitted)
            Center(
              child: ElevatedButton(
                onPressed: _submitQuiz,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text(
                  'Soumettre le quiz',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          else
            Column(
              children: [
                Text(
                  'Score: $_score%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _quizSubmitted = false;
                      _userAnswers.clear();
                      _score = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lesson['title'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFBE9E7E),
        bottom: _showQuiz
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(_sections.length, (index) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _currentPage == index
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _sections[index],
                                style: TextStyle(
                                  color: _currentPage == index
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: _currentPage == index
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              )
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: _showQuiz
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          if (_showQuiz) {
            setState(() => _currentPage = index);
          }
        },
        children: [
          _buildContentSection(widget.lesson['content']),
          if (_showQuiz) _buildQuizSection(),
        ],
      ),
      floatingActionButton: !_showQuiz
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _markAsCompleted,
              backgroundColor: const Color(0xFFBE9E7E),
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check),
              label:
                  Text(_isLoading ? 'Enregistrement...' : 'Terminer la leçon'),
            )
          : null,
    );
  }
}
