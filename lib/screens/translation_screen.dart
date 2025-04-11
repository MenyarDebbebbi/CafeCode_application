import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class TranslationScreen extends StatefulWidget {
  final String languageId;
  final String courseId;
  final List<Translation> translations;

  const TranslationScreen({
    Key? key,
    required this.languageId,
    required this.courseId,
    required this.translations,
  }) : super(key: key);

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _originalTextController = TextEditingController();
  final TextEditingController _translatedTextController =
      TextEditingController();

  Future<void> _addTranslation() async {
    if (_originalTextController.text.isEmpty ||
        _translatedTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les deux champs sont obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final newTranslation = Translation(
        originalText: _originalTextController.text,
        translatedText: _translatedTextController.text,
      );

      final updatedTranslations = [...widget.translations, newTranslation];

      await _firestore
          .collection('languages')
          .doc(widget.languageId)
          .collection('courses')
          .doc(widget.courseId)
          .update({
        'translations': updatedTranslations.map((t) => t.toMap()).toList(),
      });

      if (!mounted) return;
      _originalTextController.clear();
      _translatedTextController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Traduction ajoutée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout de la traduction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Traductions',
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _originalTextController,
                    decoration: const InputDecoration(
                      labelText: 'Texte original',
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _translatedTextController,
                    decoration: const InputDecoration(
                      labelText: 'Traduction',
                      prefixIcon: Icon(Icons.translate),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addTranslation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBE9E7E),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Ajouter la traduction',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.translations.length,
                itemBuilder: (context, index) {
                  final translation = widget.translations[index];
                  return Card(
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _originalTextController.dispose();
    _translatedTextController.dispose();
    super.dispose();
  }
}
