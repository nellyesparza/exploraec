import 'package:flutter/material.dart';

/// Tema visual de ExploraEC — Sesión 3.
///
/// Usa la misma paleta de marca que las diapositivas y documentos del curso
/// (ver `TECH_STACK.md`): navy para texto/AppBar, teal como color primario,
/// naranja como acento. Un solo lugar define los colores de toda la app —
/// cambiar uno aquí lo cambia en cada pantalla que use `Theme.of(context)`.
class AppTheme {
  AppTheme._();

  static const Color navy = Color(0xFF0E2841);
  static const Color teal = Color(0xFF156082);
  static const Color orange = Color(0xFFE97132);
  static const Color sky = Color(0xFF0F9ED5);

  static Color get colorPrimario => teal;

  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: teal,
      primary: teal,
      secondary: orange,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F9FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: navy),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF222222)),
        bodySmall: TextStyle(fontSize: 12),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48), // tamaño mínimo de toque accesible
        ),
      ),
    );
  }

  /// Tema oscuro (Paso 6, opcional). Misma semilla teal que `theme`, pero con
  /// `Brightness.dark`: Flutter genera la paleta oscura completa y cada widget
  /// que consulta `Theme.of(context)` la toma sin cambiar una sola línea.
  /// A propósito NO fija colores de texto ni de fondo — los que fijaba `theme`
  /// (navy sobre blanco) serían ilegibles sobre un fondo oscuro.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: teal,
      secondary: orange,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(48, 48), // tamaño mínimo de toque accesible
        ),
      ),
    );
  }
}

/// Constantes de espaciado — un único lugar para los valores de `EdgeInsets`
/// y `SizedBox` usados en toda la app, en vez de números sueltos repetidos
/// en cada widget.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}
