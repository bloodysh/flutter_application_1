import 'package:just_audio/just_audio.dart';

class AmbianceService {
  static final AmbianceService _instance = AmbianceService._internal();
  factory AmbianceService() => _instance;
  AmbianceService._internal();

  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  double _volume = 0.5;
  String _currentAmbiance = '';

  // Local asset paths for ambiance sounds
  final Map<String, String> _ambianceSources = {
    'ocean': 'assets/audio/ocean.mp3',
    'forest': 'assets/audio/forest.mp3',
    'rain': 'assets/audio/rain.mp3',
    'birds': 'assets/audio/birds.mp3',
  };

  bool get isPlaying => _isPlaying;
  String get currentAmbiance => _currentAmbiance;
  double get volume => _volume;

  Future<void> _initPlayer() async {
    _audioPlayer ??= AudioPlayer();
  }

  Future<void> play(String ambianceKey) async {
    if (!_ambianceSources.containsKey(ambianceKey)) {
      print('Ambiance key not found: $ambianceKey');
      return;
    }

    await _initPlayer();
    await stop();

    try {
      _currentAmbiance = ambianceKey;
      final assetPath = _ambianceSources[ambianceKey]!;

      // Use setAsset for local audio files instead of setUrl
      await _audioPlayer!.setAsset(assetPath);
      await _audioPlayer!.setVolume(_volume);
      await _audioPlayer!.setLoopMode(LoopMode.one); // Loop the audio
      await _audioPlayer!.play();
      _isPlaying = true;

      print('Successfully started playing: $ambianceKey');
    } catch (e) {
      print('Error playing audio: $e');
      print('Asset path: ${_ambianceSources[ambianceKey]}');
      _isPlaying = false;
      _currentAmbiance = '';
    }
  }

  Future<void> stop() async {
    if (_audioPlayer != null && _isPlaying) {
      try {
        await _audioPlayer!.stop();
        _isPlaying = false;
        _currentAmbiance = '';
        print('Audio stopped successfully');
      } catch (e) {
        print('Error stopping audio: $e');
      }
    }
  }

  Future<void> pause() async {
    if (_audioPlayer != null && _isPlaying) {
      try {
        await _audioPlayer!.pause();
        _isPlaying = false;
        print('Audio paused');
      } catch (e) {
        print('Error pausing audio: $e');
      }
    }
  }

  Future<void> resume() async {
    if (_audioPlayer != null && !_isPlaying && _currentAmbiance.isNotEmpty) {
      try {
        await _audioPlayer!.play();
        _isPlaying = true;
        print('Audio resumed');
      } catch (e) {
        print('Error resuming audio: $e');
      }
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_audioPlayer != null) {
      try {
        await _audioPlayer!.setVolume(_volume);
        print('Volume set to: $_volume');
      } catch (e) {
        print('Error setting volume: $e');
      }
    }
  }

  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _isPlaying = false;
    _currentAmbiance = '';
  }
}
