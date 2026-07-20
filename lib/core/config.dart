/// Configurações globais do aplicativo.
class AppConfig {
  AppConfig._();

  /// URL base da API (backend Spring Boot hospedado no Railway).
  static const String apiBaseUrl =
      'https://approtina-api-production.up.railway.app';

  /// Timeout padrão das requisições HTTP.
  static const Duration requestTimeout = Duration(seconds: 30);
}
