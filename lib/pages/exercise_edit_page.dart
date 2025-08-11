import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';
import '../models/breathing_exercise.dart';
import '../services/storage_service.dart';
import '../services/exercise_service.dart';
import '../generated/l10n/app_localizations.dart';

/// Page for editing breathing exercise parameters including name, cycles and phases
class ExerciseEditPage extends StatefulWidget {
  final BreathingExercise initialExercise;
  final String title;

  const ExerciseEditPage({
    super.key,
    required this.initialExercise,
    this.title = '',
  });

  @override
  State<ExerciseEditPage> createState() => _ExerciseEditPageState();
}

class _ExerciseEditPageState extends State<ExerciseEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _minCyclesController;
  late TextEditingController _maxCyclesController;
  late TextEditingController _cycleDurationStepController;
  
  final StorageService _storageService = StorageService();
  final ExerciseService _exerciseService = ExerciseService();


  @override
  void initState() {
    super.initState();
    
    // Set the current exercise in the service
    _exerciseService.setCurrentExercise(widget.initialExercise);
    
    // Initialize controllers
    _nameController = TextEditingController(text: widget.initialExercise.name);
    _descriptionController = TextEditingController(text: widget.initialExercise.description);
    _minCyclesController = TextEditingController(text: widget.initialExercise.minCycles.toString());
    _maxCyclesController = TextEditingController(text: widget.initialExercise.maxCycles.toString());
    _cycleDurationStepController = TextEditingController(text: widget.initialExercise.cycleDurationStep.toString());
    
    // Listen to service changes
    _exerciseService.addListener(_onExerciseServiceChanged);
  }
  
  void _onExerciseServiceChanged() {
    setState(() {
      // Service state has changed, rebuild UI
    });
  }

  void _handleBackNavigation() {
    // Return the updated exercise when navigating back
    if (_exerciseService.currentExercise != null) {
      Navigator.of(context).pop({
        'exercise': _exerciseService.currentExercise!,
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _exerciseService.removeListener(_onExerciseServiceChanged);
    _exerciseService.clearCurrentExercise();
    _nameController.dispose();
    _descriptionController.dispose();
    _minCyclesController.dispose();
    _maxCyclesController.dispose();
    _cycleDurationStepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Handle back navigation manually
          _handleBackNavigation();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title.isEmpty ? AppLocalizations.of(context).edit : widget.title),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _handleBackNavigation,
            ),
            actions: [],
          ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppLayout.maxScreenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // General error display
                if (_exerciseService.generalError != null) ...[
                  _buildErrorCard(_exerciseService.generalError!),
                  SizedBox(height: AppLayout.sectionSpacingMedium),
                ],

                // Exercise Name and Description Section
                _buildExerciseInfoSection(),
                SizedBox(height: AppLayout.sectionSpacingLarge),

                // Phases editing section
                _buildPhasesSection(),
                
                SizedBox(height: AppLayout.sectionSpacingLarge),

                // Cycles configuration section (moved to end)
                _buildCyclesConfigurationSection(),
                SizedBox(height: AppLayout.sectionSpacingLarge),

                // Total duration display
                _buildTotalDurationSection(),
                
                SizedBox(height: AppLayout.sectionSpacingLarge),

              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _exerciseService.canAddPhase() ? () {
            _exerciseService.addPhase(context);
            if (_exerciseService.currentExercise != null) {
              _storageService.saveExercise(_exerciseService.currentExercise!);
            }
          } : null,
          backgroundColor: _exerciseService.canAddPhase()
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          foregroundColor: Theme.of(context).colorScheme.surface,
          tooltip: AppLocalizations.of(context).addPhase,
          shape: CircleBorder(),
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: EdgeInsets.all(AppLayout.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        border: Border(
          left: BorderSide(color: Theme.of(context).colorScheme.error, width: 3),
          top: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3), width: 1),
          right: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3), width: 1),
          bottom: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
          SizedBox(width: AppLayout.spacingMedium),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: AppLayout.fontSizeSmall,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInfoSection() {
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
              Icon(
                Icons.edit_note,
                color: Theme.of(context).colorScheme.primary,
                size: AppLayout.iconSizeSmall,
              ),
              SizedBox(width: AppLayout.spacingSmall),
              Text(
                AppLocalizations.of(context).information,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: AppLayout.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppLayout.spacingMedium),
          child: Column(
            children: [
              // Exercise name field
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).name,
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  prefixIcon: Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                onChanged: (value) {
                  _exerciseService.updateExerciseName(value);
                  if (_exerciseService.currentExercise != null) {
                    _storageService.saveExercise(_exerciseService.currentExercise!);
                  }
                },
              ),
              
              SizedBox(height: AppLayout.spacingMedium),
              
              // Exercise description field
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).description,
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  prefixIcon: Icon(Icons.description, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                onChanged: (value) {
                  _exerciseService.updateExerciseDescription(value);
                  if (_exerciseService.currentExercise != null) {
                    _storageService.saveExercise(_exerciseService.currentExercise!);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildCyclesConfigurationSection() {
    final currentExercise = _exerciseService.currentExercise;
    final currentPhases = _exerciseService.currentPhases;
    
    if (currentExercise == null || currentPhases == null) {
      return Container();
    }
    
    final minCycles = int.tryParse(_minCyclesController.text) ?? currentExercise.minCycles;
    final maxCycles = int.tryParse(_maxCyclesController.text) ?? currentExercise.maxCycles;
    final cycleDurationStep = int.tryParse(_cycleDurationStepController.text) ?? currentExercise.cycleDurationStep;
    
    // Calculate if cycle duration editing should be enabled
    final minCycleDuration = _exerciseService.getMinTotalDuration();
    final maxCycleDuration = _exerciseService.getMaxTotalDuration();

    
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
              Icon(
                Icons.tune,
                color: Theme.of(context).colorScheme.primary,
                size: AppLayout.iconSizeSmall,
              ),
              SizedBox(width: AppLayout.spacingSmall),
              Text(
                AppLocalizations.of(context).configuration,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: AppLayout.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppLayout.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            
            // Cycles Configuration
            Text(
              AppLocalizations.of(context).cycles,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: AppLayout.fontSizeMedium,
              ),
            ),
            SizedBox(height: AppLayout.sectionSpacingSmall),
            
            // When cycles editing is enabled, show min/max fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minCyclesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).min,
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      final minCycles = int.tryParse(value) ?? 1;
                      final maxCycles = int.tryParse(_maxCyclesController.text) ?? minCycles;
                      _exerciseService.updateExerciseCycles(minCycles, maxCycles);
                      if (_exerciseService.currentExercise != null) {
                        _storageService.saveExercise(_exerciseService.currentExercise!);
                      }
                    },
                  ),
                ),
                SizedBox(width: AppLayout.spacingSmall),
                Expanded(
                  child: TextFormField(
                    controller: _maxCyclesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).max,
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      final minCycles = int.tryParse(_minCyclesController.text) ?? 1;
                      final maxCycles = int.tryParse(value) ?? minCycles;
                      _exerciseService.updateExerciseCycles(minCycles, maxCycles);
                      if (_exerciseService.currentExercise != null) {
                        _storageService.saveExercise(_exerciseService.currentExercise!);
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppLayout.sectionSpacingSmall),
            Text(
              '${AppLocalizations.of(context).cycles}: $minCycles-$maxCycles',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: AppLayout.fontSizeSmall,
              ),
            ),
            // Cycle Duration Step Configuration
            if (_exerciseService.canEditCycleDuration()) ...[
              SizedBox(height: AppLayout.sectionSpacingMedium),
              Text(
                AppLocalizations.of(context).step,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: AppLayout.fontSizeMedium,
                  ),
              ),
              SizedBox(height: AppLayout.sectionSpacingSmall),
              TextFormField(
                controller: _cycleDurationStepController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).step,
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                onChanged: (value) {
                  final cycleDurationStep = int.tryParse(value) ?? 5;
                  _exerciseService.updateCycleDurationStep(cycleDurationStep);
                  if (_exerciseService.currentExercise != null) {
                    _storageService.saveExercise(_exerciseService.currentExercise!);
                  }
                },
              ),
              SizedBox(height: AppLayout.sectionSpacingSmall),
              Text(
                '${AppLocalizations.of(context).step}: ${cycleDurationStep}s (${minCycleDuration}s-${maxCycleDuration}s)',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: AppLayout.fontSizeSmall,
                ),
              ),
            ],
            ],
          ),
        ),
      ],
    );
  }
  

  Widget _buildPhasesSection() {
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
              Icon(
                Icons.timeline,
                color: Theme.of(context).colorScheme.primary,
                size: AppLayout.iconSizeSmall,
              ),
              SizedBox(width: AppLayout.spacingSmall),
              Text(
                AppLocalizations.of(context).phases,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: AppLayout.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ), 
            ],
          ),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _exerciseService.phaseCount,
          onReorder: (oldIndex, newIndex) => _exerciseService.reorderPhases(oldIndex, newIndex),
          itemBuilder: (context, index) {
            return _buildPhaseCard(index);
          },
        ),
      ],
    );
  }

