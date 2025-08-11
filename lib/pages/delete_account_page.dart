import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../core/constants.dart';
import '../services/otp_service.dart';
import '../services/sync_service.dart';
import '../pages/auth_page.dart';
import '../generated/l10n/app_localizations.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  bool _isLoading = false;
  bool _isOTPSent = false;
  bool _showConfirmation = false;
  int _resendCountdown = 0;
  Timer? _countdownTimer;
  String? _errorMessage;
  String? _successMessage;
  
  final _otpController = TextEditingController();
  final _otpService = OTPService();
  final _syncService = SyncService();
  
  StreamSubscription<OTPStatus>? _otpStatusSubscription;
  OTPStatus _currentOTPStatus = OTPStatus.idle;
  
  String? _userEmail;

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
    _getUserEmail();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpStatusSubscription?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _getUserEmail() {
    // Get current user email from Supabase
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email;
      });
    }
  }

  Future<void> _sendDeleteOTP() async {
    if (_userEmail == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).noUserEmailFound;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await _otpService.sendOTP(_userEmail!);
      
      if (success && mounted) {
        setState(() {
          _isOTPSent = true;
          _successMessage = AppLocalizations.of(context).verificationCodeSentTo(_userEmail!);
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

  Future<void> _verifyOTPAndDelete() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).enterVerificationCode;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Verify OTP first
      final otpVerified = await _otpService.verifyOTP(_otpController.text.trim());
      
      if (otpVerified) {
        // OTP verified, now delete account
        await _deleteAccount();
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

  Future<void> _deleteAccount() async {
    try {
      // Clear all user data from sync service
      await _syncService.clearAllData();
      
      // Delete user account from Supabase (this requires admin privileges)
      // For now, we'll sign out the user as account deletion needs server-side implementation
      await _syncService.signOut();
      
      if (mounted) {
        // Show success and navigate to auth page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).accountDataCleared),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        
        // Navigate to auth page and clear navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context).failedToDeleteAccount;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_resendCountdown > 0 || _userEmail == null) return;

    setState(() => _isLoading = true);

    try {
      final success = await _otpService.sendOTP(_userEmail!);
      
      if (success && mounted) {
        setState(() {
          _successMessage = AppLocalizations.of(context).verificationCodeSentTo(_userEmail!);
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

  void _showDeleteConfirmation() {
    setState(() {
      _showConfirmation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(AppLocalizations.of(context).deleteAccountTitle),
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
                        Icons.delete_forever,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      SizedBox(height: AppLayout.authFieldSpacing),
                      Text(
                        _isOTPSent ? AppLocalizations.of(context).verifyDeletion : AppLocalizations.of(context).deleteAccountTitle,
                        style: TextStyle(
                          fontSize: AppLayout.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: AppLayout.authFieldSpacing),
                      
                      if (!_isOTPSent) ...[
                        // Initial warning screen
                        if (!_showConfirmation) ...[
                          Text(
                            AppLocalizations.of(context).permanentDeleteWarning,
                            style: TextStyle(
                              fontSize: AppLayout.fontSizeSmall,
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppLayout.authFieldSpacing),
                          Text(
                            AppLocalizations.of(context).deletionConsequences,
                            style: TextStyle(
                              fontSize: AppLayout.fontSizeSmall,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: AppLayout.authFormPadding),
                          
                          // Show confirmation button
                          SizedBox(
                            width: double.infinity,
                            height: AppLayout.authButtonHeight,
                            child: ElevatedButton(
                              onPressed: _showDeleteConfirmation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.error,
                                foregroundColor: Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context).iUnderstandContinue,
                                style: TextStyle(
                                  fontSize: AppLayout.fontSizeSmall,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Confirmation screen
                          Text(
                            AppLocalizations.of(context).accountEmail(_userEmail ?? ''),
                            style: TextStyle(
                              fontSize: AppLayout.fontSizeSmall,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppLayout.authFormPadding),
                          
                          Text(
                            AppLocalizations.of(context).sendVerificationCodeDescription,
                            style: TextStyle(
                              fontSize: AppLayout.fontSizeSmall,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppLayout.authFormPadding),
                          
                          // Send OTP button
                          SizedBox(
                            width: double.infinity,
                            height: AppLayout.authButtonHeight,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _sendDeleteOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.error,
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
                                      AppLocalizations.of(context).sendVerificationCode,
                                      style: TextStyle(
                                        fontSize: AppLayout.fontSizeSmall,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ] else ...[
                        // OTP verification screen
                        Text(
                          AppLocalizations.of(context).codeSentTo(_userEmail ?? ''),
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
                        
                        // OTP input field
                        TextFormField(
                          controller: _otpController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).verificationCode,
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
                        
                        // Delete account button
                        SizedBox(
                          width: double.infinity,
                          height: AppLayout.authButtonHeight,
                          child: ElevatedButton(
                            onPressed: (_isLoading || _currentOTPStatus == OTPStatus.verifying) ? null : _verifyOTPAndDelete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
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
                                    AppLocalizations.of(context).deleteAccountTitle,
                                    style: TextStyle(
                                      fontSize: AppLayout.fontSizeSmall,
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
                                ? AppLocalizations.of(context).resendInSeconds(_resendCountdown)
                                : AppLocalizations.of(context).resendCode,
                            style: TextStyle(
                              color: _resendCountdown > 0 
                                  ? Theme.of(context).colorScheme.onSurfaceVariant 
                                  : Theme.of(context).colorScheme.primary,
                              fontSize: AppLayout.fontSizeSmall,
                            ),
                          ),
                        ),
                      ],
                      
                      // Error message
                      if (_errorMessage != null) ...[
                        SizedBox(height: AppLayout.authFieldSpacing),
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
                      ],
                      
                      SizedBox(height: AppLayout.authFormPadding),
                      
                      // Cancel button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          AppLocalizations.of(context).cancel,
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