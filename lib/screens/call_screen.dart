import 'package:flutter/material.dart';
import 'dart:async';

class CallScreen extends StatefulWidget {
  final bool isEmergency;
  
  const CallScreen({super.key, required this.isEmergency});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  bool isConnecting = false;
  bool isConnected = false;
  bool isSpeaking = false;
  Timer? connectionTimer;
  int connectionDuration = 0;
  
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation de pulsation pour les boutons
    pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    connectionTimer?.cancel();
    pulseController.dispose();
    super.dispose();
  }

  void startCall() {
    setState(() {
      isConnecting = true;
    });
    
    pulseController.repeat(reverse: true);
    
    // Simuler la connexion
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isConnecting = false;
          isConnected = true;
          connectionDuration = 0;
        });
        
        pulseController.stop();
        pulseController.reset();
        
        // Démarrer le timer de durée d'appel
        connectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              connectionDuration++;
            });
          }
        });
      }
    });
  }

  void endCall() {
    setState(() {
      isConnecting = false;
      isConnected = false;
      isSpeaking = false;
    });
    connectionTimer?.cancel();
    pulseController.stop();
    Navigator.pop(context);
  }

  void toggleSpeaking() {
    setState(() {
      isSpeaking = !isSpeaking;
    });
  }

  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = widget.isEmergency 
        ? const Color(0xFFE74C3C) 
        : const Color(0xFF9B59B6);
    
    String title = widget.isEmergency ? 'Appel d\'Urgence' : 'Appeler un Proche';
    String subtitle = widget.isEmergency 
        ? 'Communication directe avec l\'équipe soignante'
        : 'Appel téléphonique vers votre contact';

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF34495E),
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Statut de la connexion
            if (isConnecting) ...[
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: pulseAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.3),
                        border: Border.all(color: primaryColor, width: 4),
                      ),
                      child: Icon(
                        widget.isEmergency ? Icons.mic : Icons.phone,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Connexion en cours...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ] else if (isConnected) ...[
              // Interface d'appel connecté
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isEmergency ? Icons.mic : Icons.phone,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Connecté',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      formatDuration(connectionDuration),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Contrôles d'appel
              if (widget.isEmergency) ...[
                // Bouton Push-to-Talk pour mode talkie-walkie
                GestureDetector(
                  onTapDown: (_) => toggleSpeaking(),
                  onTapUp: (_) => toggleSpeaking(),
                  onTapCancel: () => setState(() => isSpeaking = false),
                  child: Container(
                    width: 200,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isSpeaking 
                          ? const Color(0xFF27AE60) 
                          : const Color(0xFF95A5A6),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isSpeaking 
                              ? const Color(0xFF27AE60) 
                              : const Color(0xFF95A5A6)).withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSpeaking ? Icons.mic : Icons.mic_off,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSpeaking ? 'PARLEZ' : 'APPUYEZ POUR PARLER',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Maintenez appuyé pour parler',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Bouton raccrocher
              SizedBox(
                width: 200,
                height: 70,
                child: ElevatedButton(
                  onPressed: endCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call_end, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Raccrocher',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Interface avant appel
              Column(
                children: [
                  Icon(
                    widget.isEmergency ? Icons.mic : Icons.phone,
                    size: 120,
                    color: primaryColor,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Instructions spécifiques
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (widget.isEmergency) ...[
                          const Icon(
                            Icons.info_outline,
                            size: 32,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Mode Talkie-Walkie',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Communication directe avec l\'équipe soignante.\nUne fois connecté, maintenez le bouton pour parler.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ] else ...[
                          const Icon(
                            Icons.contact_phone,
                            size: 32,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Appel Téléphonique',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Appel classique vers votre contact d\'urgence.\nVous pourrez parler normalement une fois connecté.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Bouton d'appel
                  SizedBox(
                    width: 250,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: startCall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.isEmergency ? Icons.mic : Icons.phone,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            widget.isEmergency ? 'Démarrer' : 'Appeler',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}