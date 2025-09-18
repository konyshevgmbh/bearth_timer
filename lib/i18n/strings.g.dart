/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	en(languageCode: 'en', build: Translations.build),
	de(languageCode: 'de', build: _StringsDe.build),
	es(languageCode: 'es', build: _StringsEs.build),
	fr(languageCode: 'fr', build: _StringsFr.build),
	it(languageCode: 'it', build: _StringsIt.build),
	ru(languageCode: 'ru', build: _StringsRu.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, Translations> build;

	/// Gets current instance managed by [LocaleSettings].
	Translations get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
Translations get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
class TranslationProvider extends BaseTranslationProvider<AppLocale, Translations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, Translations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	Translations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, Translations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, Translations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  );

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final Translations _root = this; // ignore: unused_field

	// Translations
	String get appTitle => 'Bearth Timer';
	String get email => 'Email';
	String get password => 'Password';
	String get enterEmail => 'Enter email';
	String get enterPassword => 'Enter password';
	String get invalidEmailFormat => 'Invalid email format';
	String get minCharacters => 'Min 6 characters';
	String get signUp => 'Sign Up';
	String get signIn => 'Sign In';
	String get signOut => 'Sign Out';
	String get skip => 'Skip';
	String get cancel => 'Cancel';
	String get delete => 'Delete';
	String get ok => 'OK';
	String get close => 'Close';
	String get back => 'Back';
	String get loading => 'Loading...';
	String get syncDataAcrossDevices => 'Sync data across devices';
	String get accessDataAnywhere => 'Access your data anywhere';
	String get haveAccountSignIn => 'Have account? Sign In';
	String get needAccountSignUp => 'Need account? Sign Up';
	String get forgot => 'Forgot?';
	String get emailSent => 'Email sent! Check your inbox.';
	String get sendingEmail => 'Sending email...';
	String get signupEmailSent => 'Signup email sent! Check your inbox and set your password.';
	String get failedToSendEmail => 'Failed to send email. Check email format.';
	String get supabaseNotConfigured => 'Supabase Not Configured';
	String get updateSupabaseConstants => 'Please update SupabaseConstants with your project URL and anon key';
	String get settings => 'Settings';
	String get account => 'Account';
	String get sync => 'Sync';
	String get sound => 'Sound';
	String get dataManagement => 'Data Management';
	String get appearance => 'Appearance';
	String get about => 'About';
	String get signedInAs => 'Signed in as';
	String get unknownEmail => 'Unknown email';
	String get signOutDescription => 'Sign out and work offline';
	String get deleteAccount => 'Delete Account';
	String get deleteAccountDescription => 'Permanently delete account and data';
	String get workingOffline => 'Working Offline';
	String get signInToSync => 'Sign in to sync across devices';
	String get accessDataAnywhereButton => 'Access data anywhere';
	String get retrySync => 'Retry Sync';
	String get syncWithCloud => 'Sync with cloud';
	String get exportData => 'Export Data';
	String get saveDataToFile => 'Save data to file';
	String get importData => 'Import Data';
	String get loadDataFromFile => 'Load data from file';
	String get clearAllData => 'Clear All Data';
	String get deleteAllDataPermanently => 'Delete all data permanently';
	String get transitionSound => 'Transition Sound';
	String get playSoundWhenPhasesChange => 'Play sound when phases change';
	String get darkMode => 'Dark Mode';
	String get useDarkTheme => 'Use dark theme';
	String version({required Object version}) => 'Version ${version}';
	String get signOutConfirmTitle => 'Sign Out';
	String get signOutConfirmMessage => 'Are you sure you want to sign out? Your data will remain on this device.';
	String get clearAllDataConfirmTitle => 'Clear All Data';
	String get clearAllDataConfirmMessage => 'Are you sure you want to delete all training results? This action cannot be undone and will clear data from all your devices.';
	String get clearAll => 'Clear All';
	String get exercises => 'Exercises';
	String get importExercise => 'Import Exercise';
	String get addExercise => 'Add Exercise';
	String get noExercisesYet => 'No exercises yet';
	String get createFirstExercise => 'Create your first exercise';
	String get createYourFirstExercise => 'Create your first exercise';
	String get cycles => 'Cycles';
	String get duration => 'Duration';
	String cycleDurationSeconds({required Object cycles, required Object duration}) => '${cycles} cycles • ${duration}s duration';
	String get edit => 'Edit';
	String get duplicate => 'Duplicate';
	String get export => 'Export';
	String errorLoadingExercises({required Object error}) => 'Error loading exercises: ${error}';
	String get deleteExercise => 'Delete Exercise';
	String deleteExerciseConfirm({required Object name}) => 'Are you sure you want to delete "${name}"?';
	String get exportFailed => 'Export Failed';
	String failedToExport({required Object error}) => 'Failed to export exercise: ${error}';
	String get importSuccessful => 'Import Successful';
	String get importFailed => 'Import Failed';
	String failedToImport({required Object error}) => 'Failed to import exercise: ${error}';
	String get exerciseDetails => 'Exercise Details:';
	String get cycleDuration => 'Cycle Duration';
	String get totalDuration => 'Total Duration';
	String get phases => 'Phases';
	String get noDescriptionAvailable => 'No description available for this exercise.';
	String get description => 'Description';
	String get customize => 'Customize';
	String get time => 'Time';
	String get stop => 'Stop';
	String get start => 'Start';
	String cycleProgress({required Object current, required Object total}) => 'Cycle ${current} / ${total}';
	String get oneClap => '1 clap';
	String clapsCount({required Object count}) => '${count} claps';
	String range({required Object minDuration, required Object maxDuration}) => 'Range: ${minDuration}s - ${maxDuration}s';
	String get name => 'Name';
	String get information => 'Information';
	String get configuration => 'Configuration';
	String get min => 'Min';
	String get max => 'Max';
	String get step => 'Step';
	String get minimum => 'Minimum';
	String get current => 'Current';
	String get maximum => 'Maximum';
	String get total => 'Total';
	String get addPhase => 'Add Phase';
	String get history => 'History';
	String get overview => 'Overview';
	String get sessions => 'Sessions';
	String get totalTime => 'Total Time';
	String get avg => 'Avg';
	String get dailyDurationDiff => 'Δ Duration';
	String get dailyCycleDiff => 'Δ Cycle';
	String get bestScore => 'Best';
	String get noHistoryYet => 'No history yet';
	String get completeSessionToSeeProgress => 'Complete a session to see progress';
	String today({required Object time}) => 'Today ${time}';
	String get yesterday => 'Yesterday';
	String daysAgo({required Object days}) => '${days} days ago';
	String cyclesAndDuration({required Object cycles, required Object duration}) => '${cycles} cycles • ${duration}s';
	String get noTraining => 'No training';
	String secondsUnit({required Object value}) => '${value}s';
	String cyclesUnit({required Object value}) => '${value}c';
	String get resetPassword => 'Reset Password';
	String get enterEmailToGetResetCode => 'Enter email to get reset code';
	String get sendCode => 'Send Code';
	String get passwordResetCodeSent => 'Password reset code sent to your email';
	String get verifyEmail => 'Verify Email';
	String get checkYourEmail => 'Check Your Email';
	String codeSentTo({required Object email}) => 'Code sent to ${email}';
	String get verificationCode => 'Verification Code';
	String get createAccount => 'Create Account';
	String resendInSeconds({required Object seconds}) => 'Resend in ${seconds}s';
	String get resendCode => 'Resend Code';
	String get newCodeSentToEmail => 'New code sent to your email';
	String get enterVerificationCode => 'Enter verification code';
	String get deleteAccountTitle => 'Delete Account';
	String get verifyDeletion => 'Verify Deletion';
	String get permanentDeleteWarning => 'This will permanently delete your account and all data.';
	String get deletionConsequences => '• All training data will be lost\n• Sync settings will be cleared\n• This action cannot be undone';
	String get iUnderstandContinue => 'I Understand, Continue';
	String accountEmail({required Object email}) => 'Account: ${email}';
	String get sendVerificationCodeDescription => 'We\'ll send a verification code to confirm this action.';
	String get sendVerificationCode => 'Send Verification Code';
	String get noUserEmailFound => 'No user email found. Please sign in again.';
	String verificationCodeSentTo({required Object email}) => 'Verification code sent to ${email}';
	String get accountDataCleared => 'Account data cleared. You have been signed out.';
	String get failedToDeleteAccount => 'Failed to delete account. Please try again.';
	String get newPassword => 'New Password';
	String get enterCode => 'Enter Code';
	String get chooseStrongPassword => 'Choose a strong password';
	String get code => 'Code';
	String get confirm => 'Confirm';
	String get verify => 'Verify';
	String get update => 'Update';
	String get resendCode2 => 'Resend code';
	String get pleaseEnterPassword => 'Please enter a password';
	String get passwordMinLength => 'Password must be at least 6 characters';
	String get passwordUppercase => 'Password must contain at least one uppercase letter';
	String get passwordLowercase => 'Password must contain at least one lowercase letter';
	String get passwordNumber => 'Password must contain at least one number';
	String get pleaseConfirmPassword => 'Please confirm your password';
	String get passwordsDoNotMatch => 'Passwords do not match';
	String get passwordRequirements => 'Password Requirements:';
	String get atLeast6Characters => 'At least 6 characters';
	String get oneUppercaseLetter => 'One uppercase letter';
	String get oneLowercaseLetter => 'One lowercase letter';
	String get oneNumber => 'One number';
	String get pleaseEnterVerificationCode => 'Please enter the verification code';
	String get codeVerifiedCreatePassword => 'Code verified! Now create your new password.';
	String get newVerificationCodeSent => 'New verification code sent to your email';
	String get breathTraining => 'Breath Training';
	String get unknown => 'Unknown';
	String get timer => 'Timer';
	String get newExercise => 'New Exercise';
	String exerciseSummary({required Object cycles, required Object duration}) => '${cycles} cycles • ${duration}s duration';
	String failedToExportExercise({required Object error}) => 'Failed to export exercise: ${error}';
	String failedToImportExercise({required Object error}) => 'Failed to import exercise: ${error}';
	String confirmDeleteExercise({required Object name}) => 'Are you sure you want to delete "${name}"?';
	String get inhale => 'In';
	String get exhale => 'Out';
	String get hold => 'Hold';
	String get breathPhaseIn => 'In';
	String get breathPhaseOut => 'Out';
	String get breathPhaseHold => 'Hold';
	String get molchanovMethod => 'Molchanov';
	String get molchanovDescription => 'CO₂ tolerance training. No breaks. Pro technique for breath holds.';
	String get breathing478 => '4-7-8 Calm';
	String get breathing478Description => 'Stress relief pattern. 4 in, 7 hold, 8 out. Sleep booster.';
	String get boxBreathing => 'Box';
	String get boxBreathingDescription => 'Focus technique. Equal timing all phases. Navy method.';
	late final _StringsServicesEn services = _StringsServicesEn._(_root);
}

// Path: services
class _StringsServicesEn {
	_StringsServicesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _StringsServicesSyncEn sync = _StringsServicesSyncEn._(_root);
	late final _StringsServicesOtpEn otp = _StringsServicesOtpEn._(_root);
	late final _StringsServicesStorageEn storage = _StringsServicesStorageEn._(_root);
	late final _StringsServicesSessionEn session = _StringsServicesSessionEn._(_root);
	late final _StringsServicesInitialTrainingEn initialTraining = _StringsServicesInitialTrainingEn._(_root);
}

// Path: services.sync
class _StringsServicesSyncEn {
	_StringsServicesSyncEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get supabaseNotConfigured => 'Supabase not configured. Please check your project settings.';
	String signUpFailed({required Object error}) => 'Sign up failed: ${error}';
	String get signUpFailedGeneric => 'Sign up failed. Please try again.';
	String signInFailed({required Object error}) => 'Sign in failed: ${error}';
	String get signInFailedGeneric => 'Sign in failed. Please try again.';
	String get invalidEmailPassword => 'Invalid email or password. Please check your credentials.';
	String get exerciseIncompleteData => 'Exercise has no phases - incomplete data';
}

// Path: services.otp
class _StringsServicesOtpEn {
	_StringsServicesOtpEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get supabaseNotConfigured => 'Supabase not configured. Please check your project settings.';
	String failedToSendOtp({required Object error}) => 'Failed to send OTP: ${error}';
	String get failedToSendOtpGeneric => 'Failed to send OTP. Please try again.';
	String get noOtpRequest => 'No OTP request found. Please request a new OTP.';
	String get otpExpired => 'OTP has expired. Please request a new one.';
	String get invalidOrExpiredOtp => 'Invalid or expired OTP. Please check your code or request a new one.';
	String otpVerificationFailed({required Object error}) => 'OTP verification failed: ${error}';
	String get otpVerificationFailedGeneric => 'OTP verification failed. Please try again.';
	String get otpMustBeVerified => 'OTP must be verified before updating password.';
	String failedToUpdatePassword({required Object error}) => 'Failed to update password: ${error}';
	String get failedToUpdatePasswordGeneric => 'Failed to update password. Please try again.';
}

// Path: services.storage
class _StringsServicesStorageEn {
	_StringsServicesStorageEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get boxNotOpen => 'Storage box is not open. Initialize app first.';
	String exerciseNotFound({required Object exerciseId}) => 'Exercise not found for duplication: ${exerciseId}';
	String get copy => 'Copy';
	String get exerciseNamePlaceholder => 'Exercise Name';
	String get exerciseDescriptionPlaceholder => 'Exercise Description';
}

// Path: services.session
class _StringsServicesSessionEn {
	_StringsServicesSessionEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get ready => 'Ready';
	String get go => 'Go!';
	String get noExerciseSelected => 'Cannot start session: no exercise selected';
}

