// ignore_for_file: constant_identifier_names

/// Classe que centraliza todas as constantes do aplicativo
/// 
/// Contém as chaves para variáveis de ambiente e outras
/// constantes utilizadas ao longo da aplicação.
class Constants {
  // Construtor privado para evitar instanciação
  Constants._();

  /// Chave para URL base da API
  static const ENV_BASE_URL_KEY = 'base_url';
  
  /// Chave para URL base local da API
  static const ENV_BASE_URL_LOCAL_KEY = 'base_url_local';
  
  /// Chave para timeout de conexão do cliente REST
  static const ENV_REST_CLIENT_CONNECT_TIMEOUT_KEY = 'rest_client_connect_timeout';
  
  /// Chave para timeout de recebimento do cliente REST
  static const ENV_REST_CLIENT_RECEIVE_TIMEOUT_KEY = 'rest_client_receive_timeout';
  
  /// Chave para token de autenticação
  static const ENV_TOKEM = 'token';
}