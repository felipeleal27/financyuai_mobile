import 'package:neo_financyuai/app/service/exceptions/rest_client_response.dart';

/// Exceção customizada para requisições HTTP
class RestClienteException implements Exception {
  final String? _message;
  final int? _statusCode;
  final dynamic _error;
  final RestClientResponse _response;

  /// Mensagem de erro
  String? get message => _message;

  /// Código de status HTTP
  int? get statusCode => _statusCode;

  /// Erro original
  dynamic get error => _error;

  /// Resposta da requisição
  RestClientResponse get response => _response;

  const RestClienteException({
    String? message,
    int? statusCode,
    required dynamic error,
    required RestClientResponse response,
  }) : _message = message,
       _statusCode = statusCode,
       _error = error,
       _response = response;

  @override
  String toString() {
    return 'RestClienteException(message: $_message, statusCode: $_statusCode, error: $_error, response: $_response)';
  }
}
