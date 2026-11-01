import 'package:flutter/material.dart';

class AppTheme {
  // ПАЛИТРА ПО ТЗ (FB / Фонбет):
  // • #111415 — основной фон и нижняя навигация.
  // • #202326 — фон секций и крупных карточек.
  // • #252B34 — фон главного информационного баннера.
  // • #292D31 — поля поиска и небольшие карточки.
  // • #DA2528 — основной красный акцент: кнопки, активные вкладки, индикаторы прогресса.
  // • #B60925 — дополнительный тёмно-красный для декоративных элементов.
  // • #FFFFFF — заголовки и текст основных кнопок.
  // • #E5E5E5 — основной текст.
  // • #A9ACB0 — второстепенные подписи.
  // • #383D43 — разделители и контуры.

  static const Color background = Color(0xFF111415);
  static const Color surfaceCard = Color(0xFF202326);
  static const Color bannerBackground = Color(0xFF252B34);
  static const Color surfaceSmall = Color(0xFF292D31);
  static const Color primary = Color(0xFFDA2528); // Красный акцент
  static const Color darkRed = Color(0xFFB60925);
  static const Color textHeadlines = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFFE5E5E5);
  static const Color textSecondary = Color(0xFFA9ACB0);
  static const Color border = Color(0xFF383D43);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Совместимость
  static const Color surface = surfaceCard;
  static const Color surfaceBorder = border;
  static const Color textPrimary = textHeadlines;
  static const Color textMuted = textSecondary;
  static const Color secondary = darkRed;
  static const Color accentGold = Color(0xFFFFB703);
  static const Color accentRose = primary;
  static const Color accentOrange = Color(0xFFFB8500);
  static const Color accentBlue = Color(0xFF38BDF8);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color fonbetBlue = Color(0xFF1B63D8);
  static const Color surfaceCardHighlight = surfaceSmall;

  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double screenPadding = 16.0;
  static const double buttonHeight = 48.0;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(50),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get redGlow => [
        BoxShadow(
          color: primary.withAlpha(65),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> get neonGlow => redGlow;

  static const LinearGradient redGradient = LinearGradient(
    colors: [primary, darkRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [bannerBackground, surfaceCard],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceCard, background],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF1B63D8), Color(0xFF0F47A1)],
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
        secondary: darkRed,
        surface: surfaceCard,
        error: primary,
        onPrimary: onPrimary,
        onSurface: textHeadlines,
      ),
      fontFamily: null, // Системный шрифт
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textHeadlines),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textHeadlines),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textHeadlines),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textHeadlines),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textMain),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(0, buttonHeight),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
          elevation: 0,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textHeadlines),
        iconTheme: IconThemeData(color: primary),
      ),
    );
  }
}
