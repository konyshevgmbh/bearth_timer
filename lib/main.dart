import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// =============================================================================
// ALGORITHM & TRAINING CONSTANTS
// =============================================================================

/// Core training algorithm parameters and limits
class TrainingConstants {
  // Default training settings
  static const int defaultTotalCycles = 5;
  static const int defaultCycleDuration = 30; // seconds
  
  // Training limits and constraints
  static const int minCycles = 1;
  static const int maxCycles = 9;
  static const int minCycleDuration = 30; // seconds
  static const int maxCycleDuration = 90; // seconds  
  static const int cycleDurationStep = 5; // seconds
  
  // Phase timing constants
  static const int waitPhaseDuration = 3; // seconds
  static const int baseInhaleDuration = 5; // seconds
  static const int baseExhaleDuration = 5; // seconds
  static const int longExhaleDuration = 7; // seconds
  static const int longExhaleThreshold = 60; // seconds - when to use longer exhale
  
  // Phase calculation ratios
  static const double holdInhaleRatio = 0.75; // 75% of remaining time for hold inhale
  
  // Timer and session constants
  static const int timerTickInterval = 1; // seconds
}

/// Data storage and persistence constants
class StorageConstants {
  static const String trainingResultsKey = 'training_results';
  static const String totalCyclesKey = 'totalCycles';
  static const String cycleDurationKey = 'cycleDuration';
  static const int maxDataRetentionDays = 30;
}

/// Statistics and chart display constants
class ChartConstants {
  // Chart dimensions and intervals
  static const double chartHeight = 300.0;
  static const int dateDisplayInterval = 5; // Show every 5th date
  static const int scoreDisplayInterval = 100;
  static const double chartScaleMultiplier = 1.1; // 10% padding above max value
  static const double minChartScale = 100.0; // Minimum Y-axis scale
  
  // Chart styling
  static const double lineWidth = 3.0;
  static const double dotRadius = 4.0;
  static const double dotStrokeWidth = 2.0;
  static const double curveSmoothness = 0.3;
  static const double areaOpacity = 0.1;
  static const int gridStrokeWidth = 1;
  
  // Touch interaction
  static const int tooltipFontSize = 12;
}

// =============================================================================
// UI DESIGN CONSTANTS
// =============================================================================

// App color scheme - centralized color management
class AppColors {
  // Theme
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E2F);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);

  // Progress
  static const Color progressBackground = Color(0xFF2D2D2D);
  static const Color headerBackground = Color(0xFF3D2C54);
  static const double headerBackgroundOpacity = 0.3;
  static const double headerTextOpacity = 0.85;

  // Phases
  static const Color phaseIn = Color(0xFF80DEEA);
  static const Color phaseOut = Color(0xFFFFD59E);
  static const Color phaseHold = Color(0xFFCBBBEF);
  static const Color phaseRest = Color(0xFFD8C9F9);
  static const Color phaseWait = Color(0xFFFFFFFF);
  static const Color phaseDone = Color(0xFF9E9E9E);

  // Chart colors
  static const Color chartLine = Color(0xFF80DEEA);
  static const Color chartGrid = Color(0xFF2D2D2D);
}

// Layout constants to avoid magic numbers
class AppLayout {
  // Padding and margins
  static const double minScreenPadding = 0.0;
  static const double maxScreenPadding = 16.0;
  static const double cardElevation = 16.0;
  static const double cardBorderRadius = 24.0;
  static const double headerBorderRadius = 8.0;

  // Content spacing
  static const double headerPadding = 10.0;
  static const double sectionSpacingSmall = 10.0;
  static const double sectionSpacingMedium = 20.0;
  static const double sectionSpacingLarge = 28.0;
  static const double controlSpacing = 24.0;

  // Progress circle
  static const double progressCircleSize = 250.0;
  static const double progressStrokeWidth = 12.0;
  static const double phaseTimerSpacing = 8.0;
  static const double cycleInfoSpacing = 12.0;

  // Typography sizes (preserved as requested)
  static const double headerFontSize = 20.0;
  static const double labelFontSize = 16.0;
  static const double phaseLabelFontSize = 24.0;
  static const double timerFontSize = 48.0;
  static const double cycleInfoFontSize = 16.0;
  static const double phaseInfoFontSize = 15.0;
  static const double stepperValueFontSize = 22.0;

