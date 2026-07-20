import 'package:flutter/foundation.dart';

import '../models/estatistica.dart';
import '../models/habito.dart';
import '../models/habito_do_dia.dart';
import '../services/habito_service.dart';

/// Estado dos hábitos do dia selecionado e da lista completa.
class HabitosProvider extends ChangeNotifier {
  final HabitoService _service;
  HabitosProvider(this._service);

  // ----- Data selecionada (tela Hoje) -----
  DateTime _dataSelecionada = _hoje();
  DateTime get dataSelecionada => _dataSelecionada;

  static DateTime _hoje() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool get isHoje {
    final h = _hoje();
    return _dataSelecionada.year == h.year &&
        _dataSelecionada.month == h.month &&
        _dataSelecionada.day == h.day;
  }

  // ----- Hábitos do dia -----
  List<HabitoDoDia> _doDia = [];
  List<HabitoDoDia> get doDia => List.unmodifiable(_doDia);
  bool _loadingDia = false;
  bool get loadingDia => _loadingDia;
  String? _erroDia;
  String? get erroDia => _erroDia;

  int get totalDia => _doDia.length;
  int get concluidosDia => _doDia.where((h) => h.concluido).length;
  double get progressoDia =>
      _doDia.isEmpty ? 0 : concluidosDia / _doDia.length;

  // ----- Lista completa (gerenciar) -----
  List<Habito> _todos = [];
  List<Habito> get todos => List.unmodifiable(_todos);
  bool _loadingTodos = false;
  bool get loadingTodos => _loadingTodos;
  String? _erroTodos;
  String? get erroTodos => _erroTodos;

  Future<void> selecionarData(DateTime data) async {
    _dataSelecionada = DateTime(data.year, data.month, data.day);
    notifyListeners();
    await carregarDia();
  }

  Future<void> irParaHoje() => selecionarData(_hoje());

  Future<void> carregarDia() async {
    _loadingDia = true;
    _erroDia = null;
    notifyListeners();
    try {
      _doDia = await _service.listarDoDia(_dataSelecionada);
    } catch (e) {
      _erroDia = e.toString();
    } finally {
      _loadingDia = false;
      notifyListeners();
    }
  }

  /// Alterna o status de conclusão com atualização otimista.
  Future<void> alternarConclusao(HabitoDoDia habito) async {
    final index = _doDia.indexWhere((h) => h.id == habito.id);
    if (index == -1) return;
    final novoValor = !habito.concluido;

    _doDia[index] = habito.copyWith(concluido: novoValor);
    notifyListeners();

    try {
      if (novoValor) {
        await _service.marcarConcluido(habito.id, _dataSelecionada);
      } else {
        await _service.desmarcar(habito.id, _dataSelecionada);
      }
    } catch (e) {
      // Reverte em caso de falha.
      _doDia[index] = habito.copyWith(concluido: !novoValor);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> carregarTodos() async {
    if (_loadingTodos) return;
    _loadingTodos = true;
    _erroTodos = null;
    notifyListeners();
    try {
      _todos = await _service.listarTodos();
    } catch (e) {
      _erroTodos = e.toString();
    } finally {
      _loadingTodos = false;
      notifyListeners();
    }
  }

  Future<void> criar(String titulo, String? descricao) async {
    await _service.criar(titulo: titulo, descricao: descricao);
    await Future.wait([carregarTodos(), carregarDia()]);
  }

  Future<void> editar(String id,
      {String? titulo, String? descricao, bool? ativo}) async {
    await _service.editar(id,
        titulo: titulo, descricao: descricao, ativo: ativo);
    await Future.wait([carregarTodos(), carregarDia()]);
  }

  Future<void> deletar(String id) async {
    await _service.deletar(id);
    await Future.wait([carregarTodos(), carregarDia()]);
  }

  Future<Estatistica> carregarEstatistica(String id) =>
      _service.estatisticas(id);

  /// Limpa o estado ao fazer logout.
  void limpar() {
    _doDia = [];
    _todos = [];
    _dataSelecionada = _hoje();
    _erroDia = null;
    _erroTodos = null;
    notifyListeners();
  }
}
