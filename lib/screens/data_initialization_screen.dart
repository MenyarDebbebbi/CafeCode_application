import 'package:flutter/material.dart';
import '../services/language_service.dart';

class DataInitializationScreen extends StatefulWidget {
  const DataInitializationScreen({Key? key}) : super(key: key);

  @override
  State<DataInitializationScreen> createState() =>
      _DataInitializationScreenState();
}

class _DataInitializationScreenState extends State<DataInitializationScreen> {
  final LanguageService _languageService = LanguageService();
  bool _isLoading = false;
  String _status = '';

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _status = 'Initialisation des données...';
    });

    try {
      await _languageService.initializeLanguages();
      setState(() {
        _status = 'Données initialisées avec succès !';
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur lors de l\'initialisation : $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initialisation des données'),
        backgroundColor: const Color(0xFFBE9E7E),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE9E7E)),
                )
              else
                ElevatedButton(
                  onPressed: _initializeData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE9E7E),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Initialiser les données',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              const SizedBox(height: 24),
              if (_status.isNotEmpty)
                Text(
                  _status,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
