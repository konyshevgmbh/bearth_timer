import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/otp_service.dart';
import 'reset_password_page.dart';
import '../generated/l10n/app_localizations.dart';

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
          _successMessage = AppLocalizations.of(context).passwordResetCodeSent;
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(AppLocalizations.of(context).resetPassword),
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
                          Icons.lock_reset,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        Text(
                          AppLocalizations.of(context).resetPassword,
                          style: TextStyle(
                            fontSize: AppLayout.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        Text(
                          AppLocalizations.of(context).enterEmailToGetResetCode,
                          style: TextStyle(
                            fontSize: AppLayout.fontSizeSmall,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppLayout.authFormPadding),
                        
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).email,
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
                            prefixIcon: Icon(Icons.email, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context).enterEmail;
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return AppLocalizations.of(context).invalidEmailFormat;
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
                        
                        // Send reset code button
                        SizedBox(
                          width: double.infinity,
                          height: AppLayout.authButtonHeight,
                          child: ElevatedButton(
                            onPressed: (_isLoading || !SupabaseConstants.isConfigured) ? null : _sendResetOTP,
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
                                    AppLocalizations.of(context).sendCode,
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
                            AppLocalizations.of(context).back,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
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
                              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                              border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.warning, color: Theme.of(context).colorScheme.error, size: 20),
                                SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(context).supabaseNotConfigured,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: AppLayout.fontSizeSmall,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context).updateSupabaseConstants,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
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