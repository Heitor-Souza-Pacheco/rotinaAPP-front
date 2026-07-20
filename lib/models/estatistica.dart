/// Estatísticas de um hábito (GET /api/habitos/{id}/estatisticas).
class Estatistica {
  final String habitoId;
  final String titulo;
  final int streakAtual;
  final int maiorStreak;
  final double taxaSemana; // 0..100
  final double taxaMes; // 0..100
  final int totalDiasConcluidos;

  Estatistica({
    required this.habitoId,
    required this.titulo,
    required this.streakAtual,
    required this.maiorStreak,
    required this.taxaSemana,
    required this.taxaMes,
    required this.totalDiasConcluidos,
  });

  factory Estatistica.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
    int toInt(dynamic v) => (v as num?)?.toInt() ?? 0;
    return Estatistica(
      habitoId: json['habitoId']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      streakAtual: toInt(json['streakAtual']),
      maiorStreak: toInt(json['maiorStreak']),
      taxaSemana: toDouble(json['taxaSemana']),
      taxaMes: toDouble(json['taxaMes']),
      totalDiasConcluidos: toInt(json['totalDiasConcluidos']),
    );
  }
}
