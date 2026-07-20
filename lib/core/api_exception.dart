/// Exceção padronizada para erros vindos da API ou de rede.
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  /// Mapa de erros de validação por campo (quando status 400 com `campos`).
  final Map<String, String>? fieldErrors;

  ApiException(this.message, {this.statusCode, this.fieldErrors});

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;
}
