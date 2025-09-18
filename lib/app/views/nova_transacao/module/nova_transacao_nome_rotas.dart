/// Classe responsável por definir as rotas relacionadas à Nova Transação.
/// 
/// Contém todas as constantes de rotas usadas pelo módulo Nova Transação,
/// incluindo URLs base e navegação.
class NovaTransacaoNomeRotas {
  /// Construtor privado para prevenir instanciação.
  const NovaTransacaoNomeRotas._();
  
  /// Rota base do módulo Nova Transação.
  static const String modulo = '/nova-transacao';
  
  /// Rota para nova receita.
  static const String receita = '/receita';
  
  /// Rota para nova despesa.
  static const String despesa = '/despesa';
  
  /// Rota completa para navegação para nova receita.
  static const String navigateReceita = '$modulo$receita';
  
  /// Rota completa para navegação para nova despesa.
  static const String navigateDespesa = '$modulo$despesa';
}