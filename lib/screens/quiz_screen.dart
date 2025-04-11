import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizScreen extends StatefulWidget {
  final List<Quiz> quizzes;
  final Function onComplete;

  const QuizScreen({
    Key? key,
    required this.quizzes,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final AudioService _audioService = AudioService();
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showResult = false;
  bool _isAnswered = false;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
  }

  void _checkAnswer(String selectedAnswer) async {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedAnswer = selectedAnswer;
    });

    final quiz = widget.quizzes[_currentQuestionIndex];
    final isCorrect = selectedAnswer == quiz.correctAnswer;

    if (isCorrect) {
      setState(() => _score++);
      await _audioService.playAudio('assets/sounds/correct.mp3');
    } else {
      await _audioService.playAudio('assets/sounds/incorrect.mp3');
    }

    await Future.delayed(const Duration(seconds: 1));

    if (_currentQuestionIndex < widget.quizzes.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswer = null;
      });
    } else {
      setState(() => _showResult = true);
      final percentage = (_score / widget.quizzes.length) * 100;
      if (percentage >= 80) {
        _generateCertificate();
      }
      widget.onComplete();
    }
  }

  Future<void> _generateCertificate() async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('certificates').add({
        'userId': 'USER_ID',
        'courseName': 'Cours de langue',
        'score': _score,
        'totalQuestions': widget.quizzes.length,
        'percentage': (_score / widget.quizzes.length) * 100,
        'dateObtained': DateTime.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Félicitations ! Vous avez obtenu votre certificat !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la génération du certificat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getOptionColor(String option) {
    if (!_isAnswered) return Colors.white;

    final quiz = widget.quizzes[_currentQuestionIndex];
    if (option == quiz.correctAnswer) {
      return Colors.green.shade100;
    }
    if (option == _selectedAnswer && option != quiz.correctAnswer) {
      return Colors.red.shade100;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return _buildResultScreen();
    }

    final quiz = widget.quizzes[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFBE9E7E),
        elevation: 0,
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / widget.quizzes.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFBE9E7E)),
                ),
                const SizedBox(height: 24),
                Text(
                  'Question ${_currentQuestionIndex + 1}/${widget.quizzes.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      quiz.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: quiz.options.length,
                    itemBuilder: (context, index) {
                      final option = quiz.options[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 2,
                          color: _getOptionColor(option),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap:
                                _isAnswered ? null : () => _checkAnswer(option),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: _isAnswered &&
                                              option == quiz.correctAnswer
                                          ? Colors.green
                                          : _isAnswered &&
                                                  option == _selectedAnswer
                                              ? Colors.red
                                              : const Color(0xFFBE9E7E),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4A4A4A),
                                      ),
                                    ),
                                  ),
                                  if (_isAnswered)
                                    Icon(
                                      option == quiz.correctAnswer
                                          ? Icons.check_circle
                                          : option == _selectedAnswer
                                              ? Icons.cancel
                                              : null,
                                      color: option == quiz.correctAnswer
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / widget.quizzes.length) * 100;
    final isPerfect = percentage == 100;

    return Scaffold(
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
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: isPerfect
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPerfect ? Icons.star : Icons.emoji_events,
                      size: 60,
                      color: isPerfect ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    isPerfect
                        ? 'Félicitations !'
                        : percentage >= 70
                            ? 'Bien joué !'
                            : 'Continuez vos efforts !',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Score: $_score/${widget.quizzes.length}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isPerfect ? Colors.green : const Color(0xFFBE9E7E),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBE9E7E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Terminer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