// Path: services.initialTraining
class _StringsServicesInitialTrainingEn {
	_StringsServicesInitialTrainingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get molchanovMethodName => 'Molchanov Method';
	String get molchanovDescription => 'Aleksey Molchanov\'s daily exercise for breath-hold development. Used by the world champion during competitions. Builds CO₂ tolerance through cyclical holds without rest.\n\nTECHNIQUE:\n1. Inhale for 5 seconds through pursed lips\n2. Hold breath on full inhale (main phase)\n3. Exhale for 5-10 seconds with resistance\n4. Hold on empty lungs (optional for beginners)\n\nKEY PRINCIPLE:\nNo rest between cycles. This accumulates CO₂ and helps the body adapt to higher carbon dioxide levels.\n\nPROGRESSION:\nStart: 2 minutes with 30-second cycles (4 cycles)\nAdvance: Gradually increase to 15 minutes total\nCycles: 30s → 35s → 40s → 45s → 50s...\nFocus: Extend mainly the hold after inhale. Start with cycle count\n\nSAFETY:\nAlways sit or lie down. Never practice in water as a beginner. Take rest days when needed.\n\nLearn more: Search \"Molchanov breath hold training\"';
	String get breathing478Name => '4-7-8 Breathing';
	String get breathing478Description => 'Relaxing breathing pattern: inhale for 4, hold for 7, exhale for 8. Great for stress relief and better sleep.\n\nHOW TO USE:\nBest used before sleep or when stressed. Exhale completely before starting. Use tongue position: tip behind front teeth. Count steadily and consistently.\n\nPROGRESSION:\nWeek 1: 4 cycles before bed\nWeek 2-3: 6 cycles, twice daily\nWeek 4+: 8 cycles, anytime for calm\n\nLearn more: Search \"4-7-8 breathing Dr. Weil\"';
	String get boxBreathingName => 'Box Breathing';
	String get boxBreathingDescription => 'Equal-timing breathing pattern: inhale, hold, exhale, hold - all for the same duration. Perfect for focus and mental clarity.\n\nHOW TO USE:\nSit comfortably with straight spine. Start with 4-second intervals. Visualize drawing a box while breathing. Maintain steady, controlled pace.\n\nPROGRESSION:\nWeek 1-2: 4 seconds × 8 cycles\nWeek 3-4: 5 seconds × 8 cycles\nWeek 5+: Up to 6-8 seconds per side\n\nLearn more: Search \"box breathing Navy SEALs technique\"';
}

// Path: <root>
class _StringsDe extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsDe.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.de,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <de>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	@override late final _StringsDe _root = this; // ignore: unused_field

	// Translations
	@override String get appTitle => 'Bearth Timer';
	@override String get email => 'E-Mail';
	@override String get password => 'Passwort';
	@override String get enterEmail => 'E-Mail eingeben';
	@override String get enterPassword => 'Passwort eingeben';
	@override String get invalidEmailFormat => 'Ungültiges E-Mail-Format';
	@override String get minCharacters => 'Min. 6 Zeichen';
	@override String get signUp => 'Registrieren';
	@override String get signIn => 'Anmelden';
	@override String get signOut => 'Abmelden';
	@override String get skip => 'Überspringen';
	@override String get cancel => 'Abbrechen';
	@override String get delete => 'Löschen';
	@override String get ok => 'OK';
	@override String get close => 'Schließen';
	@override String get back => 'Zurück';
	@override String get loading => 'Lädt...';
	@override String get syncDataAcrossDevices => 'Daten geräteübergreifend synchronisieren';
	@override String get accessDataAnywhere => 'Zugriff auf Daten überall';
	@override String get haveAccountSignIn => 'Konto vorhanden? Anmelden';
	@override String get needAccountSignUp => 'Konto benötigt? Registrieren';
	@override String get forgot => 'Vergessen?';
	@override String get emailSent => 'E-Mail gesendet! Überprüfen Sie Ihr Postfach.';
	@override String get sendingEmail => 'E-Mail wird gesendet...';
	@override String get signupEmailSent => 'Registrierungs-E-Mail gesendet! Überprüfen Sie Ihr Postfach und setzen Sie Ihr Passwort.';
	@override String get failedToSendEmail => 'E-Mail senden fehlgeschlagen. Überprüfen Sie das E-Mail-Format.';
	@override String get supabaseNotConfigured => 'Supabase nicht konfiguriert';
	@override String get updateSupabaseConstants => 'Bitte aktualisieren Sie SupabaseConstants mit Ihrer Projekt-URL und dem Anon-Schlüssel';
	@override String get settings => 'Einstellungen';
	@override String get account => 'Konto';
	@override String get sync => 'Synchronisierung';
	@override String get sound => 'Ton';
	@override String get dataManagement => 'Datenverwaltung';
	@override String get appearance => 'Aussehen';
	@override String get about => 'Über';
	@override String get signedInAs => 'Angemeldet als';
	@override String get unknownEmail => 'Unbekannte E-Mail';
	@override String get signOutDescription => 'Abmelden und offline arbeiten';
	@override String get deleteAccount => 'Konto löschen';
	@override String get deleteAccountDescription => 'Konto und Daten dauerhaft löschen';
	@override String get workingOffline => 'Arbeitet offline';
	@override String get signInToSync => 'Anmelden zur geräteübergreifenden Synchronisierung';
	@override String get accessDataAnywhereButton => 'Zugriff auf Daten überall';
	@override String get retrySync => 'Synchronisierung wiederholen';
	@override String get syncWithCloud => 'Mit Cloud synchronisieren';
	@override String get exportData => 'Daten exportieren';
	@override String get saveDataToFile => 'Daten in Datei speichern';
	@override String get importData => 'Daten importieren';
	@override String get loadDataFromFile => 'Daten aus Datei laden';
	@override String get clearAllData => 'Alle Daten löschen';
	@override String get deleteAllDataPermanently => 'Alle Daten dauerhaft löschen';
	@override String get transitionSound => 'Übergangsgeräusch';
	@override String get playSoundWhenPhasesChange => 'Ton abspielen bei Phasenwechsel';
	@override String get darkMode => 'Dunkler Modus';
	@override String get useDarkTheme => 'Dunkles Design verwenden';
	@override String version({required Object version}) => 'Version ${version}';
	@override String get signOutConfirmTitle => 'Abmelden';
	@override String get signOutConfirmMessage => 'Sind Sie sicher, dass Sie sich abmelden möchten? Ihre Daten bleiben auf diesem Gerät.';
	@override String get clearAllDataConfirmTitle => 'Alle Daten löschen';
	@override String get clearAllDataConfirmMessage => 'Sind Sie sicher, dass Sie alle Trainingsergebnisse löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden und löscht Daten von all Ihren Geräten.';
	@override String get clearAll => 'Alle löschen';
	@override String get exercises => 'Übungen';
	@override String get importExercise => 'Übung importieren';
	@override String get addExercise => 'Übung hinzufügen';
	@override String get noExercisesYet => 'Noch keine Übungen';
	@override String get createFirstExercise => 'Erstellen Sie Ihre erste Übung';
	@override String get createYourFirstExercise => 'Erstellen Sie Ihre erste Übung';
	@override String get cycles => 'Zyklen';
	@override String get duration => 'Dauer';
	@override String cycleDurationSeconds({required Object cycles, required Object duration}) => '${cycles} Zyklen • ${duration}s Dauer';
	@override String get edit => 'Bearbeiten';
	@override String get duplicate => 'Duplizieren';
	@override String get export => 'Exportieren';
	@override String errorLoadingExercises({required Object error}) => 'Fehler beim Laden der Übungen: ${error}';
	@override String get deleteExercise => 'Übung löschen';
	@override String deleteExerciseConfirm({required Object name}) => 'Sind Sie sicher, dass Sie "${name}" löschen möchten?';
	@override String get exportFailed => 'Export fehlgeschlagen';
	@override String failedToExport({required Object error}) => 'Export der Übung fehlgeschlagen: ${error}';
	@override String get importSuccessful => 'Import erfolgreich';
	@override String get importFailed => 'Import fehlgeschlagen';
	@override String failedToImport({required Object error}) => 'Import der Übung fehlgeschlagen: ${error}';
	@override String get exerciseDetails => 'Übungsdetails:';
	@override String get cycleDuration => 'Zyklusdauer';
	@override String get totalDuration => 'Gesamtdauer';
	@override String get phases => 'Phasen';
	@override String get noDescriptionAvailable => 'Keine Beschreibung für diese Übung verfügbar.';
	@override String get description => 'Beschreibung';
	@override String get customize => 'Anpassen';
	@override String get time => 'Zeit';
	@override String get stop => 'Stopp';
	@override String get start => 'Start';
	@override String cycleProgress({required Object current, required Object total}) => 'Zyklus ${current} / ${total}';
	@override String get oneClap => '1 Klatschen';
	@override String clapsCount({required Object count}) => '${count} Klatschen';
	@override String range({required Object minDuration, required Object maxDuration}) => 'Bereich: ${minDuration}s - ${maxDuration}s';
	@override String get name => 'Name';
	@override String get information => 'Information';
	@override String get configuration => 'Konfiguration';
	@override String get min => 'Min';
	@override String get max => 'Max';
	@override String get step => 'Schritt';
	@override String get minimum => 'Minimum';
	@override String get current => 'Aktuell';
	@override String get maximum => 'Maximum';
	@override String get total => 'Gesamt';
	@override String get addPhase => 'Phase hinzufügen';
	@override String get history => 'Verlauf';
	@override String get overview => 'Übersicht';
	@override String get sessions => 'Sitzungen';
	@override String get totalTime => 'Gesamtzeit';
	@override String get avg => 'Durchschnitt';
	@override String get dailyDurationDiff => 'Dauer Diff.';
	@override String get dailyCycleDiff => 'Zyklen Diff.';
	@override String get bestScore => 'Beste Punktzahl';
	@override String get noHistoryYet => 'Noch kein Verlauf';
	@override String get completeSessionToSeeProgress => 'Schließen Sie eine Sitzung ab, um Fortschritt zu sehen';
	@override String today({required Object time}) => 'Heute ${time}';
	@override String get yesterday => 'Gestern';
	@override String daysAgo({required Object days}) => 'vor ${days} Tagen';
	@override String cyclesAndDuration({required Object cycles, required Object duration}) => '${cycles} Zyklen • ${duration}s';
	@override String get noTraining => 'Kein Training';
	@override String secondsUnit({required Object value}) => '${value}s';
	@override String cyclesUnit({required Object value}) => '${value}z';
	@override String get resetPassword => 'Passwort zurücksetzen';
	@override String get enterEmailToGetResetCode => 'E-Mail eingeben, um Reset-Code zu erhalten';
	@override String get sendCode => 'Code senden';
	@override String get passwordResetCodeSent => 'Passwort-Reset-Code an Ihre E-Mail gesendet';
	@override String get verifyEmail => 'E-Mail verifizieren';
	@override String get checkYourEmail => 'Überprüfen Sie Ihre E-Mail';
	@override String codeSentTo({required Object email}) => 'Code gesendet an ${email}';
	@override String get verificationCode => 'Bestätigungscode';
	@override String get createAccount => 'Konto erstellen';
	@override String resendInSeconds({required Object seconds}) => 'Erneut senden in ${seconds}s';
	@override String get resendCode => 'Code erneut senden';
	@override String get newCodeSentToEmail => 'Neuer Code an Ihre E-Mail gesendet';
	@override String get enterVerificationCode => 'Bestätigungscode eingeben';
	@override String get deleteAccountTitle => 'Konto löschen';
	@override String get verifyDeletion => 'Löschung bestätigen';
	@override String get permanentDeleteWarning => 'Dies wird Ihr Konto und alle Daten dauerhaft löschen.';
	@override String get deletionConsequences => '• Alle Trainingsdaten gehen verloren\n• Sync-Einstellungen werden gelöscht\n• Diese Aktion kann nicht rückgängig gemacht werden';
	@override String get iUnderstandContinue => 'Ich verstehe, fortfahren';
	@override String accountEmail({required Object email}) => 'Konto: ${email}';
	@override String get sendVerificationCodeDescription => 'Wir senden Ihnen einen Bestätigungscode zur Bestätigung dieser Aktion.';
	@override String get sendVerificationCode => 'Bestätigungscode senden';
	@override String get noUserEmailFound => 'Keine Benutzer-E-Mail gefunden. Bitte melden Sie sich erneut an.';
	@override String verificationCodeSentTo({required Object email}) => 'Bestätigungscode gesendet an ${email}';
	@override String get accountDataCleared => 'Kontodaten gelöscht. Sie wurden abgemeldet.';
	@override String get failedToDeleteAccount => 'Konto löschen fehlgeschlagen. Bitte versuchen Sie es erneut.';
	@override String get newPassword => 'Neues Passwort';
	@override String get enterCode => 'Code eingeben';
	@override String get chooseStrongPassword => 'Wählen Sie ein starkes Passwort';
	@override String get code => 'Code';
	@override String get confirm => 'Bestätigen';
	@override String get verify => 'Bestätigen';
	@override String get update => 'Aktualisieren';
	@override String get resendCode2 => 'Code erneut senden';
	@override String get pleaseEnterPassword => 'Bitte geben Sie ein Passwort ein';
	@override String get passwordMinLength => 'Passwort muss mindestens 6 Zeichen haben';
	@override String get passwordUppercase => 'Passwort muss mindestens einen Großbuchstaben enthalten';
	@override String get passwordLowercase => 'Passwort muss mindestens einen Kleinbuchstaben enthalten';
	@override String get passwordNumber => 'Passwort muss mindestens eine Zahl enthalten';
	@override String get pleaseConfirmPassword => 'Bitte bestätigen Sie Ihr Passwort';
	@override String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';
	@override String get passwordRequirements => 'Passwort-Anforderungen:';
	@override String get atLeast6Characters => 'Mindestens 6 Zeichen';
	@override String get oneUppercaseLetter => 'Ein Großbuchstabe';
	@override String get oneLowercaseLetter => 'Ein Kleinbuchstabe';
	@override String get oneNumber => 'Eine Zahl';
	@override String get pleaseEnterVerificationCode => 'Bitte geben Sie den Bestätigungscode ein';
	@override String get codeVerifiedCreatePassword => 'Code bestätigt! Erstellen Sie jetzt Ihr neues Passwort.';
	@override String get newVerificationCodeSent => 'Neuer Bestätigungscode an Ihre E-Mail gesendet';
	@override String get breathTraining => 'Atemtraining';
	@override String get unknown => 'Unbekannt';
	@override String get timer => 'Timer';
	@override String get newExercise => 'Neue Übung';
	@override String exerciseSummary({required Object cycles, required Object duration}) => '${cycles} Zyklen • ${duration}s Dauer';
	@override String failedToExportExercise({required Object error}) => 'Export der Übung fehlgeschlagen: ${error}';
	@override String failedToImportExercise({required Object error}) => 'Import der Übung fehlgeschlagen: ${error}';
	@override String confirmDeleteExercise({required Object name}) => 'Sind Sie sicher, dass Sie "${name}" löschen möchten?';
	@override String get inhale => 'Ein';
	@override String get exhale => 'Aus';
	@override String get hold => 'Halt';
	@override String get breathPhaseIn => 'Ein';
	@override String get breathPhaseOut => 'Aus';
	@override String get breathPhaseHold => 'Halt';
	@override String get molchanovMethod => 'Molchanov';
	@override String get molchanovDescription => 'CO₂-Toleranztraining. Ohne Pausen. Profi-Technik für Atemhalten.';
	@override String get breathing478 => '4-7-8 Ruhe';
	@override String get breathing478Description => 'Anti-Stress-Muster. 4 ein, 7 halten, 8 aus. Schlafhilfe.';
	@override String get boxBreathing => 'Box';
	@override String get boxBreathingDescription => 'Fokus-Technik. Alle Phasen gleich. Navy-Methode.';
	@override late final _StringsServicesDe services = _StringsServicesDe._(_root);
}

