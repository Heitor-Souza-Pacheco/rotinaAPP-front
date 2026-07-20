import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/habito_do_dia.dart';
import '../providers/habitos_provider.dart';
import '../providers/perfil_provider.dart';
import '../widgets/progress_ring.dart';
import '../widgets/status_views.dart';
import 'estatisticas_screen.dart';

class HojeScreen extends StatefulWidget {
  final VoidCallback? onIrParaHabitos;
  const HojeScreen({super.key, this.onIrParaHabitos});

  @override
  State<HojeScreen> createState() => _HojeScreenState();
}

class _HojeScreenState extends State<HojeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitosProvider>().carregarDia();
    });
  }

  String get _saudacao {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitosProvider>();
    final nome = context.watch<PerfilProvider>().usuario?.nome;
    final primeiroNome = (nome != null && nome.trim().isNotEmpty)
        ? nome.trim().split(' ').first
        : null;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: provider.carregarDia,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Text(
                    primeiroNome == null
                        ? '$_saudacao 👋'
                        : '$_saudacao, $primeiroNome 👋',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _HeaderCard(provider: provider)),
              SliverToBoxAdapter(child: _WeekStrip(provider: provider)),
              _buildBody(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(HabitosProvider provider) {
    if (provider.loadingDia && provider.doDia.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.erroDia != null && provider.doDia.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorStateView(
          message: provider.erroDia!,
          onRetry: provider.carregarDia,
        ),
      );
    }
    if (provider.doDia.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.checklist_rounded,
          title: 'Nenhum hábito por aqui',
          message:
              'Comece criando um hábito para acompanhar sua rotina todos os dias.',
          actionLabel: 'Criar hábito',
          onAction: widget.onIrParaHabitos,
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverList.separated(
        itemCount: provider.doDia.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final habito = provider.doDia[i];
          return _HabitoDoDiaCard(
            habito: habito,
            onToggle: () => _toggle(provider, habito),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EstatisticasScreen(
                  habitoId: habito.id,
                  titulo: habito.titulo,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggle(HabitosProvider provider, HabitoDoDia habito) async {
    try {
      await provider.alternarConclusao(habito);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final HabitosProvider provider;
  const _HeaderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final total = provider.totalDia;
    final concluidos = provider.concluidosDia;
    final restantes = total - concluidos;
    final tudoFeito = total > 0 && restantes == 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tudoFeito
                      ? 'Tudo em dia! 🎉'
                      : total == 0
                          ? 'Sem hábitos hoje'
                          : 'Você consegue!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  total == 0
                      ? 'Adicione hábitos para acompanhar.'
                      : tudoFeito
                          ? 'Você concluiu todos os hábitos do dia.'
                          : 'Faltam $restantes de $total hábitos.',
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ProgressRing(
            progress: provider.progressoDia,
            concluidos: concluidos,
            total: total,
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final HabitosProvider provider;
  const _WeekStrip({required this.provider});

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    // 7 dias terminando em hoje.
    final dias = List.generate(7, (i) {
      final d = hoje.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });
    final sel = provider.dataSelecionada;

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        itemCount: dias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final d = dias[i];
          final selecionado = d.year == sel.year &&
              d.month == sel.month &&
              d.day == sel.day;
          final ehHoje = d.year == hoje.year &&
              d.month == hoje.month &&
              d.day == hoje.day;
          final diaSemana =
              DateFormat.E('pt_BR').format(d).replaceAll('.', '');
          return GestureDetector(
            onTap: () => provider.selecionarData(d),
            child: Container(
              width: 54,
              decoration: BoxDecoration(
                gradient: selecionado ? AppColors.primaryGradient : null,
                color: selecionado ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selecionado ? Colors.transparent : AppColors.divider,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    diaSemana.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selecionado
                          ? Colors.white70
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color:
                          selecionado ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ehHoje
                          ? (selecionado ? Colors.white : AppColors.primary)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HabitoDoDiaCard extends StatelessWidget {
  final HabitoDoDia habito;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _HabitoDoDiaCard({
    required this.habito,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final concluido = habito.concluido;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: concluido ? AppColors.accentGradient : null,
                    color: concluido ? null : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          concluido ? Colors.transparent : AppColors.textFaint,
                      width: 2,
                    ),
                  ),
                  child: concluido
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 20)
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habito.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: concluido
                            ? AppColors.textFaint
                            : AppColors.textPrimary,
                        decoration: concluido
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (habito.descricao != null &&
                        habito.descricao!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        habito.descricao!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}
