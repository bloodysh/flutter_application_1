import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/analytics_service.dart';
import 'lecture_screen.dart';
import 'concentration_screen.dart';
import 'call_screen.dart';
import 'caregiver_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _analyticsService.trackScreenVisit('home_screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header with title and settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lyséa',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      _analyticsService.trackButtonPress('settings_button');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Feature buttons grid - 2x2 layout
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0,
                  children: [
                    _buildFeatureButton(
                      context: context,
                      icon: Icons.book,
                      title: 'Lecture',
                      color: const Color(0xFF3498DB),
                      onPressed: () {
                        _analyticsService.trackButtonPress('lecture_button');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LectureScreen()),
                        );
                      },
                    ),
                    _buildFeatureButton(
                      context: context,
                      icon: Icons.psychology,
                      title: 'Concentration',
                      color: const Color(0xFF9B59B6),
                      onPressed: () {
                        _analyticsService.trackButtonPress('concentration_button');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConcentrationScreen()),
                        );
                      },
                    ),
                    _buildFeatureButton(
                      context: context,
                      icon: Icons.phone,
                      title: 'Appel',
                      color: const Color(0xFF2ECC71),
                      onPressed: () {
                        _analyticsService.trackButtonPress('call_button');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CallScreen(isEmergency: false)),
                        );
                      },
                    ),
                    _buildFeatureButton(
                      context: context,
                      icon: Icons.favorite,
                      title: 'Aidant',
                      color: const Color(0xFFE74C3C),
                      onPressed: () {
                        _analyticsService.trackButtonPress('caregiver_button');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CaregiverScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        padding: const EdgeInsets.all(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
