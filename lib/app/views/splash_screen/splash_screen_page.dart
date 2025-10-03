import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/viewmodel/slpash_screen/splash_screen_viewmodel.dart';
import 'package:neo_financyuai/app/views/login/module/login_nome_rotas.dart';

/// Página de splash screen da aplicação.
/// 
/// Apresenta uma animação de carregamento enquanto inicializa serviços
/// e verifica o estado de autenticação do usuário para navegação adequada.
class SplashScreenPage extends StatefulWidget {
  /// Cria uma nova instância de [SplashScreenPage].
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

/// Estado da página de splash screen.
/// 
/// Gerencia a sequência de inicialização e navegação baseada no status de autenticação.
class _SplashScreenPageState extends State<SplashScreenPage> {
  /// ViewModel responsável pela lógica de inicialização.
  final viewmodel = Modular.get<SplashScreenViewmodel>();
  
  /// Serviço de autenticação para verificar status do usuário.
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  /// Inicia a sequência de splash screen com animação e inicialização.
  /// 
  /// Aguarda a exibição completa da animação antes de prosseguir
  /// com a inicialização e navegação.
  Future<void> _startSplashSequence() async {
    // Aguarda um tempo maior para mostrar a animação GIF completa
    await Future.delayed(const Duration(milliseconds: 4500)); // 4.5 segundos
    
    // Executa a lógica de inicialização
    await _initializeApp();
    
    // Navega para a próxima tela
    await _checkAuthAndNavigate();
  }

  /// Inicializa os serviços e dados necessários da aplicação.
  /// 
  /// Calcula saldos e inicializa categorias padrão se o usuário estiver autenticado.
  Future<void> _initializeApp() async {
    await viewmodel.calcularSaldo();
    
    // Se o usuário estiver logado, inicializar com o ID real
    if (authService.isAuthenticated && authService.userId != null) {
      await viewmodel.inicializarCategoriasPadrao(authService.userId!);
    }
  }

  /// Verifica o status de autenticação e navega para a tela apropriada.
  /// 
  /// Direciona para Home se autenticado, ou Login caso contrário.
  Future<void> _checkAuthAndNavigate() async {
    // Verifica se o usuário está autenticado
    if (authService.isAuthenticated) {
      // Usuário já logado, vai para o shell de abas (navegação fluida)
      Modular.to.pushReplacementNamed('/app/tabs');
    } else {
      // Usuário não logado, vai para login
      Modular.to.pushReplacementNamed(LoginNomeRotas.navigate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeHelper = AppThemeHelper.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: themeHelper.surfaceColor,
      body: Center(
        child: SizedBox(
          width: screenSize.width * 0.8, // 80% da largura da tela
          height: screenSize.height * 0.6, // 60% da altura da tela
          child: const Image(image: AssetImage('assets/animations/gif_financyuai.gif'),
            fit: BoxFit.contain, // Mantém proporção e mostra tudo
            gaplessPlayback: true, // Tenta melhorar reprodução
            isAntiAlias: true, // Melhora qualidade
            filterQuality: FilterQuality.high, // Qualidade alta
          ),
          // Image.asset(
          //   'assets/animations/gif_financyuai.gif',
          //   fit: BoxFit.contain, // Mantém proporção e mostra tudo
          //   gaplessPlayback: true, // Tenta melhorar reprodução
          //   isAntiAlias: true, // Melhora qualidade
          //   filterQuality: FilterQuality.high, // Qualidade alta
          // ),
        ),
      ),
    );
  }
}
