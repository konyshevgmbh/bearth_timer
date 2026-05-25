import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../models/training_result.dart';
import '../services/history_service.dart';
import '../i18n/strings.g.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService _historyService = HistoryService();
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _setupHistoryListener();
    _loadResults();
  }

  void _setupHistoryListener() {
    _historyService.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadResults() async {
    await _historyService.loadResults();
  }

  List<DateTime> get _availableMonths {
    final months = <String, DateTime>{};
    for (final results in _historyService.resultsByExercise.values) {
      for (final r in results) {
        final key = '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}';
        months[key] = DateTime(r.date.year, r.date.month);
      }
    }
    return months.values.toList()..sort();
  }

  DateTime get _effectiveMonth {
    final months = _availableMonths;
    if (months.isEmpty) return DateTime.now();
    if (_selectedMonth != null) {
      final match = months.where(
        (m) => m.year == _selectedMonth!.year && m.month == _selectedMonth!.month,
      );
      if (match.isNotEmpty) return match.first;
    }
    return months.last;
  }

  @override
  void dispose() {
    _historyService.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.history),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        automaticallyImplyLeading: false,
        actions: [
          if (_historyService.hasResults) _buildDisplayModeToggle(),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _historyService.isLoading
          ? Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatsOverview(),
                  SizedBox(height: 24),
                  !_historyService.hasResults
                      ? _buildEmptyState()
                      : _buildExercisesSections(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsOverview() {
    if (!_historyService.hasResults) {
      return const SizedBox();
    }

    final stats = _historyService.calculateStats();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppLayout.spacingMedium,
            vertical: AppLayout.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Text(
            t.overview,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: AppLayout.fontSizeSmall,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: _buildStatItem(t.sessions, stats.totalSessions.toString())),
            Expanded(child: _buildStatItem(t.totalTime, t.secondsUnit(value: stats.totalScore))) ,
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: AppLayout.fontSizeMedium,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: AppLayout.fontSizeSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: AppLayout.fontSizeSmall,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: AppLayout.fontSizeSmall - 2,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          Text(
            t.noHistoryYet,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppLayout.fontSizeMedium,
            ),
          ),
          SizedBox(height: 8),
          Text(
            t.completeSessionToSeeProgress,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: AppLayout.fontSizeSmall,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  Widget _buildExercisesSections() {
    if (_historyService.resultsByExercise.isEmpty) {
      return _buildEmptyState();
    }

    final exerciseEntries = _historyService.resultsByExercise.entries.toList();

    return Column(
      children: [
        _buildMonthSelector(),
        const SizedBox(height: 8),
        ...exerciseEntries.map((entry) {
          final exerciseId = entry.key;
          final results = entry.value;
          final exerciseName = _historyService.getExerciseDisplayName(exerciseId);
          final exerciseColor = _historyService.getExerciseColor(exerciseId, Theme.of(context).colorScheme.primary);

          return Column(
            children: [
              _buildExerciseSection(exerciseName, results, exerciseColor),
              const SizedBox(height: 24),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildExerciseSection(String exerciseName, List<TrainingResult> results, Color exerciseColor) {
    // Get exercise ID to calculate stats
    final exerciseId = _historyService.resultsByExercise.entries
        .firstWhere((entry) => entry.value == results, orElse: () => MapEntry('', results))
        .key;
    final exerciseStats = _historyService.calculateStatsForExercise(exerciseId);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppLayout.spacingMedium,
            vertical: AppLayout.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 16,
                    decoration: BoxDecoration(
                      color: exerciseColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    exerciseName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: AppLayout.fontSizeSmall,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${results.length} ${t.sessions.toLowerCase()}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: AppLayout.fontSizeSmall - 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 18), // Align with exercise name
                  Expanded(child: _buildExerciseStatItem(t.dailyDurationDiff, '${exerciseStats.dailyDurationDiff > 0 ? '+' : ''}${t.secondsUnit(value: exerciseStats.dailyDurationDiff.toInt())}')),
                  Expanded(child: _buildExerciseStatItem(t.dailyCycleDiff, '${exerciseStats.dailyCycleDiff > 0 ? '+' : ''}${exerciseStats.dailyCycleDiff.toStringAsFixed(1)}')),
                  Expanded(child: _buildExerciseStatItem(t.bestScore, exerciseStats.bestScore.toString())),
                ],
              ),
            ],
          ),
        ),
        if (results.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.all(AppLayout.spacingMedium),
            child: SizedBox(
              height: 180,
              child: _buildExerciseChart(results, exerciseColor),
            ),
          ),
        ],
        _buildExerciseResultsList(results),
        SizedBox(height: AppLayout.spacingMedium), // Add spacing between sections
      ],
    );
  }

  Widget _buildExerciseChart(List<TrainingResult> results, Color exerciseColor) {
    final chartData = _prepareChartData(results);
    
    return _ExerciseLineChart(
      chartData: chartData,
      exerciseColor: exerciseColor,
    );
  }

  List<MapEntry<DateTime, TrainingResult?>> _prepareChartData(List<TrainingResult> results) {
    if (results.isEmpty) return [];

    final month = _effectiveMonth;
    final filtered = results.where(
      (r) => r.date.year == month.year && r.date.month == month.month,
    ).toList();

    if (filtered.isEmpty) return [];

    final resultsByDate = <String, TrainingResult>{};
    for (final result in filtered) {
      final dateKey = '${result.date.year}-${result.date.month.toString().padLeft(2, '0')}-${result.date.day.toString().padLeft(2, '0')}';
      final existing = resultsByDate[dateKey];
      if (existing == null || result.score > existing.score) {
        resultsByDate[dateKey] = result;
      }
    }

    final sorted = resultsByDate.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return sorted.map((r) => MapEntry(r.date, r as TrainingResult?)).toList();
  }

  Widget _buildMonthSelector() {
    final months = _availableMonths;
    if (months.isEmpty) return const SizedBox();

    final effective = _effectiveMonth;
    final idx = months.indexWhere(
      (m) => m.year == effective.year && m.month == effective.month,
    );
    final hasPrev = idx > 0;
    final hasNext = idx < months.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          color: hasPrev
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          onPressed: hasPrev
              ? () => setState(() => _selectedMonth = months[idx - 1])
              : null,
        ),
        Text(
          DateFormat('MMMM yyyy').format(effective),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: AppLayout.fontSizeMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          color: hasNext
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          onPressed: hasNext
              ? () => setState(() => _selectedMonth = months[idx + 1])
              : null,
        ),
      ],
    );
  }


  Widget _buildDisplayModeToggle() {
    return PopupMenuButton<HistoryDisplayMode>(
      icon: Icon(
        _historyService.displayMode == HistoryDisplayMode.bestPerDay 
            ? Icons.filter_list 
            : Icons.list,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onSelected: (mode) async {
        await _historyService.setDisplayMode(mode);
      },
      itemBuilder: (context) => [
        PopupMenuItem<HistoryDisplayMode>(
          value: HistoryDisplayMode.bestPerDay,
          child: Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 20,
                color: _historyService.displayMode == HistoryDisplayMode.bestPerDay
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 12),
              Text(
                'Best per day',
                style: TextStyle(
                  color: _historyService.displayMode == HistoryDisplayMode.bestPerDay
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<HistoryDisplayMode>(
          value: HistoryDisplayMode.allResults,
          child: Row(
            children: [
              Icon(
                Icons.list,
                size: 20,
                color: _historyService.displayMode == HistoryDisplayMode.allResults
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 12),
              Text(
                'All results',
                style: TextStyle(
                  color: _historyService.displayMode == HistoryDisplayMode.allResults
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseResultsList(List<TrainingResult> results) {
    final displayCount = _historyService.displayMode == HistoryDisplayMode.bestPerDay ? 5 : 10;
    return Column(
      children: results.take(displayCount).map((result) { // Show more results for all results mode
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: AppLayout.spacingMedium, vertical: 4),
          title: Text(
            t.cyclesAndDuration(cycles: result.cycles, duration: result.duration),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: AppLayout.fontSizeSmall,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            _formatDate(result.date),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppLayout.fontSizeSmall - 2,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.secondsUnit(value: result.score.toInt()),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: AppLayout.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onSelected: (value) async {
                  if (value == 'remove') {
                    await _showRemoveDialog(result);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Remove',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  Future<void> _showRemoveDialog(TrainingResult result) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Result'),
        content: Text('Are you sure you want to delete this training result?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _historyService.removeResult(result);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting result'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inputDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(inputDate).inDays;

    if (difference == 0) {
      final time = DateFormat.Hm().format(date);
      return t.today(time: time);
    } else if (difference == 1) {
      return t.yesterday;
    } else if (difference < 7) {
      return t.daysAgo(days: difference);
    } else {
      return DateFormat('dd.MM.yyyy').format(date);
    }
  }
}

class MiniChartPainter extends CustomPainter {
  final double progress;
  final Color color;

  MiniChartPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw background line
    canvas.drawLine(
      Offset(5, size.height - 5),
      Offset(size.width - 5, 5),
      paint,
    );

    // Draw progress line
    final progressEnd = Offset(
      5 + (size.width - 10) * progress,
      size.height - 5 - (size.height - 10) * progress,
    );
    
    canvas.drawLine(
      Offset(5, size.height - 5),
      progressEnd,
      progressPaint,
    );

    // Draw progress point
    canvas.drawCircle(progressEnd, 3, progressPaint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ExerciseLineChart extends StatelessWidget {
  const _ExerciseLineChart({
    required this.chartData,
    required this.exerciseColor,
  });

  final List<MapEntry<DateTime, TrainingResult?>> chartData;
  final Color exerciseColor;

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Center(
        child: Text(
          t.noTraining,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: AppLayout.fontSizeSmall,
          ),
        ),
      );
    }
    return LineChart(
      _chartDataConfig(context),
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData _chartDataConfig(BuildContext context) => LineChartData(
        lineTouchData: _touchData(context),
        gridData: _gridData(context),
        titlesData: _titlesData(context),
        borderData: _borderData(context),
        lineBarsData: _lineBarsData(context),
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxYValue(),
      );

  LineTouchData _touchData(BuildContext context) => LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
            final index = spot.x.toInt();
            if (index >= 0 && index < chartData.length) {
              final result = chartData[index].value;
              if (result != null) {
                return LineTooltipItem(
                  '${DateFormat('MMM d').format(result.date)}\n${t.cyclesAndDuration(cycles: result.cycles, duration: result.duration)}',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: AppLayout.fontSizeSmall,
                  ),
                );
              }
            }
            return null;
          }).toList(),
        ),
      );

  FlTitlesData _titlesData(BuildContext context) => FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: _bottomTitles(context)),
        rightTitles: AxisTitles(sideTitles: _rightTitles(context)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: _leftTitles(context)),
      );

  List<LineChartBarData> _lineBarsData(BuildContext context) => [
        _durationLineData(context),
        _cyclesLineData(context),
      ];

  SideTitles _bottomTitles(BuildContext context) => SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: _calculateInterval(),
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index >= 0 && index < chartData.length) {
            return SideTitleWidget(
              meta: meta,
              child: Text(
                DateFormat('d').format(chartData[index].key),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: AppLayout.fontSizeSmall - 1,
                ),
              ),
            );
          }
          return const SizedBox();
        },
      );

  SideTitles _leftTitles(BuildContext context) => SideTitles(
        showTitles: true,
        reservedSize: 45,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          meta: meta,
          child: Text(
            t.secondsUnit(value: value.toInt()),
            style: TextStyle(color: exerciseColor, fontSize: AppLayout.fontSizeSmall - 1),
          ),
        ),
      );

  SideTitles _rightTitles(BuildContext context) => SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: (value, meta) {
          final cyclesValue = (value / _getMaxYValue() * _getMaxCyclesValue()).round();
          return SideTitleWidget(
            meta: meta,
            child: Text(
              t.cyclesUnit(value: cyclesValue.toString()),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: AppLayout.fontSizeSmall - 1,
              ),
            ),
          );
        },
      );

  FlGridData _gridData(BuildContext context) => FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: 25,
        verticalInterval: _calculateInterval(),
        getDrawingHorizontalLine: (value) => FlLine(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          strokeWidth: 1,
        ),
      );

  FlBorderData _borderData(BuildContext context) => FlBorderData(
        show: true,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      );

  LineChartBarData _durationLineData(BuildContext context) => LineChartBarData(
        spots: _getDurationSpots(),
        isCurved: true,
        curveSmoothness: 0.3,
        preventCurveOverShooting: true,
        color: exerciseColor,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 4,
            color: exerciseColor,
            strokeWidth: 2,
            strokeColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        belowBarData: BarAreaData(show: true, color: exerciseColor.withValues(alpha: 0.1)),
      );

  LineChartBarData _cyclesLineData(BuildContext context) => LineChartBarData(
        spots: _getCyclesSpots().map((spot) {
          if (spot.y.isNaN) return spot;
          return FlSpot(spot.x, spot.y / _getMaxCyclesValue() * _getMaxYValue());
        }).toList(),
        isCurved: true,
        curveSmoothness: 0.3,
        preventCurveOverShooting: true,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 3,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            strokeWidth: 1,
            strokeColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      );

  List<FlSpot> _getDurationSpots() => chartData
      .asMap()
      .entries
      .where((e) => e.value.value != null && e.value.value!.duration > 0)
      .map((e) => FlSpot(e.key.toDouble(), e.value.value!.duration.toDouble()))
      .toList();

  List<FlSpot> _getCyclesSpots() => chartData
      .asMap()
      .entries
      .where((e) => e.value.value != null && e.value.value!.cycles > 0)
      .map((e) => FlSpot(e.key.toDouble(), e.value.value!.cycles.toDouble()))
      .toList();

  double _getMaxYValue() {
    double max = 0;
    for (final e in chartData) {
      if (e.value != null && e.value!.duration > max) max = e.value!.duration.toDouble();
    }
    return max > 0 ? (max * 1.2).clamp(60, 300) : 100;
  }

  double _getMaxCyclesValue() {
    double max = 0;
    for (final e in chartData) {
      if (e.value != null && e.value!.cycles > max) max = e.value!.cycles.toDouble();
    }
    return max > 0 ? (max * 1.2).clamp(5, 50) : 10;
  }

  double _calculateInterval() {
    if (chartData.length <= 6) return 1.0;
    return (chartData.length / 6).ceilToDouble();
  }
}