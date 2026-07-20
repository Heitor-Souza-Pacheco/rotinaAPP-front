/// Hábito completo (endpoints GET /api/habitos, POST, PUT).
class Habito {
  final String id;
  final String titulo;
  final String? descricao;
  final bool ativo;

  Habito({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.ativo,
  });

  factory Habito.fromJson(Map<String, dynamic> json) {
    return Habito(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descricao: json['descricao']?.toString(),
      ativo: json['ativo'] as bool? ?? true,
    );
  }
}
