import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menyarproject/screens/quiz_screen.dart';
import '../models/course_model.dart';
import '../services/audio_service.dart';
import 'lesson_screen.dart';

class CourseScreen extends StatefulWidget {
  final String languageId;
  final String languageName;
  final String level;

  const CourseScreen({
    Key? key,
    required this.languageId,
    required this.languageName,
    required this.level,
  }) : super(key: key);

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AudioService _audioService = AudioService();
  bool _isLoading = true;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _audioService.initialize();
  }

  Future<void> _createTestCourse() async {
    try {
      print('Début de la création des cours de test');

      // Vérifier si le document de langue existe
      final languageDoc =
          await _firestore.collection('languages').doc(widget.languageId).get();

      if (!languageDoc.exists) {
        print('Le document de langue n\'existe pas. Création impossible.');
        _showErrorSnackBar('Erreur: La langue sélectionnée n\'existe pas');
        return;
      }

      print('Création du cours 1: Salutations');
      final course1 = await _firestore
          .collection('languages')
          .doc(widget.languageId)
          .collection('courses')
          .add({
        'title': 'Salutations et Présentations',
        'description': 'Apprenez à vous présenter et à saluer en français',
        'vocabulary': [
          'Bonjour',
          'Au revoir',
          'S\'il vous plaît',
          'Merci',
          'Je m\'appelle',
          'Enchanté(e)',
          'Comment allez-vous ?',
          'Très bien, merci'
        ],
        'audioUrl': 'assets/audio/lesson1.mp3',
        'level': widget.level,
        'order': 0,
        'isCompleted': false,
        'lessons': [
          {
            'title': 'Les salutations de base',
            'content':
                'Dans cette leçon, nous allons apprendre les salutations de base en français.',
            'audioUrl': 'assets/audio/lesson1_1.mp3',
            'translations': [],
            'isCompleted': false,
          },
          {
            'title': 'Se présenter',
            'content':
                'Apprenez à vous présenter et à demander le nom de quelqu\'un.',
            'audioUrl': 'assets/audio/lesson1_2.mp3',
            'translations': [],
            'isCompleted': false,
          }
        ],
        'translations': [
          {'originalText': 'Bonjour', 'translatedText': 'Hello'},
          {'originalText': 'Au revoir', 'translatedText': 'Goodbye'}
        ],
        'quizzes': [
          {
            'question': 'Comment dit-on "Hello" en français ?',
            'options': ['Bonjour', 'Au revoir', 'Merci', 'S\'il vous plaît'],
            'correctAnswer': 'Bonjour'
          },
          {
            'question': 'Quelle est la traduction de "Thank you" ?',
            'options': ['S\'il vous plaît', 'Merci', 'Au revoir', 'Bonjour'],
            'correctAnswer': 'Merci'
          },
          {
            'question': 'Comment dit-on "Goodbye" en français ?',
            'options': ['Bonjour', 'Merci', 'Au revoir', 'S\'il vous plaît'],
            'correctAnswer': 'Au revoir'
          },
          {
            'question': 'Quelle est la traduction de "Please" ?',
            'options': ['Merci', 'Bonjour', 'Au revoir', 'S\'il vous plaît'],
            'correctAnswer': 'S\'il vous plaît'
          },
          {
            'question': 'Comment demande-t-on "How are you?" en français ?',
            'options': [
              'Au revoir',
              'Bonjour',
              'Comment allez-vous ?',
              'Merci'
            ],
            'correctAnswer': 'Comment allez-vous ?'
          }
        ],
      });
      print('Cours 1 créé avec ID: ${course1.id}');

      // Attendre un peu entre chaque création pour éviter les conflits
      await Future.delayed(const Duration(milliseconds: 500));

      print('Création du cours 2: Les Nombres');
      final course2 = await _firestore
          .collection('languages')
          .doc(widget.languageId)
          .collection('courses')
          .add({
        'title': 'Les Nombres',
        'description': 'Apprenez à compter en français',
        'vocabulary': [
          'Un',
          'Deux',
          'Trois',
          'Quatre',
          'Cinq',
          'Six',
          'Sept',
          'Huit',
          'Neuf',
          'Dix'
        ],
        'audioUrl': 'assets/audio/lesson2.mp3',
        'level': widget.level,
        'order': 1,
        'isCompleted': false,
        'lessons': [
          {
            'title': 'Les nombres de 1 à 5',
            'content': 'Apprenez à compter de un à cinq en français.',
            'audioUrl': 'assets/audio/lesson2_1.mp3',
            'translations': [],
            'isCompleted': false,
          },
          {
            'title': 'Les nombres de 6 à 10',
            'content': 'Apprenez à compter de six à dix en français.',
            'audioUrl': 'assets/audio/lesson2_2.mp3',
            'translations': [],
            'isCompleted': false,
          }
        ],
        'translations': [
          {'originalText': 'Un', 'translatedText': 'One'},
          {'originalText': 'Deux', 'translatedText': 'Two'}
        ],
        'quizzes': [
          {
            'question': 'Comment dit-on "Five" en français ?',
            'options': ['Trois', 'Quatre', 'Cinq', 'Six'],
            'correctAnswer': 'Cinq'
          },
          {
            'question': 'Quel est le nombre "Three" en français ?',
            'options': ['Un', 'Deux', 'Trois', 'Quatre'],
            'correctAnswer': 'Trois'
          },
          {
            'question': 'Comment dit-on "Seven" en français ?',
            'options': ['Cinq', 'Six', 'Sept', 'Huit'],
            'correctAnswer': 'Sept'
          },
          {
            'question': 'Quel est le nombre "Ten" en français ?',
            'options': ['Sept', 'Huit', 'Neuf', 'Dix'],
            'correctAnswer': 'Dix'
          },
          {
            'question': 'Comment dit-on "One" en français ?',
            'options': ['Un', 'Deux', 'Trois', 'Quatre'],
            'correctAnswer': 'Un'
          }
        ],
      });
      print('Cours 2 créé avec ID: ${course2.id}');

      print('Création terminée, rechargement des cours');
      await _loadCourses();
    } catch (e, stackTrace) {
      print('Erreur lors de la création des cours: $e');
      print('Stack trace: $stackTrace');
      _showErrorSnackBar('Erreur lors de la création des cours: $e');
    }
  }

  Future<void> _loadCourses() async {
    print('Début du chargement des cours');
    setState(() => _isLoading = true);

    try {
      print(
          'Tentative de récupération des cours pour la langue: ${widget.languageId}, niveau: ${widget.level}');

      // Récupérer d'abord tous les cours pour ce langage
      final QuerySnapshot coursesSnapshot = await _firestore
          .collection('languages')
          .doc(widget.languageId)
          .collection('courses')
          .get();

      print('Nombre de cours trouvés: ${coursesSnapshot.docs.length}');

      // Filtrer et trier les cours en mémoire
      final filteredDocs = coursesSnapshot.docs
          .where((doc) =>
              (doc.data() as Map<String, dynamic>)['level'] == widget.level)
          .toList()
        ..sort((a, b) => ((a.data() as Map<String, dynamic>)['order'] ?? 0)
            .compareTo((b.data() as Map<String, dynamic>)['order'] ?? 0));

      setState(() {
        _courses = filteredDocs.map((doc) {
          print('Traitement du cours ID: ${doc.id}');
          final data = doc.data() as Map<String, dynamic>;
          return Course(
            id: doc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            audioUrl: data['audioUrl'] ?? '',
            vocabulary: List<String>.from(data['vocabulary'] ?? []),
            lessons: (data['lessons'] as List<dynamic>?)
                    ?.map(
                        (lesson) => Lesson.fromMap(lesson, lesson['id'] ?? ''))
                    .toList() ??
                [],
            quizzes: (data['quizzes'] as List<dynamic>?)
                    ?.map((quiz) => Quiz.fromMap(quiz))
                    .toList() ??
                [],
            translations: (data['translations'] as List<dynamic>?)
                    ?.map((t) => Translation.fromMap(t))
                    .toList() ??
                [],
            isCompleted: data['isCompleted'] ?? false,
            order: data['order'] ?? 0,
          );
        }).toList();
        _isLoading = false;
      });

      if (_courses.isEmpty) {
        print('Aucun cours trouvé, création des cours de test');
        await _createTestCourse();
      } else {
        print('Cours chargés avec succès: ${_courses.length} cours');
      }
    } catch (e, stackTrace) {
      print('Erreur lors du chargement des cours: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors du chargement des cours: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startQuiz(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          quizzes: course.quizzes,
          onComplete: () => _markCourseAsCompleted(course),
        ),
      ),
    );
  }

  Future<void> _markCourseAsCompleted(Course course) async {
    try {
      await _firestore
          .collection('languages')
          .doc(widget.languageId)
          .collection('courses')
          .doc(course.id)
          .update({'isCompleted': true});

      setState(() {
        final index = _courses.indexWhere((c) => c.id == course.id);
        if (index != -1) {
          _courses[index] = Course(
            id: course.id,
            title: course.title,
            description: course.description,
            audioUrl: course.audioUrl,
            vocabulary: course.vocabulary,
            lessons: course.lessons,
            quizzes: course.quizzes,
            translations: course.translations,
            isCompleted: true,
            order: course.order,
          );
        }
      });
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la mise à jour du cours: $e');
    }
  }

  Widget _buildVocabularyCard(String word, String audioUrl) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          word,
          style: const TextStyle(fontSize: 18),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () => _audioService.playAudio(audioUrl),
        ),
      ),
    );
  }

  void _showAddQuizDialog(Course course) {
    final questionController = TextEditingController();
    final correctAnswerController = TextEditingController();
    final optionsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un quiz'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  prefixIcon: Icon(Icons.help),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: optionsController,
                decoration: const InputDecoration(
                  labelText: 'Options (séparées par des virgules)',
                  prefixIcon: Icon(Icons.list),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: correctAnswerController,
                decoration: const InputDecoration(
                  labelText: 'Réponse correcte',
                  prefixIcon: Icon(Icons.check_circle),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (questionController.text.isEmpty ||
                  correctAnswerController.text.isEmpty ||
                  optionsController.text.isEmpty) {
                _showErrorSnackBar('Tous les champs sont obligatoires');
                return;
              }

              try {
                final options = optionsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                if (!options.contains(correctAnswerController.text.trim())) {
                  _showErrorSnackBar(
                      'La réponse correcte doit être dans les options');
                  return;
                }

                final quiz = Quiz(
                  question: questionController.text,
                  options: options,
                  correctAnswer: correctAnswerController.text.trim(),
                );

                final updatedQuizzes = [...course.quizzes, quiz];

                await _firestore
                    .collection('languages')
                    .doc(widget.languageId)
                    .collection('courses')
                    .doc(course.id)
                    .update({
                  'quizzes': updatedQuizzes.map((q) => q.toMap()).toList(),
                });

                if (!mounted) return;
                Navigator.pop(context);
                _loadCourses();
              } catch (e) {
                _showErrorSnackBar('Erreur lors de l\'ajout du quiz: $e');
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showAddLessonDialog(Course course) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final audioUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une leçon'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de la leçon',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: audioUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Audio',
                  prefixIcon: Icon(Icons.audiotrack),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  contentController.text.isEmpty) {
                _showErrorSnackBar('Le titre et le contenu sont obligatoires');
                return;
              }

              try {
                final lessonRef = await _firestore
                    .collection('languages')
                    .doc(widget.languageId)
                    .collection('courses')
                    .doc(course.id)
                    .collection('lessons')
                    .add({
                  'title': titleController.text,
                  'content': contentController.text,
                  'audioUrl': audioUrlController.text,
                  'translations': [],
                  'isCompleted': false,
                });

                if (!mounted) return;
                Navigator.pop(context);
                _loadCourses();
              } catch (e) {
                _showErrorSnackBar('Erreur lors de l\'ajout de la leçon: $e');
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showAddTranslationDialog(Course course) {
    final originalTextController = TextEditingController();
    final translatedTextController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une traduction'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: originalTextController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Texte original',
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: translatedTextController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Traduction',
                  prefixIcon: Icon(Icons.translate),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (originalTextController.text.isEmpty ||
                  translatedTextController.text.isEmpty) {
                _showErrorSnackBar(
                    'Le texte original et la traduction sont obligatoires');
                return;
              }

              try {
                final updatedTranslations = [
                  ...course.translations,
                  Translation(
                    originalText: originalTextController.text,
                    translatedText: translatedTextController.text,
                  ),
                ];

                await _firestore
                    .collection('languages')
                    .doc(widget.languageId)
                    .collection('courses')
                    .doc(course.id)
                    .update({
                  'translations':
                      updatedTranslations.map((t) => t.toMap()).toList(),
                });

                if (!mounted) return;
                Navigator.pop(context);
                _loadCourses();
              } catch (e) {
                _showErrorSnackBar(
                    'Erreur lors de l\'ajout de la traduction: $e');
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsList(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Leçons',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 12),
        ...course.lessons.map((lesson) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBE9E7E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    lesson.isCompleted ? Icons.check_circle : Icons.play_circle,
                    color: const Color(0xFFBE9E7E),
                  ),
                ),
                title: Text(
                  lesson.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFBE9E7E),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonScreen(
                        languageId: widget.languageId,
                        courseId: course.id,
                        lesson: lesson,
                      ),
                    ),
                  );
                },
              ),
            )),
      ],
    );
  }

  Widget _buildTranslationsList(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Traductions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 12),
        ...course.translations.map((translation) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translation.originalText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    const Divider(height: 24),
                    Text(
                      translation.translatedText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFBE9E7E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.languageName} - ${widget.level}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFBE9E7E),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE8E1D9),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE9E7E)),
                ),
              )
            : _courses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: Color(0xFFBE9E7E),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun cours disponible',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadCourses,
                          child: const Text('Actualiser'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ExpansionTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFBE9E7E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              course.isCompleted
                                  ? Icons.check_circle
                                  : Icons.school,
                              color: const Color(0xFFBE9E7E),
                            ),
                          ),
                          title: Text(
                            course.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                          subtitle: Text(
                            course.description,
                            style: const TextStyle(
                              color: Color(0xFF666666),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Vocabulaire',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...course.vocabulary
                                      .map((word) => _buildVocabularyCard(
                                          word, course.audioUrl))
                                      .toList(),
                                  const SizedBox(height: 16),
                                  if (course.quizzes.isNotEmpty)
                                    ElevatedButton(
                                      onPressed: () => _startQuiz(course),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFBE9E7E),
                                        minimumSize:
                                            const Size(double.infinity, 48),
                                      ),
                                      child: const Text(
                                        'Commencer le Quiz',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: () =>
                                        _showAddLessonDialog(course),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize:
                                          const Size(double.infinity, 48),
                                      side: const BorderSide(
                                          color: Color(0xFFBE9E7E)),
                                    ),
                                    child: const Text(
                                      'Ajouter une Leçon',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFBE9E7E),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: () =>
                                        _showAddTranslationDialog(course),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize:
                                          const Size(double.infinity, 48),
                                      side: const BorderSide(
                                          color: Color(0xFFBE9E7E)),
                                    ),
                                    child: const Text(
                                      'Ajouter une Traduction',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFBE9E7E),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildLessonsList(course),
                                  const SizedBox(height: 24),
                                  _buildTranslationsList(course),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCourseDialog(),
        backgroundColor: const Color(0xFFBE9E7E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddCourseDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final vocabularyController = TextEditingController();
    final audioUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un cours'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du cours',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: vocabularyController,
                decoration: const InputDecoration(
                  labelText: 'Vocabulaire (séparé par des virgules)',
                  prefixIcon: Icon(Icons.list),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: audioUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Audio',
                  prefixIcon: Icon(Icons.audiotrack),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                _showErrorSnackBar('Le titre est obligatoire');
                return;
              }

              try {
                final vocabulary = vocabularyController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                final courseRef = await _firestore
                    .collection('languages')
                    .doc(widget.languageId)
                    .collection('courses')
                    .add({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'vocabulary': vocabulary,
                  'audioUrl': audioUrlController.text,
                  'level': widget.level,
                  'order': _courses.length,
                  'isCompleted': false,
                  'lessons': [],
                  'translations': [],
                  'quizzes': [],
                });

                if (!mounted) return;
                Navigator.pop(context);
                _loadCourses();
              } catch (e) {
                _showErrorSnackBar('Erreur lors de l\'ajout du cours: $e');
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
