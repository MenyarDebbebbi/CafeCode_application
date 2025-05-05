import 'package:flutter/material.dart';

class HomeStyles {
  static const Color primaryColor = Color(0xFFBE9E7E);
  static const Color secondaryColor = Color(0xFF8B7355);

  static TextStyle getTitleStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.white : const Color(0xFF4A4A4A),
      letterSpacing: 0.5,
    );
  }

  static TextStyle getSubtitleStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 16,
      color: isDarkMode ? Colors.white70 : Colors.grey[600],
    );
  }

  static TextStyle getCardTitleStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.white : Colors.white,
    );
  }

  static TextStyle getCardSubtitleStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 14,
      color: isDarkMode ? Colors.white70 : Colors.white70,
    );
  }

  static BoxDecoration mainButtonDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
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

  static LinearGradient getBackgroundGradient(bool isDarkMode) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDarkMode
          ? [
              const Color(0xFF2C2C2C),
              const Color(0xFF1E1E1E),
            ]
          : [
              primaryColor.withOpacity(0.1),
              Colors.white,
            ],
    );
  }
}