  // Icon sizes (preserved as requested)
  static const double startStopIconSize = 48.0;

  // Layout breakpoints
  static const double wideScreenThreshold = 600.0;
  static const double tallScreenThreshold = 600.0;
  static const double wideAspectRatioThreshold = 1.3;

  // Container constraints
  static const double maxContentWidth = 600.0;
  static const double minContentWidth = 320.0;
  
  // Stepper control sizing
  static const double stepperValueWidth = 38.0;
  
  // Navigation drawer
  static const double drawerIconSize = 48.0;
  static const double drawerHeaderSpacing = 8.0;
  static const double drawerTitleFontSize = 20.0;
  
  // Statistics page
  static const double statsIconSize = 28.0;
  static const double statsHeaderSpacing = 12.0;
  static const double statsTitleFontSize = 24.0;
  static const double statsDescriptionFontSize = 16.0;
  static const double statsContentPadding = 24.0;
  static const double statsChartPadding = 32.0;
  static const double noDataIconSize = 64.0;
  static const double noDataTitleFontSize = 20.0;
  static const double noDataDescriptionFontSize = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double legendIndicatorWidth = 16.0;
  static const double legendIndicatorHeight = 3.0;
  static const double legendIndicatorRadius = 2.0;
  static const double legendSpacing = 8.0;
  static const double legendFontSize = 14.0;
}

// =============================================================================
// MAIN APPLICATION CODE
// =============================================================================

/// Represents a training result with date, duration, and cycles completed.
/// Used to track and compare training sessions over time.
class TrainingResult {
  final DateTime date;
  final int duration; // Total training duration in seconds
  final int cycles; // Number of cycles completed

  TrainingResult({
    required this.date,
    required this.duration,
    required this.cycles,
  });

  /// Converts TrainingResult to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'duration': duration,
      'cycles': cycles,
    };
  }

  /// Creates TrainingResult from JSON
  factory TrainingResult.fromJson(Map<String, dynamic> json) {
    return TrainingResult(
      date: DateTime.parse(json['date']),
      duration: json['duration'],
      cycles: json['cycles'],
    );
  }

  /// Determines if this result is better than another result.
  /// Logic: Higher cycles is better. If cycles are equal, longer duration is better.
  /// This prioritizes completing more breathing cycles as the primary goal.
  bool isBetterThan(TrainingResult other) {
    if (cycles != other.cycles) {
      return cycles > other.cycles;
    }
    return duration > other.duration;
  }

  /// Calculates a score for chart display purposes.
  /// Score combines cycles and duration with cycles being more important.
  double get score {
    return duration.toDouble();
  }
}

/// Manages storage and retrieval of training results using SharedPreferences.
/// Automatically maintains only the last 30 days of data with best result per day.
class ResultsManager {
  /// Saves a new training result, keeping only the best result per day
  static Future<void> saveResult(TrainingResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final results = await getResults();
      
      // Find if there's already a result for this date
      final dateKey = DateFormat('yyyy-MM-dd').format(result.date);
      TrainingResult? existingResult;
      int existingIndex = -1;
      
      for (int i = 0; i < results.length; i++) {
        final resultDateKey = DateFormat('yyyy-MM-dd').format(results[i].date);
        if (resultDateKey == dateKey) {
          existingResult = results[i];
          existingIndex = i;
          break;
        }
      }
      
      // Keep only the better result for the day
      if (existingResult == null || result.isBetterThan(existingResult)) {
        if (existingIndex >= 0) {
          results[existingIndex] = result;
        } else {
          results.add(result);
        }
        
        // Clean up old results (keep only last 30 days)
        final cutoffDate = DateTime.now().subtract(Duration(days: StorageConstants.maxDataRetentionDays));
        results.removeWhere((r) => r.date.isBefore(cutoffDate));
        
        // Sort by date (newest first)
        results.sort((a, b) => b.date.compareTo(a.date));
        
        // Save to SharedPreferences
        final jsonList = results.map((r) => r.toJson()).toList();
        await prefs.setString(StorageConstants.trainingResultsKey, jsonEncode(jsonList));
      }
    } catch (e) {
      // Silently handle errors to avoid disrupting the user experience
      print('Error saving result: $e');
    }
  }

  /// Retrieves all stored training results
  static Future<List<TrainingResult>> getResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(StorageConstants.trainingResultsKey);
      
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => TrainingResult.fromJson(json)).toList();
    } catch (e) {
      print('Error loading results: $e');
      return [];
    }
  }

  /// Clears all stored training results
  static Future<void> clearResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageConstants.trainingResultsKey);
    } catch (e) {
      print('Error clearing results: $e');
    }
  }

  /// Gets results for the last 30 days with empty days filled
  static Future<List<MapEntry<DateTime, double?>>> getLast30DaysData() async {
    final results = await getResults();
    final data = <MapEntry<DateTime, double?>>[];
    
    // Create map of date -> score for quick lookup
    final resultMap = <String, double>{};
    for (final result in results) {
      final dateKey = DateFormat('yyyy-MM-dd').format(result.date);
      resultMap[dateKey] = result.score;
    }
    
    // Generate last 30 days
    for (int i = StorageConstants.maxDataRetentionDays - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      data.add(MapEntry(date, resultMap[dateKey]));
    }
    
    return data;
  }
}

