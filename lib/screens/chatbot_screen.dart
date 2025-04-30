import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
        "Bonjour ! Je suis EchoBot, votre assistant d'apprentissage des langues. Comment puis-je vous aider aujourd'hui ?");
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simuler une réponse du bot après un délai
    await Future.delayed(const Duration(seconds: 1));

    String botResponse = _getBotResponse(text.toLowerCase());

    setState(() {
      _messages.add(ChatMessage(
        text: botResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = false;
    });

    _scrollToBottom();
  }

  String _getBotResponse(String message) {
    // Réponses pour les salutations
    if (message.contains('bonjour') ||
        message.contains('salut') ||
        message.contains('hello')) {
      return "Bonjour ! Je suis ravi de vous aider dans votre apprentissage des langues. Que souhaitez-vous pratiquer aujourd'hui ?";
    }

    // Réponses pour les questions sur les langues disponibles
    if (message.contains('langue') &&
        (message.contains('disponible') || message.contains('proposé'))) {
      return "Nous proposons actuellement l'apprentissage du français, de l'anglais, de l'espagnol, de l'italien et de l'arabe. Quelle langue souhaitez-vous apprendre ?";
    }

    // Réponses pour les questions sur les niveaux
    if (message.contains('niveau')) {
      return "Nous adaptons le contenu à tous les niveaux, du débutant (A1) au niveau avancé (C2). Voulez-vous faire un test de niveau pour connaître votre niveau actuel ?";
    }

    // Réponses pour les exercices
    if (message.contains('exercice') || message.contains('pratique')) {
      return "Je peux vous proposer différents types d'exercices : vocabulaire, grammaire, prononciation, ou conversation. Quel aspect souhaitez-vous travailler ?";
    }

    // Réponses pour la prononciation
    if (message.contains('prononciation') || message.contains('prononcer')) {
      return "Pour améliorer votre prononciation, je vous suggère de commencer par des exercices d'écoute et de répétition. Voulez-vous essayer un exercice maintenant ?";
    }

    // Réponses pour le vocabulaire
    if (message.contains('vocabulaire') || message.contains('mot')) {
      return "Je peux vous aider à enrichir votre vocabulaire par thème (voyage, cuisine, business, etc.) ou par niveau. Quel domaine vous intéresse ?";
    }

    // Réponses pour la grammaire
    if (message.contains('grammaire') || message.contains('conjugaison')) {
      return "La grammaire est essentielle ! Je peux vous expliquer les règles et vous proposer des exercices pratiques. Sur quel point grammatical souhaitez-vous travailler ?";
    }

    // Réponses pour les questions d'aide
    if (message.contains('aide') || message.contains('help')) {
      return "Je peux vous aider avec :\n- Exercices de langue\n- Prononciation\n- Vocabulaire\n- Grammaire\n- Test de niveau\n- Conversation\nQue souhaitez-vous explorer ?";
    }

    // Réponses pour les remerciements
    if (message.contains('merci') || message.contains('thanks')) {
      return "Je vous en prie ! N'hésitez pas si vous avez d'autres questions. Je suis là pour vous aider à progresser !";
    }

    // Réponses pour les au revoir
    if (message.contains('au revoir') ||
        message.contains('bye') ||
        message.contains('à bientôt')) {
      return "Au revoir ! J'espère vous revoir bientôt pour continuer votre apprentissage. Bonne journée !";
    }

    // Réponse par défaut
    return "Je comprends votre intérêt. Pouvez-vous me donner plus de détails sur ce que vous souhaitez apprendre ou pratiquer ?";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EchoBot',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Assistant linguistique',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFBE9E7E),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // TODO: Afficher l'aide et les commandes disponibles
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
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
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessage(message);
                },
              ),
            ),
          ),
          if (_isTyping)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBE9E7E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'EchoBot est en train d\'écrire...',
                      style: TextStyle(
                        color: Color(0xFFBE9E7E),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {
                      // TODO: Implémenter la reconnaissance vocale
                    },
                    color: const Color(0xFFBE9E7E),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Écrivez votre message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_messageController.text),
                    color: const Color(0xFFBE9E7E),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundColor: const Color(0xFFBE9E7E),
                child: Icon(
                  Icons.android,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFFBE9E7E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (message.isUser)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: const Color(0xFFBE9E7E).withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  color: const Color(0xFFBE9E7E),
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
