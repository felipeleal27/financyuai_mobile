/// Classe responsável por definir as rotas do módulo Chat IA.
class ChatIANomeRotas {
  const ChatIANomeRotas._();

  /// Rota base do módulo Chat IA.
  static const String modulo = '/chat_ia';

  /// Rota inicial do módulo Chat IA.
  static const String inicial = '/chat_ia_inicio';

  /// Rota completa para navegação até a página de Chat IA.
  static const String navigate = '$modulo$inicial';
}