// Path: services
class _StringsServicesDe extends _StringsServicesEn {
	_StringsServicesDe._(_StringsDe root) : this._root = root, super._(root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override late final _StringsServicesSyncDe sync = _StringsServicesSyncDe._(_root);
	@override late final _StringsServicesOtpDe otp = _StringsServicesOtpDe._(_root);
	@override late final _StringsServicesStorageDe storage = _StringsServicesStorageDe._(_root);
	@override late final _StringsServicesSessionDe session = _StringsServicesSessionDe._(_root);
	@override late final _StringsServicesInitialTrainingDe initialTraining = _StringsServicesInitialTrainingDe._(_root);
}

// Path: services.sync
class _StringsServicesSyncDe extends _StringsServicesSyncEn {
	_StringsServicesSyncDe._(_StringsDe root) : this._root = root, super._(root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override String get supabaseNotConfigured => 'Supabase nicht konfiguriert. Überprüfen Sie Ihre Projekteinstellungen.';
	@override String signUpFailed({required Object error}) => 'Registrierung fehlgeschlagen: ${error}';
	@override String get signUpFailedGeneric => 'Registrierung fehlgeschlagen. Bitte versuchen Sie es erneut.';
	@override String signInFailed({required Object error}) => 'Anmeldung fehlgeschlagen: ${error}';
	@override String get signInFailedGeneric => 'Anmeldung fehlgeschlagen. Bitte versuchen Sie es erneut.';
	@override String get invalidEmailPassword => 'Ungültige E-Mail oder Passwort. Bitte überprüfen Sie Ihre Daten.';
	@override String get exerciseIncompleteData => 'Übung hat keine Phasen - unvollständige Daten';
}

// Path: services.otp
class _StringsServicesOtpDe extends _StringsServicesOtpEn {
	_StringsServicesOtpDe._(_StringsDe root) : this._root = root, super._(root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override String get supabaseNotConfigured => 'Supabase nicht konfiguriert. Überprüfen Sie Ihre Projekteinstellungen.';
	@override String failedToSendOtp({required Object error}) => 'OTP-Versand fehlgeschlagen: ${error}';
	@override String get failedToSendOtpGeneric => 'OTP-Versand fehlgeschlagen. Bitte versuchen Sie es erneut.';
	@override String get noOtpRequest => 'Keine OTP-Anfrage gefunden. Bitte fordern Sie ein neues OTP an.';
	@override String get otpExpired => 'OTP ist abgelaufen. Bitte fordern Sie ein neues an.';
	@override String get invalidOrExpiredOtp => 'Ungültiges oder abgelaufenes OTP. Überprüfen Sie Ihren Code oder fordern Sie ein neues an.';
	@override String otpVerificationFailed({required Object error}) => 'OTP-Verifizierung fehlgeschlagen: ${error}';
	@override String get otpVerificationFailedGeneric => 'OTP-Verifizierung fehlgeschlagen. Bitte versuchen Sie es erneut.';
	@override String get otpMustBeVerified => 'OTP muss vor Passwort-Update verifiziert werden.';
	@override String failedToUpdatePassword({required Object error}) => 'Passwort-Update fehlgeschlagen: ${error}';
	@override String get failedToUpdatePasswordGeneric => 'Passwort-Update fehlgeschlagen. Bitte versuchen Sie es erneut.';
}

// Path: services.storage
class _StringsServicesStorageDe extends _StringsServicesStorageEn {
	_StringsServicesStorageDe._(_StringsDe root) : this._root = root, super._(root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override String get boxNotOpen => 'Speicher-Box ist nicht geöffnet. Initialisieren Sie die App zuerst.';
	@override String exerciseNotFound({required Object exerciseId}) => 'Übung nicht gefunden für Duplizierung: ${exerciseId}';
	@override String get copy => 'Kopie';
	@override String get exerciseNamePlaceholder => 'Übungsname';
	@override String get exerciseDescriptionPlaceholder => 'Übungsbeschreibung';
}

// Path: services.session
class _StringsServicesSessionDe extends _StringsServicesSessionEn {
	_StringsServicesSessionDe._(_StringsDe root) : this._root = root, super._(root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override String get ready => 'Bereit';
	@override String get go => 'Los!';
	@override String get noExerciseSelected => 'Kann keine Sitzung starten: keine Übung ausgewählt';
}

// Path: services.initialTraining
class _StringsServicesInitialTrainingDe extends _StringsServicesInitialTrainingEn {
	_StringsServicesInitialTrainingDe._(_StringsDe root) : this._root = root, super._(root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override String get molchanovMethodName => 'Molchanov-Methode';
	@override String get molchanovDescription => 'Aleksey Molchanovs tägliche Übung für die Entwicklung von Atemanhaltungen. Wird vom Weltmeister bei Wettkämpfen verwendet. Baut CO₂-Toleranz durch zyklische Anhaltungen ohne Pause auf.\n\nTECHNIK:\n1. 5 Sekunden durch gespitzte Lippen einatmen\n2. Atem bei voller Einatmung anhalten (Hauptphase)\n3. 5-10 Sekunden mit Widerstand ausatmen\n4. Bei leeren Lungen anhalten (optional für Anfänger)\n\nSCHLÜSSELPRINZIP:\nKeine Pause zwischen den Zyklen. Dies akkumuliert CO₂ und hilft dem Körper, sich an höhere Kohlendioxidwerte anzupassen.\n\nFORTSCHRITT:\nStart: 2 Minuten mit 30-Sekunden-Zyklen (4 Zyklen)\nFortschritt: Allmählich auf 15 Minuten Gesamtzeit steigern\nZyklen: 30s → 35s → 40s → 45s → 50s...\nFokus: Hauptsächlich das Anhalten nach dem Einatmen verlängern. Mit der Zyklusanzahl beginnen\n\nSICHERHEIT:\nImmer sitzen oder liegen. Als Anfänger niemals im Wasser üben. Ruhetage nach Bedarf einlegen.\n\nMehr erfahren: Suchen Sie nach \"Molchanov Atemanhaltungstraining\"';
	@override String get breathing478Name => '4-7-8 Atmung';
	@override String get breathing478Description => 'Entspannendes Atemmuster: 4 einatmen, 7 anhalten, 8 ausatmen. Großartig für Stressabbau und besseren Schlaf.\n\nANWENDUNG:\nAm besten vor dem Schlafengehen oder bei Stress anwenden. Vollständig ausatmen bevor Sie beginnen. Zungenposition verwenden: Spitze hinter den Vorderzähnen. Gleichmäßig und konsistent zählen.\n\nFORTSCHRITT:\nWoche 1: 4 Zyklen vor dem Schlafengehen\nWoche 2-3: 6 Zyklen, zweimal täglich\nWoche 4+: 8 Zyklen, jederzeit für Ruhe\n\nMehr erfahren: Suchen Sie nach \"4-7-8 Atmung Dr. Weil\"';
	@override String get boxBreathingName => 'Box-Atmung';
	@override String get boxBreathingDescription => 'Gleichzeitiges Atemmuster: einatmen, anhalten, ausatmen, anhalten - alles für die gleiche Dauer. Perfekt für Fokus und geistige Klarheit.\n\nANWENDUNG:\nBequem mit gerader Wirbelsäule sitzen. Mit 4-Sekunden-Intervallen beginnen. Visualisieren Sie das Zeichnen eines Quadrats beim Atmen. Gleichmäßiges, kontrolliertes Tempo beibehalten.\n\nFORTSCHRITT:\nWoche 1-2: 4 Sekunden × 8 Zyklen\nWoche 3-4: 5 Sekunden × 8 Zyklen\nWoche 5+: Bis zu 6-8 Sekunden pro Seite\n\nMehr erfahren: Suchen Sie nach \"Box-Atmung Navy SEALs Technik\"';
}

// Path: <root>
class _StringsEs extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsEs.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	@override late final _StringsEs _root = this; // ignore: unused_field

