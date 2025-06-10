import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF00BCD4);
  static const Color secondaryTeal = Color(0xFF4DD0E1);
  static const Color darkTeal = Color(0xFF00838F);

  static const Color primaryPurple = Color(0xFF7B1FA2);
  static const Color secondaryPurple = Color(0xFF9C27B0);
  static const Color lightPurple = Color(0xFFE1BEE7);

  static const Color backgroundDark = Color(0xFF0A0E1A);
  static const Color surfaceDark = Color(0xFF1A1F2E);
  static const Color cardDark = Color(0xFF2A2F3E);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textTertiary = Color(0xFF78909C);

  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color warningOrange = Color(0xFFFF9800);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: primaryPurple,
        surface: surfaceDark,
        background: backgroundDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: primaryTeal),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 8,
        shadowColor: primaryTeal.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryTeal.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: textTertiary, fontSize: 12),
      ),
      iconTheme: const IconThemeData(color: primaryTeal),
      dividerTheme: DividerThemeData(
        color: textTertiary.withOpacity(0.3),
        thickness: 1,
      ),
    );
  }

  static LinearGradient get primaryGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryTeal, secondaryTeal],
    );
  }

  static LinearGradient get secondaryGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryPurple, secondaryPurple],
    );
  }

  static LinearGradient get accentGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryTeal, primaryPurple],
    );
  }

  static BoxShadow get glowShadow {
    return BoxShadow(
      color: primaryTeal.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    );
  }

  static BoxShadow get purpleGlowShadow {
    return BoxShadow(
      color: primaryPurple.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    );
  }
}
