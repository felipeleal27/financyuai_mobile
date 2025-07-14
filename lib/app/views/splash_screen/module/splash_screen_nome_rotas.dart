
/// Classe responsável por definir as rotas relacionadas à Splash Screen.
/// 
/// Contém todas as constantes de rotas usadas pelo módulo de splash screen,
/// incluindo URLs base e navegação.
class SplashScreenNomeRotas {
  /// Construtor privado para prevenir instanciação.
  const SplashScreenNomeRotas._();
  
  /// Rota base do módulo de splash screen.
  static const String modulo = "/splash_screen";
  
  /// Rota inicial da splash screen.
  static const String inicial = "/splash_screen_inicio";
  
  /// Rota completa para navegação para a splash screen.
  static const String navigate = "$modulo$inicial";
}