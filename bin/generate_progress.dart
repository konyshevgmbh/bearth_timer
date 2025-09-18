import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Console utility to generate progress data for existing exercises
/// Usage: dart run bin/generate_progress.dart [input_file_or_directory] [output_file]
void main(List<String> arguments) async {
  // Parse command line arguments
  if (arguments.isEmpty) {
    print('Usage: dart run bin/generate_progress.dart <input_file_or_directory> [output_file]');
    print('Example: dart run bin/generate_progress.dart generated_exercises/exercise_test.json');
    print('Example: dart run bin/generate_progress.dart generated_exercises');
    exit(1);
  }

  final input = arguments[0];
  String inputFile;
  
  // Check if input is a directory or file
  final inputDir = Directory(input);
  if (await inputDir.exists()) {
    // Find the latest JSON file in the directory
    final files = inputDir.listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList();
    
    if (files.isEmpty) {
      print('❌ No JSON files found in directory: $input');
      exit(1);
    }
    
    // Sort by modification time and get the latest
    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    inputFile = files.first.path;
    print('📁 Using latest file from directory: ${inputFile}');
  } else {
    inputFile = input;
  }

  final outputFile = arguments.length > 1 
      ? arguments[1] 
      : inputFile.replaceAll('.json', '_with_progress.json');

  print('Generating monthly progress for existing exercises...');
  print('Input file: $inputFile');
  print('Output file: $outputFile');

  final generator = ProgressGenerator(
    inputFilePath: inputFile,
    outputFilePath: outputFile,
  );

  await generator.generateAndSave();
}

class ProgressGenerator {
  final String inputFilePath;
  final String outputFilePath;
  final Random _random = Random();

  ProgressGenerator({
    required this.inputFilePath,
    required this.outputFilePath,
  });

  /// Load existing exercise data from file
  Future<Map<String, dynamic>> loadExistingData() async {
    try {
      final file = File(inputFilePath);
      if (!await file.exists()) {
        throw Exception('Input file does not exist: $inputFilePath');
      }
      
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error loading existing data: $e');
      rethrow;
    }
  }

  /// Generate progress training results for existing exercises over 30 days
  List<Map<String, dynamic>> generateMonthlyProgress(List<dynamic> exercises) {
    final results = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final totalDays = 30;

    for (final exerciseData in exercises) {
      final exerciseId = exerciseData['id'] as String;
      final exerciseName = exerciseData['name'] as String;
      final minCycles = exerciseData['min_cycles'] as int;
      final maxCycles = exerciseData['max_cycles'] as int;
      final minCycleDuration = exerciseData['min_cycle_duration'] as int;
      final maxCycleDuration = exerciseData['max_cycle_duration'] as int;
      
      print('📈 Generating progress for exercise: $exerciseName');
      print('   Cycles: $minCycles → $maxCycles');
      print('   Duration: $minCycleDuration → $maxCycleDuration');
      
      // Generate training sessions with gaps (not every day)
      final trainingDays = _generateTrainingDays(totalDays);
      
      for (final day in trainingDays) {
        final date = now.subtract(Duration(days: totalDays - day));
        
        // Calculate progress factor (0.0 to 1.0) based on training day position
        final dayIndex = trainingDays.indexOf(day);
        final progressFactor = dayIndex / (trainingDays.length - 1);
        
        // Progressive improvement in cycles (from min to max)
        final targetCycles = (minCycles + (maxCycles - minCycles) * progressFactor).round();
        
        // Add some randomness to cycles but stay within bounds
        final cycleVariance = ((maxCycles - minCycles) * 0.1).round().clamp(0, 2); // ±10% or max 2
        final cycles = (targetCycles + _random.nextInt(cycleVariance * 2 + 1) - cycleVariance)
            .clamp(minCycles, maxCycles);
        
        // Calculate total session duration (cycles * cycle_duration + some variance)
        // Use current cycle duration from the exercise, not min/max range
        final currentCycleDuration = exerciseData['cycle_duration'] as int;
        final baseDuration = cycles * currentCycleDuration;
        
        // Add realistic session variance (±20% for breaks, setup time, etc.)
        final sessionVariance = (baseDuration * 0.2).round();
        final duration = baseDuration + _random.nextInt(sessionVariance * 2 + 1) - sessionVariance;
        
        final result = {
          'date': date.toIso8601String(),
          'duration': duration,
          'cycles': cycles,
          'exerciseId': exerciseId,
        };
        
        results.add(result);
      }
    }

    return results;
  }

  /// Generate training days with realistic gaps over 30 days
  List<int> _generateTrainingDays(int totalDays) {
    final trainingDays = <int>[];
    
    // Generate 18-22 training days out of 30 (realistic frequency)
    final targetDays = 18 + _random.nextInt(5); // 18-22 days
    
    for (int day = 1; day <= totalDays && trainingDays.length < targetDays; day++) {
      // 65-75% chance of training on any given day
      if (_random.nextDouble() < 0.7) {
        trainingDays.add(day);
      }
    }
    
    // Ensure we have at least some training days
    if (trainingDays.length < 15) {
      // Add some random days to reach minimum
      while (trainingDays.length < 18) {
        final randomDay = 1 + _random.nextInt(totalDays);
        if (!trainingDays.contains(randomDay)) {
          trainingDays.add(randomDay);
        }
      }
    }
    
    trainingDays.sort();
    return trainingDays;
  }

  /// Generate updated export data with progress
  Map<String, dynamic> generateUpdatedData(Map<String, dynamic> originalData) {
    final exercises = originalData['exercises'] as List<dynamic>;
    final existingResults = originalData['training_results'] as List<dynamic>? ?? [];
    
    // Generate new progress results
    final progressResults = generateMonthlyProgress(exercises);
    
    // Merge with existing results
    final allResults = [...existingResults, ...progressResults];
    
    return {
      ...originalData,
      'training_results': allResults,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  /// Generate and save the progress data
  Future<void> generateAndSave() async {
    try {
      // Load existing data
      final originalData = await loadExistingData();
      
      // Check if there are exercises to generate progress for
      final exercises = originalData['exercises'] as List<dynamic>? ?? [];
      if (exercises.isEmpty) {
        print('❌ No exercises found in the input file');
        exit(1);
      }
      
      // Generate updated data with progress
      final updatedData = generateUpdatedData(originalData);
      
      // Save to output file
      final jsonString = const JsonEncoder.withIndent('  ').convert(updatedData);
      
      // Ensure output directory exists
      final outputFile = File(outputFilePath);
      final outputDir = outputFile.parent;
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }
      
      await outputFile.writeAsString(jsonString);
      
      final newResultsCount = (updatedData['training_results'] as List).length - 
                             (originalData['training_results'] as List? ?? []).length;
      
      print('✅ Progress data generated and saved to: ${outputFile.path}');
      print('📊 Added $newResultsCount new training results');
      print('🏃 Exercises with progress: ${exercises.length}');
      print('📅 Monthly progress with realistic training gaps');
      
    } catch (e) {
      print('❌ Error generating progress: $e');
      exit(1);
    }
  }
}