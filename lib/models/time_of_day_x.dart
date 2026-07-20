import 'package:flutter/material.dart';

/// Utilitários para converter LocalTime (backend) <-> TimeOfDay (Flutter).
class TimeParsing {
  TimeParsing._();

  /// Aceita "HH:mm", "HH:mm:ss" ou lista [h, m]. Retorna null se vazio.
  static TimeOfDay? parse(dynamic value) {
    if (value == null) return null;
    if (value is List && value.length >= 2) {
      return TimeOfDay(
        hour: (value[0] as num).toInt(),
        minute: (value[1] as num).toInt(),
      );
    }
    final str = value.toString().trim();
    if (str.isEmpty) return null;
    final parts = str.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  /// Formata para "HH:mm:ss" (formato aceito pelo LocalTime do Spring).
  static String format(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  /// Exibição amigável "HH:mm".
  static String display(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
