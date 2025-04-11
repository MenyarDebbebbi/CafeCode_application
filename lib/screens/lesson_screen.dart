import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../services/audio_service.dart';

class LessonScreen extends StatefulWidget {
  final String languageId;
  final String courseId;
  final Lesson lesson;

  const LessonScreen({
    Key? key,
    required this.languageId,
    required this.courseId,
    required this.lesson,
  }) : super(key: key);

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AudioService _audioService = AudioService();
  bool _showTranslations = false;

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
  }

  Future<void> _markLessonAsCompleted() async {
    try {
      await _firestore
          .collection('languages')
          .doc(widget.languageId)
          .collection('courses')
          .doc(widget.courseId)
          .collection('lessons')
          .doc(widget.lesson.id)
          .update({'isCompleted': true});

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour de la leçon: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFBE9E7E),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showTranslations ? Icons.g_translate : Icons.translate,
                color: Colors.white),
            onPressed: () {
              setState(() {
                _showTranslations = !_showTranslations;
              });
            },
          ),
        ],
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.lesson.content,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.volume_up,
                              color: Color(0xFFBE9E7E),
                            ),
                            onPressed: () =>
                                _audioService.playAudio(widget.lesson.audioUrl),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_showTranslations &&
                  widget.lesson.translations.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Traductions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 16),
                ...widget.lesson.translations.map(
                  (translation) => Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translation.originalText,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                          const Divider(height: 24),
                          Text(
                            translation.translatedText,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFFBE9E7E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _markLessonAsCompleted,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBE9E7E),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              'Terminer la leçon',
              style: TextStyle(fontSize: 16),
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
