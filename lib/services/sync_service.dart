import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/training_result.dart';
import '../models/user_settings.dart';
import '../models/breathing_exercise.dart';
import '../models/breath_phase.dart';
import '../core/constants.dart';
import 'storage_service.dart';

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
          'User-Agent': 'BearthTimer/1.0.0 (${Platform.operatingSystem})',
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
      throw Exception(
        'Supabase not configured. Please check your project settings.',
      );
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
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      debugPrint('Sign up error: $e');
      _updateStatus(SyncStatus.error);
      throw Exception('Sign up failed. Please try again.');
    }
  }

  Future<bool> signIn(String email, String password) async {
    if (!SupabaseConstants.isConfigured) {
      throw Exception(
        'Supabase not configured. Please check your project settings.',
      );
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
        throw Exception(
          'Invalid email or password. Please check your credentials or sign up if you don\'t have an account.',
        );
      }
      throw Exception('Sign in failed: ${e.message}');
    } catch (e) {
      debugPrint('Sign in error: $e');
      _updateStatus(SyncStatus.error);
      throw Exception('Sign in failed. Please try again.');
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
      final localResults = await _storageService.getResults();

      final response = await Supabase.instance.client
          .from(SupabaseConstants.trainingResultsTable)
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

      final cloudResults =
          (response as List)
              .map((row) => TrainingResult.fromJson(row))
              .toList();

      final mergedResults = _mergeTrainingResults(localResults, cloudResults);
      await _storageService.saveResultsDirectly(mergedResults);
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

    for (final result in cloudResults) {
      final dateKey = DateFormat('yyyy-MM-dd').format(result.date);
      resultMap[dateKey] = result;
    }

    for (final result in localResults) {
      final dateKey = DateFormat('yyyy-MM-dd').format(result.date);
      final existing = resultMap[dateKey];

      if (existing == null || result.isBetterThan(existing)) {
        resultMap[dateKey] = result;
      }
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
        final dateKey = DateFormat('yyyy-MM-dd').format(result.date);
        cloudMap[dateKey] = result;
      }

      for (final result in localResults) {
        final dateKey = DateFormat('yyyy-MM-dd').format(result.date);
        final cloudResult = cloudMap[dateKey];

        if (cloudResult == null || result.isBetterThan(cloudResult)) {
          final data = result.toSupabase();
          data['user_id'] = Supabase.instance.client.auth.currentUser!.id;

          await Supabase.instance.client
              .from(SupabaseConstants.trainingResultsTable)
              .insert(data);
        }
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
      final localExercises = await _storageService.loadExercises();

      // Download cloud exercises with phases in a single query
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
      await _storageService.saveExercises(mergedExercises);
      await _uploadExercisesToCloud(mergedExercises, cloudExercises);
    } catch (e) {
      debugPrint('Exercise sync error: $e');
      rethrow;
    }
  }

  BreathingExercise _parseExerciseFromCloud(Map<String, dynamic> exerciseRow) {
    final phasesData = exerciseRow['phases'] as List?;
    
    // Validate phases data
    if (phasesData == null || phasesData.isEmpty) {
      throw Exception('Exercise has no phases - incomplete data');
    }

    // Sort phases by phase_order and convert to BreathPhase objects
    phasesData.sort((a, b) => (a['phase_order'] as int).compareTo(b['phase_order'] as int));
    final phases = phasesData.map((phaseRow) => BreathPhase.fromJson(phaseRow)).toList();

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

          // Mark for phase deletion
          exercisesToDeletePhases.add(exercise.id);

          // Prepare phase data
          for (int i = 0; i < exercise.phases.length; i++) {
            final phaseData = exercise.phases[i].toSupabase(
              exerciseId: exercise.id,
              exerciseUserId: userId,
              phaseOrder: i,
            );
            batchedPhases.add(phaseData);
          }
        }
      }

      // Execute batched operations
      if (updatedExercises.isNotEmpty) {
        // Upload exercises in batch
        await Supabase.instance.client
            .from(SupabaseConstants.breathingExercisesTable)
            .upsert(updatedExercises, onConflict: 'user_id,id');

        // Delete existing phases for updated exercises
        if (exercisesToDeletePhases.isNotEmpty) {
          await Supabase.instance.client
              .from(SupabaseConstants.breathPhasesTable)
              .delete()
              .inFilter('exercise_id', exercisesToDeletePhases)
              .eq('exercise_user_id', userId);
        }

        // Upload phases in batch
        if (batchedPhases.isNotEmpty) {
          await Supabase.instance.client
              .from(SupabaseConstants.breathPhasesTable)
              .insert(batchedPhases);
        }
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

  Future<bool> deleteExercise(String exerciseId) async {
    final success = await _storageService.deleteExercise(exerciseId);

    if (success && isLoggedIn) {
      try {
        _updateStatus(SyncStatus.syncing);

        // Delete phases first
        await Supabase.instance.client
            .from(SupabaseConstants.breathPhasesTable)
            .delete()
            .eq('exercise_id', exerciseId);

        // Delete exercise
        await Supabase.instance.client
            .from(SupabaseConstants.breathingExercisesTable)
            .delete()
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
