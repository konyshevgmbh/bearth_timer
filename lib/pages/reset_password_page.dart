import 'package:flutter/material.dart';
import 'dart:async';
import '../core/constants.dart';
import '../services/otp_service.dart';
import '../services/sync_service.dart';
import '../widgets/main_app_wrapper.dart';
import '../i18n/strings.g.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  
  const ResetPasswordPage({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _isLoading = false;
  bool _isOTPVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _resendCountdown = 0;
  Timer? _countdownTimer;
  String? _errorMessage;
  String? _successMessage;
  
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
          if (status == OTPStatus.verified) {
            _isOTPVerified = true;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpStatusSubscription?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _errorMessage = t.pleaseEnterVerificationCode;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await _otpService.verifyOTP(_otpController.text.trim());
      
      if (success && mounted) {
        setState(() {
          _successMessage = t.codeVerifiedCreatePassword;
        });
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

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await _otpService.updatePasswordAfterOTPVerification(
        _passwordController.text,
      );
      
      if (success && mounted) {
        // Sign in with new credentials
        final syncService = SyncService();
        final signInSuccess = await syncService.signIn(
          widget.email,
          _passwordController.text,
        );
        
        if (signInSuccess && mounted) {
          // Success - navigate to home page
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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await _otpService.sendOTP(widget.email);
      
      if (success && mounted) {
        setState(() {
          _successMessage = t.newVerificationCodeSent;
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return t.pleaseEnterPassword;
    }
    if (value.length < 6) {
      return t.passwordMinLength;
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return t.passwordUppercase;
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return t.passwordLowercase;
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return t.passwordNumber;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return t.pleaseConfirmPassword;
    }
    if (value != _passwordController.text) {
      return t.passwordsDoNotMatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(t.resetPassword),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon and title
                        Icon(
                          _isOTPVerified ? Icons.lock_reset : Icons.mark_email_read,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        Text(
                          _isOTPVerified ? t.newPassword : t.enterCode,
                          style: TextStyle(
                            fontSize: AppLayout.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        Text(
                          _isOTPVerified 
                              ? t.chooseStrongPassword
                              : t.codeSentTo(email: widget.email),
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
                        
                        if (!_isOTPVerified) ...[
                          // OTP verification section
                          TextFormField(
                            controller: _otpController,
                            decoration: InputDecoration(
                              labelText: t.code,
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
                          
                          // Verify OTP button
                          SizedBox(
                            width: double.infinity,
                            height: AppLayout.authButtonHeight,
                            child: ElevatedButton(
                              onPressed: (_isLoading || _currentOTPStatus == OTPStatus.verifying) ? null : _verifyOTP,
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
                                      t.verify,
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
                                  ? t.resendInSeconds(seconds: _resendCountdown)
                                  : t.resendCode2,
                              style: TextStyle(
                                color: _resendCountdown > 0 
                                    ? Theme.of(context).colorScheme.onSurfaceVariant 
                                    : Theme.of(context).colorScheme.primary,
                                fontSize: AppLayout.fontSizeSmall,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Password reset section
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: t.password,
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
                              prefixIcon: Icon(Icons.lock, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                            onChanged: (_) => setState(() {}),
                          ),
                          SizedBox(height: AppLayout.authFieldSpacing),
                          
                          // Confirm password field
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: t.confirm,
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
                              prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            obscureText: _obscureConfirmPassword,
                            validator: _validateConfirmPassword,
                          ),
                          SizedBox(height: AppLayout.authFieldSpacing),
                          
                          // Password requirements
                          Container(
                            padding: EdgeInsets.all(AppLayout.authFieldSpacing),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.passwordRequirements,
                                  style: TextStyle(
                                    fontSize: AppLayout.fontSizeSmall,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 4),
                                _buildRequirement(t.atLeast6Characters, 
                                    _passwordController.text.length >= 6),
                                _buildRequirement(t.oneUppercaseLetter, 
                                    _passwordController.text.contains(RegExp(r'[A-Z]'))),
                                _buildRequirement(t.oneLowercaseLetter, 
                                    _passwordController.text.contains(RegExp(r'[a-z]'))),
                                _buildRequirement(t.oneNumber, 
                                    _passwordController.text.contains(RegExp(r'[0-9]'))),
                              ],
                            ),
                          ),
                          SizedBox(height: AppLayout.authFormPadding),
                          
                          // Reset password button
                          SizedBox(
                            width: double.infinity,
                            height: AppLayout.authButtonHeight,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.surface,
                                disabledBackgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                                ),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Theme.of(context).colorScheme.surface,
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      t.update,
                                      style: TextStyle(
                                        fontSize: AppLayout.fontSizeMedium,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: AppLayout.fontSizeSmall,
              color: isMet ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}