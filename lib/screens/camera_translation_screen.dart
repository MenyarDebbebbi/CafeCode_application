import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';

class CameraTranslationScreen extends StatefulWidget {
  final String targetLanguage;

  const CameraTranslationScreen({
    Key? key,
    required this.targetLanguage,
  }) : super(key: key);

  @override
  State<CameraTranslationScreen> createState() =>
      _CameraTranslationScreenState();
}

class _CameraTranslationScreenState extends State<CameraTranslationScreen> {
  CameraController? _controller;
  late final TextRecognizer _textRecognizer;
  final _translator = GoogleTranslator();
  bool _isBusy = false;
  String _extractedText = '';
  String _translatedText = '';
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller?.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isBusy = true);

    try {
      final XFile? image = await _controller?.takePicture();
      if (image == null) return;

      _imageFile = File(image.path);
      await _processImage(_imageFile!);
    } catch (e) {
      print('Erreur lors de la prise de photo: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _imageFile = File(image.path);
      _processImage(_imageFile!);
    });
  }

  Future<void> _processImage(File image) async {
    setState(() => _isBusy = true);

    try {
      final inputImage = InputImage.fromFile(image);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      setState(() => _extractedText = recognizedText.text);

      if (_extractedText.isNotEmpty) {
        final translation = await _translator.translate(
          _extractedText,
          to: widget.targetLanguage,
        );

        setState(() => _translatedText = translation.text);
      }
    } catch (e) {
      print('Erreur lors du traitement de l\'image: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Traduction par Caméra',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFBE9E7E),
        actions: [
          IconButton(
            icon: const Icon(Icons.image, color: Colors.white),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _imageFile != null
                ? Image.file(_imageFile!)
                : CameraPreview(_controller!),
          ),
          if (_isBusy)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Texte détecté:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_extractedText),
                  const SizedBox(height: 16),
                  const Text(
                    'Traduction:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _translatedText,
                    style: const TextStyle(
                      color: Color(0xFFBE9E7E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        backgroundColor: const Color(0xFFBE9E7E),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }
}
