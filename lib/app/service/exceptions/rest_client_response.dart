/// Representa uma resposta de requisição HTTP
class RestClientResponse<T> {
  final T? _data;
  final int? _statusCode;
  final String? _statusMessage;

  /// Dados da resposta
  T? get data => _data;

  /// Código de status HTTP
  int? get statusCode => _statusCode;

  /// Mensagem de status HTTP
  String? get statusMessage => _statusMessage;
  
  const RestClientResponse({
    T? data,
    int? statusCode,
    String? statusMessage,
  }) : _data = data,
       _statusCode = statusCode,
       _statusMessage = statusMessage;

  @override
  String toString() => 'RestClientResponse(statusCode: $_statusCode, statusMessage: $_statusMessage)';
}
