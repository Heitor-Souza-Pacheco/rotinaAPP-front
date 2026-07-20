import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'config.dart';
import 'token_storage.dart';

/// Cliente HTTP central: injeta o token JWT, trata erros e desserializa JSON.
class ApiClient {
  final http.Client _http;
  final TokenStorage _tokenStorage;

  /// Callback disparado quando a API responde 401/403 (sessão expirada).
  void Function()? onUnauthorized;

  ApiClient({http.Client? httpClient, TokenStorage? tokenStorage})
      : _http = httpClient ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse('${AppConfig.apiBaseUrl}$path');
    if (query == null) return base;
    return base.replace(
      queryParameters: query.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await _tokenStorage.read();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    return _send(() async => _http
        .get(_uri(path, query), headers: await _headers(auth: auth))
        .timeout(AppConfig.requestTimeout));
  }

  Future<dynamic> post(String path,
      {Object? body, Map<String, dynamic>? query, bool auth = true}) async {
    return _send(() async => _http
        .post(_uri(path, query),
            headers: await _headers(auth: auth),
            body: body == null ? null : jsonEncode(body))
        .timeout(AppConfig.requestTimeout));
  }

  Future<dynamic> put(String path,
      {Object? body, Map<String, dynamic>? query, bool auth = true}) async {
    return _send(() async => _http
        .put(_uri(path, query),
            headers: await _headers(auth: auth),
            body: body == null ? null : jsonEncode(body))
        .timeout(AppConfig.requestTimeout));
  }

  Future<dynamic> delete(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    return _send(() async => _http
        .delete(_uri(path, query), headers: await _headers(auth: auth))
        .timeout(AppConfig.requestTimeout));
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    http.Response response;
    try {
      response = await request();
    } on Exception {
      throw ApiException(
        'Não foi possível conectar ao servidor. Verifique sua conexão.',
      );
    }

    final status = response.statusCode;
    final bodyText = utf8.decode(response.bodyBytes);
    final dynamic decoded = bodyText.isEmpty ? null : _tryDecode(bodyText);

    if (status >= 200 && status < 300) {
      return decoded;
    }

    if (status == 401 || status == 403) {
      onUnauthorized?.call();
    }

    throw _buildException(status, decoded);
  }

  dynamic _tryDecode(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      return text;
    }
  }

  ApiException _buildException(int status, dynamic decoded) {
    String message = 'Ocorreu um erro (código $status).';
    Map<String, String>? fieldErrors;
    var temMensagem = false;

    if (decoded is Map<String, dynamic>) {
      if (decoded['erro'] is String) {
        message = decoded['erro'] as String;
        temMensagem = true;
      } else if (decoded['message'] is String) {
        message = decoded['message'] as String;
        temMensagem = true;
      }
      if (decoded['campos'] is Map) {
        fieldErrors = (decoded['campos'] as Map)
            .map((k, v) => MapEntry(k.toString(), v.toString()));
        if (fieldErrors.isNotEmpty) {
          message = fieldErrors.values.first;
          temMensagem = true;
        }
      }
    }

    // Só usa a mensagem genérica de sessão quando o servidor não detalhou o erro
    // (ex.: token expirado numa chamada autenticada, sem corpo).
    if (status == 401 && !temMensagem) {
      message = 'Sessão expirada. Entre novamente.';
    }

    return ApiException(message,
        statusCode: status, fieldErrors: fieldErrors);
  }
}
