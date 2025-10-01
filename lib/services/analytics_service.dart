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
    });

    await _saveData();
  }

  /// Suivre la visite d'un écran
  Future<void> trackScreenVisit(String screenName) async {
    await _initPrefs();
    _currentScreen = screenName;

    await _logEvent('screen_visit', {
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Suivre l'appui sur un bouton
  Future<void> trackButtonPress(String buttonName) async {
    await _initPrefs();

    await _logEvent('button_press', {
      'button_name': buttonName,
      'screen': _currentScreen ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Suivre l'utilisation d'une fonctionnalité
  Future<void> trackFeatureUsage(String featureName, Map<String, dynamic> data) async {
    await _initPrefs();

    await _logEvent('feature_usage', {
      'feature_name': featureName,
      'screen': _currentScreen ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
      ...data,
    });
  }

  /// Suivre les erreurs
  Future<void> trackError(String errorType, String errorMessage) async {
    await _initPrefs();

    await _logEvent('error', {
      'error_type': errorType,
      'error_message': errorMessage,
      'screen': _currentScreen ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Suivre l'utilisation du TTS
  Future<void> trackTTSUsage(String text, bool isSuccessful) async {
    await _initPrefs();

    await _logEvent('tts_usage', {
      'text_length': text.length,
      'is_successful': isSuccessful,
      'screen': _currentScreen ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Suivre une session de concentration
  Future<void> trackConcentrationSession(String type, int durationSeconds, Map<String, dynamic> results) async {
    await _initPrefs();

    await _logEvent('concentration_session', {
      'session_type': type,
      'duration_seconds': durationSeconds,
      'results': results,
      'screen': _currentScreen ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Suivre une tentative d'appel
  Future<void> trackCallAttempt(String callType, bool isSuccessful, Map<String, dynamic> details) async {
    await _initPrefs();

    await _logEvent('call_attempt', {
      'call_type': callType,
      'is_successful': isSuccessful,
      'details': details,
      'screen': _currentScreen ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Suivre les retours utilisateur
  Future<void> trackFeedback(String feedbackType, Map<String, dynamic> feedbackData) async {
    await _initPrefs();

    await _logEvent('user_feedback', {
      'feedback_type': feedbackType,
      'feedback_data': feedbackData,
      'screen': _currentScreen ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Suivre les problèmes signalés par l'utilisateur
  Future<void> trackUserIssue(String issueType, String description, Map<String, dynamic> context) async {
    await _initPrefs();

    await _logEvent('user_issue', {
      'issue_type': issueType,
      'description': description,
      'context': context,
      'screen': _currentScreen ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Enregistrer un événement
  Future<void> _logEvent(String eventType, Map<String, dynamic> data) async {
    final event = {
      'event_type': eventType,
      'timestamp': DateTime.now().toIso8601String(),
      ...data,
    };

    _sessionData.add(event);

    // Sauvegarder périodiquement (tous les 10 événements)
    if (_sessionData.length % 10 == 0) {
      await _saveData();
    }
  }

  /// Charger les données stockées
  Future<void> _loadStoredData() async {
    try {
      final String? storedData = _prefs!.getString(_analyticsKey);
      if (storedData != null) {
        final List<dynamic> decodedData = json.decode(storedData);
        _sessionData = decodedData.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Erreur lors du chargement des données analytics: $e');
      _sessionData = [];
    }
  }

  /// Sauvegarder les données
  Future<void> _saveData() async {
    try {
      final String encodedData = json.encode(_sessionData);
      await _prefs!.setString(_analyticsKey, encodedData);
    } catch (e) {
      print('Erreur lors de la sauvegarde des données analytics: $e');
    }
  }

  /// Obtenir les statistiques d'utilisation
  Future<Map<String, dynamic>> getUsageStats() async {
    await _initPrefs();

    int sessionCount = _prefs!.getInt(_sessionCountKey) ?? 0;
    int totalMinutes = _prefs!.getInt(_totalUsageKey) ?? 0;

    // Compter les événements par type
    Map<String, int> eventCounts = {};
    for (var event in _sessionData) {
      String eventType = event['event_type'] ?? 'unknown';
      eventCounts[eventType] = (eventCounts[eventType] ?? 0) + 1;
    }

    return {
      'total_sessions': sessionCount,
      'total_usage_minutes': totalMinutes,
      'event_counts': eventCounts,
      'total_events': _sessionData.length,
    };
  }

  /// Exporter les données pour analyse clinique
  Future<String> exportDataForClinical() async {
    await _initPrefs();

    final stats = await getUsageStats();
    final exportData = {
      'export_timestamp': DateTime.now().toIso8601String(),
      'stats': stats,
      'events': _sessionData,
    };

    return json.encode(exportData);
  }

  /// Effacer toutes les données
  Future<void> clearAllData() async {
    await _initPrefs();

    await _prefs!.remove(_analyticsKey);
    await _prefs!.remove(_sessionCountKey);
    await _prefs!.remove(_totalUsageKey);

    _sessionData.clear();
  }

  /// Générer un rapport d'utilisation pour les soignants
  Future<Map<String, dynamic>> generateUsageReport() async {
    await _initPrefs();

    final stats = await getUsageStats();
    final now = DateTime.now();

    // Analyser les données des 7 derniers jours
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentEvents = _sessionData.where((event) {
      try {
        final eventTime = DateTime.parse(event['timestamp']);
        return eventTime.isAfter(weekAgo);
      } catch (e) {
        return false;
      }
    }).toList();

    // Calculer les métriques d'engagement
    final buttonPresses = recentEvents.where((e) => e['event_type'] == 'button_press').length;
    final ttsUsage = recentEvents.where((e) => e['event_type'] == 'tts_usage').length;
    final concentrationSessions = recentEvents.where((e) => e['event_type'] == 'concentration_session').length;
    final callAttempts = recentEvents.where((e) => e['event_type'] == 'call_attempt').length;

    return {
      'report_date': now.toIso8601String(),
      'period': '7 days',
      'total_sessions': stats['total_sessions'],
      'total_usage_minutes': stats['total_usage_minutes'],
      'recent_activity': {
        'button_presses': buttonPresses,
        'tts_usage_count': ttsUsage,
        'concentration_sessions': concentrationSessions,
        'call_attempts': callAttempts,
      },
      'engagement_level': _calculateEngagementLevel(recentEvents.length, stats['total_sessions']),
      'recommendations': _generateRecommendations(recentEvents),
    };
  }

  /// Calculer le niveau d'engagement
  String _calculateEngagementLevel(int recentEvents, int totalSessions) {
    if (totalSessions == 0) return 'Nouveau utilisateur';
    if (recentEvents > 50) return 'Très actif';
    if (recentEvents > 20) return 'Actif';
    if (recentEvents > 5) return 'Modéré';
    return 'Faible';
  }

  /// Générer des recommandations basées sur l'usage
  List<String> _generateRecommendations(List<Map<String, dynamic>> recentEvents) {
    List<String> recommendations = [];

    final ttsEvents = recentEvents.where((e) => e['event_type'] == 'tts_usage').length;
    final concentrationEvents = recentEvents.where((e) => e['event_type'] == 'concentration_session').length;
    final callEvents = recentEvents.where((e) => e['event_type'] == 'call_attempt').length;

    if (ttsEvents < 3) {
      recommendations.add('Encourager l\'utilisation de la lecture assistée');
    }
    if (concentrationEvents < 2) {
      recommendations.add('Proposer des sessions de concentration plus fréquentes');
    }
    if (callEvents > 10) {
      recommendations.add('Vérifier si l\'utilisateur a besoin d\'aide supplémentaire');
    }

    return recommendations;
  }
}
