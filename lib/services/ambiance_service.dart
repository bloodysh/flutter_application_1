import 'package:just_audio/just_audio.dart';

class AmbianceService {
  static final AmbianceService _instance = AmbianceService._internal();
  factory AmbianceService() => _instance;
  AmbianceService._internal();

  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  double _volume = 0.5;
  String _currentAmbiance = '';
  
  // En production, ces assets devraient être inclus dans le pubspec.yaml
  // Pour le développement, on simule avec des URLs
  final Map<String, String> _ambianceSources = {
    'ocean': 'https://cdn.pixabay.com/download/audio/2022/03/15/audio_c8c8a73467.mp3?filename=ocean-waves-112802.mp3',
    'forest': 'https://cdn.pixabay.com/download/audio/2021/08/09/audio_c62541d071.mp3?filename=forest-with-small-river-birds-and-nature-field-recording-6735.mp3',
    'rain': 'https://cdn.pixabay.com/download/audio/2021/04/07/audio_c84404951b.mp3?filename=light-rain-ambient-114354.mp3',
    'birds': 'https://cdn.pixabay.com/download/audio/2021/04/08/audio_c5776b0de7.mp3?filename=birds-singing-in-spring-01-6771.mp3',
  };
  
  bool get isPlaying => _isPlaying;
  String get currentAmbiance => _currentAmbiance;
  
  Future<void> _initPlayer() async {
    _audioPlayer ??= AudioPlayer();
  }

  Future<void> play(String ambianceKey) async {
    if (!_ambianceSources.containsKey(ambianceKey)) return;
    
    await _initPlayer();
    await stop();
    
    try {
      _currentAmbiance = ambianceKey;
      await _audioPlayer!.setUrl(_ambianceSources[ambianceKey]!);
      await _audioPlayer!.setVolume(_volume);
      await _audioPlayer!.setLoopMode(LoopMode.one); // Lecture en boucle
      await _audioPlayer!.play();
      _isPlaying = true;
    } catch (e) {
      print('Erreur de lecture audio: $e');
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    if (_audioPlayer != null && _isPlaying) {
      await _audioPlayer!.stop();
      _isPlaying = false;
      _currentAmbiance = '';
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    if (_audioPlayer != null && _isPlaying) {
      await _audioPlayer!.setVolume(volume);
    }
  }

  void dispose() {
    if (_audioPlayer != null) {
      _audioPlayer!.dispose();
      _audioPlayer = null;
      _isPlaying = false;
    }
  }
}