Widget _buildPhaseCard(int index) {
  final currentPhases = _exerciseService.currentPhases;
  if (currentPhases == null || index >= currentPhases.length) {
    return Container();
  }
  
  final phase = currentPhases[index];
  final hasError = _exerciseService.phaseErrors.containsKey(index);

  return Container(
    key: ValueKey(index),
    margin: EdgeInsets.only(bottom: 1),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: hasError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
          width: hasError ? 2 : 1,
        ),
        left: hasError ? BorderSide(color: Theme.of(context).colorScheme.error, width: 3) : BorderSide.none,
      ),
      color: hasError ? Theme.of(context).colorScheme.error.withValues(alpha: 0.05) : null,
    ),
    child: Padding(
      padding: EdgeInsets.all(AppLayout.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main row: Color | Name and Min/Max | Buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // First column - Color and Sound
              Column(
                children: [
                  _buildColorPicker(index, phase.color),
                  SizedBox(height: AppLayout.spacingSmall),
                  _buildClapsSelector(index, phase.claps),
                ],
              ),
              
              SizedBox(width: AppLayout.spacingSmall),
              
              // Second column - Name and Min/Max
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First row - phase name
                    TextFormField(
                      initialValue: phase.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: AppLayout.fontSizeSmall,
                          ),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).name,
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        _exerciseService.updatePhaseName(index, value);
                        if (_exerciseService.currentExercise != null) {
                          _storageService.saveExercise(_exerciseService.currentExercise!);
                        }
                      },
                    ),
                    
                    SizedBox(height: AppLayout.sectionSpacingSmall),
                    
 
                      _buildDurationRangeControls(index)
 
                  ],
                ),
              ),
              
              SizedBox(width: AppLayout.spacingSmall),
              
              // Third column - Buttons
              Column(
                children: [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onSelected: (value) {
                      switch (value) {
                        case 'duplicate':
                          _exerciseService.duplicatePhase(index);
                          if (_exerciseService.currentExercise != null) {
                            _storageService.saveExercise(_exerciseService.currentExercise!);
                          }
                          break;
                        case 'delete':
                          if (_exerciseService.canRemovePhase()) {
                            _exerciseService.removePhase(index);
                            if (_exerciseService.currentExercise != null) {
                              _storageService.saveExercise(_exerciseService.currentExercise!);
                            }
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'duplicate',
                        enabled: _exerciseService.canAddPhase(),
                        child: Row(
                          children: [
                            Icon(Icons.content_copy, 
                                 color: _exerciseService.canAddPhase() 
                                     ? Theme.of(context).colorScheme.onSurface 
                                     : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                            SizedBox(width: 8),
                            Text(AppLocalizations.of(context).duplicate,
                                 style: TextStyle(
                                   color: _exerciseService.canAddPhase() 
                                       ? Theme.of(context).colorScheme.onSurface 
                                       : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        enabled: _exerciseService.canRemovePhase(),
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, 
                                 color: _exerciseService.canRemovePhase() 
                                     ? Theme.of(context).colorScheme.error 
                                     : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                            SizedBox(width: 8),
                            Text(AppLocalizations.of(context).delete,
                                 style: TextStyle(
                                   color: _exerciseService.canRemovePhase() 
                                       ? Theme.of(context).colorScheme.error 
                                       : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          // Error message (if any)
          if (hasError) ...[
            SizedBox(height: AppLayout.spacingSmall),
            Text(
              _exerciseService.phaseErrors[index]!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: AppLayout.fontSizeSmall,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _buildColorPicker(int index, Color currentColor) {
    final availableColors = _exerciseService.getAvailableColors(context);
    final currentPhases = _exerciseService.currentPhases;
    
    return PopupMenuButton<Color>(
      icon: Icon(Icons.circle, color: currentColor),
      itemBuilder: (context) => availableColors.map((color) {
        return PopupMenuItem<Color>(
          value: color,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              if (currentPhases != null && index < currentPhases.length && color == currentPhases[index].color) ...[
                SizedBox(width: 8),
                Icon(Icons.check, color: Theme.of(context).colorScheme.onSurface, size: 16),
              ],
            ],
          ),
        );
      }).toList(),
      onSelected: (color) {
        _exerciseService.updatePhaseColor(index, color);
        if (_exerciseService.currentExercise != null) {
          _storageService.saveExercise(_exerciseService.currentExercise!);
        }
      },
    );
  }

  Widget _buildClapsSelector(int index, int currentClaps) {
    return PopupMenuButton<int>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 16),
          Text(
            '$currentClaps',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: AppLayout.fontSizeSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      itemBuilder: (context) => [1, 2, 3].map((claps) {
        return PopupMenuItem<int>(
          value: claps,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 16),
              SizedBox(width: 8),
              Text(
                claps == 1 ? AppLocalizations.of(context).oneClap : AppLocalizations.of(context).clapsCount(claps),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              if (claps == currentClaps) ...[
                SizedBox(width: 8),
                Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 16),
              ],
            ],
          ),
        );
      }).toList(),
      onSelected: (claps) {
        _exerciseService.updatePhaseClaps(index, claps);
        if (_exerciseService.currentExercise != null) {
          _storageService.saveExercise(_exerciseService.currentExercise!);
        }
      },
    );
  }

  Widget _buildDurationRangeControls(int index) {
    final currentPhases = _exerciseService.currentPhases;
    if (currentPhases == null || index >= currentPhases.length) {
      return Container();
    }
    
    final phase = currentPhases[index];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: phase.minDuration.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: AppLayout.fontSizeSmall,
                ),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).min,
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                onChanged: (value) {
                  final duration = int.tryParse(value);
                  if (duration != null && duration >= 0) {
                    _exerciseService.updatePhaseMinDuration(index, duration);
                    if (_exerciseService.currentExercise != null) {
                      _storageService.saveExercise(_exerciseService.currentExercise!);
                    }
                  }
                },
              ),
            ),
            SizedBox(width: AppLayout.spacingSmall),
            Expanded(
              child: TextFormField(
                initialValue: phase.maxDuration.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: AppLayout.fontSizeSmall,
                ),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).max,
                  hintText: phase.maxDuration.toString().isEmpty ? phase.minDuration.toString() : null,
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                onChanged: (value) {
                  final duration = int.tryParse(value);
                  if (duration != null && duration >= 0) {
                    _exerciseService.updatePhaseMaxDuration(index, duration);
                    if (_exerciseService.currentExercise != null) {
                      _storageService.saveExercise(_exerciseService.currentExercise!);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildTotalDurationSection() {
    if (!_exerciseService.hasValidExercise) {
      return Container();
    }
    
    final minTotal = _exerciseService.getMinTotalDuration();
    final maxTotal = _exerciseService.getMaxTotalDuration();
    final currentTotal = _exerciseService.getCurrentTotalDuration();

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
              Icon(
                Icons.timer,
                color: Theme.of(context).colorScheme.primary,
                size: AppLayout.iconSizeSmall,
              ),
              SizedBox(width: AppLayout.spacingSmall),
              Text(
                AppLocalizations.of(context).cycleDuration,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: AppLayout.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppLayout.spacingMedium),
          child: _exerciseService.canEditCycleDuration()
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDurationInfo(AppLocalizations.of(context).minimum, minTotal, Theme.of(context).colorScheme.onSurfaceVariant),
                    _buildDurationInfo(AppLocalizations.of(context).current, currentTotal, Theme.of(context).colorScheme.primary),
                    _buildDurationInfo(AppLocalizations.of(context).maximum, maxTotal, Theme.of(context).colorScheme.onSurfaceVariant),
                  ],
                )
              : Center(
                  child: _buildDurationInfo(AppLocalizations.of(context).total, currentTotal, Theme.of(context).colorScheme.primary),
                ),
        ),
      ],
    );
  }

  Widget _buildDurationInfo(String label, int duration, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: AppLayout.fontSizeSmall,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${duration}s',
          style: TextStyle(
            color: color,
            fontSize: AppLayout.fontSizeMedium,
          ),
        ),
      ],
    );
  }




}