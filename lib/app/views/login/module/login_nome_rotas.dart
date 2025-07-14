/// Classe responsável por definir as rotas relacionadas ao Login.
/// 
/// Contém todas as constantes de rotas usadas pelo módulo de autenticação,
/// incluindo URLs base e navegação.
class LoginNomeRotas {
  /// Construtor privado para prevenir instanciação.
  const LoginNomeRotas._();
  
  /// Rota base do módulo de autenticação.
  static const String modulo = "/autenticacao";
  
  /// Rota para a tela de login.
  static const String login = "/login";
  
  /// Rota completa para navegação para o login.
  static const String navigate = "$modulo$login";
}