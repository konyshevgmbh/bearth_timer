import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';

enum OTPStatus { idle, sending, sent, verifying, verified, failed, expired }

class OTPService {
  static final OTPService _instance = OTPService._internal();
  factory OTPService() => _instance;
  OTPService._internal();

  final _otpStatusController = StreamController<OTPStatus>.broadcast();
  Stream<OTPStatus> get otpStatusStream => _otpStatusController.stream;
  OTPStatus _currentStatus = OTPStatus.idle;

  Timer? _expirationTimer;
  String? _currentOTP;
  String? _currentEmail;
  DateTime? _otpExpiration;

  static const int _otpLength = 6;
  static const int _otpExpirationMinutes = 10;

  bool get hasValidOTP => _currentOTP != null && 
      _otpExpiration != null && 
      DateTime.now().isBefore(_otpExpiration!);

  void _updateStatus(OTPStatus status) {
    _currentStatus = status;
    _otpStatusController.add(status);
  }

  String _generateOTP() {
    final random = Random.secure();
    String otp = '';
    for (int i = 0; i < _otpLength; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  Future<bool> sendOTP(String email, {bool isSignup = false}) async {
    if (!SupabaseConstants.isConfigured) {
      throw Exception('Supabase not configured. Please check your project settings.');
    }

    try {
      _updateStatus(OTPStatus.sending);
      
      // Generate OTP
      _currentOTP = _generateOTP();
      _currentEmail = email;
      _otpExpiration = DateTime.now().add(Duration(minutes: _otpExpirationMinutes));

      if (isSignup) {
        // For signup, use signUp with email to send confirmation email
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: 'temp_password_${DateTime.now().millisecondsSinceEpoch}', // Temporary password
        );
      } else {
        // For password reset, use signInWithOtp
        await Supabase.instance.client.auth.signInWithOtp(
          email: email,
          emailRedirectTo: null, // We don't need redirect for OTP verification
        );
      }

      // If we reach here without exception, the OTP was sent successfully
      _updateStatus(OTPStatus.sent);
      _startExpirationTimer();
      debugPrint('OTP sent to $email (expires in $_otpExpirationMinutes minutes)');
      
      // In development, log the OTP for testing
      if (kDebugMode) {
        debugPrint('DEBUG: Generated OTP: $_currentOTP');
      }
      
      return true;
    } on AuthException catch (e) {
      debugPrint('Send OTP auth error: ${e.message}');
      _updateStatus(OTPStatus.failed);
      throw Exception('Failed to send OTP: ${e.message}');
    } catch (e) {
      debugPrint('Send OTP error: $e');
      _updateStatus(OTPStatus.failed);
      throw Exception('Failed to send OTP. Please try again.');
    }
  }

  Future<bool> verifyOTP(String otp) async {
    if (!SupabaseConstants.isConfigured) {
      throw Exception('Supabase not configured. Please check your project settings.');
    }

    if (_currentEmail == null) {
      throw Exception('No OTP request found. Please request a new OTP.');
    }

    if (!hasValidOTP) {
      _updateStatus(OTPStatus.expired);
      throw Exception('OTP has expired. Please request a new one.');
    }

    try {
      _updateStatus(OTPStatus.verifying);

      // Verify OTP with Supabase
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: _currentEmail!,
        token: otp,
        type: OtpType.email,
      );

      if (response.user != null) {
        _updateStatus(OTPStatus.verified);
        _clearOTPData();
        debugPrint('OTP verified successfully');
        return true;
      }

      _updateStatus(OTPStatus.failed);
      return false;
    } on AuthException catch (e) {
      debugPrint('Verify OTP auth error: ${e.message}');
      _updateStatus(OTPStatus.failed);
      if (e.message.contains('invalid') || e.message.contains('expired')) {
        throw Exception('Invalid or expired OTP. Please check your code or request a new one.');
      }
      throw Exception('OTP verification failed: ${e.message}');
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      _updateStatus(OTPStatus.failed);
      throw Exception('OTP verification failed. Please try again.');
    }
  }

  Future<bool> resetPasswordWithOTP(String email, String newPassword) async {
    if (!SupabaseConstants.isConfigured) {
      throw Exception('Supabase not configured. Please check your project settings.');
    }

    try {
      // Send OTP for password reset
      final otpSent = await sendOTP(email);
      if (!otpSent) {
        return false;
      }

      // The user will need to verify the OTP and then we can update the password
      // This is handled in the UI flow
      return true;
    } catch (e) {
      debugPrint('Reset password with OTP error: $e');
      rethrow;
    }
  }

  Future<bool> updatePasswordAfterOTPVerification(String newPassword) async {
    if (!SupabaseConstants.isConfigured) {
      throw Exception('Supabase not configured. Please check your project settings.');
    }

    if (_currentStatus != OTPStatus.verified) {
      throw Exception('OTP must be verified before updating password.');
    }

    try {
      // Update password for the authenticated user
      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        debugPrint('Password updated successfully');
        return true;
      }

      return false;
    } on AuthException catch (e) {
      debugPrint('Update password auth error: ${e.message}');
      throw Exception('Failed to update password: ${e.message}');
    } catch (e) {
      debugPrint('Update password error: $e');
      throw Exception('Failed to update password. Please try again.');
    }
  }

  void _startExpirationTimer() {
    _expirationTimer?.cancel();
    _expirationTimer = Timer(Duration(minutes: _otpExpirationMinutes), () {
      if (_currentStatus == OTPStatus.sent) {
        _updateStatus(OTPStatus.expired);
        _clearOTPData();
      }
    });
  }

  void _clearOTPData() {
    _expirationTimer?.cancel();
    _currentOTP = null;
    _currentEmail = null;
    _otpExpiration = null;
  }

  void clearOTP() {
    _clearOTPData();
    _updateStatus(OTPStatus.idle);
  }

  String? get currentEmail => _currentEmail;
  
  int get remainingMinutes {
    if (_otpExpiration == null) return 0;
    final remaining = _otpExpiration!.difference(DateTime.now()).inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  void dispose() {
    _expirationTimer?.cancel();
    _otpStatusController.close();
  }
}