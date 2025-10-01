import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/analytics_service.dart';
import '../services/feedback_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefsService = PreferencesService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final FeedbackService _feedbackService = FeedbackService();

  // Paramètres utilisateur
  double _ambianceVolume = 0.5;
  String _selectedAmbiance = 'ocean';
  int _sessionDuration = 5;
  double _fontSize = 36.0;
  String _caregiverNumber = '';

  // Paramètres d'accessibilité
  bool _autoFeedback = true;

  @override
  void initState() {
    super.initState();
    _analyticsService.trackScreenVisit('settings_screen');
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final volume = await _prefsService.getAmbianceVolume();
      final ambiance = await _prefsService.getSelectedAmbiance();
      final duration = await _prefsService.getSessionDuration();
      final fontSize = await _prefsService.getFontSize();
      final number = await _prefsService.getCaregiverNumber();

      setState(() {
        _ambianceVolume = volume;
        _selectedAmbiance = ambiance;
        _sessionDuration = duration;
        _fontSize = fontSize;
        _caregiverNumber = number;
      });
    } catch (e) {
      print('Erreur chargement préférences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF34495E),
        foregroundColor: Colors.white,
        title: const Text(
          'Paramètres',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Audio
            _buildSectionHeader('Audio et Sons'),
            _buildSettingsCard([
              _buildSliderSetting(
                'Volume ambiance',
                _ambianceVolume,
                0.0,
                1.0,
                Icons.volume_up,
                (value) async {
                  setState(() => _ambianceVolume = value);
                  await _prefsService.setAmbianceVolume(value);
                },
              ),
              _buildDropdownSetting(
                'Ambiance préférée',
                _selectedAmbiance,
                {
                  'ocean': 'Océan',
                  'forest': 'Forêt',
                  'rain': 'Pluie',
                  'birds': 'Oiseaux',
                },
                Icons.audiotrack,
                (value) async {
                  if (value != null) {
                    setState(() => _selectedAmbiance = value);
                    await _prefsService.setSelectedAmbiance(value);
                  }
                },
              ),
            ]),

            const SizedBox(height: 20),

            // Section Session
            _buildSectionHeader('Sessions de Concentration'),
            _buildSettingsCard([
              _buildSliderSetting(
                'Durée par défaut',
                _sessionDuration.toDouble(),
                5.0,
                30.0,
                Icons.timer,
                (value) async {
                  setState(() => _sessionDuration = value.round());
                  await _prefsService.setSessionDuration(value.round());
                },
                suffix: 'min',
              ),
            ]),

            const SizedBox(height: 20),

            // Section Accessibilité
            _buildSectionHeader('Accessibilité'),
            _buildSettingsCard([
              _buildSliderSetting(
                'Taille du texte',
                _fontSize,
                20.0,
                60.0,
                Icons.text_fields,
                (value) async {
                  setState(() => _fontSize = value);
                  await _prefsService.setFontSize(value);
                },
                suffix: 'px',
              ),
            ]),

            const SizedBox(height: 20),

            // Section Contact
            _buildSectionHeader('Contact d\'Urgence'),
            _buildSettingsCard([
              _buildTextFieldSetting(
                'Numéro du soignant',
                _caregiverNumber,
                Icons.phone,
                (value) async {
                  setState(() => _caregiverNumber = value);
                  await _prefsService.setCaregiverNumber(value);
                },
                hint: '0123456789',
              ),
            ]),

            const SizedBox(height: 20),

            // Section Tests et Feedback
            _buildSectionHeader('Tests et Amélioration'),
            _buildSettingsCard([
              _buildSwitchSetting(
                'Demandes de feedback automatiques',
                _autoFeedback,
                Icons.feedback,
                (value) {
                  setState(() => _autoFeedback = value);
                },
              ),
              _buildActionButton(
                'Donner mon avis',
                Icons.rate_review,
                () => _feedbackService.showUserFeedbackDialog(context),
                const Color(0xFF3498DB),
              ),
              _buildActionButton(
                'Signaler un problème',
                Icons.report_problem,
                () => _feedbackService.reportIssue(
                  context,
                  issueType: 'general',
                  screenName: 'settings',
                ),
                const Color(0xFFE74C3C),
              ),
            ]),


            const SizedBox(height: 20),

            // Section Données
            _buildSectionHeader('Gestion des Données'),
            _buildSettingsCard([
              _buildActionButton(
                'Réinitialiser les préférences',
                Icons.restore,
                () => _showResetDialog(context, 'preferences'),
                const Color(0xFFE67E22),
              ),
              _buildActionButton(
                'Effacer les données d\'utilisation',
                Icons.delete_sweep,
                () => _showResetDialog(context, 'analytics'),
                const Color(0xFFE74C3C),
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Container(
            decoration: BoxDecoration(
              border: isLast ? null : Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
            child: entry.value,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    double value,
    double min,
    double max,
    IconData icon,
    Function(double) onChanged, {
    String? suffix,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3498DB)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / (max > 10 ? 5 : 0.1)).round(),
            onChanged: onChanged,
            activeColor: const Color(0xFF3498DB),
          ),
          Text(
            '${value.round()}${suffix ?? ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3498DB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(
    String title,
    String value,
    Map<String, String> options,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF27AE60)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: options.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF9B59B6)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF9B59B6),
    );
  }

  Widget _buildTextFieldSetting(
    String title,
    String value,
    IconData icon,
    Function(String) onChanged, {
    String? hint,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE67E22)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _showResetDialog(BuildContext context, String type) async {
    String title, content;
    if (type == 'preferences') {
      title = 'Réinitialiser les préférences';
      content = 'Toutes vos préférences seront remises aux valeurs par défaut.';
    } else {
      title = 'Effacer les données d\'utilisation';
      content = 'Toutes les données de suivi et rapports seront supprimées.';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (type == 'preferences') {
        await _prefsService.clearAllPreferences();
        await _loadPreferences();
      } else {
        await _analyticsService.clearAllData();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              type == 'preferences' 
                  ? 'Préférences réinitialisées'
                  : 'Données d\'utilisation effacées',
            ),
            backgroundColor: const Color(0xFF27AE60),
          ),
        );
      }
    }
  }
}

