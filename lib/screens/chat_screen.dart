import 'package:flutter/material.dart';
import '../data/chat_responses.dart';
import 'dart:math' show pi, sin;

class ChatMessage {
  final String text;
  final bool isUser;
  final String language;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.language,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String _selectedLanguage = 'fr'; // Langue par défaut
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Ajouter le message de bienvenue
    _addBotMessage(
      """Bonjour ! 👋 Je suis EchoBot, votre assistant personnel pour l'apprentissage des langues.

Je peux vous aider avec :
1. Trouver une leçon spécifique
2. Pratiquer la conversation
3. Réviser la grammaire
4. Enrichir votre vocabulaire
5. Préparer des examens

Que souhaitez-vous faire aujourd'hui ?""",
    );
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: false,
          language: _selectedLanguage,
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
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

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      // Ajouter le message de l'utilisateur
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          language: _selectedLanguage,
        ),
      );
      _isTyping = true;
    });

    // Simuler un délai de réponse du bot
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          // Obtenir et ajouter la réponse du chatbot
          final response = ChatbotData.findResponse(text, _selectedLanguage);
          _messages.add(
            ChatMessage(
              text: response.answer,
              isUser: false,
              language: _selectedLanguage,
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  Widget _buildMessage(ChatMessage message) {
    final isRTL = message.language == 'ar';
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? const Color(0xFFBE9E7E)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(message.isUser ? 20 : 5),
                    bottomRight: Radius.circular(message.isUser ? 5 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
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
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 6,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                // Fonctionnalité emoji à implémenter
              },
            ),
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  hintText: _selectedLanguage == 'fr'
                      ? 'Envoyez un message...'
                      : _selectedLanguage == 'en'
                          ? 'Send a message...'
                          : '...أرسل رسالة',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBE9E7E)),
        ),
        child: DropdownButton<String>(
          value: _selectedLanguage,
          underline: Container(),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFFBE9E7E),
          ),
          items: [
            DropdownMenuItem(
              value: 'fr',
              child: Row(
                children: const [
                  Text('🇫🇷'),
                  SizedBox(width: 8),
                  Text(
                    'Français',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Row(
                children: const [
                  Text('🇬🇧'),
                  SizedBox(width: 8),
                  Text(
                    'English',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'ar',
              child: Row(
                children: const [
                  Text('🇹🇳'),
                  SizedBox(width: 8),
                  Text(
                    'العربية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                _selectedLanguage = value;
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFBE9E7E),
        title: Text(
          _selectedLanguage == 'fr'
              ? 'Assistant EchoLang'
              : _selectedLanguage == 'en'
                  ? 'EchoLang Assistant'
                  : 'مساعد إيكولانج',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _buildLanguageSelector(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          image: DecorationImage(
            image: const AssetImage('assets/images/chat_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.1),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    _buildMessage(_messages[index]),
              ),
            ),
            if (_isTyping)
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 40,
                            child: LoadingDots(),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'EchoBot est en train d\'écrire...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            _buildTextComposer(),
          ],
        ),
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

class LoadingDots extends StatefulWidget {
  const LoadingDots({Key? key}) : super(key: key);

  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(
                    0,
                    sin((_controller.value * 360 + index * 120) * pi / 180) *
                        4),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBE9E7E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
