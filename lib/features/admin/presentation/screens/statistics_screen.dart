import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../controllers/admin_controller.dart';

final _topDentistsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(adminRepositoryProvider).getTopDentists(3);
});

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final monthlyAsync = ref.watch(monthlyStatsProvider);
    final topDentistsAsync = ref.watch(_topDentistsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statistics)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(monthlyStatsProvider);
          ref.invalidate(_topDentistsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Overall stats cards row
            statsAsync.when(
              data: (stats) => Row(
                children: [
                  _MiniStatCard(
                    label: l10n.totalAppointments,
                    value: '${stats['total'] ?? 0}',
                    color: AppColors.primary,
                    icon: Icons.calendar_month,
                  ),
                  const SizedBox(width: 12),
                  _MiniStatCard(
                    label: l10n.completedAppointments,
                    value: '${stats['completed'] ?? 0}',
                    color: AppColors.statusCompleted,
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
              loading: () => const SizedBox(height: 80, child: LoadingWidget()),
              error: (e, _) => AppErrorWidget(message: e.toString()),
            ),
            const SizedBox(height: 24),

            // Monthly appointments line chart
            Text(
              l10n.appointmentsPerMonth,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            monthlyAsync.when(
              data: (monthly) => _AppointmentsLineChart(monthly: monthly),
              loading: () =>
                  const SizedBox(height: 220, child: LoadingWidget()),
              error: (e, _) => AppErrorWidget(message: e.toString()),
            ),
            const SizedBox(height: 24),

            // Status distribution pie chart (aggregate from monthly data)
            Text(
              l10n.appointmentsByStatus,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            monthlyAsync.when(
              data: (monthly) {
                final aggregated = <String, int>{};
                for (final month in monthly.values) {
                  month.forEach((status, count) {
                    aggregated[status.toLowerCase()] =
                        (aggregated[status.toLowerCase()] ?? 0) + count;
                  });
                }
                return _StatusPieChart(stats: aggregated);
              },
              loading: () =>
                  const SizedBox(height: 220, child: LoadingWidget()),
              error: (e, _) => AppErrorWidget(message: e.toString()),
            ),
            const SizedBox(height: 24),

            // Top 3 dentists
            Text(
              l10n.topDentists,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            topDentistsAsync.when(
              data: (dentists) => _TopDentistsList(dentists: dentists),
              loading: () =>
                  const SizedBox(height: 120, child: LoadingWidget()),
              error: (e, _) => AppErrorWidget(message: e.toString()),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsLineChart extends StatelessWidget {
  const _AppointmentsLineChart({required this.monthly});

  final Map<String, Map<String, int>> monthly;

  @override
  Widget build(BuildContext context) {
    if (monthly.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No data available')),
      );
    }

    final months = monthly.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (int i = 0; i < months.length; i++) {
      final total = monthly[months[i]]?.values.fold(0, (a, b) => a + b) ?? 0;
      spots.add(FlSpot(i.toDouble(), total.toDouble()));
    }

    final maxY = spots.isEmpty
        ? 10.0
        : (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2)
            .ceilToDouble();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= months.length) {
                    return const SizedBox();
                  }
                  final label = months[idx].length >= 7
                      ? months[idx].substring(5, 7)
                      : months[idx];
                  return Text(label,
                      style: const TextStyle(fontSize: 10));
                },
                reservedSize: 24,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPieChart extends StatefulWidget {
  const _StatusPieChart({required this.stats});

  final Map<String, int> stats;

  @override
  State<_StatusPieChart> createState() => _StatusPieChartState();
}

class _StatusPieChartState extends State<_StatusPieChart> {
  int _touchedIndex = -1;

  static const _statusColors = {
    'pending': AppColors.statusPending,
    'approved': AppColors.statusApproved,
    'completed': AppColors.statusCompleted,
    'rejected': AppColors.statusRejected,
    'cancelled': AppColors.statusCancelled,
  };

  @override
  Widget build(BuildContext context) {
    final statusKeys = [
      AppConstants.statusPending,
      AppConstants.statusApproved,
      AppConstants.statusCompleted,
      AppConstants.statusRejected,
      AppConstants.statusCancelled,
    ];

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < statusKeys.length; i++) {
      final key = statusKeys[i];
      final count = widget.stats[key.toLowerCase()] ?? 0;
      if (count == 0) continue;
      final isTouched = i == _touchedIndex;
      final color =
          _statusColors[key.toLowerCase()] ?? AppColors.textSecondary;
      sections.add(PieChartSectionData(
        color: color,
        value: count.toDouble(),
        title: count.toString(),
        radius: isTouched ? 70 : 58,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }

    if (sections.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No appointment data')),
      );
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final key in statusKeys) ...[
                if ((widget.stats[key.toLowerCase()] ?? 0) > 0) ...[
                  _LegendItem(
                    color: _statusColors[key.toLowerCase()] ??
                        AppColors.textSecondary,
                    label: key,
                    count: widget.stats[key.toLowerCase()] ?? 0,
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

class _TopDentistsList extends StatelessWidget {
  const _TopDentistsList({required this.dentists});

  final List<Map<String, dynamic>> dentists;

  @override
  Widget build(BuildContext context) {
    if (dentists.isEmpty) {
      return const Center(child: Text('No dentists found'));
    }
    return Column(
      children: List.generate(dentists.length, (index) {
        final d = dentists[index];
        final rating = (d['averageRating'] as num?)?.toDouble() ?? 0.0;
        final reviews = d['totalReviews'] as int? ?? 0;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: _rankColor(index).withValues(alpha: 0.15),
              child: Text(
                '#${index + 1}',
                style: TextStyle(
                  color: _rankColor(index),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            title: Text(d['name'] as String? ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(d['specialization'] as String? ?? ''),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  '$reviews reviews',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Color _rankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700);
      case 1:
        return const Color(0xFFC0C0C0);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primary;
    }
  }
}
