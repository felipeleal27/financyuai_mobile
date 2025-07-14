import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuração centralizada de temas do aplicativo
/// 
/// Responsável por definir:
/// - Tema claro e escuro
/// - Cores personalizadas do aplicativo
/// - Configurações de overlay do sistema
/// - Métodos utilitários para acesso aos temas
class UiConfigTheme {
  // Construtor privado para evitar instanciação
  UiConfigTheme._();

  /// Título do aplicativo
  static String get title => 'Financy_UAI';

  static ThemeData get themelight => ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF9AD0D3),
          foregroundColor: Color(0xFFFFFFFF),
          titleTextStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
          toolbarTextStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0xFF9AD0D3),
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFF9AD0D3),
            systemNavigationBarDividerColor: Color(0xFF9AD0D3),
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF9AD0D3),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFF8DFB77),
          onPrimaryContainer: Color(0xFF002200),
          secondary: Color.fromARGB(255, 69, 133, 206),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color.fromARGB(255, 0, 229, 245),
          onSecondaryContainer: Color(0xFF002200),
          tertiary: Color.fromARGB(255, 20, 99, 216),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFFB1F49D),
          onTertiaryContainer: Color(0xFF012200),
          error: Color(0xFFBA1A1A),
          errorContainer: Color(0xFFFFDAD6),
          onError: Color(0xFFFFFFFF),
          onErrorContainer: Color(0xFF410002),
          surface: Color(0xFFFCFDF6),
          onSurface: Color(0xFF1A1C18),
          onSurfaceVariant: Color(0xFF43483F),
          outline: Color(0xFF73796E),
          onInverseSurface: Color(0xFFF1F1EB),
          inverseSurface: Color(0xFF2F312D),
          inversePrimary: Color(0xFF72DE5E),
          shadow: Color(0xFF000000),
          surfaceTint: Color(0xFF9AD0D3),
          outlineVariant: Color(0xFFC3C8BC),
          scrim: Color(0xFF000000),
        ),
      );

  static ThemeData get themedark => ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F), // Cor escura para o modo escuro
          foregroundColor: Color(0xFFFFFFFF),
          titleTextStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
          toolbarTextStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0xFF1F1F1F), // Status bar escura
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Color(0xFF1F1F1F), // Navigation bar escura
            systemNavigationBarDividerColor: Color(0xFF1F1F1F),
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.dark, // Importante: brightness dark
          primary: Color(0xFF9AD0D3),
          onPrimary: Color(0xFF000000), // Texto escuro no primary
          primaryContainer: Color(0xFF004D40), // Container mais escuro
          onPrimaryContainer: Color(0xFFB2DFDB),
          secondary: Color.fromARGB(255, 100, 165, 255), // Secondary mais claro para contraste
          onSecondary: Color(0xFF000000),
          secondaryContainer: Color.fromARGB(255, 1, 87, 155),
          onSecondaryContainer: Color(0xFFE3F2FD),
          tertiary: Color.fromARGB(255, 92, 147, 255),
          onTertiary: Color(0xFF000000),
          tertiaryContainer: Color(0xFF1A237E),
          onTertiaryContainer: Color(0xFFC5CAE9),
          error: Color(0xFFCF6679), // Cor de erro mais suave para dark mode
          errorContainer: Color(0xFFB00020),
          onError: Color(0xFF000000),
          onErrorContainer: Color(0xFFFFCDD2),
          surface: Color(0xFF121212), // Background escuro
          onSurface: Color(0xFFFFFFFF), // Texto claro
          onSurfaceVariant: Color(0xFFBDBDBD),
          outline: Color(0xFF757575),
          onInverseSurface: Color(0xFF000000),
          inverseSurface: Color(0xFFFFFFFF),
          inversePrimary: Color(0xFF00695C),
          shadow: Color(0xFF000000),
          surfaceTint: Color(0xFF9AD0D3),
          outlineVariant: Color(0xFF424242),
          scrim: Color(0xFF000000),
        ),
      );

  // Métodos utilitários para gerenciar temas
  
  /// Verifica se o dispositivo está no modo escuro
  static bool isDarkMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  /// Retorna o tema atual baseado no contexto
  static ThemeData getCurrentTheme(BuildContext context) {
    return isDarkMode(context) ? themedark : themelight;
  }

  /// Retorna a cor primária baseada no tema atual
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Retorna a cor de surface baseada no tema atual
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Retorna a cor de texto baseada no tema atual
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  // Configurações específicas para o sistema de overlays
  static SystemUiOverlayStyle getSystemUiOverlayStyle(bool isDark) {
    if (isDark) {
      return const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1F1F1F),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF1F1F1F),
        systemNavigationBarDividerColor: Color(0xFF1F1F1F),
        systemNavigationBarIconBrightness: Brightness.light,
      );
    } else {
      return const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF9AD0D3),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF9AD0D3),
        systemNavigationBarDividerColor: Color(0xFF9AD0D3),
        systemNavigationBarIconBrightness: Brightness.light,
      );
    }
  }
}
