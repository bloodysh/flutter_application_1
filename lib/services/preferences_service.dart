import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();
  
  SharedPreferences? _prefs;
  
  // Clés de préférences
  static const String _volumeKey = 'ambiance_volume';
  static const String _selectedAmbianceKey = 'selected_ambiance';
  static const String _sessionDurationKey = 'session_duration';
  static const String _fontSizeKey = 'font_size';
  static const String _caregiverNumberKey = 'caregiver_number';
  
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  // Méthodes pour la gestion des préférences audio
  Future<double> getAmbianceVolume() async {
    await _initPrefs();
    return _prefs!.getDouble(_volumeKey) ?? 0.5; // 0.5 par défaut
  }
  
  Future<void> setAmbianceVolume(double volume) async {
    await _initPrefs();
    await _prefs!.setDouble(_volumeKey, volume);
  }
  
  Future<String> getSelectedAmbiance() async {
    await _initPrefs();
    return _prefs!.getString(_selectedAmbianceKey) ?? 'ocean'; // ocean par défaut
  }
  
  Future<void> setSelectedAmbiance(String ambiance) async {
    await _initPrefs();
    await _prefs!.setString(_selectedAmbianceKey, ambiance);
  }
  
  // Méthodes pour la gestion des préférences de session
  Future<int> getSessionDuration() async {
    await _initPrefs();
    return _prefs!.getInt(_sessionDurationKey) ?? 5; // 5 minutes par défaut
  }
  
  Future<void> setSessionDuration(int minutes) async {
    await _initPrefs();
    await _prefs!.setInt(_sessionDurationKey, minutes);
  }
  
  // Méthodes pour la gestion des préférences d'accessibilité
  Future<double> getFontSize() async {
    await _initPrefs();
    return _prefs!.getDouble(_fontSizeKey) ?? 36.0; // 36.0 par défaut
  }
  
  Future<void> setFontSize(double size) async {
    await _initPrefs();
    await _prefs!.setDouble(_fontSizeKey, size);
  }
  
  // Méthodes pour la gestion des contacts
  Future<String> getCaregiverNumber() async {
    await _initPrefs();
    return _prefs!.getString(_caregiverNumberKey) ?? '0123456789'; // À personnaliser
  }
  
  Future<void> setCaregiverNumber(String number) async {
    await _initPrefs();
    await _prefs!.setString(_caregiverNumberKey, number);
  }
  
  // Effacer toutes les préférences (reset)
  Future<void> clearAllPreferences() async {
    await _initPrefs();
    await _prefs!.clear();
  }
}
