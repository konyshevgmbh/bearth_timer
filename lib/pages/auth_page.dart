import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          _errorMessage = 'Email sent! Check your inbox.';
          _showResendEmail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // If resend fails, try signup which will send confirmation email
          _errorMessage = 'Sending email...';
        });
        
        try {
          // This will create account and send confirmation email if user doesn't exist
          await Supabase.instance.client.auth.signUp(
            email: _emailController.text.trim(),
            password: 'temp123', // Temporary password, user can reset later
          );
          
          if (mounted) {
            setState(() {
              _errorMessage = 'Signup email sent! Check your inbox and set your password.';
            });
          }
        } catch (signupError) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Failed to send email. Check email format.';
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
      backgroundColor: AppColors.background,
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
                        // App icon and title
                        Image.asset(
                          'assets/icon.png',
                          width: 64,
                          height: 64,
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        Text(
                          'Bearth Timer',
                          style: TextStyle(
                            fontSize: AppLayout.fontSizeMedium,
                            color: AppColors.textPrimary,
                          ),
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
                            // More strict email validation
                            final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppLayout.authFieldSpacing),
                        
                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
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
                            prefixIcon: Icon(Icons.lock, color: AppColors.textSecondary),
                          ),
                          style: TextStyle(color: AppColors.textPrimary),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter password';
                            }
                            if (_isSignUp && value.length < 6) {
                              return 'Min 6 characters';
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
                                ? 'Sync data across devices'
                                : 'Access your data anywhere',
                            style: TextStyle(
                              color: AppColors.textSecondary,
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
                        
                        SizedBox(height: AppLayout.authFieldSpacing),
                        
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: AppLayout.authButtonHeight,
                          child: ElevatedButton(
                            onPressed: (_isLoading || !SupabaseConstants.isConfigured) ? null : _handleAuth,
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
                                    _isSignUp ? 'Sign Up' : 'Sign In',
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
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
                              border: Border.all(
                                color: _errorMessage!.contains('sent!')
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.error.withValues(alpha: 0.3)
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: _errorMessage!.contains('sent!') 
                                        ? AppColors.primary 
                                        : AppColors.error,
                                    fontSize: AppLayout.fontSizeSmall,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_showResendEmail) ...[
                                  SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _isLoading ? null : _resendConfirmationEmail,
                                    child: Text(
                                      'Resend Email',
                                      style: TextStyle(
                                        color: AppColors.primary,
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
                                'Forgot?',
                                style: TextStyle(
                                  color: SupabaseConstants.isConfigured 
                                      ? AppColors.primary 
                                      : AppColors.textSecondary.withValues(alpha: 0.5),
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
                                ? 'Have account? Sign In'
                                : 'Need account? Sign Up',
                            style: TextStyle(
                              color: SupabaseConstants.isConfigured 
                                  ? AppColors.primary 
                                  : AppColors.textSecondary.withValues(alpha: 0.5),
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
                            'Skip',
                            style: TextStyle(color: AppColors.textSecondary),
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