	// Translations
	@override String get appTitle => 'Bearth Timer';
	@override String get email => 'Correo electrónico';
	@override String get password => 'Contraseña';
	@override String get enterEmail => 'Ingrese el correo';
	@override String get enterPassword => 'Ingrese la contraseña';
	@override String get invalidEmailFormat => 'Formato de correo inválido';
	@override String get minCharacters => 'Mín 6 caracteres';
	@override String get signUp => 'Registrarse';
	@override String get signIn => 'Iniciar sesión';
	@override String get signOut => 'Cerrar sesión';
	@override String get skip => 'Omitir';
	@override String get cancel => 'Cancelar';
	@override String get delete => 'Eliminar';
	@override String get ok => 'Aceptar';
	@override String get close => 'Cerrar';
	@override String get back => 'Volver';
	@override String get loading => 'Cargando...';
	@override String get syncDataAcrossDevices => 'Sincronizar datos entre dispositivos';
	@override String get accessDataAnywhere => 'Acceder a datos en cualquier lugar';
	@override String get haveAccountSignIn => '¿Tienes cuenta? Iniciar sesión';
	@override String get needAccountSignUp => '¿Necesitas cuenta? Registrarse';
	@override String get forgot => '¿Olvidaste?';
	@override String get emailSent => '¡Correo enviado! Revisa tu bandeja de entrada.';
	@override String get sendingEmail => 'Enviando correo...';
	@override String get signupEmailSent => '¡Correo de registro enviado! Revisa tu bandeja de entrada y establece tu contraseña.';
	@override String get failedToSendEmail => 'Error al enviar correo. Verifica el formato del correo.';
	@override String get supabaseNotConfigured => 'Supabase no configurado';
	@override String get updateSupabaseConstants => 'Actualiza SupabaseConstants con la URL de tu proyecto y la clave anónima';
	@override String get settings => 'Configuración';
	@override String get account => 'Cuenta';
	@override String get sync => 'Sincronización';
	@override String get sound => 'Sonido';
	@override String get dataManagement => 'Gestión de datos';
	@override String get appearance => 'Apariencia';
	@override String get about => 'Acerca de';
	@override String get signedInAs => 'Sesión iniciada como';
	@override String get unknownEmail => 'Correo desconocido';
	@override String get signOutDescription => 'Cerrar sesión y trabajar sin conexión';
	@override String get deleteAccount => 'Eliminar cuenta';
	@override String get deleteAccountDescription => 'Eliminar permanentemente la cuenta y los datos';
	@override String get workingOffline => 'Trabajando sin conexión';
	@override String get signInToSync => 'Inicia sesión para sincronizar entre dispositivos';
	@override String get accessDataAnywhereButton => 'Acceder a datos en cualquier lugar';
	@override String get retrySync => 'Reintentar sincronización';
	@override String get syncWithCloud => 'Sincronizar con la nube';
	@override String get exportData => 'Exportar datos';
	@override String get saveDataToFile => 'Guardar datos en archivo';
	@override String get importData => 'Importar datos';
	@override String get loadDataFromFile => 'Cargar datos desde archivo';
	@override String get clearAllData => 'Limpiar todos los datos';
	@override String get deleteAllDataPermanently => 'Eliminar todos los datos permanentemente';
	@override String get transitionSound => 'Sonido de transición';
	@override String get playSoundWhenPhasesChange => 'Reproducir sonido cuando cambien las fases';
	@override String get darkMode => 'Modo oscuro';
	@override String get useDarkTheme => 'Usar tema oscuro';
	@override String version({required Object version}) => 'Versión ${version}';
	@override String get signOutConfirmTitle => 'Cerrar sesión';
	@override String get signOutConfirmMessage => '¿Estás seguro de que quieres cerrar sesión? Tus datos permanecerán en este dispositivo.';
	@override String get clearAllDataConfirmTitle => 'Limpiar todos los datos';
	@override String get clearAllDataConfirmMessage => '¿Estás seguro de que quieres eliminar todos los resultados de entrenamiento? Esta acción no se puede deshacer y borrará datos de todos tus dispositivos.';
	@override String get clearAll => 'Limpiar todo';
	@override String get exercises => 'Ejercicios';
	@override String get importExercise => 'Importar ejercicio';
	@override String get addExercise => 'Añadir ejercicio';
	@override String get noExercisesYet => 'Aún no hay ejercicios';
	@override String get createFirstExercise => 'Crea tu primer ejercicio';
	@override String get createYourFirstExercise => 'Crea tu primer ejercicio';
	@override String get cycles => 'Ciclos';
	@override String get duration => 'Duración';
	@override String cycleDurationSeconds({required Object cycles, required Object duration}) => '${cycles} ciclos • ${duration}s duración';
	@override String get edit => 'Editar';
	@override String get duplicate => 'Duplicar';
	@override String get export => 'Exportar';
	@override String errorLoadingExercises({required Object error}) => 'Error cargando ejercicios: ${error}';
	@override String get deleteExercise => 'Eliminar ejercicio';
	@override String deleteExerciseConfirm({required Object name}) => '¿Estás seguro de que quieres eliminar "${name}"?';
	@override String get exportFailed => 'Exportación fallida';
	@override String failedToExport({required Object error}) => 'Error al exportar ejercicio: ${error}';
	@override String get importSuccessful => 'Importación exitosa';
	@override String get importFailed => 'Importación fallida';
	@override String failedToImport({required Object error}) => 'Error al importar ejercicio: ${error}';
	@override String get exerciseDetails => 'Detalles del ejercicio:';
	@override String get cycleDuration => 'Duración del ciclo';
	@override String get totalDuration => 'Duración total';
	@override String get phases => 'Fases';
	@override String get noDescriptionAvailable => 'No hay descripción disponible para este ejercicio.';
	@override String get description => 'Descripción';
	@override String get customize => 'Personalizar';
	@override String get time => 'Tiempo';
	@override String get stop => 'Detener';
	@override String get start => 'Iniciar';
	@override String cycleProgress({required Object current, required Object total}) => 'Ciclo ${current} / ${total}';
	@override String get oneClap => '1 palmada';
	@override String clapsCount({required Object count}) => '${count} palmadas';
	@override String range({required Object minDuration, required Object maxDuration}) => 'Rango: ${minDuration}s - ${maxDuration}s';
	@override String get name => 'Nombre';
	@override String get information => 'Información';
	@override String get configuration => 'Configuración';
	@override String get min => 'Mín';
	@override String get max => 'Máx';
	@override String get step => 'Paso';
	@override String get minimum => 'Mínimo';
	@override String get current => 'Actual';
	@override String get maximum => 'Máximo';
	@override String get total => 'Total';
	@override String get addPhase => 'Añadir fase';
	@override String get history => 'Historial';
	@override String get overview => 'Resumen';
	@override String get sessions => 'Sesiones';
	@override String get totalTime => 'Tiempo Total';
	@override String get avg => 'Promedio';
	@override String get dailyDurationDiff => 'Dif. Duración';
	@override String get dailyCycleDiff => 'Dif. Ciclos';
	@override String get bestScore => 'Mejor Puntuación';
	@override String get noHistoryYet => 'Aún no hay historial';
	@override String get completeSessionToSeeProgress => 'Completa una sesión para ver el progreso';
	@override String today({required Object time}) => 'Hoy ${time}';
	@override String get yesterday => 'Ayer';
	@override String daysAgo({required Object days}) => 'hace ${days} días';
	@override String cyclesAndDuration({required Object cycles, required Object duration}) => '${cycles} ciclos • ${duration}s';
	@override String get noTraining => 'Sin entrenamiento';
	@override String secondsUnit({required Object value}) => '${value}s';
	@override String cyclesUnit({required Object value}) => '${value}c';
	@override String get resetPassword => 'Restablecer contraseña';
	@override String get enterEmailToGetResetCode => 'Ingresa el correo para obtener el código de restablecimiento';
	@override String get sendCode => 'Enviar código';
	@override String get passwordResetCodeSent => 'Código de restablecimiento de contraseña enviado a tu correo';
	@override String get verifyEmail => 'Verificar correo';
	@override String get checkYourEmail => 'Revisa tu correo';
	@override String codeSentTo({required Object email}) => 'Código enviado a ${email}';
	@override String get verificationCode => 'Código de verificación';
	@override String get createAccount => 'Crear cuenta';
	@override String resendInSeconds({required Object seconds}) => 'Reenviar en ${seconds}s';
	@override String get resendCode => 'Reenviar código';
	@override String get newCodeSentToEmail => 'Nuevo código enviado a tu correo';
	@override String get enterVerificationCode => 'Ingresa el código de verificación';
	@override String get deleteAccountTitle => 'Eliminar cuenta';
	@override String get verifyDeletion => 'Verificar eliminación';
	@override String get permanentDeleteWarning => 'Esto eliminará permanentemente tu cuenta y todos los datos.';
	@override String get deletionConsequences => '• Se perderán todos los datos de entrenamiento\n• Se borrarán las configuraciones de sincronización\n• Esta acción no se puede deshacer';
	@override String get iUnderstandContinue => 'Entiendo, continuar';
	@override String accountEmail({required Object email}) => 'Cuenta: ${email}';
	@override String get sendVerificationCodeDescription => 'Enviaremos un código de verificación para confirmar esta acción.';
	@override String get sendVerificationCode => 'Enviar código de verificación';
	@override String get noUserEmailFound => 'No se encontró correo de usuario. Por favor inicia sesión nuevamente.';
	@override String verificationCodeSentTo({required Object email}) => 'Código de verificación enviado a ${email}';
	@override String get accountDataCleared => 'Datos de cuenta borrados. Has cerrado sesión.';
	@override String get failedToDeleteAccount => 'Error al eliminar cuenta. Por favor intenta nuevamente.';
	@override String get newPassword => 'Nueva contraseña';
	@override String get enterCode => 'Ingresar código';
	@override String get chooseStrongPassword => 'Elige una contraseña segura';
	@override String get code => 'Código';
	@override String get confirm => 'Confirmar';
	@override String get verify => 'Verificar';
	@override String get update => 'Actualizar';
	@override String get resendCode2 => 'Reenviar código';
	@override String get pleaseEnterPassword => 'Por favor ingresa una contraseña';
	@override String get passwordMinLength => 'La contraseña debe tener al menos 6 caracteres';
	@override String get passwordUppercase => 'La contraseña debe contener al menos una letra mayúscula';
	@override String get passwordLowercase => 'La contraseña debe contener al menos una letra minúscula';
	@override String get passwordNumber => 'La contraseña debe contener al menos un número';
	@override String get pleaseConfirmPassword => 'Por favor confirma tu contraseña';
	@override String get passwordsDoNotMatch => 'Las contraseñas no coinciden';
	@override String get passwordRequirements => 'Requisitos de contraseña:';
	@override String get atLeast6Characters => 'Al menos 6 caracteres';
	@override String get oneUppercaseLetter => 'Una letra mayúscula';
	@override String get oneLowercaseLetter => 'Una letra minúscula';
	@override String get oneNumber => 'Un número';
	@override String get pleaseEnterVerificationCode => 'Por favor ingresa el código de verificación';
	@override String get codeVerifiedCreatePassword => '¡Código verificado! Ahora crea tu nueva contraseña.';
	@override String get newVerificationCodeSent => 'Nuevo código de verificación enviado a tu correo';
	@override String get breathTraining => 'Entrenamiento de respiración';
	@override String get unknown => 'Desconocido';
	@override String get timer => 'Temporizador';
	@override String get newExercise => 'Nuevo ejercicio';
	@override String exerciseSummary({required Object cycles, required Object duration}) => '${cycles} ciclos • ${duration}s duración';
	@override String failedToExportExercise({required Object error}) => 'Error al exportar ejercicio: ${error}';
	@override String failedToImportExercise({required Object error}) => 'Error al importar ejercicio: ${error}';
	@override String confirmDeleteExercise({required Object name}) => '¿Estás seguro de que quieres eliminar "${name}"?';
	@override String get inhale => 'Entrar';
	@override String get exhale => 'Salir';
	@override String get hold => 'Aguantar';
	@override String get breathPhaseIn => 'Entrar';
	@override String get breathPhaseOut => 'Salir';
	@override String get breathPhaseHold => 'Aguantar';
	@override String get molchanovMethod => 'Molchanov';
	@override String get molchanovDescription => 'Entrenamiento de tolerancia CO₂. Sin descansos. Técnica pro para aguante.';
	@override String get breathing478 => '4-7-8 Calma';
	@override String get breathing478Description => 'Patrón anti-estrés. 4 entrar, 7 aguantar, 8 salir. Ayuda dormir.';
	@override String get boxBreathing => 'Caja';
	@override String get boxBreathingDescription => 'Técnica de foco. Todas las fases iguales. Método Navy.';
	@override late final _StringsServicesEs services = _StringsServicesEs._(_root);
}

// Path: services
class _StringsServicesEs extends _StringsServicesEn {
	_StringsServicesEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override late final _StringsServicesSyncEs sync = _StringsServicesSyncEs._(_root);
	@override late final _StringsServicesOtpEs otp = _StringsServicesOtpEs._(_root);
	@override late final _StringsServicesStorageEs storage = _StringsServicesStorageEs._(_root);
	@override late final _StringsServicesSessionEs session = _StringsServicesSessionEs._(_root);
	@override late final _StringsServicesInitialTrainingEs initialTraining = _StringsServicesInitialTrainingEs._(_root);
}

// Path: services.sync
class _StringsServicesSyncEs extends _StringsServicesSyncEn {
	_StringsServicesSyncEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get supabaseNotConfigured => 'Supabase no configurado. Verifique la configuración de su proyecto.';
	@override String signUpFailed({required Object error}) => 'Error en el registro: ${error}';
	@override String get signUpFailedGeneric => 'Error en el registro. Por favor, inténtelo de nuevo.';
	@override String signInFailed({required Object error}) => 'Error en el inicio de sesión: ${error}';
	@override String get signInFailedGeneric => 'Error en el inicio de sesión. Por favor, inténtelo de nuevo.';
	@override String get invalidEmailPassword => 'Email o contraseña inválidos. Verifique sus credenciales.';
	@override String get exerciseIncompleteData => 'El ejercicio no tiene fases - datos incompletos';
}

// Path: services.otp
class _StringsServicesOtpEs extends _StringsServicesOtpEn {
	_StringsServicesOtpEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get supabaseNotConfigured => 'Supabase no configurado. Verifique la configuración de su proyecto.';
	@override String failedToSendOtp({required Object error}) => 'Error al enviar OTP: ${error}';
	@override String get failedToSendOtpGeneric => 'Error al enviar OTP. Por favor, inténtelo de nuevo.';
	@override String get noOtpRequest => 'No se encontró solicitud de OTP. Solicite un nuevo OTP.';
	@override String get otpExpired => 'El OTP ha expirado. Solicite uno nuevo.';
	@override String get invalidOrExpiredOtp => 'OTP inválido o expirado. Verifique su código o solicite uno nuevo.';
	@override String otpVerificationFailed({required Object error}) => 'Error en la verificación de OTP: ${error}';
	@override String get otpVerificationFailedGeneric => 'Error en la verificación de OTP. Por favor, inténtelo de nuevo.';
	@override String get otpMustBeVerified => 'El OTP debe ser verificado antes de actualizar la contraseña.';
	@override String failedToUpdatePassword({required Object error}) => 'Error al actualizar contraseña: ${error}';
	@override String get failedToUpdatePasswordGeneric => 'Error al actualizar contraseña. Por favor, inténtelo de nuevo.';
}

// Path: services.storage
class _StringsServicesStorageEs extends _StringsServicesStorageEn {
	_StringsServicesStorageEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get boxNotOpen => 'La caja de almacenamiento no está abierta. Inicialice la aplicación primero.';
	@override String exerciseNotFound({required Object exerciseId}) => 'Ejercicio no encontrado para duplicación: ${exerciseId}';
	@override String get copy => 'Copia';
	@override String get exerciseNamePlaceholder => 'Nombre del ejercicio';
	@override String get exerciseDescriptionPlaceholder => 'Descripción del ejercicio';
}

// Path: services.session
class _StringsServicesSessionEs extends _StringsServicesSessionEn {
	_StringsServicesSessionEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get ready => 'Listo';
	@override String get go => '¡Vamos!';
	@override String get noExerciseSelected => 'No se puede iniciar sesión: no hay ejercicio seleccionado';
}

// Path: services.initialTraining
class _StringsServicesInitialTrainingEs extends _StringsServicesInitialTrainingEn {
	_StringsServicesInitialTrainingEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get molchanovMethodName => 'Método Molchanov';
	@override String get molchanovDescription => 'Ejercicio diario de Aleksey Molchanov para el desarrollo de retención de aliento. Usado por el campeón mundial durante competiciones. Desarrolla tolerancia al CO₂ a través de retenciones cíclicas sin descanso.\n\nTÉCNICA:\n1. Inhalar durante 5 segundos con labios fruncidos\n2. Retener el aliento con inhalación completa (fase principal)\n3. Exhalar durante 5-10 segundos con resistencia\n4. Retener con pulmones vacíos (opcional para principiantes)\n\nPRINCIPIO CLAVE:\nSin descanso entre ciclos. Esto acumula CO₂ y ayuda al cuerpo a adaptarse a niveles más altos de dióxido de carbono.\n\nPROGRESIÓN:\nInicio: 2 minutos con ciclos de 30 segundos (4 ciclos)\nAvance: Aumentar gradualmente hasta 15 minutos total\nCiclos: 30s → 35s → 40s → 45s → 50s...\nEnfoque: Extender principalmente la retención después de inhalar. Comenzar con conteo de ciclos\n\nSEGURIDAD:\nSiempre sentado o acostado. Nunca practicar en agua como principiante. Tomar días de descanso cuando sea necesario.\n\nAprende más: Busca \"entrenamiento de retención de aliento Molchanov\"';
	@override String get breathing478Name => 'Respiración 4-7-8';
	@override String get breathing478Description => 'Patrón de respiración relajante: inhalar durante 4, retener durante 7, exhalar durante 8. Excelente para alivio del estrés y mejor sueño.\n\nCÓMO USAR:\nMejor usado antes de dormir o cuando estés estresado. Exhalar completamente antes de comenzar. Usar posición de lengua: punta detrás de dientes frontales. Contar de manera constante y consistente.\n\nPROGRESIÓN:\nSemana 1: 4 ciclos antes de dormir\nSemana 2-3: 6 ciclos, dos veces al día\nSemana 4+: 8 ciclos, cualquier momento para calma\n\nAprende más: Busca \"respiración 4-7-8 Dr. Weil\"';
	@override String get boxBreathingName => 'Respiración Cuadrada';
	@override String get boxBreathingDescription => 'Patrón de respiración de tiempo igual: inhalar, retener, exhalar, retener - todo por la misma duración. Perfecto para enfoque y claridad mental.\n\nCÓMO USAR:\nSentarse cómodamente con columna recta. Comenzar con intervalos de 4 segundos. Visualizar dibujar un cuadrado mientras respiras. Mantener ritmo constante y controlado.\n\nPROGRESIÓN:\nSemana 1-2: 4 segundos × 8 ciclos\nSemana 3-4: 5 segundos × 8 ciclos\nSemana 5+: Hasta 6-8 segundos por lado\n\nAprende más: Busca \"respiración cuadrada técnica Navy SEALs\"';
}

// Path: <root>
class _StringsFr extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsFr.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <fr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	@override late final _StringsFr _root = this; // ignore: unused_field

