import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour collecter et analyser les données d'utilisation
/// pour les tests du Mois 4 et le suivi clinique
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  SharedPreferences? _prefs;
  List<Map<String, dynamic>> _sessionData = [];
  DateTime? _sessionStart;
  String? _currentScreen;
  
  // Clés de stockage
  static const String _analyticsKey = 'analytics_data';
  static const String _sessionCountKey = 'session_count';
  static const String _totalUsageKey = 'total_usage_minutes';

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadStoredData();
  }

  /// Démarrer une nouvelle session d'utilisation
  Future<void> startSession() async {
    await _initPrefs();
    _sessionStart = DateTime.now();
    _sessionData.clear();
    
    // Incrémenter le compteur de sessions
    int sessionCount = _prefs!.getInt(_sessionCountKey) ?? 0;
    await _prefs!.setInt(_sessionCountKey, sessionCount + 1);
    
    await _logEvent('session_start', {
      'timestamp': _sessionStart!.toIso8601String(),
      'session_id': sessionCount + 1,
    });
  }

  /// Terminer la session en cours
  Future<void> endSession() async {
    if (_sessionStart == null) return;
    
    final sessionDuration = DateTime.now().difference(_sessionStart!);
    
    // Ajouter la durée totale d'utilisation
    int totalMinutes = _prefs!.getInt(_totalUsageKey) ?? 0;
    await _prefs!.setInt(_totalUsageKey, totalMinutes + sessionDuration.inMinutes);
    
    await _logEvent('session_end', {
      'duration_minutes': sessionDuration.inMinutes,
      'duration_seconds': sessionDuration.inSeconds,
      'screens_visited': _getUniqueScreensVisited(),
    });
    
    await _saveAnalyticsData();
    _sessionStart = null;
  }

  /// Enregistrer la navigation vers un écran
  Future<void> trackScreenVisit(String screenName) async {
    await _initPrefs();
    _currentScreen = screenName;
    
    await _logEvent('screen_visit', {
      'screen': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Enregistrer l'utilisation du TTS
  Future<void> trackTTSUsage(String word, bool wasSuccessful) async {
    await _logEvent('tts_usage', {
      'word': word,
      'successful': wasSuccessful,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Enregistrer une session de concentration
  Future<void> trackConcentrationSession({
    required String ambiance,
    required int durationMinutes,
    required bool completedFully,
  }) async {
    await _logEvent('concentration_session', {
      'ambiance': ambiance,
      'planned_duration': durationMinutes,
      'completed_fully': completedFully,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Enregistrer un appel d'urgence ou standard
  Future<void> trackCallAttempt({
    required bool isEmergency,
    required bool wasSuccessful,
    required int durationSeconds,
  }) async {
    await _logEvent('call_attempt', {
      'is_emergency': isEmergency,
      'successful': wasSuccessful,
      'duration_seconds': durationSeconds,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Enregistrer des problèmes ou erreurs rencontrées
  Future<void> trackUserIssue({
    required String issueType,
    required String description,
    String? screenName,
  }) async {
    await _logEvent('user_issue', {
      'issue_type': issueType,
      'description': description,
      'screen': screenName ?? _currentScreen,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Enregistrer le feedback utilisateur ou soignant
  Future<void> trackFeedback({
    required String feedbackType, // 'user', 'caregiver', 'family'
    required int rating, // 1-5
    required String comment,
  }) async {
    await _logEvent('feedback', {
      'feedback_type': feedbackType,
      'rating': rating,
      'comment': comment,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Enregistrer un événement générique
  Future<void> _logEvent(String eventType, Map<String, dynamic> data) async {
    _sessionData.add({
      'event_type': eventType,
      'data': data,
      'session_time': _sessionStart != null 
          ? DateTime.now().difference(_sessionStart!).inSeconds 
          : 0,
    });
  }

  /// Sauvegarder les données d'analytics
  Future<void> _saveAnalyticsData() async {
    if (_prefs == null) return;
    
    List<String> existingData = _prefs!.getStringList(_analyticsKey) ?? [];
    
    // Ajouter les nouvelles données de session
    for (var event in _sessionData) {
      existingData.add(jsonEncode(event));
    }
    
    // Garder seulement les 1000 derniers événements pour éviter la surcharge
    if (existingData.length > 1000) {
      existingData = existingData.sublist(existingData.length - 1000);
    }
    
    await _prefs!.setStringList(_analyticsKey, existingData);
  }

  /// Charger les données stockées
  Future<void> _loadStoredData() async {
    if (_prefs == null) return;
    // Les données sont chargées à la demande pour les rapports
  }

  /// Obtenir les écrans uniques visités dans la session
  List<String> _getUniqueScreensVisited() {
    Set<String> screens = {};
    for (var event in _sessionData) {
      if (event['event_type'] == 'screen_visit') {
        screens.add(event['data']['screen']);
      }
    }
    return screens.toList();
  }

  /// Générer un rapport d'utilisation pour les tests du Mois 4
  Future<Map<String, dynamic>> generateUsageReport() async {
    await _initPrefs();
    
    List<String> storedEvents = _prefs!.getStringList(_analyticsKey) ?? [];
    int sessionCount = _prefs!.getInt(_sessionCountKey) ?? 0;
    int totalMinutes = _prefs!.getInt(_totalUsageKey) ?? 0;
    
    // Analyser les événements stockés
    Map<String, int> screenVisits = {};
    Map<String, int> ambianceUsage = {};
    List<Map<String, dynamic>> callAttempts = [];
    List<Map<String, dynamic>> feedbacks = [];
    List<Map<String, dynamic>> issues = [];
    
    for (String eventJson in storedEvents) {
      try {
        Map<String, dynamic> event = jsonDecode(eventJson);
        String eventType = event['event_type'];
        Map<String, dynamic> data = event['data'];
        
        switch (eventType) {
          case 'screen_visit':
            String screen = data['screen'];
            screenVisits[screen] = (screenVisits[screen] ?? 0) + 1;
            break;
          case 'concentration_session':
            String ambiance = data['ambiance'];
            ambianceUsage[ambiance] = (ambianceUsage[ambiance] ?? 0) + 1;
            break;
          case 'call_attempt':
            callAttempts.add(data);
            break;
          case 'feedback':
            feedbacks.add(data);
            break;
          case 'user_issue':
            issues.add(data);
            break;
        }
      } catch (e) {
        // Ignorer les événements mal formés
      }
    }
    
    return {
      'summary': {
        'total_sessions': sessionCount,
        'total_usage_minutes': totalMinutes,
        'average_session_length': sessionCount > 0 ? totalMinutes / sessionCount : 0,
        'report_generated': DateTime.now().toIso8601String(),
      },
      'screen_usage': screenVisits,
      'ambiance_preferences': ambianceUsage,
      'call_statistics': _analyzeCallAttempts(callAttempts),
      'user_feedback': _analyzeFeedback(feedbacks),
      'reported_issues': issues.length,
      'issues_details': issues,
    };
  }

  Map<String, dynamic> _analyzeCallAttempts(List<Map<String, dynamic>> calls) {
    if (calls.isEmpty) return {'total_calls': 0};
    
    int emergencyCalls = calls.where((c) => c['is_emergency'] == true).length;
    int successfulCalls = calls.where((c) => c['successful'] == true).length;
    double avgDuration = calls.map((c) => c['duration_seconds'] as int)
        .reduce((a, b) => a + b) / calls.length;
    
    return {
      'total_calls': calls.length,
      'emergency_calls': emergencyCalls,
      'standard_calls': calls.length - emergencyCalls,
      'success_rate': successfulCalls / calls.length,
      'average_duration_seconds': avgDuration,
    };
  }

  Map<String, dynamic> _analyzeFeedback(List<Map<String, dynamic>> feedbacks) {
    if (feedbacks.isEmpty) return {'total_feedback': 0};
    
    double avgRating = feedbacks.map((f) => f['rating'] as int)
        .reduce((a, b) => a + b) / feedbacks.length;
    
    Map<String, int> feedbackTypes = {};
    for (var feedback in feedbacks) {
      String type = feedback['feedback_type'];
      feedbackTypes[type] = (feedbackTypes[type] ?? 0) + 1;
    }
    
    return {
      'total_feedback': feedbacks.length,
      'average_rating': avgRating,
      'feedback_by_type': feedbackTypes,
      'recent_comments': feedbacks.take(5).map((f) => f['comment']).toList(),
    };
  }

  /// Effacer toutes les données d'analytics (pour les tests)
  Future<void> clearAllData() async {
    await _initPrefs();
    await _prefs!.remove(_analyticsKey);
    await _prefs!.remove(_sessionCountKey);
    await _prefs!.remove(_totalUsageKey);
    _sessionData.clear();
  }
}