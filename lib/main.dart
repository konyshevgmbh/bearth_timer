import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import page components and business logic
import 'pages/auth_page.dart';
import 'pages/settings_page.dart';
import 'pages/exercises_page.dart';
import 'services/sync_service.dart';
import 'core/constants.dart';
import 'widgets/main_app_wrapper.dart';
import 'models/training_result.dart';
import 'models/user_settings.dart';
import 'models/breathing_exercise.dart';
import 'models/breath_phase.dart';
import 'models/sound_settings.dart';
import 'services/storage_service.dart';
import 'services/exercise_service.dart';
import 'services/sound_service.dart';
import 'services/session_service.dart';

// =============================================================================
// MAIN APPLICATION ENTRY POINT
// =============================================================================

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      // Set up error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        AppErrorHandler.handleError(details.exception, details.stack ?? StackTrace.empty);
      };
      
      WidgetsFlutterBinding.ensureInitialized();
  
      // Initialize Hive for local storage
      await Hive.initFlutter();
      
      // Register Hive adapters
      Hive.registerAdapter(TrainingResultAdapter());
      Hive.registerAdapter(UserSettingsAdapter());
      Hive.registerAdapter(BreathingExerciseAdapter());
      Hive.registerAdapter(BreathPhaseAdapter());
      Hive.registerAdapter(SoundSettingsAdapter());
      
      // Open Hive boxes with error handling for data corruption
      await _initializeHiveBoxes();
      
      // Verify all boxes are properly opened before continuing
      await _verifyHiveBoxes();

      // Initialize sound service
      try {
        await SoundService().initialize();
      } catch (e, stack) {
        AppErrorHandler.handleError(e, stack);
        // Continue app startup even if sound initialization fails
      }
  
      // Initialize Supabase for cloud sync
      try {
        await SyncService.initialize();
      } catch (e, stack) {
        AppErrorHandler.handleError(e, stack);
        // Continue app startup even if sync fails
      }
      
      runApp(const BreathHoldApp());
    },
    (error, stack) {
      AppErrorHandler.handleError(error, stack);
    },
  );
}

/// Main application widget that sets up the app theme and initial route
class BreathHoldApp extends StatelessWidget {
  const BreathHoldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bearth Timer',
      theme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cardBackground,
        // Customize app bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        // Customize card theme
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: AppLayout.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.cardBorderRadius),
          ),
        ),
        // Customize elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
            ),
          ),
        ),
        // Customize text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
        // Customize input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
            borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
            borderSide: BorderSide(color: AppColors.error),
          ),
          labelStyle: TextStyle(color: AppColors.textSecondary),
          hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7)),
        ),
        // Customize drawer theme
        drawerTheme: DrawerThemeData(
          backgroundColor: AppColors.cardBackground,
        ),
        // Customize list tile theme
        listTileTheme: ListTileThemeData(
          textColor: AppColors.textPrimary,
          iconColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
          ),
        ),
        // Customize dialog theme
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.cardBorderRadius),
          ),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppLayout.fontSizeMedium,
          ),
          contentTextStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppLayout.fontSizeSmall,
          ),
        ),
        // Customize progress indicator theme
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.progressBackground,
          circularTrackColor: AppColors.progressBackground,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      // Define named routes for better navigation
      routes: {
        '/auth': (context) => AuthPage(),
        '/settings': (context) => SettingsPage(),
        '/exercises': (context) => ExercisesPage(),
      },
    );
  }
}

/// Wrapper to handle authentication state and navigate appropriately
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    
    // Listen to auth state changes
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Perform any additional initialization here
      // For example, checking for first-time usage, loading cached data, etc.
      
      // Simulate brief initialization delay
      await Future.delayed(Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // Handle initialization errors gracefully
      debugPrint('App initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true; // Still allow app to start
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon.png',
                width: 80,
                height: 80,
              ),
              SizedBox(height: AppLayout.sectionSpacingLarge),
              Text(
                'Bearth Timer',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppLayout.fontSizeMedium,
                      ),
              ),
              SizedBox(height: AppLayout.sectionSpacingMedium),
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      );
    }

    // Always go to main app wrapper - users can choose to sign in from settings
    // This provides a better offline-first experience
    return MainAppWrapper();
  }
}

/// Verify that all Hive boxes are properly opened and accessible
Future<void> _verifyHiveBoxes() async {
  try {
    debugPrint('Verifying Hive boxes are accessible...');
    
    // Test access to each box
    final resultsBox = Hive.box<TrainingResult>('results');
    final settingsBox = Hive.box<UserSettings>('settings');
    final exercisesBox = Hive.box<BreathingExercise>('exercises');
    final soundBox = Hive.box<SoundSettings>('sound_settings');
    
    debugPrint('All Hive boxes verified and accessible');
    
    // Log box status for debugging
    debugPrint('Results box: ${resultsBox.length} entries, isOpen: ${resultsBox.isOpen}');
    debugPrint('Settings box: ${settingsBox.length} entries, isOpen: ${settingsBox.isOpen}');
    debugPrint('Exercises box: ${exercisesBox.length} entries, isOpen: ${exercisesBox.isOpen}');
    debugPrint('Sound box: ${soundBox.length} entries, isOpen: ${soundBox.isOpen}');
    
  } catch (e, stack) {
    debugPrint('Error verifying Hive boxes: $e');
    AppErrorHandler.handleError(e, stack);
    // Re-throw to prevent app from continuing with broken storage
    rethrow;
  }
}

