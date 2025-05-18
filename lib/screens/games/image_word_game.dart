import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:translator/translator.dart';

/// Jeu éducatif "Images et Mots" qui utilise la reconnaissance d'image et la traduction
/// pour aider à l'apprentissage du vocabulaire français. Les joueurs prennent des photos
/// d'objets, le jeu reconnaît le texte en anglais et les joueurs doivent donner
/// la traduction correcte en français.
class ImageWordGame extends StatefulWidget {
  const ImageWordGame({Key? key}) : super(key: key);

  @override
  State<ImageWordGame> createState() => _ImageWordGameState();
}

/// État du jeu qui gère :
/// - La capture et le traitement des photos
/// - La reconnaissance de texte avec ML Kit
/// - La traduction avec l'API Google Translate
/// - La validation des réponses et le score
class _ImageWordGameState extends State<ImageWordGame> {
  // Services et contrôleurs
  final ImagePicker _picker = ImagePicker(); // Service de capture d'image
  final TextRecognizer _textRecognizer =
      TextRecognizer(); // Service de reconnaissance de texte
  final translator = GoogleTranslator(); // Service de traduction
  TextEditingController _answerController =
      TextEditingController(); // Contrôleur pour la réponse

  // Variables d'état du jeu
  File? _imageFile; // Image capturée
  String _detectedText = ''; // Texte reconnu dans l'image
  String _translation = ''; // Traduction française du texte
  bool _isProcessing = false; // Indique si une opération est en cours
  int _score = 0; // Score du joueur

  @override
  void dispose() {
    _textRecognizer.close();
    _answerController.dispose();
    super.dispose();
  }

  /// Capture une photo avec l'appareil photo
  /// - Initialise la reconnaissance de texte
  /// - Traduit le texte reconnu en français
  /// - Gère les erreurs potentielles
  Future<void> _takePhoto() async {
    setState(() {
      _isProcessing = true;
      _detectedText = '';
      _translation = '';
    });

    try {
      // Capture de la photo
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) {
        setState(() => _isProcessing = false);
        return;
      }

      setState(() => _imageFile = File(photo.path));

      // Reconnaissance du texte avec ML Kit
      final inputImage = InputImage.fromFile(_imageFile!);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isNotEmpty) {
        // Traduction du texte en français
        final translation = await translator.translate(
          recognizedText.text,
          from: 'auto',
          to: 'fr',
        );

        setState(() {
          _detectedText = recognizedText.text;
          _translation = translation.text;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// Vérifie la réponse donnée par l'utilisateur
  /// - Compare avec la traduction correcte
  /// - Met à jour le score (+10 points si correct)
  /// - Affiche un message de feedback
  void _checkAnswer() {
    final userAnswer = _answerController.text.trim().toLowerCase();
    final correctAnswer = _translation.toLowerCase();

    if (userAnswer == correctAnswer) {
      setState(() => _score += 10);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correct ! +10 points'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect. La bonne réponse était: $_translation'),
          backgroundColor: Colors.red,
        ),
      );
    }

    _answerController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre d'application avec score
      appBar: AppBar(
        title:
            const Text('Images et Mots', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFBE9E7E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Score: $_score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      // Corps du jeu avec fond dégradé
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFE8E1D9)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Carte d'instructions et bouton photo
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Prenez en photo un objet et essayez de le nommer en français !',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(_isProcessing
                            ? 'Traitement...'
                            : 'Prendre une photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBE9E7E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Affichage de l'image capturée
              if (_imageFile != null) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.file(_imageFile!),
                  ),
                ),
              ],
              // Champ de réponse (visible après reconnaissance du texte)
              if (_detectedText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _answerController,
                          decoration: InputDecoration(
                            labelText: 'Votre réponse en français',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: _checkAnswer,
                            ),
                          ),
                          onSubmitted: (_) => _checkAnswer(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      // Bouton flottant pour prendre une photo rapidement
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhoto,
        backgroundColor: const Color(0xFFBE9E7E),
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
