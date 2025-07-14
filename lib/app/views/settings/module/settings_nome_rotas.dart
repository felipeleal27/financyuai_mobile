/// Classe responsável por definir as rotas relacionadas às Configurações.
/// 
/// Contém todas as constantes de rotas usadas pelo módulo de configurações,
/// incluindo URLs base e navegação.
class SettingsNomeRotas {
  /// Construtor privado para prevenir instanciação.
  const SettingsNomeRotas._();
  
  /// Rota base do módulo de configurações.
  static const String modulo = "/settings";
  
  /// Rota inicial das configurações.
  static const String inicial = "/settings_inicio";
  
  /// Rota completa para navegação para as configurações.
  static const String navigate = "$modulo$inicial";
}