void main() => runApp(BreathHoldApp());

class BreathHoldApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breath-Hold Training at Home',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cardBackground,
        useMaterial3: true, // Enable Material 3 styling
      ),
      home: BreathHoldHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum Phase { Wait, In, Hold, Out, Rest, Done }

class BreathHoldHomePage extends StatefulWidget {
  @override
  State<BreathHoldHomePage> createState() => _BreathHoldHomePageState();
}

class _BreathHoldHomePageState extends State<BreathHoldHomePage> {
  // Default settings
  int totalCycles = TrainingConstants.defaultTotalCycles;
  int cycleDuration = TrainingConstants.defaultCycleDuration;

  // Current session state
  int currentCycle = 1;
  int currentPhaseIndex = 0;
  int secondsLeftInPhase = 0;
  int totalElapsed = 0;

  bool isRunning = false;
  bool isDone = true;
  Timer? timer;

  // Track session start time for result calculation
  DateTime? sessionStartTime;

  // Phase sequence and durations
  final List<Phase> phases = [
    Phase.Wait,
    Phase.In,
    Phase.Hold,
    Phase.Out,
    Phase.Rest,
    Phase.Done,
  ];
  List<int> phaseDurations = [
    TrainingConstants.waitPhaseDuration,
    TrainingConstants.baseInhaleDuration,
    17, // Will be calculated
    TrainingConstants.baseExhaleDuration,
    0,  // Will be calculated
    0,  // Done phase has no duration
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved settings from persistent storage
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        totalCycles = prefs.getInt(StorageConstants.totalCyclesKey) ?? TrainingConstants.defaultTotalCycles;
        cycleDuration = prefs.getInt(StorageConstants.cycleDurationKey) ?? TrainingConstants.defaultCycleDuration;
      });
      _recalculatePhases();
    } catch (e) {
      // If SharedPreferences fails, use defaults
      _recalculatePhases();
    }
  }

  // Save settings to persistent storage
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(StorageConstants.totalCyclesKey, totalCycles);
      await prefs.setInt(StorageConstants.cycleDurationKey, cycleDuration);
    } catch (e) {
      // Silently fail if saving is not available
    }
  }

  void _recalculatePhases() {
    // Calculate phase durations based on cycle length
    int inhale = TrainingConstants.baseInhaleDuration;
    int exhale = (cycleDuration > TrainingConstants.longExhaleThreshold) 
        ? TrainingConstants.longExhaleDuration 
        : TrainingConstants.baseExhaleDuration;
    int remain = cycleDuration - inhale - exhale;
    int holdInhale = (remain * TrainingConstants.holdInhaleRatio).round();
    int holdExhale = remain - holdInhale;

    // Phase durations: Wait, In, Hold, Out, Rest, Done
    phaseDurations = [
      TrainingConstants.waitPhaseDuration,
      inhale,
      holdInhale,
      exhale,
      holdExhale,
      0, // Done phase has no duration
    ];
    setState(() {});
  }

  void _startSession() {
    setState(() {
      currentCycle = 1;
      currentPhaseIndex = 0;
      secondsLeftInPhase = phaseDurations[0];
      totalElapsed = 0;
      isRunning = true;
      isDone = false;
      sessionStartTime = DateTime.now(); // Track session start
    });
    timer?.cancel();
    timer = Timer.periodic(
      Duration(seconds: TrainingConstants.timerTickInterval), 
      (_) => _tick()
    );
  }

  void _tick() {
    if (!isRunning || isDone) return;

    setState(() {
      if (secondsLeftInPhase > 1) {
        secondsLeftInPhase--;
        totalElapsed++;
      } else {
        totalElapsed++;
        // Move to next phase or cycle
        if (currentPhaseIndex < phases.length - 2) {
          // Don't include Done phase
          currentPhaseIndex++;
          secondsLeftInPhase = phaseDurations[currentPhaseIndex];
        } else {
          // End of cycle, check if more cycles remain
          if (currentCycle < totalCycles) {
            currentCycle++;
            currentPhaseIndex = 1; // Skip Wait phase after first cycle
            secondsLeftInPhase = phaseDurations[currentPhaseIndex];
          } else {
            // All cycles completed - save the result
            _completeSession();
          }
        }
      }
    });
  }

  /// Called when a training session is completed successfully.
  /// Saves the result and updates UI state.
  void _completeSession() async {
    if (sessionStartTime != null) {
      // Create training result
      final result = TrainingResult(
        date: sessionStartTime!,
        duration: cycleDuration,
        cycles: totalCycles,
      );
      
      // Save the result
      await ResultsManager.saveResult(result);
    }

    setState(() {
      currentPhaseIndex = phases.length - 1; // Done phase
      secondsLeftInPhase = 0;
      isRunning = false;
      isDone = true;
      timer?.cancel();
    });
  }

  void _stopSession() {
    setState(() {
      isRunning = false;
      timer?.cancel();
      currentCycle = 1;
      currentPhaseIndex = 0;
      secondsLeftInPhase = 0;
      totalElapsed = 0;
      isDone = true;
      sessionStartTime = null; // Reset session start time
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Calculate progress within current cycle (0.0 to 1.0)
  double get currentCycleProgress {
    if (phases[currentPhaseIndex] == Phase.Wait ||
        phases[currentPhaseIndex] == Phase.Done) {
      return 0.0;
    }

    int phaseSum = 0;
    for (int i = 1; i < currentPhaseIndex; i++) {
      phaseSum += phaseDurations[i];
    }

    int timeInCycle =
        phaseSum + (phaseDurations[currentPhaseIndex] - secondsLeftInPhase);
    int cyclePhasesTotal = phaseDurations
        .sublist(1, 5)
        .reduce((a, b) => a + b); // In+Hold+Out+Rest

    return (timeInCycle / cyclePhasesTotal).clamp(0.0, 1.0);
  }

  // Format timer display as MM:SS
  String get timerDisplay {
    int min = secondsLeftInPhase ~/ 60;
    int sec = secondsLeftInPhase % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  // Get current phase label
  String get phaseLabel {
    switch (phases[currentPhaseIndex]) {
      case Phase.Wait:
        return "Wait";
      case Phase.In:
        return "In";
      case Phase.Hold:
        return "Hold";
      case Phase.Out:
        return "Out";
      case Phase.Rest:
        return "Rest";
      case Phase.Done:
        return "Done";
    }
  }

  // Get color for current phase
  Color get phaseColor {
    switch (phases[currentPhaseIndex]) {
      case Phase.Wait:
        return AppColors.phaseWait;
      case Phase.In:
        return AppColors.phaseIn;
      case Phase.Hold:
        return AppColors.phaseHold;
      case Phase.Out:
        return AppColors.phaseOut;
      case Phase.Rest:
        return AppColors.phaseRest;
      case Phase.Done:
        return AppColors.phaseDone;
    }
  }

  // Calculate adaptive padding based on screen size
  double _getScreenPadding(Size screenSize) {
    final double basePadding = AppLayout.minScreenPadding;
    final double maxPadding = AppLayout.maxScreenPadding;

    // Use smaller padding on smaller screens, larger on bigger screens
    final double adaptivePadding =
        basePadding +
        (maxPadding - basePadding) *
            (screenSize.width / AppLayout.wideScreenThreshold).clamp(0.0, 1.0);

    return adaptivePadding;
  }

  // Calculate content width based on screen size
  double _getContentWidth(Size screenSize) {
    final double availableWidth =
        screenSize.width - (_getScreenPadding(screenSize) * 2);
    return availableWidth.clamp(
      AppLayout.minContentWidth,
      AppLayout.maxContentWidth,
    );
  }

  // Determine if we should use horizontal layout for wide screens
  bool _shouldUseHorizontalLayout(Size screenSize) {
    return screenSize.width > AppLayout.wideScreenThreshold &&
        screenSize.height < AppLayout.tallScreenThreshold &&
        screenSize.width / screenSize.height > AppLayout.wideAspectRatioThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool useHorizontalLayout = _shouldUseHorizontalLayout(screenSize);
    double contentWidth = (useHorizontalLayout ? 2 : 1) * _getContentWidth(screenSize);

    return Scaffold(
      // Navigation drawer with Home and Statistics options
      drawer: _buildNavigationDrawer(),
      appBar: AppBar(
        title: Text('Breath-Hold Training'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: contentWidth,
              padding: EdgeInsets.all(0),
              child: Card(
                elevation: AppLayout.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppLayout.cardBorderRadius,
                  ),
                ),
                child: Container(
                  width: contentWidth,
                  padding: EdgeInsets.symmetric(
                    vertical: AppLayout.sectionSpacingLarge,
                    horizontal: AppLayout.sectionSpacingMedium,
                  ),
                  child:
                      useHorizontalLayout
                          ? _buildHorizontalLayout()
                          : _buildVerticalLayout(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the navigation drawer with Home and Statistics options
  Widget _buildNavigationDrawer() {
    return Drawer(
      backgroundColor: AppColors.cardBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.headerBackground.withOpacity(0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.air,
                  color: AppColors.textPrimary,
                  size: AppLayout.drawerIconSize,
                ),
                SizedBox(height: AppLayout.drawerHeaderSpacing),
                Text(
                  '',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppLayout.drawerTitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: AppColors.textPrimary),
            title: Text(
              'Home',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart, color: AppColors.textPrimary),
            title: Text(
              'Statistics',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatisticsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Vertical layout for normal and tall screens
  Widget _buildVerticalLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        SizedBox(height: AppLayout.sectionSpacingMedium),
        _buildControlsSection(),
        SizedBox(height: AppLayout.sectionSpacingSmall),
        _buildPhaseInfoText(),
        SizedBox(height: AppLayout.sectionSpacingLarge),
        _buildTimerSection(),
        SizedBox(height: AppLayout.controlSpacing),
        _buildActionButton(),
        SizedBox(height: AppLayout.sectionSpacingSmall),
      ],
    );
  }

  // Horizontal layout for wide screens
  Widget _buildHorizontalLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        SizedBox(height: AppLayout.sectionSpacingMedium),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildControlsSection(),
                  SizedBox(height: AppLayout.sectionSpacingMedium),
                  _buildPhaseInfoText(),
                  SizedBox(height: AppLayout.sectionSpacingMedium),
                  _buildActionButton(),
                ],
              ),
            ),
            SizedBox(width: AppLayout.sectionSpacingLarge),
            Expanded(flex: 1, child: _buildTimerSection()),
          ],
        ),
        SizedBox(height: AppLayout.sectionSpacingSmall),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppLayout.headerPadding),
      decoration: BoxDecoration(
        color: AppColors.headerBackground.withOpacity(
          AppColors.headerBackgroundOpacity,
        ),
        borderRadius: BorderRadius.circular(AppLayout.headerBorderRadius),
      ),
      child: Text(
        "TIMER",
        style: TextStyle(
          color: AppColors.textPrimary.withOpacity(AppColors.headerTextOpacity),
          fontWeight: FontWeight.bold,
          fontSize: AppLayout.headerFontSize,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildControlsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStepper(
          label: "CYCLES",
          value: totalCycles,
          onDec: () {
            if (totalCycles > TrainingConstants.minCycles) {
              setState(() => totalCycles--);
              _saveSettings();
            }
          },
          onInc: () {
            if (totalCycles < TrainingConstants.maxCycles) {
              setState(() => totalCycles++);
              _saveSettings();
            }
          },
        ),
        _buildStepper(
          label: "TIME",
          value: cycleDuration,
          onDec: () {
            if (cycleDuration > TrainingConstants.minCycleDuration) {
              setState(() => cycleDuration -= TrainingConstants.cycleDurationStep);
              _recalculatePhases();
              _saveSettings();
            }
          },
          onInc: () {
            if (cycleDuration < TrainingConstants.maxCycleDuration) {
              setState(() => cycleDuration += TrainingConstants.cycleDurationStep);
              _recalculatePhases();
              _saveSettings();
            }
          },
        ),
      ],
    );
  }

  Widget _buildPhaseInfoText() {
    final phases = [
      'In: ${phaseDurations[1]}s Hold: ${phaseDurations[2]}s',
      'Out: ${phaseDurations[3]}s Rest: ${phaseDurations[4]}s',
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppLayout.legendSpacing, 
      runSpacing: 2,
      children: phases
          .map((text) => Text(
                text,
                style: TextStyle(
                  fontSize: AppLayout.phaseInfoFontSize,
                  color: AppColors.textSecondary,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTimerSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: AppLayout.progressCircleSize,
          height: AppLayout.progressCircleSize,
          child: CircularProgressIndicator(
            value: currentCycleProgress,
            strokeWidth: AppLayout.progressStrokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
            backgroundColor: AppColors.progressBackground,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              phaseLabel,
              style: TextStyle(
                color: phaseColor,
                fontWeight: FontWeight.bold,
                fontSize: AppLayout.phaseLabelFontSize,
              ),
            ),
            SizedBox(height: AppLayout.phaseTimerSpacing),
            Text(
              !isDone
                  ? timerDisplay
                  : "${cycleDuration.toString().padLeft(2, '0')}:00",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppLayout.timerFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: AppLayout.cycleInfoSpacing),
            Text(
              'Cycle $currentCycle / $totalCycles',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppLayout.cycleInfoFontSize,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return IconButton(
      icon: Icon(
        isRunning ? Icons.stop_circle : Icons.play_circle_fill,
        color: AppColors.textPrimary,
        size: AppLayout.startStopIconSize,
      ),
      onPressed: () {
        if (isRunning) {
          _stopSession();
        } else {
          _startSession();
        }
      },
    );
  }

  Widget _buildStepper({
    required String label,
    required int value,
    required VoidCallback onDec,
    required VoidCallback onInc,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppLayout.labelFontSize,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle, color: AppColors.textSecondary),
              onPressed: onDec,
            ),
            Container(
              width: AppLayout.stepperValueWidth,
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: AppLayout.stepperValueFontSize,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: AppColors.textSecondary),
              onPressed: onInc,
            ),
          ],
        ),
      ],
    );
  }
}


