import 'package:flutter/material.dart';
import 'dart:async';
import '../services/call_service.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';
import '../services/feedback_service.dart';

class CaregiverScreen extends StatefulWidget {
  const CaregiverScreen({super.key});

  @override
  State<CaregiverScreen> createState() => _CaregiverScreenState();
}

class _CaregiverScreenState extends State<CaregiverScreen> 
    with TickerProviderStateMixin {
  bool hasIncomingCall = false;
  bool isInCall = false;
  bool isMuted = false;
  int callDuration = 0;
  Timer? callTimer;
  String callerName = "Patient - Chambre 204";
  String callType = "Appel d'urgence";
  
  // Services
  final CallService _callService = CallService();
  final NotificationService _notificationService = NotificationService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final FeedbackService _feedbackService = FeedbackService();
  
  late AnimationController alertController;
  late Animation<double> alertAnimation;

  final List<Map<String, dynamic>> callHistory = [
    {
      'patientName': 'Patient - Chambre 204',
      'type': 'Urgence',
      'time': '14:32',
      'duration': '2:45',
      'status': 'completed'
    },
    {
      'patientName': 'Patient - Chambre 186',
      'type': 'Appel',
      'time': '13:15',
      'duration': '1:23',
      'status': 'completed'
    },
    {
      'patientName': 'Patient - Chambre 204',
      'type': 'Urgence',
      'time': '12:58',
      'duration': '0:45',
      'status': 'missed'
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Analytics: Track screen visit
    _analyticsService.trackScreenVisit('caregiver_screen');
    
    // Initialiser les services
    _notificationService.init();
    _callService.init();
    
    // Animation d'alerte
    alertController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    alertAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: alertController,
      curve: Curves.easeInOut,
    ));

    // Simuler un appel entrant après 3 secondes
    Timer(const Duration(seconds: 3), () {
      simulateIncomingCall();
    });
  }

  @override
  void dispose() {
    callTimer?.cancel();
    alertController.dispose();
    super.dispose();
  }

  void simulateIncomingCall() {
    setState(() {
      hasIncomingCall = true;
    });
    alertController.repeat(reverse: true);
    
    // Déclencher une notification d'appel d'urgence
    _notificationService.showEmergencyCallNotification(
      patientName: "Patient",
      room: "Chambre 204",
    );
  }

  Future<void> acceptCall() async {
    // Annuler la notification
    await _notificationService.cancelAllNotifications();
    
    // Rejoindre le canal d'appel d'urgence
    bool success = await _callService.startEmergencyCall();
    
    if (success) {
      setState(() {
        hasIncomingCall = false;
        isInCall = true;
        callDuration = 0;
      });
      
      alertController.stop();
      alertController.reset();
      
      // Analytics: Track caregiver call acceptance
      _analyticsService.trackCallAttempt(
        isEmergency: true,
        wasSuccessful: true,
        durationSeconds: 0, // Will be updated when call ends
      );
      
      // Démarrer le timer d'appel
      callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            callDuration++;
          });
        }
      });
    } else {
      // Échec de connexion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'établir la connexion avec le patient.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> rejectCall() async {
    // Annuler la notification
    await _notificationService.cancelAllNotifications();
    
    setState(() {
      hasIncomingCall = false;
    });
    alertController.stop();
    alertController.reset();
  }

  Future<void> endCall() async {
    final finalCallDuration = callDuration;
    
    // Terminer l'appel VoIP
    await _callService.endEmergencyCall();
    
    // Analytics: Track call completion
    _analyticsService.trackCallAttempt(
      isEmergency: true,
      wasSuccessful: true,
      durationSeconds: finalCallDuration,
    );
    
    setState(() {
      isInCall = false;
      isMuted = false;
    });
    callTimer?.cancel();
    
    // Show caregiver feedback after significant calls
    if (finalCallDuration > 60) { // Only ask for feedback on calls longer than 1 minute
      await _feedbackService.showCaregiverFeedbackDialog(context);
    }
  }

  Future<void> toggleMute() async {
    // Activer/désactiver le micro
    await _callService.setMicrophoneMuted(!isMuted);
    
    setState(() {
      isMuted = !isMuted;
    });
  }

  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        title: const Text(
          'Interface Soignant - Lyséa',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Badge de notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, size: 28),
                onPressed: () {},
              ),
              if (hasIncomingCall)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE74C3C),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Interface principale
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statut de service
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.radio_button_checked, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'En ligne - Prêt à recevoir les appels',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Statistiques du jour
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.call_received,
                              size: 32,
                              color: Color(0xFF3498DB),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '12',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              'Appels reçus',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.emergency,
                              size: 32,
                              color: Color(0xFFE74C3C),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '3',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              'Urgences',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Historique des appels
                const Text(
                  'Historique des appels',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    itemCount: callHistory.length,
                    itemBuilder: (context, index) {
                      final call = callHistory[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: call['status'] == 'missed' 
                                ? const Color(0xFFE74C3C).withOpacity(0.3)
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: call['type'] == 'Urgence' 
                                    ? const Color(0xFFE74C3C) 
                                    : const Color(0xFF3498DB),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                call['type'] == 'Urgence' ? Icons.warning : Icons.phone,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    call['patientName'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    call['type'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: call['type'] == 'Urgence' 
                                          ? const Color(0xFFE74C3C) 
                                          : const Color(0xFF3498DB),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  call['time'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF7F8C8D),
                                  ),
                                ),
                                Text(
                                  call['duration'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF95A5A6),
                                  ),
                                ),
                              ],
                            ),
                            if (call['status'] == 'missed')
                              const Icon(
                                Icons.call_missed,
                                color: Color(0xFFE74C3C),
                                size: 20,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Overlay d'appel entrant
          if (hasIncomingCall)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: AnimatedBuilder(
                  animation: alertAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: alertAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.call,
                              size: 80,
                              color: Color(0xFFE74C3C),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'APPEL ENTRANT',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE74C3C),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              callerName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              callType,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Bouton rejeter
                                SizedBox(
                                  width: 100,
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: rejectCall,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE74C3C),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Icon(Icons.call_end, size: 28),
                                  ),
                                ),
                                // Bouton accepter
                                SizedBox(
                                  width: 100,
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: acceptCall,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF27AE60),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Icon(Icons.call, size: 28),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Overlay d'appel en cours
          if (isInCall)
            Container(
              color: Colors.black.withOpacity(0.9),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.phone_in_talk,
                        size: 80,
                        color: Color(0xFF27AE60),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'EN COMMUNICATION',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27AE60),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        callerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatDuration(callDuration),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3498DB),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Bouton mute
                          SizedBox(
                            width: 80,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: toggleMute,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isMuted 
                                    ? const Color(0xFFE74C3C) 
                                    : const Color(0xFF95A5A6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Icon(
                                isMuted ? Icons.mic_off : Icons.mic,
                                size: 24,
                              ),
                            ),
                          ),
                          // Bouton raccrocher
                          SizedBox(
                            width: 100,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: endCall,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE74C3C),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Icon(Icons.call_end, size: 28),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}