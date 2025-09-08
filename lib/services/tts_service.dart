import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  double _volume = 1.0;
  double _pitch = 1.0;
  double _rate = 0.5;  // Ralenti pour être plus adapté aux personnes âgées
  String _language = 'fr-FR';

  Future<void> initTTS() async {
    if (_isInitialized) return;
    
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage(_language);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setSpeechRate(_rate);
    
    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) await initTTS();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    if (_isInitialized) {
      await _flutterTts.stop();
    }
  }

  Future<void> setVolume(double volume) async {
    if (!_isInitialized) await initTTS();
    _volume = volume;
    await _flutterTts.setVolume(volume);
  }

  Future<void> setRate(double rate) async {
    if (!_isInitialized) await initTTS();
    _rate = rate;
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) await initTTS();
    _pitch = pitch;
    await _flutterTts.setPitch(pitch);
  }

  void dispose() {
    if (_isInitialized) {
      _flutterTts.stop();
    }
  }
}
