import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

// Note: Pour utiliser Agora, vous aurez besoin d'une clé API d'Agora.io
// Pour un projet réel, créez un compte sur https://www.agora.io/
// Ceci est une simulation pour démonstration

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  // Simuler des clés et ID Agora pour la démonstration
  final String _appId = "votre_app_id_agora"; // À remplacer par une vraie clé
  final String _token = ""; // Pour les tests, peut être vide
  final String _channel = "lysea_channel";
  
  RtcEngine? _engine;
  bool _isInitialized = false;
  bool _isInCall = false;
  
  // Pour les appels normaux
  final String _emergencyNumber = "tel:112"; // À adapter selon le pays
  final String _caregiverNumber = "tel:0123456789"; // À remplacer
  
  bool get isInCall => _isInCall;
  
  // Initialiser les permissions et le moteur d'appel
  Future<void> init() async {
    if (_isInitialized) return;
    
    // Vérifier et demander les permissions nécessaires
    await [Permission.microphone, Permission.camera].request();
    
    try {
      // Créer et initialiser le moteur RTC
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: _appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));
      
      // Configuration pour appels audio uniquement
      await _engine!.enableAudio();
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      
      _isInitialized = true;
    } catch (e) {
      print('Erreur initialisation appel: $e');
      _isInitialized = false;
    }
  }
  
  // Rejoindre un canal pour un appel de type talkie-walkie
  Future<bool> startEmergencyCall() async {
    if (!_isInitialized) await init();
    if (_isInCall) return true; // Déjà en appel
    
    try {
      // Rejoindre le canal d'appel
      await _engine?.joinChannel(
        token: _token,
        channelId: _channel,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
      
      _isInCall = true;
      return true;
    } catch (e) {
      print('Erreur appel d\'urgence: $e');
      return false;
    }
  }
  
  // Quitter le canal d'appel
  Future<void> endEmergencyCall() async {
    if (_isInitialized && _isInCall) {
      await _engine?.leaveChannel();
      _isInCall = false;
    }
  }
  
  // Pour le push-to-talk (activer/désactiver le micro)
  Future<void> setMicrophoneMuted(bool muted) async {
    if (_isInitialized && _isInCall) {
      await _engine?.muteLocalAudioStream(muted);
    }
  }
  
  // Lancer un appel téléphonique classique
  Future<bool> makePhoneCall({bool isEmergency = false}) async {
    final String number = isEmergency ? _emergencyNumber : _caregiverNumber;
    
    final Uri url = Uri.parse(number);
    try {
      return await launchUrl(url);
    } catch (e) {
      print('Impossible de lancer l\'appel: $e');
      return false;
    }
  }
  
  void dispose() {
    if (_isInCall) {
      _engine?.leaveChannel();
    }
    _engine?.release();
    _isInCall = false;
    _isInitialized = false;
  }
}
