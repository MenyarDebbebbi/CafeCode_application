import 'package:flutter/foundation.dart';

class ChatResponse {
  final String question;
  final String answer;
  final String language;
  final List<String> keywords;

  ChatResponse({
    required this.question,
    required this.answer,
    required this.language,
    List<String>? keywords,
  }) : keywords = keywords ?? [question.toLowerCase()];
}

class ChatbotData {
  static final List<ChatResponse> responses = [
    // Salutations en Français
    ChatResponse(
      language: 'fr',
      question: 'Bonjour',
      answer:
          'Bonjour! Je suis votre assistant EchoLang. Comment puis-je vous aider aujourd\'hui?',
      keywords: ['bonjour', 'salut', 'hey', 'coucou', 'bonsoir'],
    ),
    ChatResponse(
      language: 'fr',
      question: 'Bonsoir',
      answer:
          'Bonsoir! Je suis là pour vous aider avec votre apprentissage des langues.',
    ),
    ChatResponse(
      language: 'fr',
      question: 'Au revoir',
      answer: 'Au revoir! Merci d\'avoir utilisé EchoLang. À bientôt!',
      keywords: ['au revoir', 'bye', 'à bientôt', 'adieu', 'à plus'],
    ),

    // Greetings in English
    ChatResponse(
      language: 'en',
      question: 'Hello',
      answer: 'Hello! I am your EchoLang assistant. How can I help you today?',
      keywords: ['hello', 'hi', 'hey', 'good morning', 'good evening'],
    ),
    ChatResponse(
      language: 'en',
      question: 'Good evening',
      answer:
          'Good evening! I\'m here to help you with your language learning.',
    ),
    ChatResponse(
      language: 'en',
      question: 'Goodbye',
      answer: 'Goodbye! Thank you for using EchoLang. See you soon!',
      keywords: ['goodbye', 'bye', 'see you', 'farewell'],
    ),

    // التحيات بالعربية
    ChatResponse(
      language: 'ar',
      question: 'السلام عليكم',
      answer:
          'وعليكم السلام! أنا مساعدك في إيكولانج. كيف يمكنني مساعدتك اليوم؟',
      keywords: ['سلام', 'مرحبا', 'صباح', 'مساء'],
    ),
    ChatResponse(
      language: 'ar',
      question: 'مساء الخير',
      answer: 'مساء النور! أنا هنا لمساعدتك في تعلم اللغات.',
    ),
    ChatResponse(
      language: 'ar',
      question: 'مع السلامة',
      answer: 'مع السلامة! شكراً لاستخدامك إيكولانج. إلى اللقاء!',
      keywords: ['سلامة', 'وداعا', 'الى اللقاء'],
    ),

    // Questions sur les langues disponibles - Français
    ChatResponse(
      language: 'fr',
      question: 'Quelles langues puis-je apprendre?',
      answer:
          'Nous proposons des cours en français, anglais et allemand. Chaque langue dispose de différents niveaux d\'apprentissage.',
      keywords: ['langues', 'apprendre', 'cours', 'disponible', 'proposé'],
    ),
    ChatResponse(
      language: 'fr',
      question: 'Comment commencer?',
      answer:
          'Vous pouvez commencer par choisir votre langue cible et passer un test de niveau. Ensuite, nous vous proposerons un parcours personnalisé.',
      keywords: ['commencer', 'débuter', 'début', 'démarrer', 'start'],
    ),

    // Language Questions - English
    ChatResponse(
      language: 'en',
      question: 'What languages can I learn?',
      answer:
          'We offer courses in French, English, and German. Each language has different learning levels.',
      keywords: ['languages', 'learn', 'available', 'offer', 'course'],
    ),
    ChatResponse(
      language: 'en',
      question: 'How do I start?',
      answer:
          'You can start by choosing your target language and taking a level test. Then, we will suggest a personalized learning path.',
      keywords: ['start', 'begin', 'how to', 'first step'],
    ),

    // أسئلة عن اللغات - العربية
    ChatResponse(
      language: 'ar',
      question: 'ما هي اللغات المتوفرة للتعلم؟',
      answer:
          'نقدم دورات في الفرنسية والإنجليزية والألمانية. كل لغة لديها مستويات تعلم مختلفة.',
      keywords: ['لغات', 'تعلم', 'دورات', 'متوفر'],
    ),
    ChatResponse(
      language: 'ar',
      question: 'كيف أبدأ؟',
      answer:
          'يمكنك البدء باختيار اللغة المستهدفة وإجراء اختبار المستوى. ثم سنقترح مساراً تعليمياً مخصصاً لك.',
      keywords: ['بدء', 'بداية', 'كيف', 'أول'],
    ),

    // Contact - Multilingue
    ChatResponse(
      language: 'fr',
      question: 'Comment vous contacter?',
      answer:
          'Vous pouvez nous contacter par email à menyardebbebi14@gmail.com ou par téléphone au 99957901.',
      keywords: ['contact', 'email', 'mail', 'téléphone', 'appeler', 'joindre'],
    ),
    ChatResponse(
      language: 'en',
      question: 'How can I contact you?',
      answer:
          'You can contact us by email at menyardebbebi14@gmail.com or by phone at 99957901.',
      keywords: ['contact', 'email', 'mail', 'phone', 'call', 'reach'],
    ),
    ChatResponse(
      language: 'ar',
      question: 'كيف يمكنني التواصل معكم؟',
      answer:
          'يمكنك التواصل معنا عبر البريد الإلكتروني menyardebbebi14@gmail.com أو عبر الهاتف 99957901.',
      keywords: ['اتصال', 'تواصل', 'بريد', 'هاتف'],
    ),

    // Catégories et Leçons - Français
    ChatResponse(
      language: 'fr',
      question: 'Quelles sont les catégories de cours?',
      answer:
          'Nous proposons plusieurs catégories: Grammaire, Vocabulaire, Prononciation, Conversation, Culture et Exercices pratiques.',
      keywords: ['catégories', 'cours', 'leçons', 'types', 'apprentissage'],
    ),
    ChatResponse(
      language: 'fr',
      question: 'Comment sont organisées les leçons?',
      answer:
          'Les leçons sont organisées par niveau (débutant, intermédiaire, avancé) et par thème. Chaque leçon comprend des exercices interactifs, des quiz et des contenus audio.',
      keywords: ['leçons', 'organisation', 'niveau', 'structure', 'cours'],
    ),

    // Categories and Lessons - English
    ChatResponse(
      language: 'en',
      question: 'What are the course categories?',
      answer:
          'We offer several categories: Grammar, Vocabulary, Pronunciation, Conversation, Culture, and Practical Exercises.',
      keywords: ['categories', 'courses', 'lessons', 'types', 'learning'],
    ),
    ChatResponse(
      language: 'en',
      question: 'How are the lessons organized?',
      answer:
          'Lessons are organized by level (beginner, intermediate, advanced) and by theme. Each lesson includes interactive exercises, quizzes, and audio content.',
      keywords: ['lessons', 'organization', 'level', 'structure', 'course'],
    ),

    // الفئات والدروس - العربية
    ChatResponse(
      language: 'ar',
      question: 'ما هي فئات الدورات؟',
      answer:
          'نقدم عدة فئات: القواعد، المفردات، النطق، المحادثة، الثقافة، والتمارين العملية.',
      keywords: ['فئات', 'دورات', 'دروس', 'أنواع', 'تعلم'],
    ),
    ChatResponse(
      language: 'ar',
      question: 'كيف يتم تنظيم الدروس؟',
      answer:
          'يتم تنظيم الدروس حسب المستوى (مبتدئ، متوسط، متقدم) وحسب الموضوع. يتضمن كل درس تمارين تفاعلية، اختبارات، ومحتوى صوتي.',
      keywords: ['دروس', 'تنظيم', 'مستوى', 'هيكل', 'دورة'],
    ),
  ];

  static ChatResponse findResponse(String question, String language) {
    question = question.toLowerCase().trim();

    // Recherche exacte
    for (var response in responses) {
      if (response.language == language &&
          (response.question.toLowerCase() == question ||
              response.keywords.contains(question))) {
        return response;
      }
    }

    // Recherche par mots-clés
    for (var response in responses) {
      if (response.language == language) {
        for (var keyword in response.keywords) {
          if (question.contains(keyword)) {
            return response;
          }
        }
      }
    }

    // Réponse par défaut si aucune correspondance n'est trouvée
    return ChatResponse(
      language: language,
      question: '',
      answer: language == 'fr'
          ? 'Je ne comprends pas votre question. Pouvez-vous la reformuler?'
          : language == 'en'
              ? 'I don\'t understand your question. Can you rephrase it?'
              : 'لم أفهم سؤالك. هل يمكنك إعادة صياغته؟',
    );
  }
}
