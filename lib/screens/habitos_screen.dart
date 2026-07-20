import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/habito.dart';
import '../providers/habitos_provider.dart';
import '../widgets/status_views.dart';
import 'estatisticas_screen.dart';
import 'habito_form_sheet.dart';

class HabitosScreen extends StatefulWidget {
  const HabitosScreen({super.key});

  @override
  State<HabitosScreen> createState() => _HabitosScreenState();
}

class _HabitosScreenState extends State<HabitosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitosProvider>().carregarTodos();
    });
  }

  Future<void> _confirmarExclusao(Habito habito) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir hábito?'),
        content: Text(
          'O hábito "${habito.titulo}" e todo o seu histórico serão removidos. '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    try {
      await context.read<HabitosProvider>().deletar(habito.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hábito excluído.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _alternarAtivo(Habito habito, bool ativo) async {
    try {
      await context
          .read<HabitosProvider>()
          .editar(habito.id, ativo: ativo);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitosProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus hábitos'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => HabitoFormSheet.mostrar(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo hábito'),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(HabitosProvider provider) {
    if (provider.loadingTodos && provider.todos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.erroTodos != null && provider.todos.isEmpty) {
      return ErrorStateView(
        message: provider.erroTodos!,
        onRetry: provider.carregarTodos,
      );
    }
    if (provider.todos.isEmpty) {
      return EmptyState(
        icon: Icons.auto_awesome_rounded,
        title: 'Crie seu primeiro hábito',
        message:
            'Hábitos ajudam você a construir uma rotina saudável, um dia de cada vez.',
        actionLabel: 'Criar hábito',
        onAction: () => HabitoFormSheet.mostrar(context),
      );
    }

    final ativos = provider.todos.where((h) => h.ativo).toList();
    final inativos = provider.todos.where((h) => !h.ativo).toList();

    return RefreshIndicator(
      onRefresh: provider.carregarTodos,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (ativos.isNotEmpty) ...[
            _sectionLabel('Ativos', ativos.length),
            ...ativos.map(_card),
          ],
          if (inativos.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionLabel('Pausados', inativos.length),
            ...inativos.map(_card),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _card(Habito habito) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EstatisticasScreen(
                habitoId: habito.id,
                titulo: habito.titulo,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: habito.ativo ? AppColors.primaryGradient : null,
                    color: habito.ativo ? null : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    habito.ativo
                        ? Icons.local_fire_department_rounded
                        : Icons.pause_rounded,
                    color: habito.ativo ? Colors.white : AppColors.textFaint,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habito.titulo,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                      if (habito.descricao != null &&
                          habito.descricao!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          habito.descricao!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) {
                    switch (value) {
                      case 'editar':
                        HabitoFormSheet.mostrar(context, habito: habito);
                        break;
                      case 'ativar':
                        _alternarAtivo(habito, !habito.ativo);
                        break;
                      case 'excluir':
                        _confirmarExclusao(habito);
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 10),
                        Text('Editar'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'ativar',
                      child: Row(children: [
                        Icon(
                            habito.ativo
                                ? Icons.pause_circle_outline_rounded
                                : Icons.play_circle_outline_rounded,
                            size: 20),
                        const SizedBox(width: 10),
                        Text(habito.ativo ? 'Pausar' : 'Reativar'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'excluir',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 20, color: AppColors.danger),
                        SizedBox(width: 10),
                        Text('Excluir',
                            style: TextStyle(color: AppColors.danger)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
