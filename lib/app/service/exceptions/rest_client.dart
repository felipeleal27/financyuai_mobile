import 'package:neo_financyuai/app/service/exceptions/rest_client_response.dart';

/// Interface abstrata para clientes REST
abstract class RestClient {
  /// Adiciona autenticação padrão às requisições
  RestClient auth();
  
  /// Adiciona autenticação com senha personalizada
  RestClient authAndSenha(String codCliente);
  
  /// Remove autenticação das requisições
  RestClient unauth();
  
  /// Adiciona cabeçalho personalizado
  RestClient addHeader(String key, dynamic value);

  Future<RestClientResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  });

  Future<RestClientResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  });

  Future<RestClientResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  });

  Future<RestClientResponse<T>> detele<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  });

  Future<RestClientResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  });

  Future<RestClientResponse<T>> resquest<T>(
    String path, {
    required String method,
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  });
}
