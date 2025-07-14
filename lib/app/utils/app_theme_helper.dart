import 'package:flutter/material.dart';

/// Classe utilitária para fornecer acesso fácil a informações de tema,
/// cores, tamanho da tela e brilho em qualquer widget da aplicação.
/// 
/// Uso:
/// ```dart
/// final helper = AppThemeHelper.of(context);
/// final primaryColor = helper.colorScheme.primary;
/// final isPhone = helper.isPhone;
/// final isDark = helper.isDark;
/// ```
class AppThemeHelper {
  final BuildContext _context;
  
  AppThemeHelper._(this._context);
  
  /// Factory constructor para criar uma instância com base no contexto
  factory AppThemeHelper.of(BuildContext context) {
    return AppThemeHelper._(context);
  }
  
  // === TEMA ===
  
  /// Retorna o tema atual
  ThemeData get theme => Theme.of(_context);
  
  /// Retorna o esquema de cores atual
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// Retorna o brilho atual (light/dark)
  Brightness get brightness => theme.brightness;
  
  /// Verifica se está em modo escuro
  bool get isDark => brightness == Brightness.dark;
  
  /// Verifica se está em modo claro
  bool get isLight => brightness == Brightness.light;
  
  // === CORES PRINCIPAIS ===
  
  /// Cor primária do tema
  Color get primaryColor => colorScheme.primary;
  
  /// Cor secundária do tema
  Color get secondaryColor => colorScheme.secondary;
  
  /// Cor de superfície
  Color get surfaceColor => colorScheme.surface;
  
  /// Cor de fundo
  Color get backgroundColor => colorScheme.surface;
  
  /// Cor do texto principal
  Color get onSurfaceColor => colorScheme.onSurface;
  
  /// Cor do texto sobre primária
  Color get onPrimaryColor => colorScheme.onPrimary;
  
  /// Cor de erro
  Color get errorColor => colorScheme.error;
  
  /// Cor de sucesso (usando secondary como fallback)
  Color get successColor => colorScheme.secondary;
  
  /// Cor de aviso (usando tertiary ou primary)
  Color get warningColor => colorScheme.tertiary;
  
  // === TAMANHO DA TELA ===
  
  /// Dados do MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(_context);
  
  /// Tamanho da tela
  Size get screenSize => mediaQuery.size;
  
  /// Largura da tela
  double get screenWidth => screenSize.width;
  
  /// Altura da tela
  double get screenHeight => screenSize.height;
  
  /// Densidade de pixels
  double get pixelRatio => mediaQuery.devicePixelRatio;
  
  /// Padding seguro (notch, navigation bar, etc.)
  EdgeInsets get padding => mediaQuery.padding;
  
  /// ViewInsets (teclado, etc.)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  
  // === BREAKPOINTS E RESPONSIVIDADE ===
  
  /// Verifica se é um dispositivo pequeno (telefone)
  bool get isPhone => screenWidth < 600;
  
  /// Verifica se é um dispositivo médio (tablet pequeno)
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  
  /// Verifica se é um dispositivo grande (desktop/tablet grande)
  bool get isDesktop => screenWidth >= 1024;
  
  /// Verifica se a orientação é retrato
  bool get isPortrait => screenHeight > screenWidth;
  
  /// Verifica se a orientação é paisagem
  bool get isLandscape => screenWidth > screenHeight;
  
  /// Verifica se o teclado está visível
  bool get isKeyboardVisible => viewInsets.bottom > 0;
  
  // === MÉTODOS DE CONVENIÊNCIA ===
  
  /// Retorna uma cor com opacidade baseada no tema
  Color getColorWithOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Retorna uma cor de texto secundária
  Color get secondaryTextColor => onSurfaceColor.withOpacity(0.7);
  
  /// Retorna uma cor de texto desabilitada
  Color get disabledTextColor => onSurfaceColor.withOpacity(0.4);
  
  /// Retorna uma cor de divisor
  Color get dividerColor => onSurfaceColor.withOpacity(0.12);
  
  /// Retorna uma sombra apropriada para o tema
  List<BoxShadow> get defaultShadow => [
    BoxShadow(
      color: isDark 
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Retorna uma sombra elevada para cards
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: isDark 
        ? Colors.black.withOpacity(0.4)
        : Colors.grey.withOpacity(0.15),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];
  
  /// Retorna padding responsivo baseado no tamanho da tela
  EdgeInsets get responsivePadding {
    if (isPhone) return const EdgeInsets.all(16);
    if (isTablet) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }
  
  /// Retorna espaçamento responsivo
  double get responsiveSpacing {
    if (isPhone) return 16;
    if (isTablet) return 24;
    return 32;
  }
  
  /// Retorna tamanho de fonte responsivo
  double getResponsiveFontSize(double baseFontSize) {
    if (isPhone) return baseFontSize;
    if (isTablet) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }
  
  // === GRADIENTES ===
  
  /// Gradiente primário do tema
  LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );
  
  /// Gradiente de fundo para telas
  LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [
            surfaceColor,
            surfaceColor.withOpacity(0.8),
            primaryColor.withOpacity(0.1),
          ]
        : [
            primaryColor.withOpacity(0.1),
            secondaryColor.withOpacity(0.05),
            Colors.white,
          ],
  );
  
  /// Cor customizada para o container da HomePage
  Color get homeContainerColor => isDark ? const Color(0xFF0A2049) : const Color(0xFF9AD0D3);
  
  // === CORES ESPECÍFICAS PARA CARDS DE TRANSAÇÃO ===
  
  /// Cor do card para receitas (entrada)
  Color get receitaCardColor => isDark 
      ? const Color(0xFF1B5E20).withOpacity(0.3)  // Verde escuro com transparência
      : const Color(0xFFE8F5E9);                  // Verde claro
  
  /// Cor do texto/valor para receitas
  Color get receitaValueColor => isDark 
      ? const Color(0xFF66BB6A)                   // Verde claro para modo escuro
      : const Color(0xFF388E3C);                  // Verde escuro para modo claro
  
  /// Cor do ícone para receitas
  Color get receitaIconColor => isDark 
      ? const Color(0xFF4CAF50)                   // Verde médio
      : const Color(0xFF81C784);                  // Verde médio claro
      
  /// Cor do card para despesas (saída)
  Color get despesaCardColor => isDark 
      ? const Color(0xFF8E0000).withOpacity(0.3)  // Vermelho escuro com transparência
      : const Color(0xFFFFEBEE);                  // Vermelho claro
  
  /// Cor do texto/valor para despesas
  Color get despesaValueColor => isDark 
      ? const Color(0xFFEF5350)                   // Vermelho claro para modo escuro
      : const Color(0xFFD32F2F);                  // Vermelho escuro para modo claro
  
  /// Cor do ícone para despesas
  Color get despesaIconColor => isDark 
      ? const Color(0xFFF44336)                   // Vermelho médio
      : const Color(0xFFE57373);                  // Vermelho médio claro
      
  // === CORES PARA MODAL/BOTTOM SHEET ===
  
  /// Cor de fundo do modal
  Color get modalBackgroundColor => isDark 
      ? const Color(0xFF2C2C2C)                   // Cinza escuro
      : const Color(0xFFFAFAFA);                  // Cinza muito claro
      
  /// Cor dos campos de texto no modal
  Color get modalFieldColor => isDark 
      ? const Color(0xFF3C3C3C)                   // Cinza médio escuro
      : const Color(0xFFF5F5F5);                  // Cinza claro
}
