import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'exercise_edit_page.dart';
import '../models/breathing_exercise.dart';
import '../services/storage_service.dart';
import '../services/exercise_service.dart';
import '../services/session_service.dart';

class ExercisesPage extends StatefulWidget {
  final Function(BreathingExercise)? onExerciseSelected;

  const ExercisesPage({super.key, this.onExerciseSelected});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final StorageService _storageService = StorageService();
  final ExerciseService _exerciseService = ExerciseService();
  final SessionService _sessionService = SessionService();
  late Future<List<BreathingExercise>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _refreshExercises();
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
    final newExercise = _exerciseService.createCustomExercise();
    _storageService.saveExercise(newExercise);
    await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => ExerciseEditPage(
          initialExercise: newExercise,
          title: 'New Exercise',
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
          title: 'Edit',
        ),
      ),
    );
    _refreshExercises();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercises'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<BreathingExercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading exercises: ${snapshot.error}',
                style: TextStyle(color: AppColors.textSecondary),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewExercise,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        tooltip: 'Add Exercise',
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
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
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No exercises yet',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppLayout.fontSizeMedium,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first exercise',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: AppLayout.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(List<BreathingExercise> exercises) {
    return ListView.separated(
      itemCount: exercises.length,
      separatorBuilder: (context, index) => Divider(
        color: AppColors.textSecondary.withValues(alpha: 0.2),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final isCurrentExercise = _sessionService.currentExercise?.id == exercise.id;
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          dense: false,
          selected: isCurrentExercise,
          selectedTileColor: AppColors.selected.withValues(alpha: 0.1),
          leading: Icon(
            isCurrentExercise ? Icons.timer : Icons.list_alt,
            color: isCurrentExercise ? AppColors.selected : AppColors.textPrimary,
            size: 28,
          ),
          title: Text(
            exercise.name,
            style: TextStyle(
              color: isCurrentExercise ? AppColors.selected : AppColors.textPrimary,
              fontSize: AppLayout.fontSizeSmall,
              fontWeight: isCurrentExercise ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${exercise.cycles} cycles • ${exercise.cycleDuration}s duration',
            style: TextStyle(
              color: isCurrentExercise ? AppColors.selected.withValues(alpha: 0.8) : AppColors.textSecondary,
              fontSize: AppLayout.fontSizeSmall - 2,
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textSecondary,
              size: 20,
            ),
            color: AppColors.cardBackground,
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editExercise(exercise);
                  break;
                case 'duplicate':
                  _duplicateExercise(exercise);
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
                    Icon(Icons.edit, color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 8),
                    Text('Duplicate', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
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

  Future<void> _deleteExercise(BreathingExercise exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text("Delete Exercise", style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          "Are you sure you want to delete \"${exercise.name}\"?",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Delete", style: TextStyle(color: AppColors.error)),
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

}