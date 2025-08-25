import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';

/// Widget reutilizável para botões de autenticação OAuth
/// 
/// Permite fácil adição de novos provedores (Google, GitHub, Microsoft, etc.)
/// com design consistente e animações suaves.
class OAuthButton extends StatelessWidget {
  /// Texto do botão
  final String label;
  
  /// Função executada ao pressionar o botão
  final VoidCallback? onPressed;
  
  /// Indica se o botão está em estado de carregamento
  final bool isLoading;
  
  /// Cor de fundo do botão
  final Color? backgroundColor;
  
  /// Cor do texto
  final Color? textColor;
  
  /// Cor da borda
  final Color? borderColor;
  
  /// Widget do ícone (pode ser Icon, Image, ou qualquer widget)
  final Widget icon;
  
  /// Texto exibido durante o carregamento
  final String? loadingText;

  const OAuthButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.white,
            foregroundColor: textColor ?? Colors.black87,
            side: BorderSide(
              color: borderColor ?? helper.colorScheme.outline.withOpacity(0.3),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 1,
          ),
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      helper.colorScheme.primary,
                    ),
                  ),
                )
              : icon,
          label: Text(
            isLoading ? (loadingText ?? 'Carregando...') : label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para ícone do Google otimizado
class GoogleIcon extends StatelessWidget {
  final double size;
  
  const GoogleIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/img/google_icon.svg',
      width: size,
      height: size,
    );
  }
}

/// Widget para ícone do GitHub
class GitHubIcon extends StatelessWidget {
  final double size;
  final Color? color;
  
  const GitHubIcon({super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/img/github_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null 
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

/// Widget para ícone da Microsoft
class MicrosoftIcon extends StatelessWidget {
  final double size;
  
  const MicrosoftIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/img/microsoft_icon.svg',
      width: size,
      height: size,
    );
  }
}
