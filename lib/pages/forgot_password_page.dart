import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/otp_service.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _otpService = OTPService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await _otpService.sendOTP(_emailController.text.trim());
      
      if (success && mounted) {
        setState(() {
          _successMessage = 'Password reset code sent to your email';
        });
        
        // Navigate to OTP verification page after a brief delay
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(
                  email: _emailController.text.trim(),
                ),
              ),
            );
          }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text('Reset Password'),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon and title
                        Icon(
                          Icons.lock_reset,
                          size: 64,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: AppLayout.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        Text(
                          'Enter email to get reset code',
                          style: TextStyle(
                            fontSize: AppLayout.fontSizeSmall,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppLayout.authFormPadding),
                        
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
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
                            prefixIcon: Icon(Icons.email, color: AppColors.textSecondary),
                          ),
                          style: TextStyle(color: AppColors.textPrimary),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter email';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Invalid email';
                            }
                            return null;
                          },
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
                        
                        // Error message
                        if (_errorMessage != null) ...[
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
                          SizedBox(height: AppLayout.authFieldSpacing),
                        ],
                        
                        // Send reset code button
                        SizedBox(
                          width: double.infinity,
                          height: AppLayout.authButtonHeight,
                          child: ElevatedButton(
                            onPressed: (_isLoading || !SupabaseConstants.isConfigured) ? null : _sendResetOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
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
                                    'Send Code',
                                    style: TextStyle(
                                      fontSize: AppLayout.fontSizeMedium,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        
                        // Back to login button
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: AppLayout.fontSizeSmall,
                            ),
                          ),
                        ),
                        
                        // Show configuration warning if Supabase not set up
                        if (!SupabaseConstants.isConfigured) ...[
                          SizedBox(height: AppLayout.authFieldSpacing),
                          Container(
                            padding: EdgeInsets.all(AppLayout.authFieldSpacing),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.warning, color: AppColors.error, size: 20),
                                SizedBox(height: 4),
                                Text(
                                  'Supabase Not Configured',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: AppLayout.fontSizeSmall,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Please update SupabaseConstants with your project URL and anon key',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: AppLayout.fontSizeSmall,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
}