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
  int currentTextIndex = 0;
  bool isReading = false;
  double fontSize = 24.0;

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
  
  // Extraits d'œuvres françaises classiques avec différents niveaux de difficulté
  final List<Map<String, dynamic>> literaryTexts = [
    {
      'title': 'Le Petit Prince - Antoine de Saint-Exupéry',
      'difficulty': 'Facile',
      'text': 'Lorsque j\'avais six ans j\'ai vu, une fois, une magnifique image, dans un livre sur la Forêt Vierge qui s\'appelait "Histoires Vécues". Ça représentait un serpent boa qui avalait un fauve.',
      'words': [
        {'word': 'Lorsque', 'syllables': ['Lors', 'que']},
        {'word': 'j\'avais', 'syllables': ['j\'a', 'vais']},
        {'word': 'six', 'syllables': ['six']},
        {'word': 'ans', 'syllables': ['ans']},
        {'word': 'j\'ai', 'syllables': ['j\'ai']},
        {'word': 'vu', 'syllables': ['vu']},
        {'word': 'une', 'syllables': ['u', 'ne']},
        {'word': 'fois', 'syllables': ['fois']},
        {'word': 'une', 'syllables': ['u', 'ne']},
        {'word': 'magnifique', 'syllables': ['ma', 'gni', 'fi', 'que']},
        {'word': 'image', 'syllables': ['i', 'ma', 'ge']},
        {'word': 'dans', 'syllables': ['dans']},
        {'word': 'un', 'syllables': ['un']},
        {'word': 'livre', 'syllables': ['li', 'vre']},
        {'word': 'sur', 'syllables': ['sur']},
        {'word': 'la', 'syllables': ['la']},
        {'word': 'Forêt', 'syllables': ['Fo', 'rêt']},
        {'word': 'Vierge', 'syllables': ['Vier', 'ge']}
      ],
      'sentences': [
        'Lorsque j\'avais six ans j\'ai vu, une fois, une magnifique image.',
        'C\'était dans un livre sur la Forêt Vierge qui s\'appelait "Histoires Vécues".',
        'Ça représentait un serpent boa qui avalait un fauve.'
      ]
    },
    {
      'title': 'Les Misérables - Victor Hugo',
      'difficulty': 'Moyen',
      'text': 'Il y a des heures dans la vie où l\'homme qui pense a besoin de solitude et de silence. Ces heures-là sont précieuses pour l\'âme.',
      'words': [
        {'word': 'Il', 'syllables': ['Il']},
        {'word': 'y', 'syllables': ['y']},
        {'word': 'a', 'syllables': ['a']},
        {'word': 'des', 'syllables': ['des']},
        {'word': 'heures', 'syllables': ['heu', 'res']},
        {'word': 'dans', 'syllables': ['dans']},
        {'word': 'la', 'syllables': ['la']},
        {'word': 'vie', 'syllables': ['vie']},
        {'word': 'où', 'syllables': ['où']},
        {'word': 'l\'homme', 'syllables': ['l\'hom', 'me']},
        {'word': 'qui', 'syllables': ['qui']},
        {'word': 'pense', 'syllables': ['pen', 'se']},
        {'word': 'a', 'syllables': ['a']},
        {'word': 'besoin', 'syllables': ['be', 'soin']},
        {'word': 'de', 'syllables': ['de']},
        {'word': 'solitude', 'syllables': ['so', 'li', 'tu', 'de']},
        {'word': 'et', 'syllables': ['et']},
        {'word': 'de', 'syllables': ['de']},
        {'word': 'silence', 'syllables': ['si', 'len', 'ce']}
      ],
      'sentences': [
        'Il y a des heures dans la vie où l\'homme qui pense a besoin de solitude.',
        'Ces moments demandent aussi le silence.',
        'Ces heures-là sont précieuses pour l\'âme.'
      ]
    },
    {
      'title': 'Candide - Voltaire',
      'difficulty': 'Facile',
      'text': 'Il y avait en Westphalie, dans le château de monsieur le baron, un jeune garçon à qui la nature avait donné les mœurs les plus douces.',
      'words': [
        {'word': 'Il', 'syllables': ['Il']},
        {'word': 'y', 'syllables': ['y']},
        {'word': 'avait', 'syllables': ['a', 'vait']},
        {'word': 'en', 'syllables': ['en']},
        {'word': 'Westphalie', 'syllables': ['West', 'pha', 'lie']},
        {'word': 'dans', 'syllables': ['dans']},
        {'word': 'le', 'syllables': ['le']},
        {'word': 'château', 'syllables': ['châ', 'teau']},
        {'word': 'de', 'syllables': ['de']},
        {'word': 'monsieur', 'syllables': ['mon', 'sieur']},
        {'word': 'le', 'syllables': ['le']},
        {'word': 'baron', 'syllables': ['ba', 'ron']},
        {'word': 'un', 'syllables': ['un']},
        {'word': 'jeune', 'syllables': ['jeu', 'ne']},
        {'word': 'garçon', 'syllables': ['gar', 'çon']}
      ],
      'sentences': [
        'Il y avait en Westphalie, dans le château de monsieur le baron.',
        'Là vivait un jeune garçon très doux.',
        'La nature lui avait donné les mœurs les plus douces.'
      ]
    },
    {
      'title': 'L\'Étranger - Albert Camus',
      'difficulty': 'Moyen',
      'text': 'Aujourd\'hui, maman est morte. Ou peut-être hier, je ne sais pas. J\'ai reçu un télégramme de l\'asile.',
      'words': [
        {'word': 'Aujourd\'hui', 'syllables': ['Au', 'jour', 'd\'hui']},
        {'word': 'maman', 'syllables': ['ma', 'man']},
        {'word': 'est', 'syllables': ['est']},
        {'word': 'morte', 'syllables': ['mor', 'te']},
        {'word': 'Ou', 'syllables': ['Ou']},
        {'word': 'peut-être', 'syllables': ['peut', 'ê', 'tre']},
        {'word': 'hier', 'syllables': ['hier']},
        {'word': 'je', 'syllables': ['je']},
        {'word': 'ne', 'syllables': ['ne']},
        {'word': 'sais', 'syllables': ['sais']},
        {'word': 'pas', 'syllables': ['pas']},
        {'word': 'J\'ai', 'syllables': ['J\'ai']},
        {'word': 'reçu', 'syllables': ['re', 'çu']},
        {'word': 'un', 'syllables': ['un']},
        {'word': 'télégramme', 'syllables': ['té', 'lé', 'gram', 'me']}
      ],
      'sentences': [
        'Aujourd\'hui, maman est morte.',
        'Ou peut-être hier, je ne sais pas.',
        'J\'ai reçu un télégramme de l\'asile.'
      ]
    },
    {
      'title': 'Le Bourgeois Gentilhomme - Molière',
      'difficulty': 'Facile',
      'text': 'Par ma foi ! il y a plus de quarante ans que je dis de la prose sans que j\'en susse rien.',
      'words': [
        {'word': 'Par', 'syllables': ['Par']},
        {'word': 'ma', 'syllables': ['ma']},
        {'word': 'foi', 'syllables': ['foi']},
        {'word': 'il', 'syllables': ['il']},
        {'word': 'y', 'syllables': ['y']},
        {'word': 'a', 'syllables': ['a']},
        {'word': 'plus', 'syllables': ['plus']},
        {'word': 'de', 'syllables': ['de']},
        {'word': 'quarante', 'syllables': ['qua', 'ran', 'te']},
        {'word': 'ans', 'syllables': ['ans']},
        {'word': 'que', 'syllables': ['que']},
        {'word': 'je', 'syllables': ['je']},
        {'word': 'dis', 'syllables': ['dis']},
        {'word': 'de', 'syllables': ['de']},
        {'word': 'la', 'syllables': ['la']},
        {'word': 'prose', 'syllables': ['pro', 'se']}
      ],
      'sentences': [
        'Par ma foi ! il y a plus de quarante ans.',
        'Depuis tout ce temps, je dis de la prose.',
        'Je ne le savais même pas !'
      ]
    }
  ];

  Map<String, dynamic> get currentText => literaryTexts[currentTextIndex];

  void nextText() {
    setState(() {
      if (currentTextIndex < literaryTexts.length - 1) {
        currentTextIndex++;
      } else {
        currentTextIndex = 0; // Retour au début
      }
    });
    _analyticsService.trackFeatureUsage('text_change', {'text_title': currentText['title']});
  }

  void previousText() {
    setState(() {
      if (currentTextIndex > 0) {
        currentTextIndex--;
      } else {
        currentTextIndex = literaryTexts.length - 1; // Aller au dernier
      }
    });
  }

  void readFullText() {
    final fullText = currentText['text'] as String;
    _ttsService.speak(fullText);
    _analyticsService.trackTTSUsage(fullText, true);

    // Déclencher feedback après lecture complète
    _feedbackService.triggerAutomaticFeedback(context, 'reading_session_completed');
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
                    'Texte ${currentTextIndex + 1} sur ${literaryTexts.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (currentTextIndex + 1) / literaryTexts.length,
                    backgroundColor: const Color(0xFFECF0F1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                    minHeight: 8,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Zone d'affichage du texte
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // En-tête avec titre et difficulté
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentText['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: currentText['difficulty'] == 'Facile'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: currentText['difficulty'] == 'Facile'
                                    ? Colors.green
                                    : Colors.orange,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Niveau: ${currentText['difficulty']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: currentText['difficulty'] == 'Facile'
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Zone de texte avec mode adaptatif
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE9ECEF)),
                          ),
                          child: SingleChildScrollView(
                            child: _buildFullTextDisplay(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Contrôles de lecture - version compacte
                      _buildReadingControls(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

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
          ],
        ),
      ),
    );
  }

  Widget _buildFullTextDisplay() {
    final fullText = currentText['text'] as String;
    return Text(
      fullText,
      style: TextStyle(
        fontSize: fontSize,
        height: 1.5,
        color: const Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildReadingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Bouton Précédent
        SizedBox(
          width: 120,
          height: 60,
          child: ElevatedButton(
            onPressed: currentTextIndex > 0 ? previousText : null,
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

        // Bouton Lire
        SizedBox(
          width: 120,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              readFullText();
            },
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
                Text('Lire', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),

        // Bouton Suivant
        SizedBox(
          width: 120,
          height: 60,
          child: ElevatedButton(
            onPressed: nextText,
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
    );
  }
}
