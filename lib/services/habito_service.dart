import 'package:intl/intl.dart';

import '../core/api_client.dart';
import '../models/estatistica.dart';
import '../models/habito.dart';
import '../models/habito_do_dia.dart';

/// Operações de hábitos e registros diários (/api/habitos).
class HabitoService {
  final ApiClient _api;
  HabitoService(this._api);

  static final DateFormat _fmt = DateFormat('yyyy-MM-dd');
  static String fmtData(DateTime d) => _fmt.format(d);

  Future<List<HabitoDoDia>> listarDoDia(DateTime data) async {
    final result = await _api.get('/api/habitos/hoje',
        query: {'data': fmtData(data)});
    return (result as List)
        .map((e) => HabitoDoDia.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Habito>> listarTodos() async {
    final result = await _api.get('/api/habitos');
    return (result as List)
        .map((e) => Habito.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Habito> criar({required String titulo, String? descricao}) async {
    final result = await _api.post('/api/habitos', body: {
      'titulo': titulo,
      if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
    });
    return Habito.fromJson(result as Map<String, dynamic>);
  }

  Future<Habito> editar(
    String habitoId, {
    String? titulo,
    String? descricao,
    bool? ativo,
  }) async {
    final result = await _api.put('/api/habitos/$habitoId', body: {
      if (titulo != null) 'titulo': titulo,
      if (descricao != null) 'descricao': descricao,
      if (ativo != null) 'ativo': ativo,
    });
    return Habito.fromJson(result as Map<String, dynamic>);
  }

  Future<void> deletar(String habitoId) =>
      _api.delete('/api/habitos/$habitoId');

  Future<void> marcarConcluido(String habitoId, DateTime data) => _api.post(
        '/api/habitos/$habitoId/concluir',
        query: {'data': fmtData(data)},
      );

  Future<void> desmarcar(String habitoId, DateTime data) => _api.delete(
        '/api/habitos/$habitoId/concluir',
        query: {'data': fmtData(data)},
      );

  Future<Estatistica> estatisticas(String habitoId) async {
    final result = await _api.get('/api/habitos/$habitoId/estatisticas');
    return Estatistica.fromJson(result as Map<String, dynamic>);
  }
}