	// Translations
	@override String get appTitle => 'Bearth Timer';
	@override String get email => 'E-mail';
	@override String get password => 'Mot de passe';
	@override String get enterEmail => 'Entrez l\'e-mail';
	@override String get enterPassword => 'Entrez le mot de passe';
	@override String get invalidEmailFormat => 'Format d\'e-mail invalide';
	@override String get minCharacters => 'Min 6 caractères';
	@override String get signUp => 'S\'inscrire';
	@override String get signIn => 'Se connecter';
	@override String get signOut => 'Se déconnecter';
	@override String get skip => 'Passer';
	@override String get cancel => 'Annuler';
	@override String get delete => 'Supprimer';
	@override String get ok => 'OK';
	@override String get close => 'Fermer';
	@override String get back => 'Retour';
	@override String get loading => 'Chargement...';
	@override String get syncDataAcrossDevices => 'Synchroniser les données entre appareils';
	@override String get accessDataAnywhere => 'Accéder aux données partout';
	@override String get haveAccountSignIn => 'Vous avez un compte ? Se connecter';
	@override String get needAccountSignUp => 'Besoin d\'un compte ? S\'inscrire';
	@override String get forgot => 'Oublié ?';
	@override String get emailSent => 'E-mail envoyé ! Vérifiez votre boîte de réception.';
	@override String get sendingEmail => 'Envoi de l\'e-mail...';
	@override String get signupEmailSent => 'E-mail d\'inscription envoyé ! Vérifiez votre boîte de réception et définissez votre mot de passe.';
	@override String get failedToSendEmail => 'Échec de l\'envoi de l\'e-mail. Vérifiez le format de l\'e-mail.';
	@override String get supabaseNotConfigured => 'Supabase non configuré';
	@override String get updateSupabaseConstants => 'Veuillez mettre à jour SupabaseConstants avec l\'URL de votre projet et la clé anonyme';
	@override String get settings => 'Paramètres';
	@override String get account => 'Compte';
	@override String get sync => 'Synchronisation';
	@override String get sound => 'Son';
	@override String get dataManagement => 'Gestion des données';
	@override String get appearance => 'Apparence';
	@override String get about => 'À propos';
	@override String get signedInAs => 'Connecté en tant que';
	@override String get unknownEmail => 'E-mail inconnu';
	@override String get signOutDescription => 'Se déconnecter et travailler hors ligne';
	@override String get deleteAccount => 'Supprimer le compte';
	@override String get deleteAccountDescription => 'Supprimer définitivement le compte et les données';
	@override String get workingOffline => 'Travail hors ligne';
	@override String get signInToSync => 'Connectez-vous pour synchroniser entre appareils';
	@override String get accessDataAnywhereButton => 'Accéder aux données partout';
	@override String get retrySync => 'Réessayer la synchronisation';
	@override String get syncWithCloud => 'Synchroniser avec le cloud';
	@override String get exportData => 'Exporter les données';
	@override String get saveDataToFile => 'Enregistrer les données dans un fichier';
	@override String get importData => 'Importer les données';
	@override String get loadDataFromFile => 'Charger les données depuis un fichier';
	@override String get clearAllData => 'Effacer toutes les données';
	@override String get deleteAllDataPermanently => 'Supprimer définitivement toutes les données';
	@override String get transitionSound => 'Son de transition';
	@override String get playSoundWhenPhasesChange => 'Jouer un son lors des changements de phase';
	@override String get darkMode => 'Mode sombre';
	@override String get useDarkTheme => 'Utiliser le thème sombre';
	@override String version({required Object version}) => 'Version ${version}';
	@override String get signOutConfirmTitle => 'Se déconnecter';
	@override String get signOutConfirmMessage => 'Êtes-vous sûr de vouloir vous déconnecter ? Vos données resteront sur cet appareil.';
	@override String get clearAllDataConfirmTitle => 'Effacer toutes les données';
	@override String get clearAllDataConfirmMessage => 'Êtes-vous sûr de vouloir supprimer tous les résultats d\'entraînement ? Cette action ne peut pas être annulée et effacera les données de tous vos appareils.';
	@override String get clearAll => 'Tout effacer';
	@override String get exercises => 'Exercices';
	@override String get importExercise => 'Importer un exercice';
	@override String get addExercise => 'Ajouter un exercice';
	@override String get noExercisesYet => 'Aucun exercice pour le moment';
	@override String get createFirstExercise => 'Créez votre premier exercice';
	@override String get createYourFirstExercise => 'Créez votre premier exercice';
	@override String get cycles => 'Cycles';
	@override String get duration => 'Durée';
	@override String cycleDurationSeconds({required Object cycles, required Object duration}) => '${cycles} cycles • ${duration}s durée';
	@override String get edit => 'Modifier';
	@override String get duplicate => 'Dupliquer';
	@override String get export => 'Exporter';
	@override String errorLoadingExercises({required Object error}) => 'Erreur lors du chargement des exercices : ${error}';
	@override String get deleteExercise => 'Supprimer l\'exercice';
	@override String deleteExerciseConfirm({required Object name}) => 'Êtes-vous sûr de vouloir supprimer "${name}" ?';
	@override String get exportFailed => 'Échec de l\'exportation';
	@override String failedToExport({required Object error}) => 'Échec de l\'exportation de l\'exercice : ${error}';
	@override String get importSuccessful => 'Importation réussie';
	@override String get importFailed => 'Échec de l\'importation';
	@override String failedToImport({required Object error}) => 'Échec de l\'importation de l\'exercice : ${error}';
	@override String get exerciseDetails => 'Détails de l\'exercice :';
	@override String get cycleDuration => 'Durée du cycle';
	@override String get totalDuration => 'Durée totale';
	@override String get phases => 'Phases';
	@override String get noDescriptionAvailable => 'Aucune description disponible pour cet exercice.';
	@override String get description => 'Description';
	@override String get customize => 'Personnaliser';
	@override String get time => 'Temps';
	@override String get stop => 'Arrêter';
	@override String get start => 'Démarrer';
	@override String cycleProgress({required Object current, required Object total}) => 'Cycle ${current} / ${total}';
	@override String get oneClap => '1 claquement';
	@override String clapsCount({required Object count}) => '${count} claquements';
	@override String range({required Object minDuration, required Object maxDuration}) => 'Plage : ${minDuration}s - ${maxDuration}s';
	@override String get name => 'Nom';
	@override String get information => 'Information';
	@override String get configuration => 'Configuration';
	@override String get min => 'Min';
	@override String get max => 'Max';
	@override String get step => 'Étape';
	@override String get minimum => 'Minimum';
	@override String get current => 'Actuel';
	@override String get maximum => 'Maximum';
	@override String get total => 'Total';
	@override String get addPhase => 'Ajouter une phase';
	@override String get history => 'Historique';
	@override String get overview => 'Aperçu';
	@override String get sessions => 'Sessions';
	@override String get totalTime => 'Temps Total';
	@override String get avg => 'Moyenne';
	@override String get dailyDurationDiff => 'Diff. Durée';
	@override String get dailyCycleDiff => 'Diff. Cycles';
	@override String get bestScore => 'Meilleur Score';
	@override String get noHistoryYet => 'Aucun historique pour le moment';
	@override String get completeSessionToSeeProgress => 'Terminez une session pour voir les progrès';
	@override String today({required Object time}) => 'Aujourd\'hui ${time}';
	@override String get yesterday => 'Hier';
	@override String daysAgo({required Object days}) => 'il y a ${days} jours';
	@override String cyclesAndDuration({required Object cycles, required Object duration}) => '${cycles} cycles • ${duration}s';
	@override String get noTraining => 'Aucun entraînement';
	@override String secondsUnit({required Object value}) => '${value}s';
	@override String cyclesUnit({required Object value}) => '${value}c';
	@override String get resetPassword => 'Réinitialiser le mot de passe';
	@override String get enterEmailToGetResetCode => 'Entrez l\'e-mail pour obtenir le code de réinitialisation';
	@override String get sendCode => 'Envoyer le code';
	@override String get passwordResetCodeSent => 'Code de réinitialisation du mot de passe envoyé à votre e-mail';
	@override String get verifyEmail => 'Vérifier l\'e-mail';
	@override String get checkYourEmail => 'Vérifiez votre e-mail';
	@override String codeSentTo({required Object email}) => 'Code envoyé à ${email}';
	@override String get verificationCode => 'Code de vérification';
	@override String get createAccount => 'Créer un compte';
	@override String resendInSeconds({required Object seconds}) => 'Renvoyer dans ${seconds}s';
	@override String get resendCode => 'Renvoyer le code';
	@override String get newCodeSentToEmail => 'Nouveau code envoyé à votre e-mail';
	@override String get enterVerificationCode => 'Entrez le code de vérification';
	@override String get deleteAccountTitle => 'Supprimer le compte';
	@override String get verifyDeletion => 'Vérifier la suppression';
	@override String get permanentDeleteWarning => 'Cela supprimera définitivement votre compte et toutes les données.';
	@override String get deletionConsequences => '• Toutes les données d\'entraînement seront perdues\n• Les paramètres de synchronisation seront effacés\n• Cette action ne peut pas être annulée';
	@override String get iUnderstandContinue => 'Je comprends, continuer';
	@override String accountEmail({required Object email}) => 'Compte : ${email}';
	@override String get sendVerificationCodeDescription => 'Nous enverrons un code de vérification pour confirmer cette action.';
	@override String get sendVerificationCode => 'Envoyer le code de vérification';
	@override String get noUserEmailFound => 'Aucun e-mail utilisateur trouvé. Veuillez vous reconnecter.';
	@override String verificationCodeSentTo({required Object email}) => 'Code de vérification envoyé à ${email}';
	@override String get accountDataCleared => 'Données du compte effacées. Vous avez été déconnecté.';
	@override String get failedToDeleteAccount => 'Échec de la suppression du compte. Veuillez réessayer.';
	@override String get newPassword => 'Nouveau mot de passe';
	@override String get enterCode => 'Entrer le code';
	@override String get chooseStrongPassword => 'Choisissez un mot de passe fort';
	@override String get code => 'Code';
	@override String get confirm => 'Confirmer';
	@override String get verify => 'Vérifier';
	@override String get update => 'Mettre à jour';
	@override String get resendCode2 => 'Renvoyer le code';
	@override String get pleaseEnterPassword => 'Veuillez entrer un mot de passe';
	@override String get passwordMinLength => 'Le mot de passe doit contenir au moins 6 caractères';
	@override String get passwordUppercase => 'Le mot de passe doit contenir au moins une lettre majuscule';
	@override String get passwordLowercase => 'Le mot de passe doit contenir au moins une lettre minuscule';
	@override String get passwordNumber => 'Le mot de passe doit contenir au moins un chiffre';
	@override String get pleaseConfirmPassword => 'Veuillez confirmer votre mot de passe';
	@override String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';
	@override String get passwordRequirements => 'Exigences du mot de passe :';
	@override String get atLeast6Characters => 'Au moins 6 caractères';
	@override String get oneUppercaseLetter => 'Une lettre majuscule';
	@override String get oneLowercaseLetter => 'Une lettre minuscule';
	@override String get oneNumber => 'Un chiffre';
	@override String get pleaseEnterVerificationCode => 'Veuillez entrer le code de vérification';
	@override String get codeVerifiedCreatePassword => 'Code vérifié ! Créez maintenant votre nouveau mot de passe.';
	@override String get newVerificationCodeSent => 'Nouveau code de vérification envoyé à votre e-mail';
	@override String get breathTraining => 'Entraînement respiratoire';
	@override String get unknown => 'Inconnu';
	@override String get timer => 'Minuteur';
	@override String get newExercise => 'Nouvel exercice';
	@override String exerciseSummary({required Object cycles, required Object duration}) => '${cycles} cycles • ${duration}s durée';
	@override String failedToExportExercise({required Object error}) => 'Échec de l\'exportation de l\'exercice : ${error}';
	@override String failedToImportExercise({required Object error}) => 'Échec de l\'importation de l\'exercice : ${error}';
	@override String confirmDeleteExercise({required Object name}) => 'Êtes-vous sûr de vouloir supprimer "${name}" ?';
	@override late final _StringsServicesFr services = _StringsServicesFr._(_root);
}

// Path: services
class _StringsServicesFr extends _StringsServicesEn {
	_StringsServicesFr._(_StringsFr root) : this._root = root, super._(root);

	@override final _StringsFr _root; // ignore: unused_field

	// Translations
	@override late final _StringsServicesSyncFr sync = _StringsServicesSyncFr._(_root);
	@override late final _StringsServicesOtpFr otp = _StringsServicesOtpFr._(_root);
	@override late final _StringsServicesStorageFr storage = _StringsServicesStorageFr._(_root);
	@override late final _StringsServicesSessionFr session = _StringsServicesSessionFr._(_root);
	@override late final _StringsServicesInitialTrainingFr initialTraining = _StringsServicesInitialTrainingFr._(_root);
}

// Path: services.sync
class _StringsServicesSyncFr extends _StringsServicesSyncEn {
	_StringsServicesSyncFr._(_StringsFr root) : this._root = root, super._(root);

	@override final _StringsFr _root; // ignore: unused_field

	// Translations
	@override String get supabaseNotConfigured => 'Supabase non configuré. Veuillez vérifier les paramètres de votre projet.';
	@override String signUpFailed({required Object error}) => 'Inscription échouée : ${error}';
	@override String get signUpFailedGeneric => 'Inscription échouée. Veuillez réessayer.';
	@override String signInFailed({required Object error}) => 'Connexion échouée : ${error}';
	@override String get signInFailedGeneric => 'Connexion échouée. Veuillez réessayer.';
	@override String get invalidEmailPassword => 'E-mail ou mot de passe invalide. Veuillez vérifier vos identifiants.';
	@override String get exerciseIncompleteData => 'L\'exercice n\'a pas de phases - données incomplètes';
}

// Path: services.otp
class _StringsServicesOtpFr extends _StringsServicesOtpEn {
	_StringsServicesOtpFr._(_StringsFr root) : this._root = root, super._(root);

	@override final _StringsFr _root; // ignore: unused_field

	// Translations
	@override String get supabaseNotConfigured => 'Supabase non configuré. Veuillez vérifier les paramètres de votre projet.';
	@override String failedToSendOtp({required Object error}) => 'Échec de l\'envoi du code OTP : ${error}';
	@override String get failedToSendOtpGeneric => 'Échec de l\'envoi du code OTP. Veuillez réessayer.';
	@override String get noOtpRequest => 'Aucune demande de code OTP trouvée. Veuillez demander un nouveau code OTP.';
	@override String get otpExpired => 'Le code OTP a expiré. Veuillez en demander un nouveau.';
	@override String get invalidOrExpiredOtp => 'Code OTP invalide ou expiré. Veuillez vérifier votre code ou en demander un nouveau.';
	@override String otpVerificationFailed({required Object error}) => 'Vérification du code OTP échouée : ${error}';
	@override String get otpVerificationFailedGeneric => 'Vérification du code OTP échouée. Veuillez réessayer.';
	@override String get otpMustBeVerified => 'Le code OTP doit être vérifié avant de mettre à jour le mot de passe.';
	@override String failedToUpdatePassword({required Object error}) => 'Échec de la mise à jour du mot de passe : ${error}';
	@override String get failedToUpdatePasswordGeneric => 'Échec de la mise à jour du mot de passe. Veuillez réessayer.';
}

// Path: services.storage
class _StringsServicesStorageFr extends _StringsServicesStorageEn {
	_StringsServicesStorageFr._(_StringsFr root) : this._root = root, super._(root);

