import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/viewmodel/login/login_viewmodel.dart';
import 'package:neo_financyuai/app/widgets/oauth_button.dart';
import 'package:neo_financyuai/app/widgets/theme_selector.dart';

/// Tela de login moderna focada em autenticação OAuth
///
/// Apresenta apenas provedores de OAuth (Google, GitHub, Microsoft, etc.)
/// com design limpo e moderno, sem campos de email/senha.
class ModernLoginPage extends StatefulWidget {
  /// ViewModel que gerencia a lógica de autenticação.
  final LoginViewModel viewmodel;

  /// Cria uma nova instância de [ModernLoginPage].
  const ModernLoginPage({super.key, required this.viewmodel});

  @override
  State<ModernLoginPage> createState() => _ModernLoginPageState();
}

class _ModernLoginPageState extends State<ModernLoginPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  helper.isDark
                      ? [
                        helper.colorScheme.surface,
                        helper.colorScheme.surface.withOpacity(0.8),
                        helper.colorScheme.primary.withOpacity(0.1),
                      ]
                      : [
                        helper.colorScheme.primary.withOpacity(0.1),
                        helper.colorScheme.secondary.withOpacity(0.05),
                        Colors.white,
                      ],
            ),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    
                    // Seletor de tema no canto superior direito
                    const Align(
                      alignment: Alignment.topRight,
                      child: ThemeToggleButton(),
                    ),
                    
                    
                
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildLogoSection(context),
                      ),
                    ),
                    
                    
                
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildLoginSection(helper),
                      ),
                    ),
                    
                    
                
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildTermsSection(helper),
                    ),
                    
                    
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        // Logo com container para melhor controle
        Container(
          width: size.width * 0.35,
          height: size.width * 0.35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/img/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        
        
        Text(
          'FinancyUAI',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppThemeHelper.of(context).colorScheme.primary,
            fontFamily: 'Shrikhand',
          ),
        ),
        
                
        Text(
          'Sua gestão financeira inteligente',
          style: TextStyle(
            fontSize: 16,
            color: AppThemeHelper.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginSection(AppThemeHelper helper) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 45.0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: helper.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: helper.colorScheme.outline.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da seção
            Text(
              'Faça login na sua conta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: helper.colorScheme.onSurface,
              ),
            ),
            
            
            Text(
              'Escolha uma das opções abaixo para continuar',
              style: TextStyle(
                fontSize: 14,
                color: helper.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            
            
      
            // Botões de OAuth
            Observer(
              builder:
                  (_) => Column(
                    children: [
                      // Google
                      OAuthButton(
                        label: 'Continuar com Google',
                        icon: const GoogleIcon(),
                        isLoading: widget.viewmodel.isLoading,
                        loadingText: 'Entrando...',
                        onPressed: () => widget.viewmodel.loginWithGoogle(),
                      ),
                      
                      
      
                      // GitHub (preparado para implementação futura)
                      OAuthButton(
                        label: 'Continuar com GitHub',
                        icon: const GitHubIcon(color: Colors.white),
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        borderColor: Colors.black,
                        onPressed: () => widget.viewmodel.loginWithGitHub(),
                      ),
                      
                      
      
                      // Microsoft (preparado para implementação futura)
                      OAuthButton(
                        label: 'Continuar com Microsoft',
                        icon: const MicrosoftIcon(),
                        backgroundColor: Colors.blue[600],
                        textColor: Colors.white,
                        borderColor: Colors.blue[600],
                        onPressed: () => widget.viewmodel.loginWithMicrosoft(),
                      ),
                    ],
                  ),
            ),
            
            
      
            // Mensagem de erro
            Observer(
              builder:
                  (_) =>
                      widget.viewmodel.errorMessage != null
                          ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.viewmodel.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: widget.viewmodel.clearError,
                                  color: Colors.red,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection(AppThemeHelper helper) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            'Ao continuar, você concorda com nossos',
            style: TextStyle(
              fontSize: 12,
              color: helper.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _showTerms(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Termos de Uso',
                  style: TextStyle(
                    fontSize: 12,
                    color: helper.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                ' e ',
                style: TextStyle(
                  fontSize: 12,
                  color: helper.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),

              TextButton(
                onPressed: () => _showPrivacyPolicy(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Política de Privacidade',
                  style: TextStyle(
                    fontSize: 12,
                    color: helper.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Termos de Uso'),
            content: const Text('Aqui ficarão os termos de uso da aplicação.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Política de Privacidade'),
            content: const Text(
              'Aqui ficará a política de privacidade da aplicação.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }
}
