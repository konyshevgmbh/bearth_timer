import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import '../models/sound_settings.dart';
import '../models/breath_phase.dart';
import 'session_service.dart';

/// Service for managing sound playback during training sessions
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  SoundSettings _soundSettings = SoundSettings();
  bool _isInitialized = false;
  late SoLoud _soloud;
  
  // Preloaded audio sources map
  final Map<int, AudioSource> _clapSources = {};
  StreamSubscription<SessionEvent>? _sessionEventSubscription;
  SessionService? _sessionService;
  
  Box<SoundSettings> get _soundBox => Hive.box<SoundSettings>('sound_settings');

  /// Initialize the sound service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _soloud = SoLoud.instance;
      await _soloud.init();
      
      // Preload all clap sounds
      _clapSources[1] = await _soloud.loadAsset('assets/sounds/clap1.wav');
      _clapSources[2] = await _soloud.loadAsset('assets/sounds/clap2.wav');
      _clapSources[3] = await _soloud.loadAsset('assets/sounds/clap3.wav');
      _clapSources[4] = await _soloud.loadAsset('assets/sounds/clapf.wav');
      // Check if audio is supported on this platform
      debugPrint('SoundService: Running on Linux platform');
      
      _loadSoundSettings();
      _subscribeToSessionEvents();
      _isInitialized = true;
      debugPrint('SoundService: Successfully initialized with preloaded sounds');
    } catch (e) {
      debugPrint('Error initializing SoundService: $e');
      _soundSettings = SoundSettings();
      _isInitialized = true;
    }
  }

  /// Subscribe to session events
  void _subscribeToSessionEvents() {
    _sessionService = SessionService();
    _sessionEventSubscription = _sessionService!.events.listen((event) {
      switch (event.type) {
        case SessionEventType.phaseTransition:
          playPhaseTransitionSound(event.phase);
          break;
        case SessionEventType.sessionComplete:
          playSessionCompleteSound();
          break;
        case SessionEventType.sessionStart:
        case SessionEventType.sessionStop:
          // No sounds for these events currently
          break;
      }
    });
  }
  
  /// Load sound settings from Hive
  void _loadSoundSettings() {
    try {
      final settings = _soundBox.get('sound_settings');
      if (settings != null) {
        _soundSettings = settings;
      } else {
        // Save default settings if none exist
        _soundSettings = SoundSettings();
        _saveSoundSettings();
      }
    } catch (e) {
      debugPrint('Error loading sound settings: $e');
      _soundSettings = SoundSettings();
    }
  }
  
  /// Save sound settings to Hive
  Future<void> _saveSoundSettings() async {
    try {
      await _soundBox.put('sound_settings', _soundSettings);
    } catch (e) {
      debugPrint('Error saving sound settings: $e');
    }
  }

  /// Update sound enabled setting
  Future<void> setSoundEnabled(bool enabled) async {
    _soundSettings = _soundSettings.copyWith(soundEnabled: enabled);
    await _saveSoundSettings();
  }
  
  /// Update sound settings
  Future<void> updateSoundSettings(SoundSettings settings) async {
    _soundSettings = settings;
    await _saveSoundSettings();
  }

  /// Get current sound enabled setting
  bool get isSoundEnabled => _soundSettings.soundEnabled;
  
  /// Get current sound settings
  SoundSettings get soundSettings => _soundSettings;

  /// Play phase transition sound based on phase
  Future<void> playPhaseTransitionSound([BreathPhase? phase]) async {
    if (!_soundSettings.soundEnabled || !_isInitialized) return;
    
    final elapsedMs = _sessionService?.getElapsedTimeMs() ?? 0;
    final elapsedSeconds = (elapsedMs / 1000).toStringAsFixed(3);
    
    try {
      if (phase != null) {
        final source = _getClapSource(phase.claps);
        if (source != null) {
          await _soloud.play(source, volume: _soundSettings.volume);
          debugPrint('SoundService: Playing ${phase.claps} clap sound at ${elapsedSeconds}s');
          return;
        }
      }
      
      // Fallback to default phase transition sound
      final defaultSource = _clapSources[1];
      if (defaultSource != null) {
        await _soloud.play(defaultSource, volume: _soundSettings.volume);
        debugPrint('SoundService: Playing default phase transition sound at ${elapsedSeconds}s');
      }
    } catch (e) {
      debugPrint('Error playing phase transition sound at ${elapsedSeconds}s: $e');
      if (!kIsWeb && Platform.isLinux) {
        debugPrint('Linux audio error - this may be due to missing audio dependencies');
      }
    }
  }

  /// Get the preloaded audio source based on number of claps
  AudioSource? _getClapSource(int claps) {
    return _clapSources[claps] ?? _clapSources[1]; // Default to single clap
  }

  /// Play session complete sound
  Future<void> playSessionCompleteSound() async {
    if (!_soundSettings.soundEnabled || !_isInitialized) return;
    
    final elapsedMs = _sessionService?.getElapsedTimeMs() ?? 0;
    final elapsedSeconds = (elapsedMs / 1000).toStringAsFixed(1);
    
    try {
      final sessionCompleteSource = _clapSources[4];
      if (sessionCompleteSource != null) {
        await _soloud.play(sessionCompleteSource, volume: _soundSettings.volume);
        debugPrint('SoundService: Playing session complete sound at ${elapsedSeconds}s');
      }
    } catch (e) {
      debugPrint('Error playing session complete sound at ${elapsedSeconds}s: $e');
      if (!kIsWeb && Platform.isLinux) {
        debugPrint('Linux audio error - this may be due to missing audio dependencies');
      }
    }
  }


  /// Dispose audio player resources
  Future<void> dispose() async {
    if (_isInitialized) {
      _sessionEventSubscription?.cancel();
      _sessionEventSubscription = null;
      _soloud.deinit();
    }
  }
}