/// Statistics page showing training results over the last 30 days with a dual-axis chart
class StatisticsPage extends StatefulWidget {
  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<MapEntry<DateTime, TrainingResult?>> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads the last 30 days of training data for the chart
  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final results = await ResultsManager.getResults();
    final data = <MapEntry<DateTime, TrainingResult?>>[];
    
    // Create map of date -> result for quick lookup
    final resultMap = <String, TrainingResult>{};
    for (final result in results) {
      final dateKey = DateFormat('yyyy-MM-dd').format(result.date);
      resultMap[dateKey] = result;
    }
    
    // Generate last 30 days
    for (int i = StorageConstants.maxDataRetentionDays - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      data.add(MapEntry(date, resultMap[dateKey]));
    }
    
    setState(() {
      chartData = data;
      isLoading = false;
    });
  }

  /// Clears all stored results with user confirmation
  Future<void> _clearResults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Clear All Results',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete all training results? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ResultsManager.clearResults();
      _loadData(); // Refresh the chart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All results cleared'),
          backgroundColor: AppColors.cardBackground,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training Statistics'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: _clearResults,
            tooltip: 'Clear all results',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.chartLine),
            )
          : _buildStatisticsContent(),
    );
  }

  Widget _buildStatisticsContent() {
    final hasData = chartData.any((entry) => entry.value != null);

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppLayout.maxScreenPadding),
      child: Card(
        elevation: AppLayout.cardElevation,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.cardBorderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppLayout.statsContentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Row(
                children: [
                  Icon(Icons.bar_chart, color: AppColors.textPrimary, size: AppLayout.statsIconSize),
                  SizedBox(width: AppLayout.statsHeaderSpacing),
                  Text(
                    'Progress Tracking',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppLayout.statsTitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppLayout.legendSpacing),
              Text(
                'Cycle duration and count over time',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppLayout.statsDescriptionFontSize,
                ),
              ),
              SizedBox(height: AppLayout.statsChartPadding),

              // Chart section
              if (hasData) ...[
                Container(
                  height: ChartConstants.chartHeight,
                  child: LineChart(
                    LineChartData(
                      // Grid and background styling
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        drawHorizontalLine: true,
                        horizontalInterval: 25, // Better spacing for 0-100 normalized scale
                        verticalInterval: ChartConstants.dateDisplayInterval.toDouble(),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.chartGrid,
                          strokeWidth: ChartConstants.gridStrokeWidth.toDouble(),
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: AppColors.chartGrid,
                          strokeWidth: ChartConstants.gridStrokeWidth.toDouble(),
                        ),
                      ),
                      
                      // Chart boundaries and labels
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: ChartConstants.dateDisplayInterval.toDouble(),
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < chartData.length && index % ChartConstants.dateDisplayInterval == 0) {
                                final date = chartData[index].key;
                                return Padding(
                                  padding: EdgeInsets.only(top: AppLayout.legendSpacing),
                                  child: Text(
                                    DateFormat('M/d').format(date),
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: ChartConstants.tooltipFontSize.toDouble(),
                                    ),
                                  ),
                                );
                              }
                              return SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Duration (sec)',
                            style: TextStyle(
                              color: AppColors.phaseIn,
                              fontSize: ChartConstants.tooltipFontSize.toDouble(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            interval: 25,
                            getTitlesWidget: (value, meta) {
                              // Show duration values in 30-90 range
                              final duration = _normalizedToDuration(value);
                              if (duration >= TrainingConstants.minCycleDuration && 
                                  duration <= TrainingConstants.maxCycleDuration &&
                                  duration % 15 == 0) { // Show every 15 seconds
                                return Text(
                                  duration.toString(),
                                  style: TextStyle(
                                    color: AppColors.phaseIn,
                                    fontSize: ChartConstants.tooltipFontSize.toDouble(),
                                  ),
                                );
                              }
                              return SizedBox();
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Cycles',
                            style: TextStyle(
                              color: AppColors.phaseOut,
                              fontSize: ChartConstants.tooltipFontSize.toDouble(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            interval: 25,
                            getTitlesWidget: (value, meta) {
                              // Show cycle count values in 1-9 range
                              final cycles = _normalizedToCycles(value);
                              if (cycles >= TrainingConstants.minCycles && 
                                  cycles <= TrainingConstants.maxCycles) {
                                return Text(
                                  cycles.toString(),
                                  style: TextStyle(
                                    color: AppColors.phaseOut,
                                    fontSize: ChartConstants.tooltipFontSize.toDouble(),
                                  ),
                                );
                              }
                              return SizedBox();
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      
                      // Chart borders
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: AppColors.chartGrid, width: ChartConstants.gridStrokeWidth.toDouble()),
                      ),
                      
                      // Min/max values
                      minX: 0,
                      maxX: (chartData.length - 1).toDouble(),
                      minY: 0,
                      maxY: 100, // Normalized scale
                      
                      // Line data - Duration and Cycles
                      lineBarsData: [
                        // Duration line (primary Y-axis)
                        LineChartBarData(
                          spots: _getDurationSpots(),
                          isCurved: true,
                          curveSmoothness: ChartConstants.curveSmoothness,
                          color: AppColors.phaseIn,
                          barWidth: ChartConstants.lineWidth,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: ChartConstants.dotRadius,
                                color: AppColors.phaseIn,
                                strokeWidth: ChartConstants.dotStrokeWidth,
                                strokeColor: AppColors.background,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.phaseIn.withOpacity(ChartConstants.areaOpacity),
                          ),
                        ),
                        // Cycles line (secondary Y-axis)
                        LineChartBarData(
                          spots: _getCyclesSpots(),
                          isCurved: true,
                          curveSmoothness: ChartConstants.curveSmoothness,
                          color: AppColors.phaseOut,
                          barWidth: ChartConstants.lineWidth,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: ChartConstants.dotRadius,
                                color: AppColors.phaseOut,
                                strokeWidth: ChartConstants.dotStrokeWidth,
                                strokeColor: AppColors.background,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(show: false), // Only show area for duration
                        ),
                      ],
                      
                      // Touch interactions
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            final tooltips = <LineTooltipItem?>[];
                            
                            for (int i = 0; i < touchedSpots.length; i++) {
                              final spot = touchedSpots[i];
                              final index = spot.x.toInt();
                              
                              if (index >= 0 && index < chartData.length && chartData[index].value != null) {
                                final date = chartData[index].key;
                                final result = chartData[index].value!;
                                
                                if (i == 0) {
                                  // Duration line tooltip
                                  tooltips.add(LineTooltipItem(
                                    '${DateFormat('MMM d').format(date)}\nDuration: ${result.duration}s\nCycles: ${result.cycles}',
                                    TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: ChartConstants.tooltipFontSize.toDouble(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ));
                                } else {
                                  // For cycles line, we don't want duplicate tooltip
                                  tooltips.add(null);
                                }
                              } else {
                                tooltips.add(null);
                              }
                            }
                            
                            return tooltips;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppLayout.statsContentPadding),
                
                // Chart legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Duration legend
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: AppLayout.legendIndicatorWidth,
                          height: AppLayout.legendIndicatorHeight,
                          decoration: BoxDecoration(
                            color: AppColors.phaseIn,
                            borderRadius: BorderRadius.circular(AppLayout.legendIndicatorRadius),
                          ),
                        ),
                        SizedBox(width: AppLayout.legendSpacing),
                        Text(
                          'Duration (sec)',
                          style: TextStyle(
                            color: AppColors.phaseIn,
                            fontSize: AppLayout.legendFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Cycles legend
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: AppLayout.legendIndicatorWidth,
                          height: AppLayout.legendIndicatorHeight,
                          decoration: BoxDecoration(
                            color: AppColors.phaseOut,
                            borderRadius: BorderRadius.circular(AppLayout.legendIndicatorRadius),
                          ),
                        ),
                        SizedBox(width: AppLayout.legendSpacing),
                        Text(
                          'Cycles',
                          style: TextStyle(
                            color: AppColors.phaseOut,
                            fontSize: AppLayout.legendFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                // No data message
                Container(
                  height: ChartConstants.chartHeight,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insights,
                          size: AppLayout.noDataIconSize,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        SizedBox(height: AppLayout.maxScreenPadding),
                        Text(
                          'No Training Data Yet',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: AppLayout.noDataTitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppLayout.legendSpacing),
                        Text(
                          'Complete some training sessions to see your progress here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppLayout.noDataDescriptionFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              SizedBox(height: AppLayout.statsChartPadding),
              
              // Clear results button
              Center(
                child: ElevatedButton.icon(
                  onPressed: hasData ? _clearResults : null,
                  icon: Icon(Icons.delete_outline),
                  label: Text('Clear All Results'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: AppLayout.statsContentPadding, vertical: AppLayout.statsHeaderSpacing),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Converts duration chart data to FlSpot objects with normalized values
  List<FlSpot> _getDurationSpots() {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < chartData.length; i++) {
      final result = chartData[i].value;
      if (result != null) {
        // Normalize duration to 0-100 scale using fixed training constants
        final durationRange = TrainingConstants.maxCycleDuration - TrainingConstants.minCycleDuration;
        double normalizedValue = ((result.duration - TrainingConstants.minCycleDuration) / durationRange) * 100;
        normalizedValue = normalizedValue.clamp(0.0, 100.0);
        spots.add(FlSpot(i.toDouble(), normalizedValue));
      }
    }
    return spots;
  }

  /// Converts cycles chart data to FlSpot objects with normalized values
  List<FlSpot> _getCyclesSpots() {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < chartData.length; i++) {
      final result = chartData[i].value;
      if (result != null) {
        // Normalize cycles to 0-100 scale using fixed training constants
        final cycleRange = TrainingConstants.maxCycles - TrainingConstants.minCycles;
        double normalizedValue = ((result.cycles - TrainingConstants.minCycles) / cycleRange) * 100;
        normalizedValue = normalizedValue.clamp(0.0, 100.0);
        spots.add(FlSpot(i.toDouble(), normalizedValue));
      }
    }
    return spots;
  }

  /// Converts normalized value back to actual duration for Y-axis labels
  int _normalizedToDuration(double normalizedValue) {
    final durationRange = TrainingConstants.maxCycleDuration - TrainingConstants.minCycleDuration;
    return (TrainingConstants.minCycleDuration + (normalizedValue / 100) * durationRange).round();
  }

  /// Converts normalized value back to actual cycles for Y-axis labels
  int _normalizedToCycles(double normalizedValue) {
    final cycleRange = TrainingConstants.maxCycles - TrainingConstants.minCycles;
    return (TrainingConstants.minCycles + (normalizedValue / 100) * cycleRange).round();
  }
}