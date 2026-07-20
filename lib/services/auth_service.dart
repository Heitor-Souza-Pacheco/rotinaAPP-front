import '../core/api_client.dart';
import '../core/token_storage.dart';

/// Autenticação: registro e login (endpoints públicos /api/auth/**).
class AuthService {
  final ApiClient _api;
  final TokenStorage _tokenStorage;

  AuthService(this._api, this._tokenStorage);

  Future<void> registrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final data = await _api.post(
      '/api/auth/registrar',
      auth: false,
      body: {'nome': nome, 'email': email, 'senha': senha},
    );
    await _persistToken(data);
  }

  Future<void> login({
    required String email,
    required String senha,
  }) async {
    final data = await _api.post(
      '/api/auth/login',
      auth: false,
      body: {'email': email, 'senha': senha},
    );
    await _persistToken(data);
  }

  Future<void> _persistToken(dynamic data) async {
    if (data is Map && data['token'] is String) {
      await _tokenStorage.save(data['token'] as String);
    } else {
      throw Exception('Resposta de autenticação inválida.');
    }
  }
}
