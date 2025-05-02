import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_page.dart';
import 'screens/home_screen.dart';
import 'screens/parametres_screen.dart';
import 'screens/certificates_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/studies_screen.dart';
import 'screens/lessons_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/data_initialization_screen.dart';
import 'screens/camera_translation_screen.dart';
import 'screens/podcast_screen.dart';
import 'screens/games_screen.dart';
import 'screens/games/quiz_game.dart';
import 'screens/games/word_search_game.dart';
import 'screens/games/fill_blanks_game.dart';
import 'screens/games/word_race_game.dart';
import 'screens/games/crosswords_game.dart';
import 'screens/games/verb_battle_game.dart';
import 'screens/games/image_word_game.dart';
import 'screens/games/memory_game.dart';
import 'screens/games/cooking_vocab_game.dart';
import 'screens/games/interactive_story_game.dart';
import 'screens/games/virtual_dialogue_game.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Erreur d\'initialisation Firebase: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final themeService = ThemeService(prefs);

  // Configuration de l'orientation et du style système
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Forcer l'orientation portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider.value(
      value: themeService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'EchoLang',
      debugShowCheckedModeBanner: false,
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
      themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
            padding: EdgeInsets.zero,
          ),
          child: child!,
        );
      },
      home: const AuthPage(),
      routes: {
        '/auth': (context) => const AuthPage(),
        '/home': (context) => const HomeScreen(firstName: '', lastName: ''),
        '/parametres': (context) => const ParametresScreen(),
        '/certificates': (context) => const CertificatesScreen(),
        '/languages': (context) => const LanguageSelectionScreen(),
        '/data-init': (context) => const DataInitializationScreen(),
        '/podcast': (context) => const PodcastScreen(),
        '/camera-translation': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return CameraTranslationScreen(
            targetLanguage: args['targetLanguage'] as String,
          );
        },
        '/games': (context) => const GamesScreen(),
        '/quiz_game': (context) => const QuizGameScreen(),
        '/games/word-search': (context) => const WordSearchGame(),
        '/games/fill-blanks': (context) => const FillBlanksGame(),
        '/games/word-race': (context) => const WordRaceGame(),
        '/games/crosswords': (context) => const CrosswordsGame(),
        '/games/verb-battle': (context) => const VerbBattleGame(),
        '/games/image-word': (context) => const ImageWordGame(),
        '/games/memory': (context) => const MemoryGame(),
        '/games/cooking-vocab': (context) => const CookingVocabGame(),
        '/games/interactive-story': (context) => const InteractiveStoryGame(),
        '/games/virtual-dialogue': (context) => const VirtualDialogueGame(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/studies') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => StudiesScreen(
              languageId: args['languageId'] as String,
            ),
          );
        }
        if (settings.name == '/lessons') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => LessonsScreen(
              theme: args['theme'] as String,
              lessons: (args['lessons'] as List)
                  .map((lesson) => Map<String, dynamic>.from(lesson as Map))
                  .toList(),
              languageId: args['languageId'] as String,
            ),
          );
        }
        if (settings.name == '/lesson') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => LessonScreen(
              lesson: args['lesson'] as Map<String, dynamic>,
              languageId: args['languageId'] as String,
            ),
          );
        }
        return null;
      },
    );
  }
}
