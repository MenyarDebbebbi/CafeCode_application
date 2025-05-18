import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
import '../../styles/home_styles.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
        """Bonjour ! 👋 Je suis EchoBot, votre assistant personnel pour l'apprentissage des langues.

Je peux vous aider avec :
1. Trouver une leçon spécifique
2. Pratiquer la conversation
3. Réviser la grammaire
4. Enrichir votre vocabulaire
5. Préparer des examens

Que souhaitez-vous faire aujourd'hui ?""");
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    // Simuler un délai de réponse du bot
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _addBotMessage(_getBotResponse(text.toLowerCase()));
        });
      }
    });
  }

  void _addBotMessage(String message) {
    _messages.add(
      ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    // Faire défiler jusqu'au dernier message
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getBotResponse(String message) {
    // Réponses pour les leçons spécifiques
    if (message.contains('alphabet') && message.contains('fr')) {
      return """Je peux vous aider avec l'alphabet français ! 🇫🇷

Voici un aperçu de la leçon :
• Durée : 10 minutes
• XP à gagner : 50 points
• Niveau : Débutant (A1)

La leçon couvre :
- Les 26 lettres de l'alphabet
- La prononciation de chaque lettre
- Les accents spéciaux (é, è, ê, ë, etc.)
- Des exercices pratiques

Voulez-vous :
1. Commencer la leçon maintenant ? Tapez 'commencer'
2. Voir d'autres leçons de base ? Tapez 'autres leçons'
3. Faire un test de niveau ? Tapez 'test'""";
    }

    // Réponses pour les salutations
    if (message.contains('bonjour') ||
        message.contains('salut') ||
        message.contains('hello')) {
      return """Bonjour ! 👋 Je suis EchoBot, votre assistant personnel pour l'apprentissage des langues.

Je peux vous aider avec :
1. Trouver une leçon spécifique
2. Pratiquer la conversation
3. Réviser la grammaire
4. Enrichir votre vocabulaire
5. Préparer des examens

Que souhaitez-vous faire aujourd'hui ?""";
    }

    // Réponses pour les questions sur les langues disponibles
    if (message.contains('langue') &&
        (message.contains('disponible') || message.contains('proposé'))) {
      return """Nous proposons actuellement les langues suivantes :

🇫🇷 Français - Tous niveaux (A1 à C2)
🇬🇧 Anglais - Tous niveaux (A1 à C2)
🇪🇸 Espagnol - Tous niveaux (A1 à C2)
🇮🇹 Italien - Tous niveaux (A1 à C2)
🇩🇪 Allemand - Tous niveaux (A1 à C2)

Chaque langue propose :
• Des leçons structurées
• Des exercices pratiques
• Des quiz interactifs
• Des jeux éducatifs
• Des ressources audio

Quelle langue souhaitez-vous apprendre ?""";
    }

    // Réponse par défaut
    return """Je comprends que vous souhaitez apprendre. Pour mieux vous aider, pourriez-vous préciser :

1. La langue que vous voulez apprendre
2. Votre niveau actuel
3. Ce que vous souhaitez pratiquer (grammaire, vocabulaire, prononciation, etc.)
4. Le type d'exercice qui vous intéresse

Par exemple : 'Je veux apprendre l'alphabet en français' ou 'Je cherche des exercices de grammaire niveau B1'""";
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeService>().isDarkMode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HomeStyles.primaryColor,
        title: const Text(
          'Assistant EchoLang',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/parametres'),
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: HomeStyles.getBackgroundGradient(isDarkMode),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessage(message, isDarkMode);
                },
              ),
            ),
            if (_isTyping)
              Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'EchoBot est en train d\'écrire...',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            _buildInputArea(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: HomeStyles.primaryColor,
                child: const Icon(
                  Icons.assistant,
                  color: Colors.white,
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: message.isUser
                    ? HomeStyles.primaryColor
                    : (isDarkMode ? const Color(0xFF2C2C2C) : Colors.white),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser
                      ? Colors.white
                      : (isDarkMode ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
          if (message.isUser)
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: HomeStyles.secondaryColor,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Posez votre question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                contentPadding: const EdgeInsets.all(12.0),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: () => _handleSubmitted(_textController.text),
            backgroundColor: HomeStyles.primaryColor,
            elevation: 2.0,
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
