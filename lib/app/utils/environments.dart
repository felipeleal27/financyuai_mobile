import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Classe utilitária para gerenciar variáveis de ambiente
/// 
/// Fornece métodos para:
/// - Carregar variáveis de ambiente do arquivo .env
/// - Acessar parâmetros de configuração de forma segura
/// - Centralizar o acesso a configurações do ambiente
class Environments {
  // Construtor privado para evitar instanciação
  Environments._();

  /// Obtém o valor de um parâmetro de ambiente
  /// 
  /// [paramName] Nome do parâmetro a ser buscado
  /// Retorna null se o parâmetro não existir
  static String? param(String paramName) {
    return dotenv.env[paramName];
  }

  /// Carrega as variáveis de ambiente do arquivo .env
  /// 
  /// Deve ser chamado antes de acessar qualquer parâmetro
  static Future<void> loadEnvs() async {
    await dotenv.load(fileName: ".env");
  }
}