	@override final _StringsFr _root; // ignore: unused_field

	// Translations
	@override String get boxNotOpen => 'La boîte de stockage n\'est pas ouverte. Initialisez d\'abord l\'application.';
	@override String exerciseNotFound({required Object exerciseId}) => 'Exercice non trouvé pour la duplication : ${exerciseId}';
	@override String get copy => 'Copie';
}

// Path: services.session
class _StringsServicesSessionFr extends _StringsServicesSessionEn {
	_StringsServicesSessionFr._(_StringsFr root) : this._root = root, super._(root);

	@override final _StringsFr _root; // ignore: unused_field

	// Translations
	@override String get ready => 'Prêt';
	@override String get go => 'C\'est parti !';
	@override String get noExerciseSelected => 'Impossible de démarrer la session : aucun exercice sélectionné';
}

// Path: services.initialTraining
class _StringsServicesInitialTrainingFr extends _StringsServicesInitialTrainingEn {
	_StringsServicesInitialTrainingFr._(_StringsFr root) : this._root = root, super._(root);

	@override final _StringsFr _root; // ignore: unused_field

	// Translations
	@override String get molchanovMethodName => 'Méthode Molchanov';
	@override String get molchanovDescription => 'Exercice quotidien d\'Aleksey Molchanov pour développer l\'apnée. Utilisé par le champion du monde en compétition. Développe la tolérance au CO₂ par des apnées cycliques sans repos.\n\nTECHNIQUE :\n1. Inspirez 5 secondes par les lèvres pincées\n2. Retenez le souffle poumons pleins (phase principale)\n3. Expirez 5-10 secondes avec résistance\n4. Retenez poumons vides (optionnel débutants)\n\nPRINCIPE CLÉ :\nAucun repos entre cycles. Ceci accumule le CO₂ et aide le corps à s\'adapter aux niveaux élevés de dioxyde de carbone.\n\nPROGRESSION :\nDébut : 2 minutes avec cycles de 30 secondes (4 cycles)\nAvancé : Augmenter graduellement jusqu\'à 15 minutes total\nCycles : 30s → 35s → 40s → 45s → 50s...\nFocus : Prolonger surtout l\'apnée après inspiration. Commencer par le nombre de cycles\n\nSÉCURITÉ :\nToujours assis ou allongé. Jamais dans l\'eau pour les débutants. Prendre des jours de repos si nécessaire.\n\nEn savoir plus : Recherchez \"Molchanov breath hold training\"';
	@override String get breathing478Name => 'Respiration 4-7-8';
	@override String get breathing478Description => 'Schéma respiratoire relaxant : inspirer 4, retenir 7, expirer 8. Excellent pour réduire le stress et améliorer le sommeil.\n\nUTILISATION :\nIdéal avant le coucher ou en cas de stress. Expirer complètement avant de commencer. Position de la langue : pointe derrière les dents de devant. Compter de façon régulière et constante.\n\nPROGRESSION :\nSemaine 1 : 4 cycles avant le coucher\nSemaine 2-3 : 6 cycles, deux fois par jour\nSemaine 4+ : 8 cycles, à tout moment pour se calmer\n\nEn savoir plus : Recherchez \"4-7-8 breathing Dr. Weil\"';
	@override String get boxBreathingName => 'Respiration Carrée';
	@override String get boxBreathingDescription => 'Schéma respiratoire à temps égaux : inspirer, retenir, expirer, retenir - tout pour la même durée. Parfait pour la concentration et la clarté mentale.\n\nUTILISATION :\nS\'asseoir confortablement avec la colonne droite. Commencer avec des intervalles de 4 secondes. Visualiser dessiner un carré en respirant. Maintenir un rythme stable et contrôlé.\n\nPROGRESSION :\nSemaine 1-2 : 4 secondes × 8 cycles\nSemaine 3-4 : 5 secondes × 8 cycles\nSemaine 5+ : Jusqu\'à 6-8 secondes par côté\n\nEn savoir plus : Recherchez \"box breathing Navy SEALs technique\"';
}

// Path: <root>
class _StringsIt extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsIt.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.it,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <it>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	@override late final _StringsIt _root = this; // ignore: unused_field

	// Translations
	@override String get appTitle => 'Bearth Timer';
	@override String get email => 'E-mail';
	@override String get password => 'Password';
	@override String get enterEmail => 'Inserisci e-mail';
	@override String get enterPassword => 'Inserisci password';
	@override String get invalidEmailFormat => 'Formato e-mail non valido';
	@override String get minCharacters => 'Min 6 caratteri';
	@override String get signUp => 'Registrati';
	@override String get signIn => 'Accedi';
	@override String get signOut => 'Esci';
	@override String get skip => 'Salta';
	@override String get cancel => 'Annulla';
	@override String get delete => 'Elimina';
	@override String get ok => 'OK';
	@override String get close => 'Chiudi';
	@override String get back => 'Indietro';
	@override String get loading => 'Caricamento...';
	@override String get syncDataAcrossDevices => 'Sincronizza dati tra dispositivi';
	@override String get accessDataAnywhere => 'Accedi ai dati ovunque';
	@override String get haveAccountSignIn => 'Hai un account? Accedi';
	@override String get needAccountSignUp => 'Serve un account? Registrati';
	@override String get forgot => 'Dimenticato?';
	@override String get emailSent => 'E-mail inviata! Controlla la tua casella di posta.';
	@override String get sendingEmail => 'Invio e-mail...';
	@override String get signupEmailSent => 'E-mail di registrazione inviata! Controlla la tua casella di posta e imposta la password.';
	@override String get failedToSendEmail => 'Invio e-mail fallito. Controlla il formato dell\'e-mail.';
	@override String get supabaseNotConfigured => 'Supabase non configurato';
	@override String get updateSupabaseConstants => 'Aggiorna SupabaseConstants con l\'URL del progetto e la chiave anonima';
	@override String get settings => 'Impostazioni';
	@override String get account => 'Account';
	@override String get sync => 'Sincronizzazione';
	@override String get sound => 'Suono';
	@override String get dataManagement => 'Gestione dati';
	@override String get appearance => 'Aspetto';
	@override String get about => 'Info';
	@override String get signedInAs => 'Connesso come';
	@override String get unknownEmail => 'E-mail sconosciuta';
	@override String get signOutDescription => 'Esci e lavora offline';
	@override String get deleteAccount => 'Elimina account';
	@override String get deleteAccountDescription => 'Elimina definitivamente account e dati';
	@override String get workingOffline => 'Lavoro offline';
	@override String get signInToSync => 'Accedi per sincronizzare tra dispositivi';
	@override String get accessDataAnywhereButton => 'Accedi ai dati ovunque';
	@override String get retrySync => 'Riprova sincronizzazione';
	@override String get syncWithCloud => 'Sincronizza con il cloud';
	@override String get exportData => 'Esporta dati';
	@override String get saveDataToFile => 'Salva dati su file';
	@override String get importData => 'Importa dati';
	@override String get loadDataFromFile => 'Carica dati da file';
	@override String get clearAllData => 'Cancella tutti i dati';
	@override String get deleteAllDataPermanently => 'Elimina definitivamente tutti i dati';
	@override String get transitionSound => 'Suono di transizione';
	@override String get playSoundWhenPhasesChange => 'Riproduci suono al cambio fase';
	@override String get darkMode => 'Modalità scura';
	@override String get useDarkTheme => 'Usa tema scuro';
	@override String version({required Object version}) => 'Versione ${version}';
	@override String get signOutConfirmTitle => 'Esci';
	@override String get signOutConfirmMessage => 'Sei sicuro di voler uscire? I tuoi dati rimarranno su questo dispositivo.';
	@override String get clearAllDataConfirmTitle => 'Cancella tutti i dati';
	@override String get clearAllDataConfirmMessage => 'Sei sicuro di voler eliminare tutti i risultati di allenamento? Questa azione non può essere annullata e cancellerà i dati da tutti i tuoi dispositivi.';
	@override String get clearAll => 'Cancella tutto';
	@override String get exercises => 'Esercizi';
	@override String get importExercise => 'Importa esercizio';
	@override String get addExercise => 'Aggiungi esercizio';
	@override String get noExercisesYet => 'Nessun esercizio ancora';
	@override String get createFirstExercise => 'Crea il tuo primo esercizio';
	@override String get createYourFirstExercise => 'Crea il tuo primo esercizio';
	@override String get cycles => 'Cicli';
	@override String get duration => 'Durata';
	@override String cycleDurationSeconds({required Object cycles, required Object duration}) => '${cycles} cicli • ${duration}s durata';
	@override String get edit => 'Modifica';
	@override String get duplicate => 'Duplica';
	@override String get export => 'Esporta';
	@override String errorLoadingExercises({required Object error}) => 'Errore caricamento esercizi: ${error}';
	@override String get deleteExercise => 'Elimina esercizio';
	@override String deleteExerciseConfirm({required Object name}) => 'Sei sicuro di voler eliminare "${name}"?';
	@override String get exportFailed => 'Esportazione fallita';
	@override String failedToExport({required Object error}) => 'Esportazione esercizio fallita: ${error}';
	@override String get importSuccessful => 'Importazione riuscita';
	@override String get importFailed => 'Importazione fallita';
	@override String failedToImport({required Object error}) => 'Importazione esercizio fallita: ${error}';
	@override String get exerciseDetails => 'Dettagli esercizio:';
	@override String get cycleDuration => 'Durata ciclo';
	@override String get totalDuration => 'Durata totale';
	@override String get phases => 'Fasi';
	@override String get noDescriptionAvailable => 'Nessuna descrizione disponibile per questo esercizio.';
	@override String get description => 'Descrizione';
	@override String get customize => 'Personalizza';
	@override String get time => 'Tempo';
	@override String get stop => 'Ferma';
	@override String get start => 'Avvia';
	@override String cycleProgress({required Object current, required Object total}) => 'Ciclo ${current} / ${total}';
	@override String get oneClap => '1 battito';
	@override String clapsCount({required Object count}) => '${count} battiti';
	@override String range({required Object minDuration, required Object maxDuration}) => 'Intervallo: ${minDuration}s - ${maxDuration}s';
	@override String get name => 'Nome';
	@override String get information => 'Informazioni';
	@override String get configuration => 'Configurazione';
	@override String get min => 'Min';
	@override String get max => 'Max';
	@override String get step => 'Passo';
	@override String get minimum => 'Minimo';
	@override String get current => 'Corrente';
	@override String get maximum => 'Massimo';
	@override String get total => 'Totale';
	@override String get addPhase => 'Aggiungi fase';
	@override String get history => 'Cronologia';
	@override String get overview => 'Panoramica';
	@override String get sessions => 'Sessioni';
	@override String get totalTime => 'Tempo Totale';
	@override String get avg => 'Media';
	@override String get dailyDurationDiff => 'Diff. Durata';
	@override String get dailyCycleDiff => 'Diff. Cicli';
	@override String get bestScore => 'Miglior Punteggio';
	@override String get noHistoryYet => 'Nessuna cronologia ancora';
	@override String get completeSessionToSeeProgress => 'Completa una sessione per vedere i progressi';
	@override String today({required Object time}) => 'Oggi ${time}';
	@override String get yesterday => 'Ieri';
	@override String daysAgo({required Object days}) => '${days} giorni fa';
	@override String cyclesAndDuration({required Object cycles, required Object duration}) => '${cycles} cicli • ${duration}s';
	@override String get noTraining => 'Nessun allenamento';
	@override String secondsUnit({required Object value}) => '${value}s';
	@override String cyclesUnit({required Object value}) => '${value}c';
	@override String get resetPassword => 'Reimposta password';
	@override String get enterEmailToGetResetCode => 'Inserisci e-mail per ottenere il codice di reset';
	@override String get sendCode => 'Invia codice';
	@override String get passwordResetCodeSent => 'Codice di reset password inviato alla tua e-mail';
	@override String get verifyEmail => 'Verifica e-mail';
	@override String get checkYourEmail => 'Controlla la tua e-mail';
	@override String codeSentTo({required Object email}) => 'Codice inviato a ${email}';
	@override String get verificationCode => 'Codice di verifica';
	@override String get createAccount => 'Crea account';
	@override String resendInSeconds({required Object seconds}) => 'Reinvia tra ${seconds}s';
	@override String get resendCode => 'Reinvia codice';
	@override String get newCodeSentToEmail => 'Nuovo codice inviato alla tua e-mail';
	@override String get enterVerificationCode => 'Inserisci codice di verifica';
	@override String get deleteAccountTitle => 'Elimina account';
	@override String get verifyDeletion => 'Verifica eliminazione';
	@override String get permanentDeleteWarning => 'Questo eliminerà definitivamente il tuo account e tutti i dati.';
	@override String get deletionConsequences => '• Tutti i dati di allenamento andranno persi\n• Le impostazioni di sincronizzazione verranno cancellate\n• Questa azione non può essere annullata';
	@override String get iUnderstandContinue => 'Capisco, continua';
	@override String accountEmail({required Object email}) => 'Account: ${email}';
	@override String get sendVerificationCodeDescription => 'Invieremo un codice di verifica per confermare questa azione.';
	@override String get sendVerificationCode => 'Invia codice di verifica';
	@override String get noUserEmailFound => 'Nessuna e-mail utente trovata. Per favore accedi di nuovo.';
	@override String verificationCodeSentTo({required Object email}) => 'Codice di verifica inviato a ${email}';
	@override String get accountDataCleared => 'Dati account cancellati. Sei stato disconnesso.';
	@override String get failedToDeleteAccount => 'Eliminazione account fallita. Riprova.';
	@override String get newPassword => 'Nuova password';
	@override String get enterCode => 'Inserisci codice';
	@override String get chooseStrongPassword => 'Scegli una password forte';
	@override String get code => 'Codice';
	@override String get confirm => 'Conferma';
	@override String get verify => 'Verifica';
	@override String get update => 'Aggiorna';
	@override String get resendCode2 => 'Reinvia codice';
	@override String get pleaseEnterPassword => 'Per favore inserisci una password';
	@override String get passwordMinLength => 'La password deve avere almeno 6 caratteri';
	@override String get passwordUppercase => 'La password deve contenere almeno una lettera maiuscola';
	@override String get passwordLowercase => 'La password deve contenere almeno una lettera minuscola';
	@override String get passwordNumber => 'La password deve contenere almeno un numero';
	@override String get pleaseConfirmPassword => 'Per favore conferma la password';
	@override String get passwordsDoNotMatch => 'Le password non corrispondono';
	@override String get passwordRequirements => 'Requisiti password:';
	@override String get atLeast6Characters => 'Almeno 6 caratteri';
	@override String get oneUppercaseLetter => 'Una lettera maiuscola';
	@override String get oneLowercaseLetter => 'Una lettera minuscola';
	@override String get oneNumber => 'Un numero';
	@override String get pleaseEnterVerificationCode => 'Per favore inserisci il codice di verifica';
	@override String get codeVerifiedCreatePassword => 'Codice verificato! Ora crea la tua nuova password.';
	@override String get newVerificationCodeSent => 'Nuovo codice di verifica inviato alla tua e-mail';
	@override String get breathTraining => 'Allenamento respiratorio';
	@override String get unknown => 'Sconosciuto';
	@override String get timer => 'Timer';
	@override String get newExercise => 'Nuovo esercizio';
	@override String exerciseSummary({required Object cycles, required Object duration}) => '${cycles} cicli • ${duration}s durata';
	@override String failedToExportExercise({required Object error}) => 'Esportazione esercizio fallita: ${error}';
	@override String failedToImportExercise({required Object error}) => 'Importazione esercizio fallita: ${error}';
	@override String confirmDeleteExercise({required Object name}) => 'Sei sicuro di voler eliminare "${name}"?';
	@override String get inhale => 'Inspira';
	@override String get exhale => 'Espira';
	@override String get hold => 'Pausa';
	@override String get breathPhaseIn => 'Inspira';
	@override String get breathPhaseOut => 'Espira';
	@override String get breathPhaseHold => 'Pausa';
	@override String get molchanovMethod => 'Molchanov';
	@override String get molchanovDescription => 'Allenamento tolleranza CO₂. Senza pause. Tecnica pro per apnea.';
	@override String get breathing478 => '4-7-8 Calma';
	@override String get breathing478Description => 'Schema anti-stress. 4 inspira, 7 pausa, 8 espira. Aiuta sonno.';
	@override String get boxBreathing => 'Box';
	@override String get boxBreathingDescription => 'Tecnica focus. Tutte fasi uguali. Metodo Navy.';
	@override late final _StringsServicesIt services = _StringsServicesIt._(_root);
}

// Path: services
class _StringsServicesIt extends _StringsServicesEn {
	_StringsServicesIt._(_StringsIt root) : this._root = root, super._(root);

