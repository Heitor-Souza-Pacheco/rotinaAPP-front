import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/estatistica.dart';
import '../providers/habitos_provider.dart';
import '../widgets/progress_ring.dart';
import '../widgets/status_views.dart';

class EstatisticasScreen extends StatefulWidget {
  final String habitoId;
  final String titulo;

  const EstatisticasScreen({
    super.key,
    required this.habitoId,
    required this.titulo,
  });

  @override
  State<EstatisticasScreen> createState() => _EstatisticasScreenState();
}

class _EstatisticasScreenState extends State<EstatisticasScreen> {
  late Future<Estatistica> _future;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _future =
        context.read<HabitosProvider>().carregarEstatistica(widget.habitoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: FutureBuilder<Estatistica>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorStateView(
              message: snapshot.error.toString(),
              onRetry: () => setState(_carregar),
            );
          }
          final stats = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(_carregar);
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Text(stats.titulo.isEmpty ? widget.titulo : stats.titulo,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                _StreakBanner(stats: stats),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.emoji_events_rounded,
                        color: AppColors.amber,
                        value: '${stats.maiorStreak}',
                        label: 'Maior sequência',
                        suffix: 'dias',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.check_circle_rounded,
                        color: AppColors.accent,
                        value: '${stats.totalDiasConcluidos}',
                        label: 'Total concluído',
                        suffix: 'dias',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Taxa de conclusão',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _RateCard(
                  label: 'Últimos 7 dias',
                  percent: stats.taxaSemana,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _RateCard(
                  label: 'Últimos 30 dias',
                  percent: stats.taxaMes,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 24),
                Text('Comparativo',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _BarChartCard(stats: stats),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  final Estatistica stats;
  const _StreakBanner({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.coral, AppColors.amber],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.coral.withValues(alpha: 0.3),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 44)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.streakAtual} ${stats.streakAtual == 1 ? "dia" : "dias"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'sequência atual',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String suffix;

  const _MetricCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(width: 4),
              Text(suffix,
                  style: const TextStyle(color: AppColors.textFaint)),
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  final String label;
  final double percent; // 0..100
  final Color color;

  const _RateCard({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text('${percent.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: color, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgress(value: percent / 100, color: color, height: 10),
        ],
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  final Estatistica stats;
  const _BarChartCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final dados = [
      ('7 dias', stats.taxaSemana, AppColors.primary),
      ('30 dias', stats.taxaMes, AppColors.secondary),
    ];
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: BarChart(
        BarChartData(
          maxY: 100,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppColors.divider, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 34,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                      color: AppColors.textFaint, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= dados.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(dados[i].$1,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < dados.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: dados[i].$2,
                    width: 34,
                    color: dados[i].$3,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
