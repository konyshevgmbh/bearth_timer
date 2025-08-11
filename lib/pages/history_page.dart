import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../models/training_result.dart';
import '../services/history_service.dart';
import '../i18n/translations.g.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService _historyService = HistoryService();

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

  @override
  void dispose() {
    _historyService.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.history.title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        automaticallyImplyLeading: false,
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
            t.history.overview,
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
            Expanded(child: _buildStatItem('Sessions', stats.totalSessions.toString())),
            Expanded(child: _buildStatItem('Time', '${stats.totalDuration}s')),
            Expanded(child: _buildStatItem('Avg', '${stats.avgDuration}s')),
            Expanded(child: _buildStatItem('Cycles', stats.totalCycles.toString())),
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
            t.history.noHistoryYet,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppLayout.fontSizeMedium,
            ),
          ),
          SizedBox(height: 8),
          Text(
            t.history.completeSessionToSee,
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
      children: exerciseEntries.map((entry) {
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
      }).toList(),
    );
  }

  Widget _buildExerciseSection(String exerciseName, List<TrainingResult> results, Color exerciseColor) {
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
          child: Row(
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
                '${results.length} sessions',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: AppLayout.fontSizeSmall - 2,
                ),
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
    
    // Find the date range: from earliest data to current date
    final now = DateTime.now();
    final sortedResults = List<TrainingResult>.from(results);
    sortedResults.sort((a, b) => a.date.compareTo(b.date));
    
    // Get start date (earliest data, but at least 30 days ago)
    final earliestData = sortedResults.first.date;
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final startDate = earliestData.isBefore(thirtyDaysAgo) ? earliestData : thirtyDaysAgo;
    
    // Create map of existing results by date
    final resultsByDate = <String, TrainingResult>{};
    for (final result in results) {
      final dateKey = '${result.date.year}-${result.date.month}-${result.date.day}';
      resultsByDate[dateKey] = result;
    }
    
    // Generate complete date range from start to current date
    final chartData = <MapEntry<DateTime, TrainingResult?>>[];
    DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final endDate = DateTime(now.year, now.month, now.day);
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final dateKey = '${currentDate.year}-${currentDate.month}-${currentDate.day}';
      final result = resultsByDate[dateKey];
      chartData.add(MapEntry(currentDate, result));
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return chartData;
  }


  Widget _buildExerciseResultsList(List<TrainingResult> results) {
    return Column(
      children: results.take(5).map((result) { // Show only latest 5 results
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: AppLayout.spacingMedium, vertical: 4),
          title: Text(
            '${result.cycles} cycles • ${result.duration}s',
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
          trailing: Text(
            '${result.score.toInt()}s',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: AppLayout.fontSizeSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }


  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
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
    return LineChart(
      chartDataConfig(context),
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData chartDataConfig(BuildContext context) => LineChartData(
        lineTouchData: touchData(context),
        gridData: gridData(context),
        titlesData: titlesData(context),
        borderData: borderData(context),
        lineBarsData: lineBarsData(context),
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxYValue(),
      );

  LineTouchData touchData(BuildContext context) => LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index >= 0 && index < chartData.length) {
                final result = chartData[index].value;
                if (result != null) {
                  return LineTooltipItem(
                    '${DateFormat('MMM d').format(result.date)}\n${result.duration}s, ${result.cycles} cycles',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: AppLayout.fontSizeSmall,
                    ),
                  );
                } else {
                  return LineTooltipItem(
                    '${DateFormat('MMM d').format(chartData[index].key)}\nNo training',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: AppLayout.fontSizeSmall,
                    ),
                  );
                }
              }
              return null;
            }).toList();
          },
        ),
      );

  FlTitlesData titlesData(BuildContext context) => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles(context),
        ),
        rightTitles: AxisTitles(
          sideTitles: rightTitles(context),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(context),
        ),
      );

  List<LineChartBarData> lineBarsData(BuildContext context) => [
        durationLineData(context),
        cyclesLineData(context),
      ];

  Widget bottomTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    final index = value.toInt();
    if (index >= 0 && index < chartData.length) {
      final date = chartData[index].key;
      
      // Calculate available width for labels
      final chartWidth = meta.parentAxisSize;
      final labelCount = (chartData.length / _calculateInterval()).ceil();
      final availableWidthPerLabel = chartWidth / labelCount;
      
      // Choose format based on available space
      String dateText;
      if (availableWidthPerLabel < 50) {
        // Very tight space - show only day
        dateText = DateFormat('d').format(date);
      } else if (availableWidthPerLabel < 70) {
        // Moderate space - show month/day abbreviated
        dateText = DateFormat('M/d').format(date);
      } else {
        // Enough space - show full format
        dateText = DateFormat('MMM d').format(date);
      }
      
      return SideTitleWidget(
        meta: meta,
        child: Text(
          dateText,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: AppLayout.fontSizeSmall - 1,
          ),
        ),
      );
    }
    return const SizedBox();
  }

  SideTitles bottomTitles(BuildContext context) => SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: _calculateInterval(),
        getTitlesWidget: (value, meta) => bottomTitleWidgets(value, meta, context),
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        '${value.toInt()}s',
        style: TextStyle(
          color: exerciseColor,
          fontSize: AppLayout.fontSizeSmall - 1,
        ),
      ),
    );
  }

  SideTitles leftTitles(BuildContext context) => SideTitles(
        showTitles: true,
        reservedSize: 45,
        getTitlesWidget: leftTitleWidgets,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    final cyclesValue = (value / _getMaxYValue() * _getMaxCyclesValue()).round();
    return SideTitleWidget(
      meta: meta,
      child: Text(
        '${cyclesValue}c',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: AppLayout.fontSizeSmall - 1,
        ),
      ),
    );
  }

  SideTitles rightTitles(BuildContext context) => SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: (value, meta) => rightTitleWidgets(value, meta, context),
      );

  FlGridData gridData(BuildContext context) => FlGridData(
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

  FlBorderData borderData(BuildContext context) => FlBorderData(
        show: true,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      );

  LineChartBarData durationLineData(BuildContext context) => LineChartBarData(
        spots: _getDurationSpots(),
        isCurved: true,
        curveSmoothness: 0.3,
        color: exerciseColor,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: exerciseColor,
              strokeWidth: 2,
              strokeColor: Theme.of(context).colorScheme.surface,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: exerciseColor.withValues(alpha: 0.1),
        ),
      );

  LineChartBarData cyclesLineData(BuildContext context) => LineChartBarData(
        spots: _getCyclesSpots().map((spot) {
          if (spot.y.isNaN) return spot;
          final scaledY = spot.y / _getMaxCyclesValue() * _getMaxYValue();
          return FlSpot(spot.x, scaledY);
        }).toList(),
        isCurved: true,
        curveSmoothness: 0.3,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 3,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              strokeWidth: 1,
              strokeColor: Theme.of(context).colorScheme.surface,
            );
          },
        ),
      );

  List<FlSpot> _getDurationSpots() {
    final spots = <FlSpot>[];
    for (int i = 0; i < chartData.length; i++) {
      final result = chartData[i].value;
      if (result != null && result.duration > 0) {
        spots.add(FlSpot(i.toDouble(), result.duration.toDouble()));
      }
    }
    return spots;
  }

  List<FlSpot> _getCyclesSpots() {
    final spots = <FlSpot>[];
    for (int i = 0; i < chartData.length; i++) {
      final result = chartData[i].value;
      if (result != null && result.cycles > 0) {
        spots.add(FlSpot(i.toDouble(), result.cycles.toDouble()));
      }
    }
    return spots;
  }

  double _getMaxYValue() {
    double maxDuration = 0;
    for (final entry in chartData) {
      if (entry.value != null && entry.value!.duration > maxDuration) {
        maxDuration = entry.value!.duration.toDouble();
      }
    }
    // Ensure minimum value even if no data
    return maxDuration > 0 ? (maxDuration * 1.2).clamp(60, 300) : 100;
  }

  double _getMaxCyclesValue() {
    double maxCycles = 0;
    for (final entry in chartData) {
      if (entry.value != null && entry.value!.cycles > maxCycles) {
        maxCycles = entry.value!.cycles.toDouble();
      }
    }
    // Ensure minimum value even if no data
    return maxCycles > 0 ? (maxCycles * 1.2).clamp(5, 50) : 10;
  }

  double _calculateInterval() {
    if (chartData.length <= 7) {
      return 1; // Show all labels for small datasets
    } else if (chartData.length <= 14) {
      return 2; // Show every 2nd label
    } else if (chartData.length <= 30) {
      return (chartData.length / 5).ceil().toDouble(); // Show roughly 5 labels
    } else {
      return (chartData.length / 4).ceil().toDouble(); // Show roughly 4 labels for large datasets
    }
  }
}