import 'package:flutter/material.dart';
import 'dart:async';
import '../core/constants.dart';
import '../services/otp_service.dart';
import '../services/sync_service.dart';
import '../widgets/main_app_wrapper.dart';

class VerifySignupPage extends StatefulWidget {
  final String email;
  final String password;
  
  const VerifySignupPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<VerifySignupPage> createState() => _VerifySignupPageState();
}

class _VerifySignupPageState extends State<VerifySignupPage> {
  bool _isLoading = false;
  int _resendCountdown = 0;
  Timer? _countdownTimer;
  String? _errorMessage;
  String? _successMessage;
  
  final _otpController = TextEditingController();
  final _otpService = OTPService();
  
  StreamSubscription<OTPStatus>? _otpStatusSubscription;
  OTPStatus _currentOTPStatus = OTPStatus.idle;

  @override
  void initState() {
    super.initState();
    _otpStatusSubscription = _otpService.otpStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _currentOTPStatus = status;
        });
      }
    });
    _startResendCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpStatusSubscription?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOTPAndSignup() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Enter verification code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // First verify the OTP
      final otpVerified = await _otpService.verifyOTP(_otpController.text.trim());
      
      if (otpVerified) {
        // OTP verified, now create the account
        final syncService = SyncService();
        final success = await syncService.signUp(
          widget.email,
          widget.password,
        );
        
        if (success && mounted) {
          // Account created successfully, navigate to main app
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainAppWrapper()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_resendCountdown > 0) return;

    setState(() => _isLoading = true);

    try {
      final success = await _otpService.sendOTP(widget.email, isSignup: true);
      
      if (success && mounted) {
        setState(() {
          _successMessage = 'New code sent to your email';
        });
        
        _startResendCountdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text('Verify Email'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(maxWidth: AppLayout.maxContentWidth),
              padding: EdgeInsets.all(AppLayout.authFormPadding),
              child: Card(
                elevation: AppLayout.cardElevation,
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppLayout.cardBorderRadius),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppLayout.authFormPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon and title
                      Icon(
                        Icons.mark_email_read,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: AppLayout.authFieldSpacing),
                      Text(
                        'Check Your Email',
                        style: TextStyle(
                          fontSize: AppLayout.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: AppLayout.authFieldSpacing),
                      Text(
                        'Code sent to ${widget.email}',
                        style: TextStyle(
                          fontSize: AppLayout.fontSizeSmall,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppLayout.authFormPadding),
                      
                      // Success message
                      if (_successMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(AppLayout.authFieldSpacing),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _successMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: AppLayout.fontSizeSmall,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                      ],
                      
                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(AppLayout.authFieldSpacing),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                            border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: AppLayout.fontSizeSmall,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                      ],
                      
                      // OTP input field
                      TextFormField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          labelText: 'Verification Code',
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
                          prefixIcon: Icon(Icons.security, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                      ),
                      SizedBox(height: AppLayout.authFieldSpacing),
                      
                      // Verify button
                      SizedBox(
                        width: double.infinity,
                        height: AppLayout.authButtonHeight,
                        child: ElevatedButton(
                          onPressed: (_isLoading || _currentOTPStatus == OTPStatus.verifying) ? null : _verifyOTPAndSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.surface,
                            disabledBackgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                            ),
                          ),
                          child: _isLoading || _currentOTPStatus == OTPStatus.verifying
                              ? CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.surface,
                                  strokeWidth: 2,
                                )
                              : Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: AppLayout.fontSizeMedium,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: AppLayout.authFieldSpacing),
                      
                      // Resend OTP button
                      TextButton(
                        onPressed: _resendCountdown > 0 ? null : _resendOTP,
                        child: Text(
                          _resendCountdown > 0 
                              ? 'Resend in ${_resendCountdown}s'
                              : 'Resend Code',
                          style: TextStyle(
                            color: _resendCountdown > 0 
                                ? Theme.of(context).colorScheme.onSurfaceVariant 
                                : Theme.of(context).colorScheme.primary,
                            fontSize: AppLayout.fontSizeSmall,
                          ),
                        ),
                      ),
                      SizedBox(height: AppLayout.authFieldSpacing),
                      
                      // Back to signup button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: AppLayout.fontSizeSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}