/// Initialize Hive boxes with error handling for data corruption
Future<void> _initializeHiveBoxes() async {
  try {
    // Try to open all boxes normally
    await Hive.openBox<TrainingResult>('results');
    await Hive.openBox<UserSettings>('settings');
    await Hive.openBox<BreathingExercise>('exercises');
    await Hive.openBox<SoundSettings>('sound_settings');
    
    // Test if we can read from the exercises box to detect schema incompatibilities
    final exercisesBox = Hive.box<BreathingExercise>('exercises');
    try {
      final exercises = exercisesBox.values.toList();
      
      // If exercises box is empty, initialize with default data
      if (exercises.isEmpty) {
        debugPrint('Exercises box is empty, initializing with default data');
        await _initializeDefaultData();
      } else {
        // If exercises exist but no current exercise is set, set the first one
        final sessionService = SessionService();
        if (sessionService.currentExercise == null && exercises.isNotEmpty) {
          sessionService.setExercise(exercises.first);
          debugPrint('Set first available exercise as current: ${exercises.first.name}');
        }
      }
    } catch (readError) {
      debugPrint('Error reading exercises from box: $readError');
      // If we can't read from the box, there's likely a schema mismatch
      rethrow;
    }
    
  } catch (e, stack) {
    debugPrint('Hive initialization error: $e');
    debugPrint('Stack trace: $stack');
    
    // If there's an error (likely due to schema changes), clear all boxes and reinitialize
    await _recoverFromHiveError();
  }
}

/// Recover from Hive errors by clearing corrupted data and reinitializing
Future<void> _recoverFromHiveError() async {
  try {
    debugPrint('Attempting to recover from Hive data corruption...');
    
    // Close any open boxes first
    try {
      await Hive.close();
    } catch (e) {
      debugPrint('Error closing boxes: $e');
    }
    
    // Delete all Hive files to clear corrupted data
    try {
      await Hive.deleteFromDisk();
      await Hive.deleteBoxFromDisk('results');
      await Hive.deleteBoxFromDisk('settings');
      await Hive.deleteBoxFromDisk('exercises');
      await Hive.deleteBoxFromDisk('sound_settings');
      debugPrint('Successfully deleted all Hive data from disk');
    } catch (e) {
      debugPrint('Error deleting Hive data: $e');
    }
    
    // Reinitialize Hive
    await Hive.initFlutter();
    
    // Re-register adapters only if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TrainingResultAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(BreathingExerciseAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BreathPhaseAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SoundSettingsAdapter());
    }
    
    // Open fresh boxes
    await Hive.openBox<TrainingResult>('results');
    await Hive.openBox<UserSettings>('settings');
    await Hive.openBox<BreathingExercise>('exercises');
    await Hive.openBox<SoundSettings>('sound_settings');
    
    // Initialize with default data
    await _initializeDefaultData();
    
    debugPrint('Successfully recovered from Hive data corruption');
    
  } catch (e, stack) {
    debugPrint('Critical error during Hive recovery: $e');
    AppErrorHandler.handleError(e, stack);
    // Continue app startup even if recovery fails - app will create new data on demand
  }
}

/// Manually clear all Hive boxes and reinitialize (for debugging or reset)
Future<void> clearAllHiveData() async {
  await _recoverFromHiveError();
}

/// Initialize default data when starting fresh
Future<void> _initializeDefaultData() async {
  try {
    final storageService = StorageService();
    final exerciseService = ExerciseService();
    final sessionService = SessionService();
    
    // Create default exercises
    final defaultExercises = exerciseService.createDefaultExercises();
    
    // Save default exercises
    for (final exercise in defaultExercises) {
      await storageService.saveExercise(exercise);
    }
    
    // Set the first exercise as current if none is set
    if (defaultExercises.isNotEmpty && sessionService.currentExercise == null) {
      sessionService.setExercise(defaultExercises.first);
    }
    
    debugPrint('Initialized ${defaultExercises.length} default exercises');
    
  } catch (e, stack) {
    debugPrint('Error initializing default data: $e');
    AppErrorHandler.handleError(e, stack);
    // Continue even if default data initialization fails
  }
}

/// Global error handler for the app
class AppErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    // Log error for debugging
    debugPrint('App Error: $error');
    debugPrint('Stack Trace: $stackTrace');
    
    // In a production app, you might want to send this to a crash reporting service
    // like Firebase Crashlytics or Sentry
  }
}

/// Global app state that can be accessed throughout the app
class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Add other global state variables as needed
  // For example: user preferences, app settings, etc.
}