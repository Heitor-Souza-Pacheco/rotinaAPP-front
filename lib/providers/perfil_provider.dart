import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/perfil_service.dart';

/// Estado do perfil do usuário.
class PerfilProvider extends ChangeNotifier {
  final PerfilService _service;
  PerfilProvider(this._service);

  Usuario? _usuario;
  Usuario? get usuario => _usuario;

  bool _loading = false;
  bool get loading => _loading;

  bool _saving = false;
  bool get saving => _saving;

  String? _erro;
  String? get erro => _erro;

  Future<void> carregar() async {
    if (_loading) return;
    _loading = true;
    _erro = null;
    notifyListeners();
    try {
      _usuario = await _service.verPerfil();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> atualizar({
    String? fusoHorario,
    TimeOfDay? horarioReset,
    TimeOfDay? horarioNotificacao,
  }) async {
    _saving = true;
    notifyListeners();
    try {
      _usuario = await _service.atualizar(
        fusoHorario: fusoHorario,
        horarioReset: horarioReset,
        horarioNotificacao: horarioNotificacao,
      );
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  void limpar() {
    _usuario = null;
    _erro = null;
    notifyListeners();
  }
}
