import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/preferences_service.dart';
import '../services/analytics_service.dart';
import '../services/feedback_service.dart';

class LectureScreen extends StatefulWidget {
  const LectureScreen({super.key});

  @override
  State<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  int currentWordIndex = 0;
  int currentSyllableIndex = 0;
  bool isReading = false;
  double fontSize = 36.0;
  
  // Services
  final TTSService _ttsService = TTSService();
  final PreferencesService _prefsService = PreferencesService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final FeedbackService _feedbackService = FeedbackService();
  
  @override
  void initState() {
    super.initState();
    _analyticsService.trackScreenVisit('lecture_screen');
    _loadPreferences();
  }
  
  // Exemple de texte avec syllabes marquées
  final List<Map<String, dynamic>> lessonContent = [
    {
      'word': 'Bon-jour',
      'syllables': ['Bon', 'jour'],
      'fullWord': 'Bonjour'
    },
    {
      'word': 'com-ment',
      'syllables': ['com', 'ment'],
      'fullWord': 'comment'
    },
    {
      'word': 'al-lez',
      'syllables': ['al', 'lez'],
      'fullWord': 'allez'
    },
    {
      'word': 'vous',
      'syllables': ['vous'],
      'fullWord': 'vous'
    },
  ];

  void nextWord() {
    setState(() {
      if (currentWordIndex < lessonContent.length - 1) {
        currentWordIndex++;
        currentSyllableIndex = 0;
      } else {
        // Session de lecture terminée
        _analyticsService.trackScreenVisit('lecture_completed');
        _feedbackService.triggerAutomaticFeedback(context, 'reading_session_completed');
      }
    });
  }

  void previousWord() {
    setState(() {
      if (currentWordIndex > 0) {
        currentWordIndex--;
        currentSyllableIndex = 0;
      }
    });
  }

  void nextSyllable() {
    setState(() {
      final currentWord = lessonContent[currentWordIndex];
      if (currentSyllableIndex < currentWord['syllables'].length - 1) {
        currentSyllableIndex++;
      } else {
        nextWord();
      }
    });
  }

  void repeatWord() {
    final String wordToRead = lessonContent[currentWordIndex]['fullWord'];
    _ttsService.speak(wordToRead);
    _analyticsService.trackTTSUsage(wordToRead, true);
  }
  
  // Chargement des préférences utilisateur
  Future<void> _loadPreferences() async {
    try {
      fontSize = await _prefsService.getFontSize();
      setState(() {});
    } catch (e) {
      print('Erreur chargement préférences: $e');
    }
  }
  
  // Sauvegarde des préférences utilisateur
  Future<void> _saveFontSize() async {
    try {
      await _prefsService.setFontSize(fontSize);
    } catch (e) {
      print('Erreur sauvegarde taille police: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = lessonContent[currentWordIndex];
    final syllables = currentWord['syllables'] as List<String>;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
        title: const Text(
          'Lecture Assistée',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Boutons d'urgence dans l'AppBar
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
            // Indicateur de progression
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Mot ${currentWordIndex + 1} sur ${lessonContent.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (currentWordIndex + 1) / lessonContent.length,
                    backgroundColor: const Color(0xFFECF0F1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                    minHeight: 8,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Zone d'affichage du mot
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Affichage des syllabes
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: syllables.asMap().entries.map((entry) {
                        int index = entry.key;
                        String syllable = entry.value;
                        bool isCurrentSyllable = index == currentSyllableIndex;
                        bool isReadSyllable = index < currentSyllableIndex;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isCurrentSyllable
                                ? const Color(0xFF3498DB)
                                : isReadSyllable
                                    ? const Color(0xFF27AE60)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            syllable,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: isCurrentSyllable || isReadSyllable
                                  ? Colors.white
                                  : const Color(0xFF2C3E50),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Mot complet en plus petit
                    Text(
                      currentWord['fullWord'],
                      style: TextStyle(
                        fontSize: fontSize * 0.6,
                        color: const Color(0xFF7F8C8D),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Contrôles de taille de police
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Taille du texte: ', style: TextStyle(fontSize: 16)),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (fontSize > 20) fontSize -= 4;
                      _saveFontSize();
                    });
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 32,
                ),
                Text(
                  '${fontSize.toInt()}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (fontSize < 60) fontSize += 4;
                      _saveFontSize();
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 32,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Boutons de contrôle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Bouton Précédent
                SizedBox(
                  width: 120,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: currentWordIndex > 0 ? previousWord : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF95A5A6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.skip_previous, size: 24),
                        Text('Précédent', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                // Bouton Répéter
                SizedBox(
                  width: 120,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: repeatWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volume_up, size: 24),
                        Text('Écouter', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                // Bouton Syllabe suivante
                SizedBox(
                  width: 120,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: nextSyllable,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.skip_next, size: 24),
                        Text('Suivant', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}