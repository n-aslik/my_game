import 'package:flutter/material.dart';

/// Набор цветов игры. Каждая часть игры выбирает свою палитру в main.dart.
class AppPalette {
  final Color bg;
  final Color surface;
  final Color accent;
  final Color accent2;
  final Color warm;
  final Color text;
  final Color textDim;

  /// Рисовать ли на главном экране часовой механизм (часть 2).
  final bool chrono;

  const AppPalette({
    required this.bg,
    required this.surface,
    required this.accent,
    required this.accent2,
    required this.warm,
    required this.text,
    required this.textDim,
    this.chrono = false,
  });

  /// Часть 1: лунный фиолетовый и призрачный бирюзовый.
  static const mystic = AppPalette(
    bg: Color(0xFF07060C),
    surface: Color(0xFF14111E),
    accent: Color(0xFFB48CFF),
    accent2: Color(0xFF5EEAD4),
    warm: Color(0xFFFFC27A),
    text: Color(0xFFF1ECFA),
    textDim: Color(0xFFA9A1BA),
  );

  /// Часть 2: латунь и патина, 1927 год.
  static const brass = AppPalette(
    bg: Color(0xFF0A0806),
    surface: Color(0xFF1A1410),
    accent: Color(0xFFFFB454),
    accent2: Color(0xFF6FD6C4),
    warm: Color(0xFFFF8A5B),
    text: Color(0xFFF7EEDF),
    textDim: Color(0xFFB5A892),
    chrono: true,
  );
}

class AppTheme {
  static AppPalette palette = AppPalette.mystic;

  static const List<String> serifFallback = [
    'Georgia',
    'Cambria',
    'Times New Roman',
    'serif',
  ];

  /// Заголовочный стиль с засечками.
  static TextStyle title(double size, {Color? color, double spacing = 0.5}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: spacing,
      height: 1.15,
      color: color ?? palette.text,
      fontFamilyFallback: serifFallback,
    );
  }

  static ThemeData dark() {
    final p = palette;
    final scheme = ColorScheme.dark(
      primary: p.accent,
      onPrimary: const Color(0xFF14101C),
      secondary: p.accent2,
      onSecondary: const Color(0xFF06201C),
      surface: p.surface,
      onSurface: p.text,
      error: const Color(0xFFFF6B6B),
    );

    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      textTheme: base.textTheme.apply(
        bodyColor: p.text,
        displayColor: p.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: title(20),
      ),
      cardTheme: CardThemeData(
        color: p.surface.withValues(alpha: 0.7),
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: const Color(0xFF14101C),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.accent),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF241E30),
        contentTextStyle: TextStyle(color: p.text, fontSize: 14, height: 1.3),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.accent.withValues(alpha: 0.35)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1B1626),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: p.accent.withValues(alpha: 0.3)),
        ),
        titleTextStyle: title(22),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2236),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(color: p.text, fontSize: 12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent,
        linearTrackColor: Colors.white.withValues(alpha: 0.08),
        circularTrackColor: Colors.white.withValues(alpha: 0.08),
      ),
    );
  }
}

/// Плавный переход между экранами: затухание + лёгкий подъём.
Route<T> softRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
