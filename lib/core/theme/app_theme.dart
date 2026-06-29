import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // NOTE: Legacy palette retargeted to the "Clay & Blueprint" / "Midnight"
  // Archy design tokens (see lib/core/design/archy_tokens.dart). Keeping the old
  // names means the existing dashboards adopt the new look without a full rewrite.
  // `primaryBlue` is now the clay accent despite its name.
  static const Color primaryBlue = Color(0xFFBE5A3C); // clay accent
  static const Color accentBlue = Color(0xFF3A5680); // blueprint
  static const Color darkBackground = Color(0xFF14161B); // Midnight paper
  static const Color darkSurface = Color(0xFF1D2026); // Midnight paper-2
  static const Color darkCard = Color(0xFF23262E); // Midnight paper-3
  static const Color lightBackground = Color(0xFFEFEADF); // paper
  static const Color lightSurface = Color(0xFFFBF8F2); // paper-2
  static const Color lightCard = Color(0xFFFBF8F2); // paper-2

  // Border colors (formerly neomorphic shadow/highlight) — now hairline borders.
  static const Color darkShadow = Color(0xFF2C2F37);
  static const Color darkHighlight = Color(0xFF33373F);
  static const Color lightShadow = Color(0xFFDBD5C8);
  static const Color lightHighlight = Color(0xFFE7E2D6);

  // Status colors — mapped to the Archy tones.
  static const Color success = Color(0xFF4F7A48); // green
  static const Color warning = Color(0xFFB0823A); // gold
  static const Color error = Color(0xFFC0392B);
  static const Color info = Color(0xFF3A5680); // blueprint

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: darkSurface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme)
          .copyWith(
        headlineLarge: GoogleFonts.newsreader(
            color: Colors.white, fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.newsreader(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.newsreader(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.white54,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: lightSurface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme)
          .copyWith(
        headlineLarge: GoogleFonts.newsreader(
            color: const Color(0xFF20242B),
            fontSize: 32,
            fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.newsreader(
            color: const Color(0xFF20242B),
            fontSize: 24,
            fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.newsreader(
            color: const Color(0xFF20242B),
            fontSize: 20,
            fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.black38,
      ),
    );
  }
}
