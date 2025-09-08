import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    const AndroidInitializationSettings initializationSettingsAndroid = 
      AndroidInitializationSettings('@mipmap/ic_launcher');
      
    const DarwinInitializationSettings initializationSettingsIOS = 
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Traiter la réponse à la notification ici
      },
    );
    
    _isInitialized = true;
  }

  // Notification pour appel entrant d'urgence
  Future<void> showEmergencyCallNotification({
    required String patientName,
    required String room,
  }) async {
    if (!_isInitialized) await init();
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'emergency_call_channel',
      'Appels d\'urgence',
      channelDescription: 'Canal pour les appels d\'urgence des patients',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Appel d\'urgence',
      sound: RawResourceAndroidNotificationSound('alarm'),
      playSound: true,
      enableLights: true,
      fullScreenIntent: true,
      color: Color.fromARGB(255, 231, 76, 60), // Rouge d'urgence
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    
    await _notificationsPlugin.show(
      0,
      'APPEL D\'URGENCE',
      'Patient: $patientName - Chambre: $room',
      platformDetails,
      payload: 'emergency_$room',
    );
  }

  // Notification pour appel entrant standard
  Future<void> showCallNotification({
    required String patientName,
    required String room,
  }) async {
    if (!_isInitialized) await init();
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'call_channel',
      'Appels standards',
      channelDescription: 'Canal pour les appels standards des patients',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Appel entrant',
      playSound: true,
      color: Color.fromARGB(255, 155, 89, 182), // Violet des appels standard
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    
    await _notificationsPlugin.show(
      1,
      'Appel entrant',
      'Patient: $patientName - Chambre: $room',
      platformDetails,
      payload: 'call_$room',
    );
  }
  
  // Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;
    await _notificationsPlugin.cancelAll();
  }
}
