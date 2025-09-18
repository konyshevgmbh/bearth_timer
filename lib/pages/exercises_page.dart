import 'package:flutter/material.dart';
import '../i18n/strings.g.dart';
import '../core/constants.dart';
import 'exercise_edit_page.dart';
import '../models/breathing_exercise.dart';
import '../services/storage_service.dart';
import '../services/exercise_service.dart';
import '../services/session_service.dart';
import '../services/export_import_service.dart';

class ExercisesPage extends StatefulWidget {
  final Function(BreathingExercise)? onExerciseSelected;

  const ExercisesPage({super.key, this.onExerciseSelected});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> with TickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  final ExerciseService _exerciseService = ExerciseService();
  final SessionService _sessionService = SessionService();
  final ExportImportService _exportImportService = ExportImportService();
  late Future<List<BreathingExercise>> _exercisesFuture;
  
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    _refreshExercises();
    
    // Initialize FAB animation
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    
    // Listen for session changes to update selection state
    _sessionService.events.listen((_) {
      if (mounted) {
        setState(() {
          // Trigger rebuild when session state changes
        });
      }
    });
  }

  void _refreshExercises() {
    setState(() {
      _exercisesFuture = _storageService.loadExercises();
    });
  }


  Future<void> _addNewExercise() async {
    final newExercise = _exerciseService.createCustomExercise(context);
    _storageService.saveExercise(newExercise);
    await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => ExerciseEditPage(
          initialExercise: newExercise,
          title: t.newExercise,
        ),
      ),
    );
    _refreshExercises();
  }

  Future<void> _editExercise(BreathingExercise exercise) async {
    await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => ExerciseEditPage(
          initialExercise: exercise,
          title: t.edit,
        ),
      ),
    );
    _refreshExercises();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.exercises),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        automaticallyImplyLeading: false,
        actions: [],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<List<BreathingExercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                t.errorLoadingExercises(error: snapshot.error.toString()),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            );
          }
          
          final exercises = snapshot.data ?? [];
          
          return Padding(
            padding: EdgeInsets.all(16),
            child: exercises.isEmpty
                ? _buildEmptyState()
                : _buildExercisesList(exercises),
          );
        },
      ),
      floatingActionButton: _buildExpandableFab(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          Text(
            t.noExercisesYet,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppLayout.fontSizeMedium,
            ),
          ),
          SizedBox(height: 8),
          Text(
            t.createYourFirstExercise,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: AppLayout.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(List<BreathingExercise> exercises) {
    // Sort exercises alphabetically by name
    exercises.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    
    return ListView.separated(
      itemCount: exercises.length,
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final isCurrentExercise = _sessionService.currentExercise?.id == exercise.id;
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          dense: false,
          selected: isCurrentExercise,
          selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          leading: Icon(
            isCurrentExercise ? Icons.timer : Icons.list_alt,
            color: isCurrentExercise ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
            size: 28,
          ),
          title: Text(
            exercise.name,
            style: TextStyle(
              color: isCurrentExercise ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              fontSize: AppLayout.fontSizeSmall,
              fontWeight: isCurrentExercise ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          subtitle: Text(
            t.exerciseSummary(cycles: exercise.cycles, duration: exercise.cycleDuration),
            style: TextStyle(
              color: isCurrentExercise ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.8) : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppLayout.fontSizeSmall - 2,
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editExercise(exercise);
                  break;
                case 'duplicate':
                  _duplicateExercise(exercise);
                  break;
                case 'export':
                  _exportExercise(exercise);
                  break;
                case 'delete':
                  _deleteExercise(exercise);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface, size: 20),
                    SizedBox(width: 8),
                    Text(t.edit, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, color: Theme.of(context).colorScheme.onSurface, size: 20),
                    SizedBox(width: 8),
                    Text(t.duplicate, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_upload, color: Theme.of(context).colorScheme.onSurface, size: 20),
                    SizedBox(width: 8),
                    Text(t.export, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Theme.of(context).colorScheme.error, size: 20),
                    SizedBox(width: 8),
                    Text(t.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            // Exercise selection handled by callback
            if (widget.onExerciseSelected != null) {
              widget.onExerciseSelected!(exercise);
            }
          },
        );
      },
    );
  }

  Future<void> _duplicateExercise(BreathingExercise exercise) async {
      BreathingExercise? duplicatedExercise = await _storageService.duplicateExercise(exercise.id);
      
      if (duplicatedExercise != null) {
        _editExercise(duplicatedExercise);
      }
        
  }

  Future<void> _exportExercise(BreathingExercise exercise) async {
    try {
      await _exportImportService.exportExerciseToFile(exercise);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            title: Text(t.exportFailed, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            content: Text(
              t.failedToExportExercise(error: e.toString()),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t.ok, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _importExercise() async {
    try {
      final result = await _exportImportService.importAndAddExercise();
      if (mounted) {
        if (result.success) {
          _refreshExercises();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
              title: Text(t.importSuccessful, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              content: Text(
                result.summary,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.ok, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
              title: Text(t.importFailed, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              content: Text(
                result.error ?? t.importFailed,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.ok, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            title: Text(t.importFailed, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            content: Text(
              t.failedToImportExercise(error: e.toString()),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t.ok, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _deleteExercise(BreathingExercise exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        title: Text(t.deleteExercise, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          t.confirmDeleteExercise(name: exercise.name),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancel, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteExercise(exercise.id);
        _refreshExercises(); // Trigger rebuild with fresh data
      } catch (e) {
        // Failed to delete exercise
      }
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
  }

  Widget _buildExpandableFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Import Exercise FAB
        AnimatedBuilder(
          animation: _fabAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabAnimation.value,
              child: Opacity(
                opacity: _fabAnimation.value,
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: FloatingActionButton(
                    heroTag: "import_fab",
                    onPressed: _isFabExpanded ? () {
                      _toggleFab();
                      _importExercise();
                    } : null,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    tooltip: t.importExercise,
                    shape: CircleBorder(),
                    child: Icon(Icons.file_download),
                  ),
                ),
              ),
            );
          },
        ),
        // Add Exercise FAB
        AnimatedBuilder(
          animation: _fabAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabAnimation.value,
              child: Opacity(
                opacity: _fabAnimation.value,
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: FloatingActionButton(
                    heroTag: "add_fab",
                    onPressed: _isFabExpanded ? () {
                      _toggleFab();
                      _addNewExercise();
                    } : null,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    tooltip: t.addExercise,
                    shape: CircleBorder(),
                    child: Icon(Icons.edit),
                  ),
                ),
              ),
            );
          },
        ),
        // Main FAB
        FloatingActionButton(
          heroTag: "main_fab",
          onPressed: _toggleFab,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.surface,
          tooltip: _isFabExpanded ? t.close : t.addExercise,
          shape: CircleBorder(),
          child: AnimatedRotation(
            turns: _isFabExpanded ? 0.125 : 0.0, // 45 degrees when expanded
            duration: Duration(milliseconds: 250),
            child: Icon(_isFabExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }

}