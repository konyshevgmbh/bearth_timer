// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bearth Timer';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get minCharacters => 'Min 6 characters';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get skip => 'Skip';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get loading => 'Loading...';

  @override
  String get syncDataAcrossDevices => 'Sync data across devices';

  @override
  String get accessDataAnywhere => 'Access your data anywhere';

  @override
  String get haveAccountSignIn => 'Have account? Sign In';

  @override
  String get needAccountSignUp => 'Need account? Sign Up';

  @override
  String get forgot => 'Forgot?';

  @override
  String get emailSent => 'Email sent! Check your inbox.';

  @override
  String get sendingEmail => 'Sending email...';

  @override
  String get signupEmailSent =>
      'Signup email sent! Check your inbox and set your password.';

  @override
  String get failedToSendEmail => 'Failed to send email. Check email format.';

  @override
  String get supabaseNotConfigured => 'Supabase Not Configured';

  @override
  String get updateSupabaseConstants =>
      'Please update SupabaseConstants with your project URL and anon key';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get sync => 'Sync';

  @override
  String get sound => 'Sound';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get appearance => 'Appearance';

  @override
  String get about => 'About';

  @override
  String get signedInAs => 'Signed in as';

  @override
  String get unknownEmail => 'Unknown email';

  @override
  String get signOutDescription => 'Sign out and work offline';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountDescription => 'Permanently delete account and data';

  @override
  String get workingOffline => 'Working Offline';

  @override
  String get signInToSync => 'Sign in to sync across devices';

  @override
  String get accessDataAnywhereButton => 'Access data anywhere';

  @override
  String get retrySync => 'Retry Sync';

  @override
  String get syncWithCloud => 'Sync with cloud';

  @override
  String get exportData => 'Export Data';

  @override
  String get saveDataToFile => 'Save data to file';

  @override
  String get importData => 'Import Data';

  @override
  String get loadDataFromFile => 'Load data from file';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get deleteAllDataPermanently => 'Delete all data permanently';

  @override
  String get transitionSound => 'Transition Sound';

  @override
  String get playSoundWhenPhasesChange => 'Play sound when phases change';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get useDarkTheme => 'Use dark theme';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get signOutConfirmTitle => 'Sign Out';

  @override
  String get signOutConfirmMessage =>
      'Are you sure you want to sign out? Your data will remain on this device.';

  @override
  String get clearAllDataConfirmTitle => 'Clear All Data';

  @override
  String get clearAllDataConfirmMessage =>
      'Are you sure you want to delete all training results? This action cannot be undone and will clear data from all your devices.';

  @override
  String get clearAll => 'Clear All';

  @override
  String get exercises => 'Exercises';

  @override
  String get importExercise => 'Import Exercise';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get noExercisesYet => 'No exercises yet';

  @override
  String get createFirstExercise => 'Create your first exercise';

  @override
  String get createYourFirstExercise => 'Create your first exercise';

  @override
  String get cycles => 'Cycles';

  @override
  String get duration => 'Duration';

  @override
  String cycleDurationSeconds(int cycles, int duration) {
    return '$cycles cycles • ${duration}s duration';
  }

  @override
  String get edit => 'Edit';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get export => 'Export';

  @override
  String errorLoadingExercises(String error) {
    return 'Error loading exercises: $error';
  }

  @override
  String get deleteExercise => 'Delete Exercise';

  @override
  String deleteExerciseConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get exportFailed => 'Export Failed';

  @override
  String failedToExport(String error) {
    return 'Failed to export exercise: $error';
  }

  @override
  String get importSuccessful => 'Import Successful';

  @override
  String get importFailed => 'Import Failed';

  @override
  String failedToImport(String error) {
    return 'Failed to import exercise: $error';
  }

  @override
  String get exerciseDetails => 'Exercise Details:';

  @override
  String get cycleDuration => 'Cycle Duration';

  @override
  String get totalDuration => 'Total Duration';

  @override
  String get phases => 'Phases';

  @override
  String get noDescriptionAvailable =>
      'No description available for this exercise.';

  @override
  String get description => 'Description';

  @override
  String get customize => 'Customize';

  @override
  String get time => 'Time';

  @override
  String get stop => 'Stop';

  @override
  String get start => 'Start';

  @override
  String cycleProgress(int current, int total) {
    return 'Cycle $current / $total';
  }

  @override
  String get oneClap => '1 clap';

  @override
  String clapsCount(int count) {
    return '$count claps';
  }

  @override
  String range(String range) {
    return 'Range: $range';
  }

  @override
  String get name => 'Name';

  @override
  String get information => 'Information';

  @override
  String get configuration => 'Configuration';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get step => 'Step';

  @override
  String get minimum => 'Minimum';

  @override
  String get current => 'Current';

  @override
  String get maximum => 'Maximum';

  @override
  String get total => 'Total';

  @override
  String get addPhase => 'Add Phase';

  @override
  String get history => 'History';

  @override
  String get overview => 'Overview';

  @override
  String get sessions => 'Sessions';

  @override
  String get avg => 'Avg';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get completeSessionToSeeProgress =>
      'Complete a session to see progress';

  @override
  String today(String time) {
    return 'Today $time';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String cyclesAndDuration(int cycles, int duration) {
    return '$cycles cycles • ${duration}s';
  }

  @override
  String get noTraining => 'No training';

  @override
  String secondsUnit(int value) {
    return '${value}s';
  }

  @override
  String cyclesUnit(String value) {
    return '${value}c';
  }

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get enterEmailToGetResetCode => 'Enter email to get reset code';

  @override
  String get sendCode => 'Send Code';

  @override
  String get passwordResetCodeSent => 'Password reset code sent to your email';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get checkYourEmail => 'Check Your Email';

  @override
  String codeSentTo(String email) {
    return 'Code sent to $email';
  }

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get createAccount => 'Create Account';

  @override
  String resendInSeconds(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get resendCode => 'Resend Code';

  @override
  String get newCodeSentToEmail => 'New code sent to your email';

  @override
  String get enterVerificationCode => 'Enter verification code';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get verifyDeletion => 'Verify Deletion';

  @override
  String get permanentDeleteWarning =>
      'This will permanently delete your account and all data.';

  @override
  String get deletionConsequences =>
      '• All training data will be lost\\n• Sync settings will be cleared\\n• This action cannot be undone';

  @override
  String get iUnderstandContinue => 'I Understand, Continue';

  @override
  String accountEmail(String email) {
    return 'Account: $email';
  }

  @override
  String get sendVerificationCodeDescription =>
      'We\'ll send a verification code to confirm this action.';

  @override
  String get sendVerificationCode => 'Send Verification Code';

  @override
  String get noUserEmailFound => 'No user email found. Please sign in again.';

  @override
  String verificationCodeSentTo(String email) {
    return 'Verification code sent to $email';
  }

  @override
  String get accountDataCleared =>
      'Account data cleared. You have been signed out.';

  @override
  String get failedToDeleteAccount =>
      'Failed to delete account. Please try again.';

  @override
  String get newPassword => 'New Password';

  @override
  String get enterCode => 'Enter Code';

  @override
  String get chooseStrongPassword => 'Choose a strong password';

  @override
  String get code => 'Code';

  @override
  String get confirm => 'Confirm';

  @override
  String get verify => 'Verify';

  @override
  String get update => 'Update';

  @override
  String get resendCode2 => 'Resend code';

  @override
  String get pleaseEnterPassword => 'Please enter a password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordUppercase =>
      'Password must contain at least one uppercase letter';

  @override
  String get passwordLowercase =>
      'Password must contain at least one lowercase letter';

  @override
  String get passwordNumber => 'Password must contain at least one number';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordRequirements => 'Password Requirements:';

  @override
  String get atLeast6Characters => 'At least 6 characters';

  @override
  String get oneUppercaseLetter => 'One uppercase letter';

  @override
  String get oneLowercaseLetter => 'One lowercase letter';

  @override
  String get oneNumber => 'One number';

  @override
  String get pleaseEnterVerificationCode =>
      'Please enter the verification code';

  @override
  String get codeVerifiedCreatePassword =>
      'Code verified! Now create your new password.';

  @override
  String get newVerificationCodeSent =>
      'New verification code sent to your email';

  @override
  String get breathTraining => 'Breath Training';

  @override
  String get unknown => 'Unknown';

  @override
  String get timer => 'Timer';

  @override
  String get newExercise => 'New Exercise';

  @override
  String exerciseSummary(int cycles, int duration) {
    return '$cycles cycles • ${duration}s duration';
  }

  @override
  String failedToExportExercise(String error) {
    return 'Failed to export exercise: $error';
  }

  @override
  String failedToImportExercise(String error) {
    return 'Failed to import exercise: $error';
  }

  @override
  String confirmDeleteExercise(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }
}
