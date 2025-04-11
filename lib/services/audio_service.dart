import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      _isInitialized = true;
    }
  }

  Future<void> playAudio(String path) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _audioPlayer.stop();
      if (path.startsWith('assets/')) {
        // Utiliser AssetSource pour les fichiers locaux
        await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
      } else {
        // Utiliser UrlSource pour les URLs distantes
        await _audioPlayer.play(UrlSource(path));
      }
    } catch (e) {
      print('Erreur lors de la lecture audio: $e');
    }
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
    _isInitialized = false;
  }
}
