import 'package:flutter/material.dart';

// =============================================================================
// APP CONSTANTS
// =============================================================================

/// Data storage and persistence constants
class StorageConstants {
  static const String trainingResultsKey = 'training_results';
  static const String totalCyclesKey = 'totalCycles';
  static const String cycleDurationKey = 'cycleDuration';
  static const int maxDataRetentionDays = 30;
}

/// Statistics and chart display constants
class ChartConstants {
  static const double chartHeight = 300.0;
  static const int dateDisplayInterval = 5;
  static const int scoreDisplayInterval = 100;
  static const double chartScaleMultiplier = 1.1;
  static const double minChartScale = 100.0;
  static const double lineWidth = 3.0;
  static const double dotRadius = 4.0;
  static const double dotStrokeWidth = 2.0;
  static const double curveSmoothness = 0.3;
  static const double areaOpacity = 0.1;
  static const int gridStrokeWidth = 1;
  static const int tooltipFontSize = 12;
}


class SupabaseConstants {
  // Replace these with your actual Supabase URL and anon key
  // Get them from: https://app.supabase.com -> Project Settings -> API
  static const String supabaseUrl = 'https://uviqlyhocrhzpsrbvkkg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2aXFseWhvY3JoenBzcmJ2a2tnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkxNjE1MjMsImV4cCI6MjA2NDczNzUyM30.AUyF59VJIWidU9KWGGBjpogVuCo9GHcYNmVakz9c-hY';
  
  // Table names
  static const String trainingResultsTable = 'training_results';
  static const String userSettingsTable = 'user_settings';
  static const String breathingExercisesTable = 'breathing_exercises';
  static const String breathPhasesTable = 'breath_phases';
  
  // Check if Supabase is properly configured
  static bool get isConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL' && 
           supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
           supabaseUrl.isNotEmpty && 
           supabaseAnonKey.isNotEmpty;
  }
}

/// Layout and UI constants
class AppLayout {
  // Screen dimensions and breakpoints
  static const double responsiveBreakpoint = 600.0;
  static const double wideAspectRatioThreshold = 1.3;
  static const double maxContentWidth = 600.0;
  static const double minContentWidth = 320.0;
  static const double minContentHeight = 422.0;
  
  // Padding and spacing
  static const double minScreenPadding = 0.0;
  static const double maxScreenPadding = 16.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double sectionSpacingSmall = 10.0;
  static const double sectionSpacingMedium = 20.0;
  static const double sectionSpacingLarge = 28.0;
  static const double controlSpacing = 24.0;
  static const double statsContentPadding = 24.0;
  static const double statsChartPadding = 32.0;
  static const double authFormPadding = 32.0;
  static const double authFieldSpacing = 16.0;
  static const double syncStatusPadding = 8.0;
  
  // Font sizes
  static const double fontSizeSmall = 16.0;
  static const double fontSizeMedium = 24.0;
  static const double fontSizeLarge = 48.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 48.0;
  
  // Card and UI element styling
  static const double cardElevation = 16.0;
  static const double cardBorderRadius = 24.0;
  static const double buttonBorderRadius = 12.0;
  
  // Specific component sizes
  static const double progressCircleSize = 250.0;
  static const double progressStrokeWidth = 12.0;
  static const double stepperValueWidth = 48.0;
  static const double authButtonHeight = 48.0;
  
  // Legend and indicator styling
  static const double legendIndicatorWidth = 16.0;
  static const double legendIndicatorHeight = 3.0;
  static const double legendIndicatorRadius = 2.0;
}

/// Core training algorithm parameters and limits
class TrainingConstants {
  
  // Default training settings
  static const int defaultTotalCycles = 5;
  static const int defaultCycleDuration = 30; // seconds

  // Training limits and constraints
  static const int minCycles = 1;
  static const int maxCycles = 9;
  // Note: minCycleDuration and maxCycleDuration are now calculated from phases
  static const int cycleDurationStep = 5; // seconds

  // Phase timing constants
  static const int waitPhaseDuration = 3; // seconds

  // Timer and session constants
  static const int timerTickInterval = 1; // seconds
}