	@override final _StringsIt _root; // ignore: unused_field

	// Translations
	@override late final _StringsServicesSyncIt sync = _StringsServicesSyncIt._(_root);
	@override late final _StringsServicesOtpIt otp = _StringsServicesOtpIt._(_root);
	@override late final _StringsServicesStorageIt storage = _StringsServicesStorageIt._(_root);
	@override late final _StringsServicesSessionIt session = _StringsServicesSessionIt._(_root);
	@override late final _StringsServicesInitialTrainingIt initialTraining = _StringsServicesInitialTrainingIt._(_root);
}

// Path: services.sync
class _StringsServicesSyncIt extends _StringsServicesSyncEn {
	_StringsServicesSyncIt._(_StringsIt root) : this._root = root, super._(root);

	@override final _StringsIt _root; // ignore: unused_field

	// Translations
	@override String get supabaseNotConfigured => 'Supabase non configurato. Controlla le impostazioni del progetto.';
	@override String signUpFailed({required Object error}) => 'Registrazione fallita: ${error}';
	@override String get signUpFailedGeneric => 'Registrazione fallita. Riprova.';
	@override String signInFailed({required Object error}) => 'Accesso fallito: ${error}';
	@override String get signInFailedGeneric => 'Accesso fallito. Riprova.';
	@override String get invalidEmailPassword => 'E-mail o password non validi. Controlla le credenziali.';
	@override String get exerciseIncompleteData => 'L\'esercizio non ha fasi - dati incompleti';
}

// Path: services.otp
class _StringsServicesOtpIt extends _StringsServicesOtpEn {
	_StringsServicesOtpIt._(_StringsIt root) : this._root = root, super._(root);

	@override final _StringsIt _root; // ignore: unused_field

	// Translations
	@override String get supabaseNotConfigured => 'Supabase non configurato. Controlla le impostazioni del progetto.';
	@override String failedToSendOtp({required Object error}) => 'Invio codice OTP fallito: ${error}';
	@override String get failedToSendOtpGeneric => 'Invio codice OTP fallito. Riprova.';
	@override String get noOtpRequest => 'Nessuna richiesta OTP trovata. Richiedi un nuovo codice OTP.';
	@override String get otpExpired => 'Il codice OTP è scaduto. Richiedine uno nuovo.';
	@override String get invalidOrExpiredOtp => 'Codice OTP non valido o scaduto. Controlla il codice o richiedine uno nuovo.';
	@override String otpVerificationFailed({required Object error}) => 'Verifica codice OTP fallita: ${error}';
	@override String get otpVerificationFailedGeneric => 'Verifica codice OTP fallita. Riprova.';
	@override String get otpMustBeVerified => 'Il codice OTP deve essere verificato prima di aggiornare la password.';
	@override String failedToUpdatePassword({required Object error}) => 'Aggiornamento password fallito: ${error}';
	@override String get failedToUpdatePasswordGeneric => 'Aggiornamento password fallito. Riprova.';
}

// Path: services.storage
class _StringsServicesStorageIt extends _StringsServicesStorageEn {
	_StringsServicesStorageIt._(_StringsIt root) : this._root = root, super._(root);

	@override final _StringsIt _root; // ignore: unused_field

	// Translations
	@override String get boxNotOpen => 'Il box di archiviazione non è aperto. Prima inizializza l\'app.';
	@override String exerciseNotFound({required Object exerciseId}) => 'Esercizio non trovato per la duplicazione: ${exerciseId}';
	@override String get copy => 'Copia';
	@override String get exerciseNamePlaceholder => 'Nome esercizio';
	@override String get exerciseDescriptionPlaceholder => 'Descrizione esercizio';
}

// Path: services.session
class _StringsServicesSessionIt extends _StringsServicesSessionEn {
	_StringsServicesSessionIt._(_StringsIt root) : this._root = root, super._(root);

	@override final _StringsIt _root; // ignore: unused_field

	// Translations
	@override String get ready => 'Pronto';
	@override String get go => 'Via!';
	@override String get noExerciseSelected => 'Impossibile avviare la sessione: nessun esercizio selezionato';
}

// Path: services.initialTraining
class _StringsServicesInitialTrainingIt extends _StringsServicesInitialTrainingEn {
	_StringsServicesInitialTrainingIt._(_StringsIt root) : this._root = root, super._(root);

	@override final _StringsIt _root; // ignore: unused_field

	// Translations
	@override String get molchanovMethodName => 'Metodo Molchanov';
	@override String get molchanovDescription => 'Esercizio quotidiano di Aleksey Molchanov per lo sviluppo dell\'apnea. Usato dal campione del mondo in competizione. Sviluppa la tolleranza al CO₂ attraverso apnee cicliche senza riposo.\n\nTECNICA:\n1. Inspira per 5 secondi attraverso labbra socchiuse\n2. Trattieni il respiro a polmoni pieni (fase principale)\n3. Espira per 5-10 secondi con resistenza\n4. Trattieni a polmoni vuoti (opzionale per principianti)\n\nPRINCIPIO CHIAVE:\nNessun riposo tra i cicli. Questo accumula CO₂ e aiuta il corpo ad adattarsi a livelli più alti di anidride carbonica.\n\nPROGRESSIONE:\nInizio: 2 minuti con cicli di 30 secondi (4 cicli)\nAvanzato: Aumentare gradualmente fino a 15 minuti totali\nCicli: 30s → 35s → 40s → 45s → 50s...\nFocus: Estendere principalmente l\'apnea dopo l\'inspirazione. Iniziare con il numero di cicli\n\nSICUREZZA:\nSempre seduti o sdraiati. Mai in acqua per i principianti. Prendere giorni di riposo quando necessario.\n\nPer saperne di più: Cerca \"Molchanov breath hold training\"';
	@override String get breathing478Name => 'Respirazione 4-7-8';
	@override String get breathing478Description => 'Schema respiratorio rilassante: inspira per 4, trattieni per 7, espira per 8. Ottimo per alleviare lo stress e migliorare il sonno.\n\nCOME USARE:\nMeglio usato prima di dormire o quando si è stressati. Espira completamente prima di iniziare. Posizione della lingua: punta dietro i denti anteriori. Conta in modo costante e regolare.\n\nPROGRESSIONE:\nSettimana 1: 4 cicli prima di dormire\nSettimana 2-3: 6 cicli, due volte al giorno\nSettimana 4+: 8 cicli, in qualsiasi momento per calmarsi\n\nPer saperne di più: Cerca \"4-7-8 breathing Dr. Weil\"';
	@override String get boxBreathingName => 'Respirazione a Scatola';
	@override String get boxBreathingDescription => 'Schema respiratorio a tempo uguale: inspira, trattieni, espira, trattieni - tutto per la stessa durata. Perfetto per la concentrazione e la chiarezza mentale.\n\nCOME USARE:\nSediti comodamente con la colonna vertebrale dritta. Inizia con intervalli di 4 secondi. Visualizza di disegnare una scatola mentre respiri. Mantieni un ritmo costante e controllato.\n\nPROGRESSIONE:\nSettimana 1-2: 4 secondi × 8 cicli\nSettimana 3-4: 5 secondi × 8 cicli\nSettimana 5+: Fino a 6-8 secondi per lato\n\nPer saperne di più: Cerca \"box breathing Navy SEALs technique\"';
}

// Path: <root>
class _StringsRu extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsRu.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	@override late final _StringsRu _root = this; // ignore: unused_field

