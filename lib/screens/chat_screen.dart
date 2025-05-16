import 'package:flutter/material.dart';
import '../data/chat_responses.dart';

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

      // Obtenir et ajouter la réponse du chatbot
      ChatResponse? response =
          ChatbotData.findResponse(text, _selectedLanguage);
      if (response != null) {
        _messages.add(
          ChatMessage(
            text: response.answer,
            isUser: false,
            language: _selectedLanguage,
          ),
        );
      }
    });

    // Faire défiler jusqu'au dernier message
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButton<String>(
        value: _selectedLanguage,
        items: [
          DropdownMenuItem(
            value: 'fr',
            child: Row(
              children: [
                Text('🇫🇷'),
                SizedBox(width: 8),
                Text('Français'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'en',
            child: Row(
              children: [
                Text('🇬🇧'),
                SizedBox(width: 8),
                Text('English'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'ar',
            child: Row(
              children: [
                Text('🇹🇳'),
                SizedBox(width: 8),
                Text('العربية'),
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
    );
  }

  Widget _buildTextComposer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).primaryColor),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
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
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isRTL = message.language == 'ar';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Directionality(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedLanguage == 'fr'
              ? 'Assistant EchoLang'
              : _selectedLanguage == 'en'
                  ? 'EchoLang Assistant'
                  : 'مساعد إيكولانج',
        ),
        actions: [
          _buildLanguageSelector(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          _buildTextComposer(),
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
