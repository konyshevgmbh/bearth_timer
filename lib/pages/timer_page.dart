import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../i18n/translations.g.dart';
import 'exercise_edit_page.dart';
import '../models/breathing_exercise.dart';
import '../services/session_service.dart';
import '../widgets/unified_progress_ring.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({
    super.key,
  });

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _setupSessionListener();
  }

  Future<void> _initializeSession() async {
    await _sessionService.initialize();
    if (mounted) {
      setState(() {}); // Trigger UI update after initialization
    }
  }

  void _setupSessionListener() {
    _sessionService.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }


  Future<void> _startSession() async {
    debugPrint('TimerPage: Starting session...');
    await _sessionService.start();
    if (mounted) {
      setState(() {});
    }
    debugPrint('TimerPage: Session started');
  }



  Future<void> _stopSession() async {
    debugPrint('TimerPage: Stopping session...');
    await _sessionService.stop();
    if (mounted) {
      setState(() {});
    }
    debugPrint('TimerPage: Session stopped');
  }

  void _showExerciseDescription() {
    final exercise = _sessionService.currentExercise;
    if (exercise == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.cardBorderRadius),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  exercise.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: AppLayout.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.description.isNotEmpty 
                      ? exercise.description 
                      : 'No description available for this exercise.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: AppLayout.fontSizeSmall,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                // Exercise details
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exercise Details:',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: AppLayout.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildDetailRow('Cycles', '${exercise.cycles}'),
                      _buildDetailRow('Cycle Duration', '${exercise.cycleDuration}s'),
                      _buildDetailRow('Total Duration', '${(exercise.cycles * exercise.cycleDuration / 60).toStringAsFixed(1)} min'),
                      _buildDetailRow('Phases', '${exercise.phases.length}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: AppLayout.fontSizeSmall,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppLayout.fontSizeSmall,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: AppLayout.fontSizeSmall,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEditExercise() async {
    if (_sessionService.isRunning) {
      await _stopSession();
    }
    
    if (!mounted) return;
    
    try {
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => ExerciseEditPage(
            initialExercise: _sessionService.currentExercise!,
            title: t.timer.customize,
             
          ),
        ),
      );
      
      if (result != null && result['exercise'] != null && mounted) {
        final updatedExercise = result['exercise'] as BreathingExercise;
        await _sessionService.updateExerciseSettings(updatedExercise);
        
        if (mounted) {
          setState(() {
            // Force UI update with new exercise
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // Failed to load exercise editor
      }
    }
  }

  @override
  void dispose() {
    // Stop session when leaving timer page
    if (_sessionService.isRunning) {
      _sessionService.stop().catchError((e) {
        debugPrint('Error stopping session in dispose: $e');
      });
    }
    super.dispose();
  }

  double _getScreenPadding(Size screenSize) {
    final double basePadding = AppLayout.minScreenPadding;
    final double maxPadding = AppLayout.maxScreenPadding;

    final double adaptivePadding =
        basePadding +
        (maxPadding - basePadding) *
            (screenSize.width / AppLayout.responsiveBreakpoint).clamp(0.0, 1.0);

    return adaptivePadding;
  }

  double _getContentWidth(Size screenSize) {
    final double availableWidth =
        screenSize.width - (_getScreenPadding(screenSize) * 2);
    return availableWidth.clamp(
      AppLayout.minContentWidth,
      AppLayout.maxContentWidth,
    );
  }

  bool _shouldUseHorizontalLayout(Size screenSize) {
    return screenSize.width > AppLayout.responsiveBreakpoint &&
        screenSize.height < AppLayout.responsiveBreakpoint &&
        screenSize.width / screenSize.height >
            AppLayout.wideAspectRatioThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool useHorizontalLayout = _shouldUseHorizontalLayout(screenSize);
    double contentWidth =
        (useHorizontalLayout ? 2 : 1) * _getContentWidth(screenSize);

    return Scaffold(
      appBar: AppBar(
        title: Text(_sessionService.currentExercise?.name ?? 'Exercise'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showExerciseDescription,
            tooltip: 'Description',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _sessionService.isRunning ? null : _navigateToEditExercise,
            tooltip: t.timer.customize,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: useHorizontalLayout
                        ? _buildHorizontalLayout()
                        : _buildVerticalLayout(),
                  ),
                ),
              ),
            ),
            if (!_sessionService.isRunning && !useHorizontalLayout) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: _buildControlsSection(),
              ),
              SizedBox(height: 80), // Space for floating action button
            ],
          ],
        ),
      ),
      floatingActionButton: useHorizontalLayout ? null : FloatingActionButton.extended(
        onPressed: () async {
          if (_sessionService.isRunning) {
            await _stopSession();
          } else {
            await _startSession();
          }
        },
        backgroundColor: _sessionService.isRunning ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
        icon: Icon(
          _sessionService.isRunning ? Icons.stop : Icons.play_arrow,
          color: Colors.black,
          size: 36,
        ),
        label: Text(
          _sessionService.isRunning ? t.timer.stop : t.timer.start,
          style: TextStyle(
            color: Colors.black,
            fontSize: AppLayout.fontSizeMedium,
          ),
        ),
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  Widget _buildVerticalLayout() {
    if (_sessionService.isRunning) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: _buildTimerSection()),
          SizedBox(height: AppLayout.sectionSpacingLarge * 2),
        ],
      );
    } else {
      return _buildScrollablePhasesList();
    }
  }

  Widget _buildHorizontalLayout() {
    // Same layout for both start and stop states on big screens
    return Column(
      children: [
        Expanded(
          child: _sessionService.isRunning? _buildTimerSection() :  
           Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildScrollablePhasesList(),
                    ),

                  ],
                ),
              ),
              SizedBox(width: AppLayout.sectionSpacingLarge),
              Expanded(
                flex: 1, 
                child: Center(child: _buildHorizontalControlsSection()),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: 200,
            height: 56,
            child: FloatingActionButton.extended(
              onPressed: () async {
                if (_sessionService.isRunning) {
                  await _stopSession();
                } else {
                  await _startSession();
                }
              },
              backgroundColor: _sessionService.isRunning ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
              icon: Icon(
                _sessionService.isRunning ? Icons.stop : Icons.play_arrow,
                color: Colors.black,
                size: 36,
              ),
              label: Text(
                _sessionService.isRunning ? t.timer.stop : t.timer.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: AppLayout.fontSizeMedium,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsSection() {
    final currentExercise = _sessionService.currentExercise;
    if (currentExercise == null) return const SizedBox();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (currentExercise.canEditCyclesCountCalculated)
              _buildStepper(
                label: t.timer.cycles,
                value: currentExercise.cycles,
                canDecrease: _sessionService.canDecreaseCycles(),
                canIncrease: _sessionService.canIncreaseCycles(),
                onDec: () async {
                  try {
                    final success = await _sessionService.decreaseCycles();
                    if (success) {
                      setState(() {}); // Force UI update
                    }
                  } catch (e) {
                    debugPrint('Error updating cycles: $e');
                  }
                },
                onInc: () async {
                  try {
                    final success = await _sessionService.increaseCycles();
                    if (success) {
                      setState(() {}); // Force UI update
                    }
                  } catch (e) {
                    debugPrint('Error updating cycles: $e');
                  }
                },
              )
            else
              _buildFixedValue(
                label: t.timer.cycles,
                value: currentExercise.cycles,
              ),
            
            if (currentExercise.canEditCycleDurationCalculated)
              _buildStepper(
                label: t.timer.time,
                value: currentExercise.cycleDuration,
                canDecrease: _sessionService.canDecreaseCycleDuration(),
                canIncrease: _sessionService.canIncreaseCycleDuration(),
                onDec: () async {
                  try {
                    final success = await _sessionService.decreaseCycleDuration();
                    if (success) {
                      setState(() {}); // Force UI update
                    }
                  } catch (e) {
                    debugPrint('Error updating cycle duration: $e');
                  }
                },
                onInc: () async {
                  try {
                    final success = await _sessionService.increaseCycleDuration();
                    if (success) {
                      setState(() {}); // Force UI update
                    }
                  } catch (e) {
                    debugPrint('Error updating cycle duration: $e');
                  }
                },
              )
            else
              _buildFixedValue(
                label: t.timer.time,
                value: currentExercise.cycleDuration,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHorizontalControlsSection() {
    final currentExercise = _sessionService.currentExercise;
    if (currentExercise == null) return const SizedBox();
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentExercise.canEditCyclesCountCalculated)
          _buildHorizontalStepper(
            label: t.timer.cycles,
            value: currentExercise.cycles,
            canDecrease: _sessionService.canDecreaseCycles(),
            canIncrease: _sessionService.canIncreaseCycles(),
            onDec: () async {
              try {
                final success = await _sessionService.decreaseCycles();
                if (success) {
                  setState(() {});
                }
              } catch (e) {
                debugPrint('Error updating cycles: $e');
              }
            },
            onInc: () async {
              try {
                final success = await _sessionService.increaseCycles();
                if (success) {
                  setState(() {});
                }
              } catch (e) {
                debugPrint('Error updating cycles: $e');
              }
            },
          )
        else
          _buildHorizontalFixedValue(
            label: t.timer.cycles,
            value: currentExercise.cycles,
          ),
        SizedBox(height: AppLayout.sectionSpacingLarge),
        if (currentExercise.canEditCycleDurationCalculated)
          _buildHorizontalStepper(
            label: t.timer.time,
            value: currentExercise.cycleDuration,
            canDecrease: _sessionService.canDecreaseCycleDuration(),
            canIncrease: _sessionService.canIncreaseCycleDuration(),
            onDec: () async {
              try {
                final success = await _sessionService.decreaseCycleDuration();
                if (success) {
                  setState(() {});
                }
              } catch (e) {
                debugPrint('Error updating cycle duration: $e');
              }
            },
            onInc: () async {
              try {
                final success = await _sessionService.increaseCycleDuration();
                if (success) {
                  setState(() {});
                }
              } catch (e) {
                debugPrint('Error updating cycle duration: $e');
              }
            },
          )
        else
          _buildHorizontalFixedValue(
            label: t.timer.time,
            value: currentExercise.cycleDuration,
          ),
      ],
    );
  }


  Widget _buildScrollablePhasesList() {
    final currentExercise = _sessionService.currentExercise;
    if (currentExercise == null) return const SizedBox();
    final phases = currentExercise.phases;
    
    return ListView.separated(
      itemCount: phases.length,
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final phase = phases[index];
        final hasRange = phase.minDuration != phase.maxDuration;
        final rangeText = hasRange ? '${phase.minDuration}s - ${phase.maxDuration}s' : '';
        final clapsText = phase.claps == 1 ? '1 clap' : '${phase.claps} claps';
        return ListTile(
          leading: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: phase.color,
              shape: BoxShape.circle,
            ),
          ),
          title: Text(
            phase.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: AppLayout.fontSizeSmall,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: hasRange ? Text(
            '$clapsText • Range: $rangeText',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppLayout.fontSizeSmall - 2,
            ),
          ) : Text(
            clapsText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppLayout.fontSizeSmall - 2,
            ),
          ),
          trailing: Text(
            '${phase.duration}s',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: AppLayout.fontSizeSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          dense: true,
        );
      },
    );
  }

  Widget _buildTimerSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildUnifiedProgressRing(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _sessionService.phaseLabel,
              style: TextStyle(
                color: _sessionService.phaseColor(context),
                fontSize: AppLayout.fontSizeMedium,
              ),
            ),
            SizedBox(height: AppLayout.spacingSmall),
            Text(
              !_sessionService.isDone
                  ? _sessionService.timerDisplay
                  : _sessionService.defaultTimerDisplay,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: AppLayout.fontSizeLarge,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: AppLayout.spacingMedium),
            Text(
              'Cycle ${_sessionService.currentCycle} / ${_sessionService.currentExercise?.cycles ?? 0}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: AppLayout.fontSizeSmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnifiedProgressRing() {
    // Don't show progress ring on small screens
    final screenSize = MediaQuery.of(context).size;
    if (screenSize.height < AppLayout.minContentHeight) {
      return SizedBox.shrink();
    }
    
    final currentExercise = _sessionService.currentExercise;
    if (currentExercise == null) {
      return SizedBox(
        width: AppLayout.progressCircleSize,
        height: AppLayout.progressCircleSize,
      );
    }

    // Calculate segment fractions based on phase durations
    final phases = currentExercise.phases;
    final totalCycles = currentExercise.cycles;
    final totalPhaseDuration = phases.fold(0.0, (sum, phase) => sum + phase.duration);
    final singleCycleSegmentFractions = phases.map((phase) => phase.duration / totalPhaseDuration).toList();
    final singleCycleSegmentColors = phases.map((phase) => phase.color).toList();
    
    // Repeat segments for all cycles
    final segmentFractions = <double>[];
    final segmentColors = <Color>[];
    for (int cycle = 0; cycle < totalCycles; cycle++) {
      segmentFractions.addAll(singleCycleSegmentFractions.map((fraction) => fraction / totalCycles));
      segmentColors.addAll(singleCycleSegmentColors);
    }

    // Calculate overall progress (across all cycles) - this represents total session progress
    final currentCycle = _sessionService.currentCycle;
    final currentCycleProgress = _sessionService.currentCycleProgress;
    final overallProgress = ((currentCycle - 1) + currentCycleProgress) / totalCycles;

    // Calculate current phase index and phase progress
    int currentPhaseIndex = 0;
    double phaseProgress = 0.0;
    
    // Find which phase we're currently in within the cycle
    double cumulativeProgress = 0.0;
    for (int i = 0; i < phases.length; i++) {
      double phaseEnd = cumulativeProgress + singleCycleSegmentFractions[i];
      if (currentCycleProgress <= phaseEnd || i == phases.length - 1) {
        currentPhaseIndex = i;
        phaseProgress = i == 0 ? 
          (currentCycleProgress / singleCycleSegmentFractions[i]).clamp(0.0, 1.0) :
          ((currentCycleProgress - cumulativeProgress) / singleCycleSegmentFractions[i]).clamp(0.0, 1.0);
        break;
      }
      cumulativeProgress = phaseEnd;
    }

    return UnifiedProgressRing(
      // Outer ring - shows all phases for all cycles
      outerRadius: AppLayout.progressCircleSize / 2,
      outerStrokeWidth: AppLayout.progressStrokeWidth,
      segmentFractions: segmentFractions,
      segmentColors: segmentColors,
      overallProgress: overallProgress,
      // Inner ring - shows current phase progress (completes full circle per phase)
      innerRadius: (AppLayout.progressCircleSize / 2) - 20,
      innerStrokeWidth: AppLayout.progressStrokeWidth - 2,
      innerProgress: phaseProgress,
      innerColor: singleCycleSegmentColors[currentPhaseIndex],
      innerBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      currentPhaseIndex: currentPhaseIndex,
      singleCycleColors: singleCycleSegmentColors,
      animationDuration: const Duration(milliseconds: 150),
    );
  }

  Widget _buildControlsRow({
    required int value,
    bool showButtons = true,
    bool canDecrease = false,
    bool canIncrease = false,
    VoidCallback? onDec,
    VoidCallback? onInc,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        showButtons ? IconButton(
          icon: Icon(
            Icons.remove_circle,
            color: canDecrease && !_sessionService.isRunning
                ? Theme.of(context).colorScheme.onSurfaceVariant 
                : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          onPressed: (canDecrease && !_sessionService.isRunning) ? onDec : null,
        ) : SizedBox(width: 48),
        Container(
          width: AppLayout.stepperValueWidth,
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              fontSize: AppLayout.fontSizeMedium * (value >= 100 ? 0.8 : 1.0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        showButtons ? IconButton(
          icon: Icon(
            Icons.add_circle,
            color: canIncrease && !_sessionService.isRunning
                ? Theme.of(context).colorScheme.onSurfaceVariant 
                : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          onPressed: (canIncrease && !_sessionService.isRunning) ? onInc : null,
        ) : SizedBox(width: 48),
      ],
    );
  }

  Widget _buildVerticalControl({
    required String label,
    required Widget controlsRow,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: AppLayout.fontSizeSmall,
          ),
        ),
        SizedBox(height: 8),
        controlsRow,
      ],
    );
  }

  Widget _buildHorizontalControl({
    required String label,
    required Widget controlsRow,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: AppLayout.fontSizeSmall,
          ),
        ),
        controlsRow,
      ],
    );
  }

  Widget _buildStepper({
    required String label,
    required int value,
    required bool canDecrease,
    required bool canIncrease,
    required VoidCallback onDec,
    required VoidCallback onInc,
  }) {
    return _buildVerticalControl(
      label: label,
      controlsRow: _buildControlsRow(
        value: value,
        showButtons: true,
        canDecrease: canDecrease,
        canIncrease: canIncrease,
        onDec: onDec,
        onInc: onInc,
      ),
    );
  }

 
  Widget _buildHorizontalStepper({
    required String label,
    required int value,
    required bool canDecrease,
    required bool canIncrease,
    required VoidCallback onDec,
    required VoidCallback onInc,
  }) {
    return _buildHorizontalControl(
      label: label,
      controlsRow: _buildControlsRow(
        value: value,
        showButtons: true,
        canDecrease: canDecrease,
        canIncrease: canIncrease,
        onDec: onDec,
        onInc: onInc,
      ),
    );
  }

  Widget _buildFixedValue({
    required String label,
    required int value,
  }) {
    return _buildVerticalControl(
      label: label,
      controlsRow: _buildControlsRow(
        value: value,
        showButtons: false,
      ),
    );
  }

  Widget _buildHorizontalFixedValue({
    required String label,
    required int value,
  }) {
    return _buildHorizontalControl(
      label: label,
      controlsRow: _buildControlsRow(
        value: value,
        showButtons: false,
      ),
    );
  }
}