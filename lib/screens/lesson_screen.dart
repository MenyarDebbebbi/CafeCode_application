import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _sections = ['Théorie', 'Pratique', 'Quiz'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markAsCompleted() async {
    setState(() => _isLoading = true);
    try {
      // Mettre à jour le statut de la leçon dans Firestore
      await FirebaseFirestore.instance
          .collection('languages')
          .doc(widget.languageId)
          .update({
        'lessons.${widget.lesson['id']}.completed': true,
        'lessons.${widget.lesson['id']}.completedAt':
            FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leçon terminée !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
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

  Widget _buildTheorySection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.lesson['title'] ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.lesson['description'] != null)
            Text(
              widget.lesson['description'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          const SizedBox(height: 24),
          // Contenu de la leçon
          if (widget.lesson['content'] != null) ...[
            if (widget.lesson['content'] is List) ...[
              ...(widget.lesson['content'] as List).map<Widget>((content) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    content.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ] else if (widget.lesson['content'] is String) ...[
              Text(
                widget.lesson['content'].toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
          // Exemples
          if (widget.lesson['examples'] != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Exemples',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.lesson['examples'] is List) ...[
              ...(widget.lesson['examples'] as List).map<Widget>((example) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      example.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
            ] else if (widget.lesson['examples'] is String) ...[
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.lesson['examples'].toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPracticeSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Exercices à venir',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSection() {
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
            'Quiz à venir',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
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
        bottom: PreferredSize(
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
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        children: [
          _buildTheorySection(),
          _buildPracticeSection(),
          _buildQuizSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        label: Text(_isLoading ? 'Enregistrement...' : 'Terminer la leçon'),
      ),
    );
  }
}
