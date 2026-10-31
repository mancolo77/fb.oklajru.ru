import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Fonbet Signature Brand Colors
  static const Color primary = Color(0xFFE21A22); // Fonbet Signature Crimson Red
  static const Color primaryDark = Color(0xFFB8141F); // Fonbet Dark Crimson
  static const Color primaryLight = Color(0xFFFF3B47); // Fonbet Bright Red Accent
  static const Color secondary = Color(0xFF10B981); // Emerald / Success
  static const Color fonbetBlue = Color(0xFF1B63D8); // Fonbet Royal/Cobalt Blue
  static const Color accentBlue = Color(0xFF38BDF8); // Ice / Stats Blue
  static const Color accentGold = Color(0xFFFFB703); // Gold / Loyalty Coins / VIP
  static const Color accentRose = Color(0xFFEF4444); // Error / Danger
  static const Color accentOrange = Color(0xFFFB8500); // Daily Streak / Fire
  static const Color accentPurple = Color(0xFF8B5CF6); // Special Quests

  // Background Surfaces (Fonbet Dark Charcoal & Deep Navy Slate)
  static const Color background = Color(0xFF0F141D); // Deep Carbon Dark
  static const Color surface = Color(0xFF161C28); // Slate Surface / AppBars / Nav
  static const Color surfaceCard = Color(0xFF1E2536); // Elevated Card Surface
  static const Color surfaceCardHighlight = Color(0xFF252F44); // Hover / Highlight Card
  static const Color surfaceBorder = Color(0xFF2C384E); // Crisp Structural Border

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // High-contrast White
  static const Color textSecondary = Color(0xFF94A3B8); // Slate Silver
  static const Color textMuted = Color(0xFF64748B); // Muted Blue-Grey

  // Box Shadows & Glows
  static List<BoxShadow> get redGlow => [
        BoxShadow(
          color: primary.withAlpha(65),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> get neonGlow => redGlow;

  // Gradients
  static const LinearGradient redGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF222B3D), Color(0xFF141926)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF20283A), Color(0xFF161C28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [fonbetBlue, Color(0xFF0F47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: accentRose,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: surfaceBorder),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
