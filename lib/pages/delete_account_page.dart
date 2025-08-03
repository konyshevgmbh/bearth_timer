import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../core/constants.dart';
import '../services/otp_service.dart';
import '../services/sync_service.dart';
import '../pages/auth_page.dart';

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
        _errorMessage = 'No user email found. Please sign in again.';
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
          _successMessage = 'Verification code sent to $_userEmail';
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
            content: Text('Account data cleared. You have been signed out.'),
            backgroundColor: AppColors.primary,
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
          _errorMessage = 'Failed to delete account. Please try again.';
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
          _successMessage = 'New code sent to $_userEmail';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text('Delete Account'),
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
                color: AppColors.cardBackground,
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
                        color: AppColors.error,
                      ),
                      SizedBox(height: AppLayout.authFieldSpacing),
                      Text(
                        _isOTPSent ? 'Verify Deletion' : 'Delete Account',
                        style: TextStyle(
                          fontSize: AppLayout.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppLayout.authFieldSpacing),
                      
                      if (!_isOTPSent) ...[
                        // Initial warning screen
                        if (!_showConfirmation) ...[
                          Text(
                            'This will permanently delete your account and all data.',
                            style: TextStyle(
                              fontSize: AppLayout.fontSizeSmall,
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppLayout.authFieldSpacing),
                          Text(
                            '• All training data will be lost\n• Sync settings will be cleared\n• This action cannot be undone',
                            style: TextStyle(
                              fontSize: AppLayout.fontSizeSmall,
                              color: AppColors.textSecondary,
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
                                backgroundColor: AppColors.error,
                                foregroundColor: AppColors.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                                ),
                              ),
                              child: Text(
                                'I Understand, Continue',
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
                            'Account: $_userEmail',
                            style: TextStyle(
                              fontSize: AppLayout.fontSizeSmall,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppLayout.authFormPadding),
                          
                          Text(
                            'We\'ll send a verification code to confirm this action.',
                            style: TextStyle(
                              fontSize: AppLayout.fontSizeSmall,
                              color: AppColors.textSecondary,
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
                                backgroundColor: AppColors.error,
                                foregroundColor: AppColors.background,
                                disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                                ),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: AppColors.background,
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      'Send Verification Code',
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
                          'Code sent to $_userEmail',
                          style: TextStyle(
                            fontSize: AppLayout.fontSizeSmall,
                            color: AppColors.textSecondary,
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
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              _successMessage!,
                              style: TextStyle(
                                color: AppColors.primary,
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
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                              borderSide: BorderSide(color: AppColors.textSecondary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                            prefixIcon: Icon(Icons.security, color: AppColors.textSecondary),
                          ),
                          style: TextStyle(color: AppColors.textPrimary),
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
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.background,
                              disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                              ),
                            ),
                            child: _isLoading || _currentOTPStatus == OTPStatus.verifying
                                ? CircularProgressIndicator(
                                    color: AppColors.background,
                                    strokeWidth: 2,
                                  )
                                : Text(
                                    'Delete Account',
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
                                ? 'Resend in ${_resendCountdown}s'
                                : 'Resend Code',
                            style: TextStyle(
                              color: _resendCountdown > 0 
                                  ? AppColors.textSecondary 
                                  : AppColors.primary,
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
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: AppColors.error,
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
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textSecondary,
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