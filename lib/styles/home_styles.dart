import 'package:flutter/material.dart';

class HomeStyles {
  static const Color primaryColor = Color(0xFFBE9E7E);
  static const Color secondaryColor = Color(0xFFA98B6F);
  static const Color textColor = Color(0xFF4A4A4A);

  static BoxDecoration cardDecoration(Color color) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.05),
          Colors.white,
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration mainButtonDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static TextStyle titleStyle = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle subtitleStyle = const TextStyle(
    fontSize: 16,
    color: Colors.grey,
    fontWeight: FontWeight.w500,
  );

  static TextStyle cardTitleStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle cardSubtitleStyle = TextStyle(
    color: Colors.white.withOpacity(0.9),
    fontSize: 14,
  );
}
