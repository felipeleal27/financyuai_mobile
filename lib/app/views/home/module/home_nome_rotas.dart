/// Classe responsável por definir as rotas relacionadas à Home.
/// 
/// Contém todas as constantes de rotas usadas pelo módulo Home,
/// incluindo URLs base e navegação.
class HomeNomeRotas {
  /// Construtor privado para prevenir instanciação.
  const HomeNomeRotas._();
  
  /// Rota base do módulo Home.
  static const String modulo = '/home';
  
  /// Rota inicial da Home.
  static const String inicial = '/inicial';
  
  /// Rota completa para navegação para a Home.
  static const String navigate = '$modulo$inicial';
}