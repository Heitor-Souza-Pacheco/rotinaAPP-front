import 'package:flutter/material.dart';

import 'time_of_day_x.dart';

/// Representa o usuário autenticado (endpoint /api/usuarios/perfil).
class Usuario {
  final String id;
  final String nome;
  final String email;
  final String fusoHorario;
  final TimeOfDay? horarioReset;
  final TimeOfDay? horarioNotificacao;
  final String? fcmToken;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.fusoHorario,
    this.horarioReset,
    this.horarioNotificacao,
    this.fcmToken,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fusoHorario: json['fusoHorario']?.toString() ?? 'America/Sao_Paulo',
      horarioReset: TimeParsing.parse(json['horarioReset']),
      horarioNotificacao: TimeParsing.parse(json['horarioNotificacao']),
      fcmToken: json['fcmToken']?.toString(),
    );
  }
}
