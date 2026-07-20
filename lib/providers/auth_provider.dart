import 'package:flutter/foundation.dart';

import '../core/api_exception.dart';
import '../core/token_storage.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Gerencia o estado de autenticação e o token da sessão.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthProvider(this._authService, this._tokenStorage);

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  bool _loading = false;
  bool get loading => _loading;

  /// Verifica se já existe um token salvo (chamado na inicialização).
  Future<void> init() async {
    final token = await _tokenStorage.read();
    _status = (token != null && token.isNotEmpty)
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> login(String email, String senha) async {
    _setLoading(true);
    try {
      await _authService.login(email: email, senha: senha);
      _status = AuthStatus.authenticated;
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> registrar(String nome, String email, String senha) async {
    _setLoading(true);
    try {
      await _authService.registrar(nome: nome, email: email, senha: senha);
      _status = AuthStatus.authenticated;
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Chamado pelo ApiClient quando a sessão expira (401/403).
  void onSessionExpired() {
    if (_status == AuthStatus.authenticated) {
      _tokenStorage.clear();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  String messageFor(Object error) {
    if (error is ApiException) return error.message;
    return 'Algo deu errado. Tente novamente.';
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
