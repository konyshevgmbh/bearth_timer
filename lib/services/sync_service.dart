import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/training_result.dart';
import '../models/user_settings.dart';
import '../models/breathing_exercise.dart';
import '../models/breath_phase.dart';
import '../core/constants.dart';
import 'storage_service.dart';
import '../i18n/strings.g.dart';

enum SyncStatus { synced, syncing, offline, error, pendingChanges }

/// Service for cloud synchronization and data export/import
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  SyncStatus _currentStatus = SyncStatus.offline;

  final StorageService _storageService = StorageService();

  bool get isOnline => _currentStatus != SyncStatus.offline;
  bool get isLoggedIn => Supabase.instance.client.auth.currentUser != null;

  static Future<void> initialize() async {
    if (!SupabaseConstants.isConfigured) {
      debugPrint(
        '⚠️  Supabase not configured. Please update SupabaseConstants with your project URL and anon key.',
      );
      debugPrint(
        '   Get them from: https://app.supabase.com -> Project Settings -> API',
      );
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConstants.supabaseUrl,
        anonKey: SupabaseConstants.supabaseAnonKey,
        headers: {
          'User-Agent': 'BearthTimer',
          'X-Supabase-Client-Platform-Version': '1.0.0',
        },
      );
      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      debugPrint('❌ Supabase initialization failed: $e');
      debugPrint('   Check your URL and anon key in SupabaseConstants');
    }
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  Future<bool> signUp(String email, String password) async {
    if (!SupabaseConstants.isConfigured) {
      throw Exception(t.services.sync.supabaseNotConfigured);
    }

    try {
      _updateStatus(SyncStatus.syncing);
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _performInitialSync();
        return true;
      }
      _updateStatus(SyncStatus.error);
      return false;
    } on AuthException catch (e) {
      debugPrint('Sign up auth error: ${e.message}');
      _updateStatus(SyncStatus.error);
      throw Exception(t.services.sync.signUpFailed(error: e.message));
    } catch (e) {
      debugPrint('Sign up error: $e');
      _updateStatus(SyncStatus.error);
      throw Exception(t.services.sync.signUpFailedGeneric);
    }
  }

  Future<bool> signIn(String email, String password) async {
    if (!SupabaseConstants.isConfigured) {
      throw Exception(t.services.sync.supabaseNotConfigured);
    }

    try {
      _updateStatus(SyncStatus.syncing);
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _performInitialSync();
        return true;
      }
      _updateStatus(SyncStatus.error);
      return false;
    } on AuthException catch (e) {
      debugPrint('Sign in auth error: ${e.message}');
      _updateStatus(SyncStatus.error);
      if (e.message.contains('Invalid login credentials')) {
        throw Exception(t.services.sync.invalidEmailPassword);
      }
      throw Exception(t.services.sync.signInFailed(error: e.message));
    } catch (e) {
      debugPrint('Sign in error: $e');
      _updateStatus(SyncStatus.error);
      throw Exception(t.services.sync.signInFailedGeneric);
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      _updateStatus(SyncStatus.offline);
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  Future<void> _performInitialSync() async {
    try {
      _updateStatus(SyncStatus.syncing);
      await _syncExercises();
      await _syncTrainingResults();
      await _syncUserSettings();
      _updateStatus(SyncStatus.synced);
    } catch (e) {
      debugPrint('Initial sync error: $e');
      _updateStatus(SyncStatus.error);
    }
  }

  Future<void> _syncTrainingResults() async {
    if (!isLoggedIn) return;

    try {
      final localResults = await _storageService.getAllResultsIncludingDeleted();

      // Fetch all training results including deleted ones for proper sync
      final response = await Supabase.instance.client
          .from(SupabaseConstants.trainingResultsTable)
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

      final cloudResults =
          (response as List)
              .map((row) => TrainingResult.fromJson(row))
              .toList();

      final mergedResults = _mergeTrainingResults(localResults, cloudResults);
      await _storageService.saveAllResults(mergedResults);
      await _uploadTrainingResultsToCloud(mergedResults, cloudResults);
    } catch (e) {
      debugPrint('Training results sync error: $e');
      rethrow;
    }
  }

  List<TrainingResult> _mergeTrainingResults(
    List<TrainingResult> localResults,
    List<TrainingResult> cloudResults,
  ) {
    final Map<String, TrainingResult> resultMap = {};

    // Add cloud results first
    for (final result in cloudResults) {
      final dateKey = result.date.toIso8601String();
      resultMap[dateKey] = result;
    }

    // Merge local results, preferring more recent versions or better performance
    for (final result in localResults) {
      final dateKey = result.date.toIso8601String();
      final existing = resultMap[dateKey];

      if (existing == null) {
        // No cloud version, use local
        resultMap[dateKey] = result;
      } else if (result.isMoreRecentThan(existing)) {
        // Local version is more recent (including deletions), use it
        resultMap[dateKey] = result;
      } else if (!existing.isMoreRecentThan(result) && result.isBetterThan(existing)) {
        // Same recency but local performance is better, use it
        resultMap[dateKey] = result;
      }
      // Otherwise keep the existing (cloud) version
    }

    final cutoffDate = DateTime.now().subtract(
      Duration(days: StorageConstants.maxDataRetentionDays),
    );

    final mergedResults =
        resultMap.values.where((r) => r.date.isAfter(cutoffDate)).toList();

    mergedResults.sort((a, b) => b.date.compareTo(a.date));
    return mergedResults;
  }

  Future<void> _uploadTrainingResultsToCloud(
    List<TrainingResult> localResults,
    List<TrainingResult> cloudResults,
  ) async {
    if (!isLoggedIn) return;

    try {
      final cloudMap = <String, TrainingResult>{};
      for (final result in cloudResults) {
        final dateKey = result.date.toIso8601String();
        cloudMap[dateKey] = result;
      }

      final resultsToUpload = <Map<String, dynamic>>[];
      final userId = Supabase.instance.client.auth.currentUser!.id;

      for (final result in localResults) {
        final dateKey = result.date.toIso8601String();
        final cloudResult = cloudMap[dateKey];

        // Upload if new, more recent, or better performance (when same recency)
        bool shouldUpload = false;
        
        if (cloudResult == null) {
          // No cloud version, upload local
          shouldUpload = true;
        } else if (result.isMoreRecentThan(cloudResult)) {
          // Local is more recent (including deletions)
          shouldUpload = true;
        } else if (!cloudResult.isMoreRecentThan(result) && 
                   result.deletedAt == null && cloudResult.deletedAt == null &&
                   result.isBetterThan(cloudResult)) {
          // Same recency, both active, but local performance is better
          shouldUpload = true;
        }

        if (shouldUpload) {
          final data = result.toSupabase();
          data['user_id'] = userId;
          resultsToUpload.add(data);
        }
      }

      // Upload in batch using upsert
      if (resultsToUpload.isNotEmpty) {
        await Supabase.instance.client
            .from(SupabaseConstants.trainingResultsTable)
            .upsert(resultsToUpload, onConflict: 'user_id,date');
      }
    } catch (e) {
      debugPrint('Upload training results error: $e');
      rethrow;
    }
  }

  Future<void> _syncUserSettings() async {
    if (!isLoggedIn) return;

    try {
      final localSettings = await _storageService.loadUserSettings();

      final response = await Supabase.instance.client
          .from(SupabaseConstants.userSettingsTable)
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .limit(1);

      if (response.isNotEmpty) {
        final cloudSettings = UserSettings.fromJson(response.first);
        await _storageService.saveUserSettings(cloudSettings);
      } else {
        await _uploadUserSettings(localSettings);
      }
    } catch (e) {
      debugPrint('User settings sync error: $e');
      rethrow;
    }
  }

  Future<void> _uploadUserSettings(UserSettings settings) async {
    if (!isLoggedIn) return;

    try {
      final data = settings.toSupabase();
      data['user_id'] = Supabase.instance.client.auth.currentUser!.id;

      await Supabase.instance.client
          .from(SupabaseConstants.userSettingsTable)
          .upsert(data, onConflict: 'user_id');
    } catch (e) {
      debugPrint('Upload user settings error: $e');
      rethrow;
    }
  }

  Future<void> _syncExercises() async {
    if (!isLoggedIn) return;

    try {
      final localExercises = await _storageService.loadAllExercises();

      // Download cloud exercises with phases in a single query (including deleted ones)
      final exerciseResponse = await Supabase.instance.client
          .from(SupabaseConstants.breathingExercisesTable)
          .select('*, phases: ${SupabaseConstants.breathPhasesTable}(*)')
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

      final cloudExercises = <BreathingExercise>[];
      for (final exerciseRow in exerciseResponse) {
        try {
          final exercise = _parseExerciseFromCloud(exerciseRow);
          cloudExercises.add(exercise);
        } catch (e) {
          debugPrint('Skipping exercise ${exerciseRow['id']}: $e');
          continue;
        }
      }

      final mergedExercises = _mergeExercises(localExercises, cloudExercises);
      await _storageService.saveAllExercises(mergedExercises);
      await _uploadExercisesToCloud(mergedExercises, cloudExercises);
    } catch (e) {
      debugPrint('Exercise sync error: $e');
      rethrow;
    }
  }

  BreathingExercise _parseExerciseFromCloud(Map<String, dynamic> exerciseRow) {
    final phasesData = exerciseRow['phases'] as List?;
    
    // If exercise is deleted, we still need to parse it for sync purposes
    final isExerciseDeleted = exerciseRow['deleted_at'] != null;
    
    // Validate phases data
    if (phasesData == null || phasesData.isEmpty) {
      if (isExerciseDeleted) {
        // For deleted exercises, create minimal phase data to avoid errors
        final deletedAt = DateTime.parse(exerciseRow['deleted_at']);
        final phases = [
          BreathPhase(
            name: 'Deleted Phase',
            duration: 1,
            minDuration: 1,
            maxDuration: 1,
            color: Color(0xFF000000),
            deletedAt: deletedAt,
          )
        ];
        final exerciseData = Map<String, dynamic>.from(exerciseRow)
          ..remove('phases')
          ..['phases'] = phases.map((phase) => phase.toJson()).toList();
        return BreathingExercise.fromJson(exerciseData);
      }
      throw Exception(t.services.sync.exerciseIncompleteData);
    }

    // For active exercises, filter out deleted phases
    // For deleted exercises, keep all phases as they were when deleted
    final filteredPhasesData = isExerciseDeleted 
        ? phasesData 
        : phasesData.where((phaseRow) => phaseRow['deleted_at'] == null).toList();
    
    if (filteredPhasesData.isEmpty && !isExerciseDeleted) {
      throw Exception(t.services.sync.exerciseIncompleteData);
    }

    filteredPhasesData.sort((a, b) => (a['phase_order'] as int).compareTo(b['phase_order'] as int));
    final phases = filteredPhasesData.map((phaseRow) => BreathPhase.fromJson(phaseRow)).toList();

    // Create exercise data without nested phases table
    final exerciseData = Map<String, dynamic>.from(exerciseRow)
      ..remove('phases')
      ..['phases'] = phases.map((phase) => phase.toJson()).toList();

    return BreathingExercise.fromJson(exerciseData);
  }

  List<BreathingExercise> _mergeExercises(
    List<BreathingExercise> localExercises,
    List<BreathingExercise> cloudExercises,
  ) {
    final Map<String, BreathingExercise> exerciseMap = {};

    // Add cloud exercises first
    for (final exercise in cloudExercises) {
      exerciseMap[exercise.id] = exercise;
    }

    // Add or update with local exercises (preferring newer updates)
    for (final exercise in localExercises) {
      final existing = exerciseMap[exercise.id];
      if (existing == null) {
        // No cloud version exists, use local
        exerciseMap[exercise.id] = exercise;
      } else if (exercise.isMoreRecentThan(existing)) {
        // Local exercise is more recent, use it
        exerciseMap[exercise.id] = exercise;
      }
      // Otherwise keep the existing (cloud) version
    }

    return exerciseMap.values.toList();
  }

  Future<void> _uploadExercisesToCloud(
    List<BreathingExercise> localExercises,
    List<BreathingExercise> cloudExercises,
  ) async {
    if (!isLoggedIn) return;

    try {
      final cloudMap = <String, BreathingExercise>{};
      for (final exercise in cloudExercises) {
        cloudMap[exercise.id] = exercise;
      }

      final updatedExercises = <Map<String, dynamic>>[];
      final batchedPhases = <Map<String, dynamic>>[];
      final exercisesToDeletePhases = <String>[];
      final exercisesToSoftDeletePhases = <String>[];
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // Prepare batched data
      for (final exercise in localExercises) {
        final cloudExercise = cloudMap[exercise.id];

        // Upload if new or more recent
        if (cloudExercise == null || exercise.isMoreRecentThan(cloudExercise)) {
          // Prepare exercise data
          final exerciseData = exercise.toSupabase();
          exerciseData['user_id'] = userId;
          updatedExercises.add(exerciseData);

          if (exercise.deletedAt == null) {
            // For active exercises: clear phases and upload new ones
            exercisesToDeletePhases.add(exercise.id);

            // Prepare phase data for active exercises
            for (int i = 0; i < exercise.phases.length; i++) {
              final phaseData = exercise.phases[i].toSupabase(
                exerciseId: exercise.id,
                exerciseUserId: userId,
                phaseOrder: i,
              );
              batchedPhases.add(phaseData);
            }
          } else {
            // For deleted exercises: soft-delete their phases
            exercisesToSoftDeletePhases.add(exercise.id);
          }
        }
      }

      // Execute batched operations
      if (updatedExercises.isNotEmpty) {
        // Separate deleted and active exercises for different handling
        final activeExercises = updatedExercises.where((ex) => ex['deleted_at'] == null).toList();
        final deletedExercises = updatedExercises.where((ex) => ex['deleted_at'] != null).toList();
        
        // Upload active exercises first
        if (activeExercises.isNotEmpty) {
          await Supabase.instance.client
              .from(SupabaseConstants.breathingExercisesTable)
              .upsert(activeExercises, onConflict: 'user_id,id');
        }
        
        // Handle deleted exercises separately - use upsert to avoid duplicate key errors
        if (deletedExercises.isNotEmpty) {
          try {
            await Supabase.instance.client
                .from(SupabaseConstants.breathingExercisesTable)
                .upsert(deletedExercises, onConflict: 'user_id,id');
          } catch (upsertError) {
            debugPrint('Failed to sync deleted exercises: $upsertError');
            // Try updating each one individually if batch upsert fails
            for (final deletedExercise in deletedExercises) {
              try {
                await Supabase.instance.client
                    .from(SupabaseConstants.breathingExercisesTable)
                    .update({
                      'deleted_at': deletedExercise['deleted_at'],
                      'updated_at': deletedExercise['updated_at'],
                    })
                    .eq('id', deletedExercise['id'])
                    .eq('user_id', deletedExercise['user_id']);
              } catch (individualError) {
                debugPrint('Failed to sync deleted exercise ${deletedExercise['id']}: $individualError');
              }
            }
          }
        }
      }

      // Hard delete existing phases for active exercises (will be replaced with new ones)
      if (exercisesToDeletePhases.isNotEmpty) {
        await Supabase.instance.client
            .from(SupabaseConstants.breathPhasesTable)
            .delete()
            .inFilter('exercise_id', exercisesToDeletePhases)
            .eq('exercise_user_id', userId);
      }

      // Soft delete phases for deleted exercises
      if (exercisesToSoftDeletePhases.isNotEmpty) {
        await Supabase.instance.client
            .from(SupabaseConstants.breathPhasesTable)
            .update({'deleted_at': DateTime.now().toIso8601String()})
            .inFilter('exercise_id', exercisesToSoftDeletePhases)
            .eq('exercise_user_id', userId);
      }

      // Upload phases in batch (only for active exercises)
      if (batchedPhases.isNotEmpty) {
        await Supabase.instance.client
            .from(SupabaseConstants.breathPhasesTable)
            .insert(batchedPhases);
      }
    } catch (e) {
      debugPrint('Upload exercises error: $e');
      rethrow;
    }
  }

  Future<void> saveTrainingResult(TrainingResult result) async {
    await _storageService.saveResult(result);

    if (isLoggedIn) {
      try {
        _updateStatus(SyncStatus.syncing);

        final data = result.toSupabase();
        data['user_id'] = Supabase.instance.client.auth.currentUser!.id;

        await Supabase.instance.client
            .from(SupabaseConstants.trainingResultsTable)
            .insert(data);

        _updateStatus(SyncStatus.synced);
      } catch (e) {
        debugPrint('Save training result to cloud error: $e');
        _updateStatus(SyncStatus.pendingChanges);
      }
    } else {
      _updateStatus(SyncStatus.offline);
    }
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    await _storageService.saveUserSettings(settings);

    if (isLoggedIn) {
      try {
        await _uploadUserSettings(settings);
        _updateStatus(SyncStatus.synced);
      } catch (e) {
        debugPrint('Save user settings to cloud error: $e');
        _updateStatus(SyncStatus.pendingChanges);
      }
    } else {
      _updateStatus(SyncStatus.offline);
    }
  }

  Future<void> saveExercise(BreathingExercise exercise) async {
    await _storageService.saveExercise(exercise);

    if (isLoggedIn) {
      try {
        _updateStatus(SyncStatus.syncing);

        // Upload exercise
        final exerciseData = exercise.toSupabase();
        exerciseData['user_id'] = Supabase.instance.client.auth.currentUser!.id;

        await Supabase.instance.client
            .from(SupabaseConstants.breathingExercisesTable)
            .upsert(exerciseData, onConflict: 'user_id,id');

        // Delete existing phases
        await Supabase.instance.client
            .from(SupabaseConstants.breathPhasesTable)
            .delete()
            .eq('exercise_id', exercise.id)
            .eq(
              'exercise_user_id',
              Supabase.instance.client.auth.currentUser!.id,
            );

        // Upload phases
        for (int i = 0; i < exercise.phases.length; i++) {
          final phaseData = exercise.phases[i].toSupabase(
            exerciseId: exercise.id,
            exerciseUserId: Supabase.instance.client.auth.currentUser!.id,
            phaseOrder: i,
          );

          await Supabase.instance.client
              .from(SupabaseConstants.breathPhasesTable)
              .insert(phaseData);
        }

        _updateStatus(SyncStatus.synced);
      } catch (e) {
        debugPrint('Save exercise to cloud error: $e');
        _updateStatus(SyncStatus.pendingChanges);
      }
    } else {
      _updateStatus(SyncStatus.offline);
    }
  }

  Future<bool> deleteTrainingResult(String resultId) async {
    if (isLoggedIn) {
      try {
        _updateStatus(SyncStatus.syncing);

        final now = DateTime.now();

        // Soft delete training result
        await Supabase.instance.client
            .from(SupabaseConstants.trainingResultsTable)
            .update({'deleted_at': now.toIso8601String()})
            .eq('id', resultId)
            .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

        _updateStatus(SyncStatus.synced);
        return true;
      } catch (e) {
        debugPrint('Delete training result from cloud error: $e');
        _updateStatus(SyncStatus.pendingChanges);
        return false;
      }
    } else {
      _updateStatus(SyncStatus.offline);
      return false;
    }
  }

  Future<bool> deleteExercise(String exerciseId) async {
    final success = await _storageService.deleteExercise(exerciseId);

    if (success && isLoggedIn) {
      try {
        _updateStatus(SyncStatus.syncing);

        final now = DateTime.now();

        // Soft delete phases first
        await Supabase.instance.client
            .from(SupabaseConstants.breathPhasesTable)
            .update({'deleted_at': now.toIso8601String()})
            .eq('exercise_id', exerciseId)
            .eq('exercise_user_id', Supabase.instance.client.auth.currentUser!.id);

        // Soft delete exercise
        await Supabase.instance.client
            .from(SupabaseConstants.breathingExercisesTable)
            .update({'deleted_at': now.toIso8601String()})
            .eq('id', exerciseId)
            .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

        _updateStatus(SyncStatus.synced);
      } catch (e) {
        debugPrint('Delete exercise from cloud error: $e');
        _updateStatus(SyncStatus.pendingChanges);
      }
    } else if (!isLoggedIn) {
      _updateStatus(SyncStatus.offline);
    }

    return success;
  }

  Future<void> clearAllData() async {
    // Reset all app data to defaults
    await _storageService.resetAllAppData();

    if (isLoggedIn) {
      try {
        _updateStatus(SyncStatus.syncing);

        // Clear training results from cloud
        await Supabase.instance.client
            .from(SupabaseConstants.trainingResultsTable)
            .delete()
            .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

        // Clear exercises from cloud
        final userId = Supabase.instance.client.auth.currentUser!.id;

        // Get all user's exercise IDs first
        final exercisesResponse = await Supabase.instance.client
            .from(SupabaseConstants.breathingExercisesTable)
            .select('id')
            .eq('user_id', userId);

        final exerciseIds =
            (exercisesResponse as List).map((e) => e['id'] as String).toList();

        // Delete phases for user's exercises
        if (exerciseIds.isNotEmpty) {
          await Supabase.instance.client
              .from(SupabaseConstants.breathPhasesTable)
              .delete()
              .inFilter('exercise_id', exerciseIds);
        }

        // Delete user's exercises
        await Supabase.instance.client
            .from(SupabaseConstants.breathingExercisesTable)
            .delete()
            .eq('user_id', userId);

        // Upload default exercises to cloud
        final defaultExercises = await _storageService.loadExercises();
        for (final exercise in defaultExercises) {
          await saveExercise(exercise);
        }

        _updateStatus(SyncStatus.synced);
      } catch (e) {
        debugPrint('Clear cloud data error: $e');
        _updateStatus(SyncStatus.error);
      }
    }
  }

  Future<void> retrySync() async {
    if (!isLoggedIn) return;

    try {
      await _performInitialSync();
    } catch (e) {
      debugPrint('Retry sync error: $e');
    }
  }

  void dispose() {
    _syncStatusController.close();
  }
}
