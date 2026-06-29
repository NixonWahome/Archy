import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'archy_tokens.dart';

/// Typography + ThemeData built from [ArchyColors].
///
/// Fonts mirror the design: Newsreader (serif display), Space Grotesk (sans
/// body/UI), JetBrains Mono (numbers, labels, "technical" accents).
class ArchyTheme {
  static TextStyle serif(
    ArchyColors c, {
    double size = 27,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double height = 1.1,
  }) =>
      GoogleFonts.newsreader(
        fontSize: size,
        fontWeight: weight,
        color: color ?? c.ink,
        height: height,
        letterSpacing: -0.01 * size,
      );

  static TextStyle sans(
    ArchyColors c, {
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.4,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        color: color ?? c.ink,
        height: height,
      );

  static TextStyle mono(
    ArchyColors c, {
    double size = 12,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double letterSpacing = 0.02,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color ?? c.ink2,
        letterSpacing: letterSpacing,
      );

  static ThemeData build(ArchyColors c) {
    final scheme = ColorScheme(
      brightness: c.brightness,
      primary: c.clay,
      onPrimary: Colors.white,
      secondary: c.blueprint,
      onSecondary: Colors.white,
      error: const Color(0xFFC0392B),
      onError: Colors.white,
      surface: c.paper2,
      onSurface: c.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      scaffoldBackgroundColor: c.paper,
      colorScheme: scheme,
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        c.isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).apply(bodyColor: c.ink, displayColor: c.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: c.paper,
        foregroundColor: c.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: serif(c, size: 22),
      ),
      iconTheme: IconThemeData(color: c.ink),
      dividerColor: c.line,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
