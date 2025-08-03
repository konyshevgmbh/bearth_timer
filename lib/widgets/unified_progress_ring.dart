import 'dart:math';
import 'package:flutter/material.dart';

class UnifiedProgressRing extends StatefulWidget {
  // Outer ring properties (multi-color segments)
  final double outerRadius;
  final double outerStrokeWidth;
  final List<double> segmentFractions;
  final List<Color> segmentColors;
  final double overallProgress;
  
  // Inner ring properties (current phase)
  final double innerRadius;
  final double innerStrokeWidth;
  final double innerProgress;
  final Color innerColor;
  final Color innerBackgroundColor;
  final int currentPhaseIndex;
  final List<Color> singleCycleColors;

  const UnifiedProgressRing({
    super.key,
    required this.outerRadius,
    required this.outerStrokeWidth,
    required this.segmentFractions,
    required this.segmentColors,
    required this.overallProgress,
    required this.innerRadius,
    required this.innerStrokeWidth,
    required this.innerProgress,
    required this.innerColor,
    required this.innerBackgroundColor,
    required this.currentPhaseIndex,
    required this.singleCycleColors,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  final Duration animationDuration;

  @override
  State<UnifiedProgressRing> createState() => _UnifiedProgressRingState();
}

class _UnifiedProgressRingState extends State<UnifiedProgressRing>
    with TickerProviderStateMixin {
  late AnimationController _overallProgressController;
  late AnimationController _innerProgressController;
  late Animation<double> _overallProgressAnimation;
  late Animation<double> _innerProgressAnimation;
  
  double _previousOverallProgress = 0.0;
  double _previousInnerProgress = 0.0;
  int _previousPhaseIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _overallProgressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _innerProgressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _overallProgressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.overallProgress,
    ).animate(CurvedAnimation(
      parent: _overallProgressController,
      curve: Curves.easeInOut,
    ));
    
    _innerProgressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.innerProgress,
    ).animate(CurvedAnimation(
      parent: _innerProgressController,
      curve: Curves.easeInOut,
    ));
    
    _previousOverallProgress = widget.overallProgress;
    _previousInnerProgress = widget.innerProgress;
    _previousPhaseIndex = widget.currentPhaseIndex;
    
    _overallProgressController.forward();
    _innerProgressController.forward();
  }

  @override
  void didUpdateWidget(UnifiedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle overall progress animation
    if ((widget.overallProgress - _previousOverallProgress).abs() > 0.001) {
      _overallProgressAnimation = Tween<double>(
        begin: _previousOverallProgress,
        end: widget.overallProgress,
      ).animate(CurvedAnimation(
        parent: _overallProgressController,
        curve: Curves.easeInOut,
      ));
      
      _overallProgressController.reset();
      _overallProgressController.forward();
      _previousOverallProgress = widget.overallProgress;
    }
    
    // Handle inner progress animation
    // Reset to 0 when phase changes, then animate to new progress
    if (widget.currentPhaseIndex != _previousPhaseIndex) {
      _innerProgressAnimation = Tween<double>(
        begin: 0.0,
        end: widget.innerProgress,
      ).animate(CurvedAnimation(
        parent: _innerProgressController,
        curve: Curves.easeInOut,
      ));
      
      _innerProgressController.reset();
      _innerProgressController.forward();
      _previousPhaseIndex = widget.currentPhaseIndex;
      _previousInnerProgress = widget.innerProgress;
    } else if ((widget.innerProgress - _previousInnerProgress).abs() > 0.001) {
      _innerProgressAnimation = Tween<double>(
        begin: _previousInnerProgress,
        end: widget.innerProgress,
      ).animate(CurvedAnimation(
        parent: _innerProgressController,
        curve: Curves.easeInOut,
      ));
      
      _innerProgressController.reset();
      _innerProgressController.forward();
      _previousInnerProgress = widget.innerProgress;
    }
  }

  @override
  void dispose() {
    _overallProgressController.dispose();
    _innerProgressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        final minSize = min (availableHeight , availableWidth );
        
        final safeSize = minSize ;
        final scaledOuterRadius = safeSize / 2 * (widget.outerRadius / (widget.outerRadius + widget.outerStrokeWidth));
        final scaledInnerRadius = safeSize / 2 * (widget.innerRadius / (widget.outerRadius + widget.outerStrokeWidth));
        
        return Center(
          child: SizedBox(
            width: safeSize,
            height: safeSize,
            child: AnimatedBuilder(
              animation: Listenable.merge([_overallProgressAnimation, _innerProgressAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  size: Size(safeSize, safeSize),
                  painter: _UnifiedProgressPainter(
                    outerRadius: scaledOuterRadius,
                    outerStrokeWidth: widget.outerStrokeWidth,
                    segmentFractions: widget.segmentFractions,
                    segmentColors: widget.segmentColors,
                    overallProgress: _overallProgressAnimation.value,
                    innerRadius: scaledInnerRadius,
                    innerStrokeWidth: widget.innerStrokeWidth,
                    innerProgress: _innerProgressAnimation.value,
                    innerColor: widget.innerColor,
                    innerBackgroundColor: widget.innerBackgroundColor,
                    currentPhaseIndex: widget.currentPhaseIndex,
                    singleCycleColors: widget.singleCycleColors,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _UnifiedProgressPainter extends CustomPainter {
  final double outerRadius;
  final double outerStrokeWidth;
  final List<double> segmentFractions;
  final List<Color> segmentColors;
  final double overallProgress;
  final double innerRadius;
  final double innerStrokeWidth;
  final double innerProgress;
  final Color innerColor;
  final Color innerBackgroundColor;
  final int currentPhaseIndex;
  final List<Color> singleCycleColors;

  _UnifiedProgressPainter({
    required this.outerRadius,
    required this.outerStrokeWidth,
    required this.segmentFractions,
    required this.segmentColors,
    required this.overallProgress,
    required this.innerRadius,
    required this.innerStrokeWidth,
    required this.innerProgress,
    required this.innerColor,
    required this.innerBackgroundColor,
    required this.currentPhaseIndex,
    required this.singleCycleColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    
    // Paint for outer ring
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerStrokeWidth
      ..strokeCap = StrokeCap.round;

    // Paint for inner ring
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerStrokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw outer ring background
    outerPaint.color = innerBackgroundColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      0,
      2 * pi,
      false,
      outerPaint,
    );

    // Draw outer ring segments with progress
    double startAngle = -pi / 2;
    double cumulativeProgress = 0;
    
    for (int i = 0; i < segmentFractions.length; i++) {
      double segmentEnd = cumulativeProgress + segmentFractions[i];
      double segmentSweep = 2 * pi * segmentFractions[i];
      
      if (overallProgress > cumulativeProgress) {
        double segmentProgress = ((overallProgress - cumulativeProgress) / segmentFractions[i]).clamp(0.0, 1.0);
        double drawSweep = segmentSweep * segmentProgress;
        
        outerPaint.color = segmentColors[i];
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: outerRadius),
          startAngle,
          drawSweep,
          false,
          outerPaint,
        );
      }
      
      startAngle += segmentSweep;
      cumulativeProgress = segmentEnd;
    }

    // Draw inner ring background
    innerPaint.color = innerBackgroundColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      0,
      2 * pi,
      false,
      innerPaint,
    );

    // Draw inner ring progress - current phase progress only
    innerPaint.color = singleCycleColors[currentPhaseIndex];
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      -pi / 2,
      2 * pi * innerProgress,
      false,
      innerPaint,
    );

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}