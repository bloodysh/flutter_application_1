import 'package:flutter/material.dart';
import 'analytics_service.dart';

/// Service pour collecter le feedback des utilisateurs et soignants
/// dans le cadre des tests du Mois 4
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final AnalyticsService _analyticsService = AnalyticsService();

  /// Afficher une boîte de dialogue de feedback simple pour les utilisateurs
  Future<void> showUserFeedbackDialog(BuildContext context) async {
    int? rating;
    String comment = '';
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Votre avis nous intéresse',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Comment avez-vous trouvé cette activité ?',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    // Système de notation avec des visages
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        IconData icon;
                        Color color;
                        switch (index) {
                          case 0:
                            icon = Icons.sentiment_very_dissatisfied;
                            color = Colors.red;
                            break;
                          case 1:
                            icon = Icons.sentiment_dissatisfied;
                            color = Colors.orange;
                            break;
                          case 2:
                            icon = Icons.sentiment_neutral;
                            color = Colors.yellow;
                            break;
                          case 3:
                            icon = Icons.sentiment_satisfied;
                            color = Colors.lightGreen;
                            break;
                          case 4:
                            icon = Icons.sentiment_very_satisfied;
                            color = Colors.green;
                            break;
                          default:
                            icon = Icons.sentiment_neutral;
                            color = Colors.grey;
                        }
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                          child: Icon(
                            icon,
                            size: 48,
                            color: rating == index + 1 ? color : Colors.grey,
                          ),
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Zone de commentaire optionnelle
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Un commentaire ? (optionnel)',
                        border: OutlineInputBorder(),
                        hintStyle: TextStyle(fontSize: 16),
                      ),
                      maxLines: 3,
                      style: const TextStyle(fontSize: 16),
                      onChanged: (value) {
                        comment = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Passer',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: rating != null ? () {
                    _analyticsService.trackFeedback(
                      feedbackType: 'user',
                      rating: rating!,
                      comment: comment,
                    );
                    Navigator.of(context).pop();
                    _showThankYouMessage(context);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Envoyer',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Afficher une interface de feedback pour les soignants
  Future<void> showCaregiverFeedbackDialog(BuildContext context) async {
    int? rating;
    String comment = '';
    String selectedCategory = 'interface';
    
    final categories = {
      'interface': 'Interface utilisateur',
      'patient_response': 'Réaction du patient',
      'functionality': 'Fonctionnalités',
      'accessibility': 'Accessibilité',
      'overall': 'Évaluation globale',
    };
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Évaluation Soignant',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catégorie d\'évaluation:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      
                      // Sélection de catégorie
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: categories.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Évaluation (1-5):',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      
                      // Notation numérique pour les soignants
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                rating = index + 1;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: rating == index + 1 
                                    ? const Color(0xFF3498DB) 
                                    : Colors.grey[300],
                                border: Border.all(
                                  color: const Color(0xFF3498DB),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: rating == index + 1 
                                        ? Colors.white 
                                        : const Color(0xFF3498DB),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Commentaires détaillés
                      const Text(
                        'Observations:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Vos observations détaillées...',
                          border: OutlineInputBorder(),
                          hintStyle: TextStyle(fontSize: 14),
                        ),
                        maxLines: 4,
                        style: const TextStyle(fontSize: 14),
                        onChanged: (value) {
                          comment = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler', style: TextStyle(fontSize: 14)),
                ),
                ElevatedButton(
                  onPressed: rating != null ? () {
                    _analyticsService.trackFeedback(
                      feedbackType: 'caregiver',
                      rating: rating!,
                      comment: '$selectedCategory: $comment',
                    );
                    Navigator.of(context).pop();
                    _showThankYouMessage(context);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34495E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Soumettre', style: TextStyle(fontSize: 14)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Signaler un problème rencontré
  Future<void> reportIssue(BuildContext context, {
    required String issueType,
    String? screenName,
  }) async {
    String description = '';
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Signaler un problème',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Type de problème: $issueType',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Décrivez le problème rencontré...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                onChanged: (value) {
                  description = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (description.isNotEmpty) {
                  _analyticsService.trackUserIssue(
                    issueType: issueType,
                    description: description,
                    screenName: screenName,
                  );
                  Navigator.of(context).pop();
                  _showThankYouMessage(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Signaler'),
            ),
          ],
        );
      },
    );
  }

  /// Message de remerciement
  void _showThankYouMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Merci pour votre retour ! Il nous aide à améliorer l\'application.',
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: Color(0xFF27AE60),
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Collecte automatique de feedback après certaines actions
  Future<void> triggerAutomaticFeedback(BuildContext context, String activity) async {
    // Demander un feedback après certaines activités importantes
    switch (activity) {
      case 'concentration_session_completed':
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          await showUserFeedbackDialog(context);
        }
        break;
      case 'reading_session_completed':
        // Feedback moins fréquent pour la lecture
        if (DateTime.now().millisecond % 3 == 0) { // 1/3 des sessions
          await Future.delayed(const Duration(seconds: 1));
          if (context.mounted) {
            await showUserFeedbackDialog(context);
          }
        }
        break;
    }
  }
}