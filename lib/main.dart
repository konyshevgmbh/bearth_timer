import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}

// Layout constants to avoid magic numbers
class AppLayout {
  // Padding and margins
  static const double minScreenPadding = 16.0;
  static const double maxScreenPadding = 32.0;
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

  // Container constraints
  static const double maxContentWidth = 500.0;
  static const double minContentWidth = 320.0;
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
  int totalCycles = 5;
  int cycleDuration = 30; // seconds

  // Current session state
  int currentCycle = 1;
  int currentPhaseIndex = 0;
  int secondsLeftInPhase = 0;
  int totalElapsed = 0;

  bool isRunning = false;
  bool isDone = true;
  Timer? timer;

  // Phase sequence and durations
  final List<Phase> phases = [
    Phase.Wait,
    Phase.In,
    Phase.Hold,
    Phase.Out,
    Phase.Rest,
    Phase.Done,
  ];
  List<int> phaseDurations = [3, 5, 17, 5, 0, 0]; // Default values

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
        totalCycles = prefs.getInt('totalCycles') ?? 5;
        cycleDuration = prefs.getInt('cycleDuration') ?? 30;
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
      await prefs.setInt('totalCycles', totalCycles);
      await prefs.setInt('cycleDuration', cycleDuration);
    } catch (e) {
      // Silently fail if saving is not available
    }
  }

  void _recalculatePhases() {
    // Calculate phase durations based on cycle length
    int inhale = 5;
    int exhale = (cycleDuration > 60) ? 7 : 5;
    int remain = cycleDuration - inhale - exhale;
    int holdInhale = (remain * 0.75).round();
    int holdExhale = remain - holdInhale;

    // Phase durations: Wait, In, Hold, Out, Rest, Done
    phaseDurations = [
      3, // Wait: 3 seconds preparation
      inhale, // In: inhale phase
      holdInhale, // Hold: breath hold phase
      exhale, // Out: exhale phase
      holdExhale, // Rest: rest phase
      0, // Done: completion (no duration)
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
    });
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (_) => _tick());
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
            // All cycles completed
            currentPhaseIndex = phases.length - 1; // Done phase
            secondsLeftInPhase = 0;
            isRunning = false;
            isDone = true;
            timer?.cancel();
          }
        }
      }
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
        screenSize.width / screenSize.height > 1.3; // Wide aspect ratio
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double contentWidth = _getContentWidth(screenSize);
    final bool useHorizontalLayout = _shouldUseHorizontalLayout(screenSize);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
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
            if (totalCycles > 1) {
              setState(() => totalCycles--);
              _saveSettings();
            }
          },
          onInc: () {
            if (totalCycles < 9) {
              setState(() => totalCycles++);
              _saveSettings();
            }
          },
        ),
        _buildStepper(
          label: "TIME",
          value: cycleDuration,
          onDec: () {
            if (cycleDuration > 30) {
              setState(() => cycleDuration -= 5);
              _recalculatePhases();
              _saveSettings();
            }
          },
          onInc: () {
            if (cycleDuration < 90) {
              setState(() => cycleDuration += 5);
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
    'In: ${phaseDurations[1]}s',
    'Hold: ${phaseDurations[2]}s',
    'Out: ${phaseDurations[3]}s',
    'Rest: ${phaseDurations[4]}s',
  ];

  return Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 8, 
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
              width: 38,
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