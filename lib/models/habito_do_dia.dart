/// Hábito no contexto de um dia específico (GET /api/habitos/hoje).
class HabitoDoDia {
  final String id;
  final String titulo;
  final String? descricao;
  final bool concluido;

  HabitoDoDia({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.concluido,
  });

  factory HabitoDoDia.fromJson(Map<String, dynamic> json) {
    return HabitoDoDia(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descricao: json['descricao']?.toString(),
      concluido: json['concluido'] as bool? ?? false,
    );
  }

  HabitoDoDia copyWith({bool? concluido}) => HabitoDoDia(
        id: id,
        titulo: titulo,
        descricao: descricao,
        concluido: concluido ?? this.concluido,
      );
}
