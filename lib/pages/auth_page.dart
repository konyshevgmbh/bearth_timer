import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../i18n/strings.g.dart';

// Import business logic modules
import '../core/constants.dart';
import '../services/sync_service.dart';
import '../services/otp_service.dart';
import '../widgets/main_app_wrapper.dart';
import 'forgot_password_page.dart';
import 'verify_signup_page.dart';

// =============================================================================
// AUTHENTICATION PAGES
// =============================================================================

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _showResendEmail = false;
  String? _errorMessage;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resendConfirmationEmail() async {
    if (_emailController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Try to resend confirmation email
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: _emailController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _errorMessage = t.emailSent;
          _showResendEmail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // If resend fails, try signup which will send confirmation email
          _errorMessage = t.sendingEmail;
        });
        
        try {
          // This will create account and send confirmation email if user doesn't exist
          await Supabase.instance.client.auth.signUp(
            email: _emailController.text.trim(),
            password: 'temp123', // Temporary password, user can reset later
          );
          
          if (mounted) {
            setState(() {
              _errorMessage = t.signupEmailSent;
            });
          }
        } catch (signupError) {
          if (mounted) {
            setState(() {
              _errorMessage = t.failedToSendEmail;
            });
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showResendEmail = false;
    });

    try {
      final syncService = SyncService();
      bool success;

      if (_isSignUp) {
        // Send OTP for signup verification
        final otpService = OTPService();
        final otpSent = await otpService.sendOTP(_emailController.text.trim(), isSignup: true);
        
        if (otpSent && mounted) {
          // Navigate to OTP verification page with email and password
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerifySignupPage(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              ),
            ),
          );
          return;
        }
      } else {
        success = await syncService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (success && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainAppWrapper()),
          );
          return;
        }
      }

      // If we get here, success was false but no exception was thrown
      // Authentication failed
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          // Show resend email button for email-related errors
          _showResendEmail = _errorMessage!.toLowerCase().contains('email not confirmed') ||
                           _errorMessage!.toLowerCase().contains('not confirmed') ||
                           _errorMessage!.toLowerCase().contains('invalid login credentials') ||
                           _errorMessage!.toLowerCase().contains('email address') ||
                           _errorMessage!.toLowerCase().contains('invalid');
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
                        // App icon and title
                        Image.asset(
                          'assets/icon.png',
                          width: 64,
                          height: 64,
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        Text(
                          t.appTitle,
                          style: TextStyle(
                            fontSize: AppLayout.fontSizeMedium,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: AppLayout.authFormPadding),
                        
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: t.email,
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
                              return t.enterEmail;
                            }
                            // More strict email validation
                            final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return t.invalidEmailFormat;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        
                        // Password field
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
                          ),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return t.enterPassword;
                            }
                            if (_isSignUp && value.length < 6) {
                              return t.minCharacters;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        
                        // Helper text
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            _isSignUp 
                                ? t.syncDataAcrossDevices
                                : t.accessDataAnywhere,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: AppLayout.fontSizeSmall,
                            ),
                            textAlign: TextAlign.center,
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
                                  t.supabaseNotConfigured,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: AppLayout.fontSizeSmall,
                                          ),
                                ),
                                Text(
                                  t.updateSupabaseConstants,
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
                        
                        SizedBox(height: AppLayout.authFieldSpacing),
                        
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: AppLayout.authButtonHeight,
                          child: ElevatedButton(
                            onPressed: (_isLoading || !SupabaseConstants.isConfigured) ? null : _handleAuth,
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
                                    _isSignUp ? t.signUp : t.signIn,
                                    style: TextStyle(
                                      fontSize: AppLayout.fontSizeMedium,
                                              ),
                                  ),
                          ),
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        
                        // Error message and resend email button
                        if (_errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(AppLayout.authFieldSpacing),
                            decoration: BoxDecoration(
                              color: _errorMessage!.contains('sent!') 
                                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                                  : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                              border: Border.all(
                                color: _errorMessage!.contains('sent!')
                                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                                    : Theme.of(context).colorScheme.error.withValues(alpha: 0.3)
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: _errorMessage!.contains('sent!') 
                                        ? Theme.of(context).colorScheme.primary 
                                        : Theme.of(context).colorScheme.error,
                                    fontSize: AppLayout.fontSizeSmall,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_showResendEmail) ...[
                                  SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _isLoading ? null : _resendConfirmationEmail,
                                    child: Text(
                                      t.resendCode,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: AppLayout.fontSizeSmall,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: AppLayout.authFieldSpacing),
                        ],
                        
                        // Forgot password link (only show when signing in)
                        if (!_isSignUp) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: SupabaseConstants.isConfigured ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPasswordPage(),
                                  ),
                                );
                              } : null,
                              child: Text(
                                t.forgot,
                                style: TextStyle(
                                  color: SupabaseConstants.isConfigured 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                  fontSize: AppLayout.fontSizeSmall,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: AppLayout.authFieldSpacing),
                        ],
                        
                        // Toggle between sign in and sign up
                        TextButton(
                          onPressed: SupabaseConstants.isConfigured ? () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          } : null,
                          child: Text(
                            _isSignUp
                                ? t.haveAccountSignIn
                                : t.needAccountSignUp,
                            style: TextStyle(
                              color: SupabaseConstants.isConfigured 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: AppLayout.authFieldSpacing),
                        
                        // Continue offline button
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => MainAppWrapper()),
                            );
                          },
                          child: Text(
                            t.skip,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
      ),
    );
  }
}