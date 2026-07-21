import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../models/time_of_day_x.dart';
import '../models/usuario.dart';

/// Perfil do usuário (/api/usuarios/perfil).
class PerfilService {
  final ApiClient _api;
  PerfilService(this._api);

  Future<Usuario> verPerfil() async {
    final result = await _api.get('/api/usuarios/perfil');
    return Usuario.fromJson(result as Map<String, dynamic>);
  }

  Future<Usuario> atualizar({
    String? fusoHorario,
    TimeOfDay? horarioReset,
    TimeOfDay? horarioNotificacao,
    String? fcmToken,
  }) async {
    final body = <String, dynamic>{
      'fusoHorario': ?fusoHorario,
      if (horarioReset != null) 'horarioReset': TimeParsing.format(horarioReset),
      if (horarioNotificacao != null)
        'horarioNotificacao': TimeParsing.format(horarioNotificacao),
      'fcmToken': ?fcmToken,
    };
    final result = await _api.put('/api/usuarios/perfil', body: body);
    return Usuario.fromJson(result as Map<String, dynamic>);
  }
}
