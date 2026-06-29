import 'package:flutter/material.dart';

/// Archy design tokens — a faithful port of the "Clay & Blueprint" (light) and
/// "Midnight" (dark) palettes from the approved HTML design.
///
/// Naming mirrors the original CSS custom properties (--paper, --ink, --clay…)
/// so screens read the same as the design source.
class ArchyColors {
  final Brightness brightness;

  final Color paper; // app background
  final Color paper2; // raised surface / card
  final Color paper3; // input / inset
  final Color ink; // primary text
  final Color ink2; // secondary text
  final Color ink3; // tertiary / muted text
  final Color line; // borders
  final Color line2; // subtle borders
  final Color clay; // primary accent (terracotta)
  final Color claySoft; // accent tint background
  final Color clayDeep; // accent text-on-tint
  final Color blueprint; // secondary accent (blue)
  final Color blueprintSoft;
  final Color green;
  final Color greenSoft;
  final Color gold;

  const ArchyColors({
    required this.brightness,
    required this.paper,
    required this.paper2,
    required this.paper3,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.line2,
    required this.clay,
    required this.claySoft,
    required this.clayDeep,
    required this.blueprint,
    required this.blueprintSoft,
    required this.green,
    required this.greenSoft,
    required this.gold,
  });

  bool get isDark => brightness == Brightness.dark;

  /// "Clay & Blueprint" — light theme.
  static const ArchyColors light = ArchyColors(
    brightness: Brightness.light,
    paper: Color(0xFFEFEADF),
    paper2: Color(0xFFFBF8F2),
    paper3: Color(0xFFF4F0E7),
    ink: Color(0xFF20242B),
    ink2: Color(0xFF565B65),
    ink3: Color(0xFF8C909A),
    line: Color(0xFFDBD5C8),
    line2: Color(0xFFE7E2D6),
    clay: Color(0xFFBE5A3C),
    claySoft: Color(0xFFF0DDD3),
    clayDeep: Color(0xFF974029),
    blueprint: Color(0xFF3A5680),
    blueprintSoft: Color(0xFFDFE5EE),
    green: Color(0xFF4F7A48),
    greenSoft: Color(0xFFDEE8DB),
    gold: Color(0xFFB0823A),
  );

  /// "Midnight" — dark theme.
  static const ArchyColors dark = ArchyColors(
    brightness: Brightness.dark,
    paper: Color(0xFF14161B),
    paper2: Color(0xFF1D2026),
    paper3: Color(0xFF23262E),
    ink: Color(0xFFF1EEE7),
    ink2: Color(0xFFA7AAB2),
    ink3: Color(0xFF6B6F78),
    line: Color(0xFF2C2F37),
    line2: Color(0xFF33373F),
    clay: Color(0xFFD8714F),
    claySoft: Color(0xFF3A271F),
    clayDeep: Color(0xFFEC8C6C),
    blueprint: Color(0xFF7396C6),
    blueprintSoft: Color(0xFF202A3A),
    green: Color(0xFF6FA968),
    greenSoft: Color(0xFF21301F),
    gold: Color(0xFFC99A4E),
  );

  /// Resolve a semantic "tone" name (used throughout the design data) to a color.
  Color tone(String name) {
    switch (name) {
      case 'clay':
        return clay;
      case 'blue':
      case 'blueprint':
        return blueprint;
      case 'green':
        return green;
      case 'gold':
        return gold;
      case 'ink':
        return ink;
      default:
        return ink3;
    }
  }

  Color toneSoft(String name) {
    switch (name) {
      case 'clay':
        return claySoft;
      case 'blue':
      case 'blueprint':
        return blueprintSoft;
      case 'green':
        return greenSoft;
      default:
        return paper3;
    }
  }
}

/// Shared spacing / radius scale from the design.
class ArchySize {
  static const double radiusCard = 18;
  static const double radiusSm = 12;
  static const double radiusPill = 999;
  static const double gap = 16;
  static const double padScreen = 20;
}
