import 'package:flutter/material.dart';
import 'dart:async';

class ConcentrationScreen extends StatefulWidget {
  const ConcentrationScreen({super.key});

  @override
  State<ConcentrationScreen> createState() => _ConcentrationScreenState();
}

class _ConcentrationScreenState extends State<ConcentrationScreen>
    with TickerProviderStateMixin {
  bool isSessionActive = false;
  Timer? sessionTimer;
  int sessionDuration = 5; // en minutes
  int remainingTime = 0;
  String selectedAmbiance = 'ocean';
  double volume = 0.5;
  
  late AnimationController breathingController;
  late Animation<double> breathingAnimation;

  final Map<String, Map<String, dynamic>> ambiances = {
    'ocean': {
      'name': 'Océan',
      'icon': Icons.waves,
      'color': Color(0xFF3498DB),
      'description': 'Sons apaisants de vagues'
    },
    'forest': {
      'name': 'Forêt',
      'icon': Icons.forest,
      'color': Color(0xFF27AE60),
      'description': 'Bruissement des feuilles'
    },
    'rain': {
      'name': 'Pluie',
      'icon': Icons.grain,
      'color': Color(0xFF34495E),
      'description': 'Pluie douce sur les feuilles'
    },
    'birds': {
      'name': 'Oiseaux',
      'icon': Icons.music_note,
      'color': Color(0xFFE67E22),
      'description': 'Chants d\'oiseaux matinaux'
    },
  };

  @override
  void initState() {
    super.initState();
    remainingTime = sessionDuration * 60;
    
    // Animation de respiration
    breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: breathingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    sessionTimer?.cancel();
    breathingController.dispose();
    super.dispose();
  }

  void startSession() {
    setState(() {
      isSessionActive = true;
      remainingTime = sessionDuration * 60;
    });
    
    // Démarrer l'animation de respiration
    breathingController.repeat(reverse: true);
    
    // Démarrer le timer
    sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          stopSession();
        }
      });
    });
  }

  void stopSession() {
    setState(() {
      isSessionActive = false;
    });
    sessionTimer?.cancel();
    breathingController.stop();
    breathingController.reset();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentAmbiance = ambiances[selectedAmbiance]!;

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF34495E),
        foregroundColor: Colors.white,
        title: const Text(
          'Mode Concentration',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Boutons d'urgence
          IconButton(
            icon: const Icon(Icons.mic, size: 28),
            onPressed: () {
              // TODO: Appel urgence
            },
            tooltip: 'Appel urgence',
          ),
          IconButton(
            icon: const Icon(Icons.phone, size: 28),
            onPressed: () {
              // TODO: Appel téléphone
            },
            tooltip: 'Appeler proche',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Timer et contrôles de session
            if (isSessionActive) ...[
              // Animation de respiration pendant la session
              Expanded(
                flex: 2,
                child: Center(
                  child: AnimatedBuilder(
                    animation: breathingAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: breathingAnimation.value,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentAmbiance['color'].withOpacity(0.3),
                            border: Border.all(
                              color: currentAmbiance['color'],
                              width: 3,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                currentAmbiance['icon'],
                                size: 60,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                formatTime(remainingTime),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Instructions de respiration
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Respirez calmement',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Suivez le rythme du cercle\nInspirez quand il grandit, expirez quand il rétrécit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Bouton Arrêter
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  onPressed: stopSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Arrêter la session',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ] else ...[
              // Configuration de la session
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sélection de la durée
                      const Text(
                        'Durée de la session',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [5, 10, 15, 20].map((duration) {
                          return SizedBox(
                            width: 80,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  sessionDuration = duration;
                                  remainingTime = duration * 60;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sessionDuration == duration
                                    ? const Color(0xFF3498DB)
                                    : const Color(0xFF95A5A6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                '${duration}min',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 40),

                      // Sélection de l'ambiance sonore
                      const Text(
                        'Ambiance sonore',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ...ambiances.entries.map((entry) {
                        String key = entry.key;
                        Map<String, dynamic> ambiance = entry.value;
                        bool isSelected = selectedAmbiance == key;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedAmbiance = key;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? ambiance['color']
                                  : Colors.white.withOpacity(0.1),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 70),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(ambiance['icon'], size: 32),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        ambiance['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ambiance['description'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, size: 24),
                              ],
                            ),
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 30),

                      // Contrôle du volume
                      const Text(
                        'Volume',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.volume_down, color: Colors.white),
                          Expanded(
                            child: Slider(
                              value: volume,
                              onChanged: (value) {
                                setState(() {
                                  volume = value;
                                });
                              },
                              activeColor: currentAmbiance['color'],
                              inactiveColor: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          const Icon(Icons.volume_up, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton Commencer
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: startSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'Commencer la session',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}