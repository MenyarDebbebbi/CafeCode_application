class Quiz {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Quiz({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? '',
    );
  }
}

class Translation {
  final String originalText;
  final String translatedText;

  Translation({
    required this.originalText,
    required this.translatedText,
  });

  Map<String, dynamic> toMap() {
    return {
      'originalText': originalText,
      'translatedText': translatedText,
    };
  }

  factory Translation.fromMap(Map<String, dynamic> map) {
    return Translation(
      originalText: map['originalText'] ?? '',
      translatedText: map['translatedText'] ?? '',
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? '',
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String content;
  final String audioUrl;
  final List<Translation> translations;
  final List<Question> questions;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.audioUrl,
    required this.translations,
    required this.questions,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'audioUrl': audioUrl,
      'translations': translations.map((t) => t.toMap()).toList(),
      'questions': questions.map((q) => q.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map, String id) {
    return Lesson(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      translations: (map['translations'] as List<dynamic>?)
              ?.map((t) => Translation.fromMap(t))
              .toList() ??
          [],
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromMap(q))
              .toList() ??
          [],
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class Course {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final List<String> vocabulary;
  final List<Lesson> lessons;
  final List<Quiz> quizzes;
  final List<Translation> translations;
  final bool isCompleted;
  final int order;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.vocabulary,
    required this.lessons,
    required this.quizzes,
    required this.translations,
    this.isCompleted = false,
    required this.order,
  });

  factory Course.fromMap(Map<String, dynamic> map, String id) {
    return Course(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      vocabulary: List<String>.from(map['vocabulary'] ?? []),
      lessons: (map['lessons'] as List<dynamic>?)
              ?.map((lesson) => Lesson.fromMap(lesson, lesson['id'] ?? ''))
              .toList() ??
          [],
      quizzes: (map['quizzes'] as List<dynamic>?)
              ?.map((quiz) => Quiz.fromMap(quiz))
              .toList() ??
          [],
      translations: (map['translations'] as List<dynamic>?)
              ?.map((t) => Translation.fromMap(t))
              .toList() ??
          [],
      isCompleted: map['isCompleted'] ?? false,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'vocabulary': vocabulary,
      'lessons': lessons.map((lesson) => lesson.toMap()).toList(),
      'quizzes': quizzes.map((quiz) => quiz.toMap()).toList(),
      'translations': translations.map((t) => t.toMap()).toList(),
      'isCompleted': isCompleted,
      'order': order,
    };
  }
}
