import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../models/language.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

/// Service de gestion des langues
class LanguageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final cloudinary = CloudinaryPublic('daav4neoy', 'ml_default', cache: false);

  /// Récupère la liste des langues disponibles
  Future<List<Map<String, dynamic>>> getLanguages() async {
    final snapshot = await _firestore.collection('languages').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Récupère les détails d'une langue
  Future<Map<String, dynamic>?> getLanguageDetails(String languageId) async {
    final doc = await _firestore.collection('languages').doc(languageId).get();
    return doc.data();
  }

  // Récupérer une langue spécifique
  Future<Language?> getLanguage(String languageId) async {
    final doc = await _firestore.collection('languages').doc(languageId).get();
    return doc.exists ? Language.fromFirestore(doc) : null;
  }

  // Uploader une image vers Cloudinary
  Future<String> uploadImage(File image, String languageCode) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          folder: 'language_flags',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      rethrow;
    }
  }

  // Initialiser les langues dans Firebase
  Future<void> initializeLanguages() async {
    try {
      print('Début de l\'initialisation des langues...');

      final languages = {
        'english': {
          'name': 'English',
          'code': 'en',
          'flag': 'assets/flags/gb.png',
          'description':
              'Learn English, the global language of business and communication.',
          'level': 'Beginner',
          'categories': {
            'basics': {
              'name': 'Basics',
              'description': 'Start with the fundamentals of English',
              'lessons': [
                {
                  'id': 'alphabet',
                  'title': 'The English Alphabet',
                  'duration': '10 minutes',
                  'xp': 50,
                  'contentUrl': 'assets/lessons/english/alphabet.json',
                  'completed': false,
                  'progress': 0.0
                },
                {
                  'id': 'greetings',
                  'title': 'English Greetings',
                  'duration': '15 minutes',
                  'xp': 60,
                  'contentUrl': 'assets/lessons/english/greetings.json',
                  'completed': false,
                  'progress': 0.0
                }
              ]
            },
            'numbers_and_colors': {
              'name': 'Numbers and Colors',
              'description': 'Learn essential numbers and colors',
              'lessons': [
                {
                  'id': 'numbers',
                  'title': 'Numbers in English',
                  'duration': '20 minutes',
                  'xp': 70,
                  'contentUrl': 'assets/lessons/english/numbers.json',
                  'completed': false,
                  'progress': 0.0
                },
                {
                  'id': 'colors',
                  'title': 'Colors in English',
                  'duration': '15 minutes',
                  'xp': 60,
                  'contentUrl': 'assets/lessons/english/colors.json',
                  'completed': false,
                  'progress': 0.0
                }
              ]
            }
          }
        },
        'french': {
          'name': 'Français',
          'code': 'fr',
          'flag': 'assets/flags/fr.png',
          'description':
              'Apprenez le français, la langue de la culture et de l\'art.',
          'level': 'Débutant',
          'categories': {
            'basics': {
              'name': 'Les bases',
              'description': 'Commencez par les bases du français',
              'lessons': [
                {
                  'id': 'alphabet',
                  'title': 'L\'alphabet français',
                  'duration': '10 minutes',
                  'xp': 50,
                  'contentUrl': 'assets/lessons/french/alphabet.json',
                  'completed': false,
                  'progress': 0.0
                },
                {
                  'id': 'greetings',
                  'title': 'Les salutations en français',
                  'duration': '15 minutes',
                  'xp': 60,
                  'contentUrl': 'assets/lessons/french/greetings.json',
                  'completed': false,
                  'progress': 0.0
                }
              ]
            },
            'numbers_and_colors': {
              'name': 'Nombres et Couleurs',
              'description': 'Apprenez les nombres et les couleurs essentiels',
              'lessons': [
                {
                  'id': 'numbers',
                  'title': 'Les nombres en français',
                  'duration': '20 minutes',
                  'xp': 70,
                  'contentUrl': 'assets/lessons/french/numbers.json',
                  'completed': false,
                  'progress': 0.0
                },
                {
                  'id': 'colors',
                  'title': 'Les couleurs en français',
                  'duration': '15 minutes',
                  'xp': 60,
                  'contentUrl': 'assets/lessons/french/colors.json',
                  'completed': false,
                  'progress': 0.0
                }
              ]
            }
          }
        },
        'german': {
          'name': 'Deutsch',
          'code': 'de',
          'flag': 'assets/flags/de.png',
          'description':
              'Lernen Sie Deutsch, die Sprache der Dichter und Denker.',
          'level': 'Anfänger',
          'categories': {
            'basics': {
              'name': 'Grundlagen',
              'description':
                  'Beginnen Sie mit den Grundlagen der deutschen Sprache',
              'lessons': [
                {
                  'id': 'alphabet',
                  'title': 'Das deutsche Alphabet',
                  'duration': '10 minutes',
                  'xp': 50,
                  'contentUrl': 'assets/lessons/german/alphabet.json',
                  'completed': false,
                  'progress': 0.0
                },
                {
                  'id': 'greetings',
                  'title': 'Deutsche Grüße',
                  'duration': '15 minutes',
                  'xp': 60,
                  'contentUrl': 'assets/lessons/german/greetings.json',
                  'completed': false,
                  'progress': 0.0
                }
              ]
            },
            'numbers_and_colors': {
              'name': 'Zahlen und Farben',
              'description': 'Lernen Sie die grundlegenden Zahlen und Farben',
              'lessons': [
                {
                  'id': 'numbers',
                  'title': 'Zahlen auf Deutsch',
                  'duration': '20 minutes',
                  'xp': 70,
                  'contentUrl': 'assets/lessons/german/numbers.json',
                  'completed': false,
                  'progress': 0.0
                },
                {
                  'id': 'colors',
                  'title': 'Farben auf Deutsch',
                  'duration': '15 minutes',
                  'xp': 60,
                  'contentUrl': 'assets/lessons/german/colors.json',
                  'completed': false,
                  'progress': 0.0
                }
              ]
            }
          }
        },
        'spanish': {
          'name': 'Español',
          'code': 'es',
          'flag': 'assets/flags/es.png',
          'description': 'Aprende español, la lengua de Cervantes.',
          'level': 'Principiante',
          'categories': {
            'basics': {
              'name': 'Fundamentos',
              'description': 'Comienza con los fundamentos del español',
              'lessons': [
                {
                  'id': 'alphabet',
                  'title': 'El alfabeto español',
                  'duration': '10 minutes',
                  'xp': 50,
                  'contentUrl': 'assets/lessons/spanish/alphabet.json',
                  'completed': false,
                  'progress': 0.0
                },
                {
                  'id': 'greetings',
                  'title': 'Saludos en español',
                  'duration': '15 minutes',
                  'xp': 60,
                  'contentUrl': 'assets/lessons/spanish/greetings.json',
                  'completed': false,
                  'progress': 0.0
                }
              ]
            },
            'numbers_and_colors': {
              'name': 'Números y Colores',
              'description': 'Aprende los números y colores básicos',
              'lessons': [
                {
                  'id': 'numbers',
                  'title': 'Números en español',
                  'duration': '20 minutes',
                  'xp': 70,
                  'contentUrl': 'assets/lessons/spanish/numbers.json',
                  'completed': false,
                  'progress': 0.0
                },
                {
                  'id': 'colors',
                  'title': 'Colores en español',
                  'duration': '15 minutes',
                  'xp': 60,
                  'contentUrl': 'assets/lessons/spanish/colors.json',
                  'completed': false,
                  'progress': 0.0
                }
              ]
            }
          }
        },
        'italian': {
          'name': 'Italiano',
          'code': 'it',
          'flag': 'assets/flags/it.png',
          'description':
              'Impara l\'italiano, la lingua dell\'arte e della cultura.',
          'level': 'Principiante',
          'categories': {
            'basics': {
              'name': 'Fondamenti',
              'description': 'Inizia con i fondamenti dell\'italiano',
              'lessons': [
                {
                  'id': 'alphabet',
                  'title': 'L\'alfabeto italiano',
                  'duration': '10 minutes',
                  'xp': 50,
                  'contentUrl': 'assets/lessons/italian/alphabet.json',
                  'completed': false,
                  'progress': 0.0
                },
                {
                  'id': 'greetings',
                  'title': 'Saluti in italiano',
                  'duration': '15 minutes',
                  'xp': 60,
                  'contentUrl': 'assets/lessons/italian/greetings.json',
                  'completed': false,
                  'progress': 0.0
                }
              ]
            },
            'numbers_and_colors': {
              'name': 'Numeri e Colori',
              'description': 'Impara i numeri e i colori di base',
              'lessons': [
                {
                  'id': 'numbers',
                  'title': 'Numeri in italiano',
                  'duration': '20 minutes',
                  'xp': 70,
                  'contentUrl': 'assets/lessons/italian/numbers.json',
                  'completed': false,
                  'progress': 0.0
                },
                {
                  'id': 'colors',
                  'title': 'Colori in italiano',
                  'duration': '15 minutes',
                  'xp': 60,
                  'contentUrl': 'assets/lessons/italian/colors.json',
                  'completed': false,
                  'progress': 0.0
                }
              ]
            }
          }
        }
      };

      // Vérifier si les langues existent déjà
      final existingLanguages = await _firestore.collection('languages').get();
      if (existingLanguages.docs.isNotEmpty) {
        print('Les langues sont déjà initialisées');
        return;
      }

      // Ajouter les langues à Firestore
      for (var entry in languages.entries) {
        print('Ajout de la langue: ${entry.key}');

        // Créer un document pour la langue
        final languageRef = _firestore.collection('languages').doc(entry.key);

        // Ajouter les informations de base de la langue
        await languageRef.set({
          'name': entry.value['name'],
          'code': entry.value['code'],
          'flag': entry.value['flag'],
          'description': entry.value['description'],
          'level': entry.value['level'],
        });

        // Ajouter les catégories et leurs leçons
        final categories = entry.value['categories'] as Map<String, dynamic>;
        for (var categoryEntry in categories.entries) {
          print(
              'Ajout de la catégorie: ${categoryEntry.key} pour ${entry.key}');

          final categoryRef =
              languageRef.collection('categories').doc(categoryEntry.key);
          final categoryData = categoryEntry.value as Map<String, dynamic>;

          await categoryRef.set({
            'name': categoryData['name'],
            'description': categoryData['description'],
            'lessons': categoryData['lessons'],
          });
        }
      }

      print('Initialisation des langues terminée avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation des langues: $e');
      rethrow;
    }
  }

  // Méthode pour récupérer le contenu d'une leçon
  Future<dynamic> getLessonContent(String contentUrl) async {
    try {
      print('Chargement du contenu de la leçon depuis: $contentUrl');

      final content = await rootBundle.loadString(contentUrl);
      final jsonContent = json.decode(content);

      print('Contenu chargé avec succès');
      return jsonContent;
    } catch (e) {
      print('Erreur lors du chargement du contenu: $e');
      return {
        "title": "Contenu temporairement indisponible",
        "content": [
          {
            "type": "text",
            "data":
                "Le contenu de cette leçon est en cours de chargement. Veuillez réessayer dans quelques instants."
          }
        ]
      };
    }
  }

  // Méthode pour récupérer une leçon spécifique avec son contenu
  Future<Map<String, dynamic>?> getLesson(
      String languageId, String categoryId, String lessonId) async {
    try {
      print('Récupération de la leçon: $lessonId pour la langue: $languageId');

      final categorySnapshot = await _firestore
          .collection('languages')
          .doc(languageId)
          .collection('categories')
          .doc(categoryId)
          .get();

      if (!categorySnapshot.exists) {
        print('Catégorie non trouvée: $categoryId');
        return null;
      }

      final categoryData = categorySnapshot.data()!;
      final lessons =
          List<Map<String, dynamic>>.from(categoryData['lessons'] ?? []);

      final lesson = lessons.firstWhere(
        (lesson) => lesson['id'] == lessonId,
        orElse: () => <String, dynamic>{},
      );

      if (lesson.isEmpty) {
        print('Leçon non trouvée: $lessonId');
        return null;
      }

      if (lesson['contentUrl'] != null) {
        try {
          final content = await getLessonContent(lesson['contentUrl']);
          lesson['content'] = content['content'];
          lesson['title'] = content['title'];
          if (content['quiz'] != null) {
            lesson['quiz'] = content['quiz'];
          }
          print('Contenu de la leçon chargé avec succès');
        } catch (e) {
          print('Erreur lors du chargement du contenu: $e');
          lesson['content'] = [
            {
              'type': 'text',
              'data':
                  'Erreur lors du chargement du contenu. Veuillez réessayer.'
            }
          ];
        }
      }

      return lesson;
    } catch (e) {
      print('Erreur lors de la récupération de la leçon: $e');
      return null;
    }
  }

  // Mettre à jour une langue
  Future<void> updateLanguage(
      String languageId, Map<String, dynamic> data) async {
    await _firestore.collection('languages').doc(languageId).update(data);
  }

  // Supprimer une langue
  Future<void> deleteLanguage(String languageId) async {
    await _firestore.collection('languages').doc(languageId).delete();
  }

  Future<List<Map<String, dynamic>>> getThemes(String languageId) async {
    final themesSnapshot = await _firestore
        .collection('languages')
        .doc(languageId)
        .collection('themes')
        .get();
    return themesSnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getSkills(String languageId) async {
    final snapshot = await _firestore
        .collection('languages')
        .doc(languageId)
        .collection('skills')
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // Méthodes pour les langues
  Stream<DocumentSnapshot> getLanguageStream(String languageId) {
    return _firestore.collection('languages').doc(languageId).snapshots();
  }

  // Méthodes pour les thèmes
  Stream<QuerySnapshot> getThemesStream(String languageId) {
    return _firestore
        .collection('languages')
        .doc(languageId)
        .collection('themes')
        .orderBy('order')
        .snapshots();
  }

  Future<void> updateThemeProgress(
      String languageId, String themeId, double progress) {
    return _firestore
        .collection('languages')
        .doc(languageId)
        .collection('themes')
        .doc(themeId)
        .update({'progress': progress});
  }

  // Méthodes pour les compétences
  Stream<QuerySnapshot> getSkillsStream(String languageId) {
    return _firestore
        .collection('languages')
        .doc(languageId)
        .collection('skills')
        .orderBy('order')
        .snapshots();
  }

  Future<void> updateSkillProgress(
      String languageId, String skillId, double progress) {
    return _firestore
        .collection('languages')
        .doc(languageId)
        .collection('skills')
        .doc(skillId)
        .update({'progress': progress});
  }

  // Méthode d'initialisation des données (à utiliser une seule fois)
  Future<void> initializeLanguageData(
      String languageId, Map<String, dynamic> languageData) async {
    final languageRef = _firestore.collection('languages').doc(languageId);

    // Créer ou mettre à jour la langue
    await languageRef.set(languageData);

    // Initialiser les thèmes par défaut
    final themesCollection = languageRef.collection('themes');
    final defaultThemes = [
      {
        'title': 'Bases',
        'description': 'Apprenez les fondamentaux',
        'iconCodePoint': 0xe88e, // school
        'order': 0,
        'progress': 0.0,
      },
      {
        'title': 'Vie quotidienne',
        'description': 'Conversations de tous les jours',
        'iconCodePoint': 0xe7fb, // people
        'order': 1,
        'progress': 0.0,
      },
      {
        'title': 'Culture',
        'description': 'Découvrez la culture',
        'iconCodePoint': 0xe55b, // museum
        'order': 2,
        'progress': 0.0,
      },
    ];

    for (final theme in defaultThemes) {
      await themesCollection.add(theme);
    }

    // Initialiser les compétences par défaut
    final skillsCollection = languageRef.collection('skills');
    final defaultSkills = [
      {
        'name': 'Écoute',
        'iconCodePoint': 0xe3a1, // headphones
        'order': 0,
        'progress': 0.0,
      },
      {
        'name': 'Lecture',
        'iconCodePoint': 0xe865, // book
        'order': 1,
        'progress': 0.0,
      },
      {
        'name': 'Écriture',
        'iconCodePoint': 0xe3c9, // edit
        'order': 2,
        'progress': 0.0,
      },
      {
        'name': 'Prononciation',
        'iconCodePoint': 0xe029, // mic
        'order': 3,
        'progress': 0.0,
      },
    ];

    for (final skill in defaultSkills) {
      await skillsCollection.add(skill);
    }
  }

  // Méthode pour récupérer les questions du quiz d'une leçon
  Future<List<Map<String, dynamic>>> getQuizQuestions(
      String languageId, String categoryId, String lessonId) async {
    try {
      print('Récupération des questions du quiz pour la leçon: $lessonId');

      // Récupérer la catégorie
      final categorySnapshot = await _firestore
          .collection('languages')
          .doc(languageId)
          .collection('categories')
          .where('name', isEqualTo: categoryId)
          .get();

      if (categorySnapshot.docs.isEmpty) {
        print('Catégorie non trouvée: $categoryId');
        return [];
      }

      final categoryDoc = categorySnapshot.docs.first;
      final lessons =
          List<Map<String, dynamic>>.from(categoryDoc.data()['lessons'] ?? []);

      // Trouver la leçon spécifique
      final lesson = lessons.firstWhere(
        (lesson) => lesson['id'] == lessonId,
        orElse: () => <String, dynamic>{},
      );

      if (lesson.isEmpty || !lesson.containsKey('quiz')) {
        print('Quiz non trouvé pour la leçon: $lessonId');
        return [];
      }

      final quiz = lesson['quiz'] as Map<String, dynamic>;
      if (!quiz.containsKey('questions')) {
        print('Pas de questions trouvées dans le quiz');
        return [];
      }

      final questions = List<Map<String, dynamic>>.from(quiz['questions']);
      print('Nombre de questions récupérées: ${questions.length}');

      return questions;
    } catch (e) {
      print('Erreur lors de la récupération des questions du quiz: $e');
      return [];
    }
  }

  // Méthode pour sauvegarder le score du quiz
  Future<void> saveQuizScore(
      String languageId, String categoryId, String lessonId, int score) async {
    try {
      final userDoc = _firestore.collection('users').doc('current_user');
      await userDoc.collection('quiz_scores').add({
        'languageId': languageId,
        'categoryId': categoryId,
        'lessonId': lessonId,
        'score': score,
        'timestamp': DateTime.now()
      });
    } catch (e) {
      print('Erreur lors de la sauvegarde du score: $e');
    }
  }

  // Méthode pour ajouter une leçon à une catégorie existante
  Future<bool> addLessonToCategory(
    String languageId,
    String categoryId,
    Map<String, dynamic> lessonData,
  ) async {
    try {
      // Récupérer la catégorie
      final categorySnapshot = await _firestore
          .collection('languages')
          .doc(languageId)
          .collection('categories')
          .where('name', isEqualTo: categoryId)
          .get();

      if (categorySnapshot.docs.isEmpty) {
        print('Catégorie non trouvée: $categoryId');
        return false;
      }

      final categoryDoc = categorySnapshot.docs.first;
      final currentLessons =
          List<Map<String, dynamic>>.from(categoryDoc.data()['lessons'] ?? []);

      // Vérifier si la leçon existe déjà
      final lessonExists =
          currentLessons.any((lesson) => lesson['id'] == lessonData['id']);

      if (lessonExists) {
        print('Une leçon avec cet ID existe déjà');
        return false;
      }

      // Ajouter la nouvelle leçon
      currentLessons.add(lessonData);

      // Mettre à jour la catégorie
      await categoryDoc.reference.update({'lessons': currentLessons});
      print('Leçon ajoutée avec succès');
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout de la leçon: $e');
      return false;
    }
  }

  // Méthode pour ajouter un quiz à une leçon
  Future<bool> addQuizToLesson(
    String languageId,
    String categoryId,
    String lessonId,
    Map<String, dynamic> quizData,
  ) async {
    try {
      print('Ajout d\'un quiz pour la leçon: $lessonId');

      final categoryRef = _firestore
          .collection('languages')
          .doc(languageId)
          .collection('categories')
          .doc(categoryId);

      final categoryDoc = await categoryRef.get();
      if (!categoryDoc.exists) {
        print('Catégorie non trouvée');
        return false;
      }

      final lessons =
          List<Map<String, dynamic>>.from(categoryDoc.data()?['lessons'] ?? []);
      final lessonIndex =
          lessons.indexWhere((lesson) => lesson['id'] == lessonId);

      if (lessonIndex == -1) {
        print('Leçon non trouvée');
        return false;
      }

      // Mettre à jour le quiz de la leçon
      lessons[lessonIndex]['quiz'] = quizData;

      // Mettre à jour la catégorie avec la leçon modifiée
      await categoryRef.update({'lessons': lessons});
      print('Quiz ajouté avec succès');
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout du quiz: $e');
      return false;
    }
  }

  // Méthode pour récupérer le quiz d'une leçon
  Future<Map<String, dynamic>?> getLessonQuiz(
    String languageId,
    String categoryId,
    String lessonId,
  ) async {
    try {
      print('Récupération du quiz pour la leçon: $lessonId');

      final categoryRef = _firestore
          .collection('languages')
          .doc(languageId)
          .collection('categories')
          .doc(categoryId);

      final categoryDoc = await categoryRef.get();
      if (!categoryDoc.exists) {
        print('Catégorie non trouvée');
        return null;
      }

      final lessons =
          List<Map<String, dynamic>>.from(categoryDoc.data()?['lessons'] ?? []);
      final lesson = lessons.firstWhere(
        (lesson) => lesson['id'] == lessonId,
        orElse: () => <String, dynamic>{},
      );

      if (lesson.isEmpty) {
        print('Leçon non trouvée');
        return null;
      }

      final quiz = lesson['quiz'] as Map<String, dynamic>?;
      if (quiz == null) {
        print('Quiz non trouvé pour cette leçon');
        return null;
      }

      return quiz;
    } catch (e) {
      print('Erreur lors de la récupération du quiz: $e');
      return null;
    }
  }

  // Méthode pour mettre à jour le score d'un quiz
  Future<bool> updateQuizScore(
    String userId,
    String languageId,
    String categoryId,
    String lessonId,
    int score,
    int totalQuestions,
  ) async {
    try {
      await _firestore.collection('quiz_scores').add({
        'userId': userId,
        'languageId': languageId,
        'categoryId': categoryId,
        'lessonId': lessonId,
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': (score / totalQuestions) * 100,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mettre à jour le progrès de la leçon si le score est bon
      if (score / totalQuestions >= 0.7) {
        // 70% de réussite
        final categoryRef = _firestore
            .collection('languages')
            .doc(languageId)
            .collection('categories')
            .doc(categoryId);

        final categoryDoc = await categoryRef.get();
        if (categoryDoc.exists) {
          final lessons = List<Map<String, dynamic>>.from(
              categoryDoc.data()?['lessons'] ?? []);
          final lessonIndex =
              lessons.indexWhere((lesson) => lesson['id'] == lessonId);

          if (lessonIndex != -1) {
            lessons[lessonIndex]['completed'] = true;
            lessons[lessonIndex]['progress'] = 1.0;
            await categoryRef.update({'lessons': lessons});
          }
        }
      }

      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du score du quiz: $e');
      return false;
    }
  }

  // Méthode pour récupérer l'historique des scores d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserQuizHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('quiz_scores')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique des quiz: $e');
      return [];
    }
  }
}