	// Translations
	@override String get appTitle => 'Bearth Timer';
	@override String get email => 'Email';
	@override String get password => 'Пароль';
	@override String get enterEmail => 'Email';
	@override String get enterPassword => 'Пароль';
	@override String get invalidEmailFormat => 'Плохой email';
	@override String get minCharacters => 'Мин 6';
	@override String get signUp => 'Регистрация';
	@override String get signIn => 'Вход';
	@override String get signOut => 'Выход';
	@override String get skip => 'Пропустить';
	@override String get cancel => 'Отмена';
	@override String get delete => 'Удалить';
	@override String get ok => 'OK';
	@override String get close => 'Закрыть';
	@override String get back => 'Назад';
	@override String get loading => '...';
	@override String get syncDataAcrossDevices => 'Синхронизация';
	@override String get accessDataAnywhere => 'Синхронизация';
	@override String get haveAccountSignIn => 'Вход';
	@override String get needAccountSignUp => 'Регистрация';
	@override String get forgot => 'Забыли пароль?';
	@override String get emailSent => 'Письмо отправлено!';
	@override String get sendingEmail => 'Отправка письма...';
	@override String get signupEmailSent => 'Письмо для регистрации отправлено! Проверьте почту и установите пароль.';
	@override String get failedToSendEmail => 'Не удалось отправить письмо. Проверьте формат email.';
	@override String get supabaseNotConfigured => 'Supabase не настроен';
	@override String get updateSupabaseConstants => 'Обновите SupabaseConstants с URL проекта и анонимным ключом';
	@override String get settings => 'Настройки';
	@override String get account => 'Аккаунт';
	@override String get sync => 'Синхронизация';
	@override String get sound => 'Звук';
	@override String get dataManagement => 'Данные';
	@override String get appearance => 'Вид';
	@override String get about => 'О нас';
	@override String get signedInAs => 'Вошел как';
	@override String get unknownEmail => 'Неизвестный email';
	@override String get signOutDescription => 'Выйти офлайн';
	@override String get deleteAccount => 'Удалить';
	@override String get deleteAccountDescription => 'Навсегда удалить';
	@override String get workingOffline => 'Офлайн';
	@override String get signInToSync => 'Войди';
	@override String get accessDataAnywhereButton => 'Доступ везде';
	@override String get retrySync => 'Запросить данные';
	@override String get syncWithCloud => 'Из облака';
	@override String get exportData => 'Экспорт';
	@override String get saveDataToFile => 'Сохранить в файл';
	@override String get importData => 'Импорт';
	@override String get loadDataFromFile => 'Загрузить из файла';
	@override String get clearAllData => 'Очистить все';
	@override String get deleteAllDataPermanently => 'Навсегда удалить все данные';
	@override String get transitionSound => 'Звук переходов';
	@override String get playSoundWhenPhasesChange => 'Воспроизводить звук при смене фаз';
	@override String get darkMode => 'Темная тема';
	@override String get useDarkTheme => 'Использовать темную тему';
	@override String version({required Object version}) => 'Версия ${version}';
	@override String get signOutConfirmTitle => 'Выход';
	@override String get signOutConfirmMessage => 'Вы уверены, что хотите выйти? Ваши данные останутся на этом устройстве.';
	@override String get clearAllDataConfirmTitle => 'Очистить все данные';
	@override String get clearAllDataConfirmMessage => 'Вы уверены, что хотите удалить все результаты тренировок? Это действие нельзя отменить и оно очистит данные со всех ваших устройств.';
	@override String get clearAll => 'Очистить все';
	@override String get exercises => 'Упражнения';
	@override String get importExercise => 'Импорт упражнения';
	@override String get addExercise => 'Добавить упражнение';
	@override String get noExercisesYet => 'Пока нет упражнений';
	@override String get createFirstExercise => 'Создайте первое упражнение';
	@override String get createYourFirstExercise => 'Создайте первое упражнение';
	@override String get cycles => 'Циклы';
	@override String get duration => 'Время';
	@override String cycleDurationSeconds({required Object cycles, required Object duration}) => '${cycles} циклов x ${duration}с';
	@override String get edit => 'Редактировать';
	@override String get duplicate => 'Дублировать';
	@override String get export => 'Экспорт';
	@override String errorLoadingExercises({required Object error}) => 'Ошибка загрузки упражнений: ${error}';
	@override String get deleteExercise => 'Удалить упражнение';
	@override String deleteExerciseConfirm({required Object name}) => 'Вы уверены, что хотите удалить "${name}"?';
	@override String get exportFailed => 'Экспорт не удался';
	@override String failedToExport({required Object error}) => 'Не удалось экспортировать упражнение: ${error}';
	@override String get importSuccessful => 'Импорт успешен';
	@override String get importFailed => 'Импорт не удался';
	@override String failedToImport({required Object error}) => 'Не удалось импортировать упражнение: ${error}';
	@override String get exerciseDetails => 'Детали:';
	@override String get cycleDuration => 'Время';
	@override String get totalDuration => 'Суммарное';
	@override String get phases => 'Фазы';
	@override String get noDescriptionAvailable => 'Описание для этого упражнения недоступно.';
	@override String get description => 'Описание';
	@override String get customize => 'Настроить';
	@override String get time => 'Время';
	@override String get stop => 'Стоп';
	@override String get start => 'Старт';
	@override String cycleProgress({required Object current, required Object total}) => 'Цикл ${current} / ${total}';
	@override String get oneClap => '1 👏';
	@override String clapsCount({required Object count}) => '${count} 👏';
	@override String range({required Object minDuration, required Object maxDuration}) => 'Время: ${minDuration}с - ${maxDuration}с';
	@override String get name => 'Название';
	@override String get information => 'Информация';
	@override String get configuration => 'Конфигурация';
	@override String get min => 'Мин';
	@override String get max => 'Макс';
	@override String get step => 'Шаг';
	@override String get minimum => 'Минимум';
	@override String get current => 'Текущий';
	@override String get maximum => 'Максимум';
	@override String get total => 'Всего';
	@override String get addPhase => 'Добавить фазу';
	@override String get history => 'История';
	@override String get overview => 'Обзор';
	@override String get sessions => 'Сессии';
	@override String get totalTime => 'Σ времени';
	@override String get avg => 'Среднее';
	@override String get dailyDurationDiff => 'Δ времени';
	@override String get dailyCycleDiff => 'Δ циклам';
	@override String get bestScore => 'Лучший';
	@override String get noHistoryYet => 'Пока нет истории';
	@override String get completeSessionToSeeProgress => 'Завершите сессию, чтобы увидеть прогресс';
	@override String today({required Object time}) => 'Сегодня ${time}';
	@override String get yesterday => 'Вчера';
	@override String daysAgo({required Object days}) => '${days} дней назад';
	@override String cyclesAndDuration({required Object cycles, required Object duration}) => '${cycles} циклов • ${duration}с';
	@override String get noTraining => 'Нет тренировок';
	@override String secondsUnit({required Object value}) => '${value}с';
	@override String cyclesUnit({required Object value}) => '${value}ц';
	@override String get resetPassword => 'Сброс пароля';
	@override String get enterEmailToGetResetCode => 'Введите email для получения кода сброса';
	@override String get sendCode => 'Отправить код';
	@override String get passwordResetCodeSent => 'Код сброса пароля отправлен на вашу почту';
	@override String get verifyEmail => 'Подтвердить email';
	@override String get checkYourEmail => 'Проверьте вашу почту';
	@override String codeSentTo({required Object email}) => 'Код отправлен на ${email}';
	@override String get verificationCode => 'Код подтверждения';
	@override String get createAccount => 'Создать аккаунт';
	@override String resendInSeconds({required Object seconds}) => 'Повторить через ${seconds}с';
	@override String get resendCode => 'Повторить код';
	@override String get newCodeSentToEmail => 'Новый код отправлен на вашу почту';
	@override String get enterVerificationCode => 'Введите код подтверждения';
	@override String get deleteAccountTitle => 'Удалить аккаунт';
	@override String get verifyDeletion => 'Подтвердить удаление';
	@override String get permanentDeleteWarning => 'Это навсегда удалит ваш аккаунт и все данные.';
	@override String get deletionConsequences => '• Все данные тренировок будут потеряны\n• Настройки синхронизации будут очищены\n• Это действие нельзя отменить';
	@override String get iUnderstandContinue => 'Я понимаю, продолжить';
	@override String accountEmail({required Object email}) => 'Аккаунт: ${email}';
	@override String get sendVerificationCodeDescription => 'Мы отправим код подтверждения для подтверждения этого действия.';
	@override String get sendVerificationCode => 'Отправить код подтверждения';
	@override String get noUserEmailFound => 'Email пользователя не найден. Пожалуйста, войдите снова.';
	@override String verificationCodeSentTo({required Object email}) => 'Код подтверждения отправлен на ${email}';
	@override String get accountDataCleared => 'Данные аккаунта очищены. Вы вышли из системы.';
	@override String get failedToDeleteAccount => 'Не удалось удалить аккаунт. Пожалуйста, попробуйте снова.';
	@override String get newPassword => 'Новый пароль';
	@override String get enterCode => 'Введите код';
	@override String get chooseStrongPassword => 'Выберите надежный пароль';
	@override String get code => 'Код';
	@override String get confirm => 'Подтвердить';
	@override String get verify => 'Проверить';
	@override String get update => 'Обновить';
	@override String get resendCode2 => 'Повторить код';
	@override String get pleaseEnterPassword => 'Пожалуйста, введите пароль';
	@override String get passwordMinLength => 'Пароль должен содержать не менее 6 символов';
	@override String get passwordUppercase => 'Пароль должен содержать хотя бы одну заглавную букву';
	@override String get passwordLowercase => 'Пароль должен содержать хотя бы одну строчную букву';
	@override String get passwordNumber => 'Пароль должен содержать хотя бы одну цифру';
	@override String get pleaseConfirmPassword => 'Пожалуйста, подтвердите пароль';
	@override String get passwordsDoNotMatch => 'Пароли не совпадают';
	@override String get passwordRequirements => 'Требования к паролю:';
	@override String get atLeast6Characters => 'Не менее 6 символов';
	@override String get oneUppercaseLetter => 'Одна заглавная буква';
	@override String get oneLowercaseLetter => 'Одна строчная буква';
	@override String get oneNumber => 'Одна цифра';
	@override String get pleaseEnterVerificationCode => 'Пожалуйста, введите код подтверждения';
	@override String get codeVerifiedCreatePassword => 'Код подтвержден! Теперь создайте новый пароль.';
	@override String get newVerificationCodeSent => 'Новый код подтверждения отправлен на вашу почту';
	@override String get breathTraining => 'Тренировка дыхания';
	@override String get unknown => 'Неизвестно';
	@override String get timer => 'Таймер';
	@override String get newExercise => 'Новое упражнение';
	@override String exerciseSummary({required Object cycles, required Object duration}) => '${cycles} циклов x ${duration}с ';
	@override String failedToExportExercise({required Object error}) => 'Не удалось экспортировать упражнение: ${error}';
	@override String failedToImportExercise({required Object error}) => 'Не удалось импортировать упражнение: ${error}';
	@override String confirmDeleteExercise({required Object name}) => 'Вы уверены, что хотите удалить "${name}"?';
	@override String get inhale => 'Вдох';
	@override String get exhale => 'Выдох';
	@override String get hold => 'Задержка';
	@override String get breathPhaseIn => 'Вдох';
	@override String get breathPhaseOut => 'Выдох';
	@override String get breathPhaseHold => 'Задержка';
	@override String get molchanovMethod => 'Молчанов';
	@override String get molchanovDescription => 'CO₂ тренинг. Без пауз. Про задержка.';
	@override String get breathing478 => '4-7-8';
	@override String get breathing478Description => 'От стресса. Сон лучше.';
	@override String get boxBreathing => 'Бокс';
	@override String get boxBreathingDescription => 'Фокус. Равные фазы.';
	@override late final _StringsServicesRu services = _StringsServicesRu._(_root);
}

// Path: services
class _StringsServicesRu extends _StringsServicesEn {
	_StringsServicesRu._(_StringsRu root) : this._root = root, super._(root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override late final _StringsServicesSyncRu sync = _StringsServicesSyncRu._(_root);
	@override late final _StringsServicesOtpRu otp = _StringsServicesOtpRu._(_root);
	@override late final _StringsServicesStorageRu storage = _StringsServicesStorageRu._(_root);
	@override late final _StringsServicesSessionRu session = _StringsServicesSessionRu._(_root);
	@override late final _StringsServicesInitialTrainingRu initialTraining = _StringsServicesInitialTrainingRu._(_root);
}

// Path: services.sync
class _StringsServicesSyncRu extends _StringsServicesSyncEn {
	_StringsServicesSyncRu._(_StringsRu root) : this._root = root, super._(root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get supabaseNotConfigured => 'Supabase не настроен. Проверьте настройки вашего проекта.';
	@override String signUpFailed({required Object error}) => 'Регистрация не удалась: ${error}';
	@override String get signUpFailedGeneric => 'Регистрация не удалась. Попробуйте снова.';
	@override String signInFailed({required Object error}) => 'Вход не удался: ${error}';
	@override String get signInFailedGeneric => 'Вход не удался. Попробуйте снова.';
	@override String get invalidEmailPassword => 'Неверный email или пароль. Проверьте ваши данные.';
	@override String get exerciseIncompleteData => 'У упражнения нет фаз - неполные данные';
}

// Path: services.otp
class _StringsServicesOtpRu extends _StringsServicesOtpEn {
	_StringsServicesOtpRu._(_StringsRu root) : this._root = root, super._(root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get supabaseNotConfigured => 'Supabase не настроен. Проверьте настройки вашего проекта.';
	@override String failedToSendOtp({required Object error}) => 'Не удалось отправить код OTP: ${error}';
	@override String get failedToSendOtpGeneric => 'Не удалось отправить код OTP. Попробуйте снова.';
	@override String get noOtpRequest => 'Запрос на код OTP не найден. Запросите новый код OTP.';
	@override String get otpExpired => 'Код OTP истек. Запросите новый.';
	@override String get invalidOrExpiredOtp => 'Неверный или просроченный код OTP. Проверьте код или запросите новый.';
	@override String otpVerificationFailed({required Object error}) => 'Проверка кода OTP не удалась: ${error}';
	@override String get otpVerificationFailedGeneric => 'Проверка кода OTP не удалась. Попробуйте снова.';
	@override String get otpMustBeVerified => 'Код OTP должен быть проверен перед обновлением пароля.';
	@override String failedToUpdatePassword({required Object error}) => 'Не удалось обновить пароль: ${error}';
	@override String get failedToUpdatePasswordGeneric => 'Не удалось обновить пароль. Попробуйте снова.';
}

// Path: services.storage
class _StringsServicesStorageRu extends _StringsServicesStorageEn {
	_StringsServicesStorageRu._(_StringsRu root) : this._root = root, super._(root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get boxNotOpen => 'Контейнер хранения не открыт. Сначала инициализируйте приложение.';
	@override String exerciseNotFound({required Object exerciseId}) => 'Упражнение для дублирования не найдено: ${exerciseId}';
	@override String get copy => 'Копия';
	@override String get exerciseNamePlaceholder => 'Название упражнения';
	@override String get exerciseDescriptionPlaceholder => 'Описание упражнения';
}

// Path: services.session
class _StringsServicesSessionRu extends _StringsServicesSessionEn {
	_StringsServicesSessionRu._(_StringsRu root) : this._root = root, super._(root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get ready => 'Внимание!';
	@override String get go => 'Поехали!';
	@override String get noExerciseSelected => 'Невозможно начать сессию: упражнение не выбрано';
}

// Path: services.initialTraining
class _StringsServicesInitialTrainingRu extends _StringsServicesInitialTrainingEn {
	_StringsServicesInitialTrainingRu._(_StringsRu root) : this._root = root, super._(root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get molchanovMethodName => 'Метод Молчанова';
	@override String get molchanovDescription => 'Ежедневное упражнение Алексея Молчанова для развития задержки дыхания. Используется чемпионом мира на соревнованиях. Развивает толерантность к CO₂ через циклические задержки без отдыха.\n\nТЕХНИКА:\n1. Вдох 5 секунд через сжатые губы\n2. Задержка дыхания на полных легких (основная фаза)\n3. Выдох 5-10 секунд с сопротивлением\n4. Задержка на пустых легких (опционально для новичков)\n\nКЛЮЧЕВОЙ ПРИНЦИП:\nНикакого отдыха между циклами. Это накапливает CO₂ и помогает телу адаптироваться к более высоким уровням углекислого газа.\n\nПРОГРЕССИЯ:\nНачало: 2 минуты с циклами по 30 секунд (4 цикла)\nПродвинутый: Постепенно увеличивать до 15 минут общего времени\nЦиклы: 30с → 35с → 40с → 45с → 50с...\nФокус: Увеличивать в основном задержку после вдоха. Начинать с количества циклов\n\nБЕЗОПАСНОСТЬ:\nВсегда сидя или лежа. Никогда в воде для новичков. Делать дни отдыха при необходимости.\n\nУзнать больше: Найдите \"Molchanov breath hold training\"';
	@override String get breathing478Name => '4-7-8';
	@override String get breathing478Description => 'Расслабляющий дыхательный паттерн: вдох на 4, задержка на 7, выдох на 8. Отлично для снятия стресса и улучшения сна.\n\nКАК ИСПОЛЬЗОВАТЬ:\nЛучше всего использовать перед сном или при стрессе. Полностью выдохните перед началом. Положение языка: кончик за передними зубами. Считайте равномерно и последовательно.\n\nПРОГРЕССИЯ:\nНеделя 1: 4 цикла перед сном\nНеделя 2-3: 6 циклов, дважды в день\nНеделя 4+: 8 циклов, в любое время для успокоения\n\nУзнать больше: Найдите \"4-7-8 breathing Dr. Weil\"';
	@override String get boxBreathingName => 'Квадратное Дыхание';
	@override String get boxBreathingDescription => 'Дыхательный паттерн с равными интервалами: вдох, задержка, выдох, задержка - все одинаковой продолжительности. Идеально для концентрации и ясности ума.\n\nКАК ИСПОЛЬЗОВАТЬ:\nСидите удобно с прямой спиной. Начните с интервалов в 4 секунды. Визуализируйте рисование квадрата во время дыхания. Поддерживайте стабильный, контролируемый темп.\n\nПРОГРЕССИЯ:\nНеделя 1-2: 4 секунды × 8 циклов\nНеделя 3-4: 5 секунд × 8 циклов\nНеделя 5+: До 6-8 секунд на сторону\n\nУзнать больше: Найдите \"box breathing Navy SEALs technique\"';
}
