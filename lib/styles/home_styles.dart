import 'package:flutter/material.dart';

/// Styles pour l'écran d'accueil et les composants communs
class HomeStyles {
  static const Color primaryColor = Color(0xFFBE9E7E);
  static const Color secondaryColor = Color(0xFF8B7355);

  static LinearGradient getBackgroundGradient(bool isDarkMode) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkMode
          ? [Colors.grey[900]!, Colors.grey[800]!]
          : [const Color(0xFFFAF6F3), const Color(0xFFF5EDE6)],
    );
  }

  static TextStyle getTitleStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.white : const Color(0xFF4A4A4A),
    );
  }

  static TextStyle getSubtitleStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 16,
      color: isDarkMode ? Colors.white70 : Colors.grey[600],
    );
  }

  static TextStyle getCardTitleStyle(bool isDarkMode) {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  static TextStyle getCardSubtitleStyle(bool isDarkMode) {
    return const TextStyle(
      fontSize: 14,
      color: Colors.white70,
    );
  }

  static BoxDecoration mainButtonDecoration() {
    return BoxDecoration(
      color: primaryColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration getCardDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  }
}
