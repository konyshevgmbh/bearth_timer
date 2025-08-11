/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 1
/// Strings: 176
///
/// Built on 2025-08-11 at 10:24 UTC

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
	en(languageCode: 'en', build: Translations.build);

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
/// String b = t['someKey.anotherKey']; // Only for edge cases!
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
/// String b = t['someKey.anotherKey']; // Only for edge cases!
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
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	late final _TranslationsAppEn app = _TranslationsAppEn._(_root);
	late final _TranslationsNavigationEn navigation = _TranslationsNavigationEn._(_root);
	late final _TranslationsExercisesEn exercises = _TranslationsExercisesEn._(_root);
	late final _TranslationsTimerEn timer = _TranslationsTimerEn._(_root);
	late final _TranslationsHistoryEn history = _TranslationsHistoryEn._(_root);
	late final _TranslationsSettingsEn settings = _TranslationsSettingsEn._(_root);
	late final _TranslationsAuthEn auth = _TranslationsAuthEn._(_root);
	late final _TranslationsDeleteAccountEn deleteAccount = _TranslationsDeleteAccountEn._(_root);
	late final _TranslationsForgotPasswordEn forgotPassword = _TranslationsForgotPasswordEn._(_root);
	late final _TranslationsResetPasswordEn resetPassword = _TranslationsResetPasswordEn._(_root);
	late final _TranslationsVerifySignupEn verifySignup = _TranslationsVerifySignupEn._(_root);
	late final _TranslationsImportExportEn importExport = _TranslationsImportExportEn._(_root);
	late final _TranslationsDialogsEn dialogs = _TranslationsDialogsEn._(_root);
	late final _TranslationsValidationEn validation = _TranslationsValidationEn._(_root);
}

// Path: app
class _TranslationsAppEn {
	_TranslationsAppEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Bearth Timer';
	String get loading => 'Lädt...';
	String get unknown => 'Unbekannt';
	String get error => 'Fehler';
	String get unknownEmail => 'Unbekannte E-Mail';
}

// Path: navigation
class _TranslationsNavigationEn {
	_TranslationsNavigationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get exercises => 'Übungen';
	String get timer => 'Timer';
	String get history => 'Verlauf';
	String get settings => 'Einstellungen';
	String get breathTraining => 'Atemtraining';
}

// Path: exercises
class _TranslationsExercisesEn {
	_TranslationsExercisesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Übungen';
	String get noExercisesYet => 'Noch keine Übungen';
	String get createFirstExercise => 'Erstellen Sie Ihre erste Übung';
	String get newExercise => 'Neue Übung';
	String get customBreathingExercise => 'Benutzerdefinierte Atemübung';
	String get edit => 'Bearbeiten';
	String get duplicate => 'Duplizieren';
	String get export => 'Exportieren';
	String get delete => 'Löschen';
	String get importExercise => 'Übung importieren';
	String get exportExercise => 'Übung exportieren';
	String get addExercise => 'Übung hinzufügen';
	String get cycles => 'Zyklen';
	String get duration => 'Dauer';
	String get errorLoading => 'Fehler beim Laden der Übungen: {error}';
	String get editExercise => 'Übung bearbeiten';
	String get information => 'Information';
	String get name => 'Name';
	String get description => 'Beschreibung';
	String get configuration => 'Konfiguration';
	String get min => 'Min';
	String get max => 'Max';
	String get step => 'Schritt';
	String get phases => 'Phasen';
	String get addPhase => 'Phase hinzufügen';
	String get cycleDuration => 'Zyklusdauer';
	String get minimum => 'Minimum';
	String get current => 'Aktuell';
	String get maximum => 'Maximum';
	String get total => 'Gesamt';
	String get clap => 'Klatschen';
	String get claps => 'Klatschen';
}

// Path: timer
class _TranslationsTimerEn {
	_TranslationsTimerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get exercise => 'Übung';
	String get noDescription => 'Für diese Übung ist keine Beschreibung verfügbar.';
	String get exerciseDetails => 'Übungsdetails:';
	String get cycles => 'Zyklen';
	String get cycleDuration => 'Zyklusdauer';
	String get totalDuration => 'Gesamtdauer';
	String get phases => 'Phasen';
	String get close => 'Schließen';
	String get customize => 'Anpassen';
	String get stop => 'Stop';
	String get start => 'Start';
	String get time => 'Zeit';
	String get range => 'Bereich:';
	String get currentCycle => 'Zyklus {current} / {total}';
	String get oneClap => '1 Klatschen';
	String get multipleClaps => '{count} Klatschen';
}

// Path: history
class _TranslationsHistoryEn {
	_TranslationsHistoryEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Verlauf';
	String get overview => 'Überblick';
	String get sessions => 'Sitzungen';
	String get time => 'Zeit';
	String get avg => 'Durchschn.';
	String get cycles => 'Zyklen';
	String get noHistoryYet => 'Noch kein Verlauf';
	String get completeSessionToSee => 'Schließen Sie eine Sitzung ab, um den Fortschritt zu sehen';
	String get sessionsLabel => 'Sitzungen';
	String get today => 'Heute';
	String get yesterday => 'Gestern';
	String get daysAgo => 'vor {days} Tagen';
}

// Path: settings
class _TranslationsSettingsEn {
	_TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Einstellungen';
	String get account => 'Konto';
	String get signedInAs => 'Angemeldet als';
	String get signOut => 'Abmelden';
	String get signOutAndWork => 'Abmelden und offline arbeiten';
	String get deleteAccount => 'Konto löschen';
	String get permanentlyDelete => 'Konto und Daten dauerhaft löschen';
	String get workingOffline => 'Offline arbeiten';
	String get signInToSync => 'Anmelden, um zwischen Geräten zu synchronisieren';
	String get signIn => 'Anmelden';
	String get accessDataAnywhere => 'Daten überall verfügbar';
	String get sync => 'Synchronisierung';
	String get retrySync => 'Synchronisierung wiederholen';
	String get syncWithCloud => 'Mit Cloud synchronisieren';
	String get sound => 'Ton';
	String get transitionSound => 'Übergangston';
	String get playSoundWhenPhases => 'Ton bei Phasenwechsel abspielen';
	String get dataManagement => 'Datenverwaltung';
	String get exportData => 'Daten exportieren';
	String get saveDataToFile => 'Daten in Datei speichern';
	String get importData => 'Daten importieren';
	String get loadDataFromFile => 'Daten aus Datei laden';
	String get clearAllData => 'Alle Daten löschen';
	String get deleteAllData => 'Alle Daten dauerhaft löschen';
	String get appearance => 'Erscheinungsbild';
	String get darkMode => 'Dunkler Modus';
	String get useDarkTheme => 'Dunkles Design verwenden';
	String get about => 'Über';
	String get version => 'Version {version}';
	String get confirmClearData => 'Sind Sie sicher, dass Sie alle Daten löschen möchten? Dies kann nicht rückgängig gemacht werden.';
	String get confirmDeleteAccount => 'Sind Sie sicher, dass Sie Ihr Konto löschen möchten? Dies kann nicht rückgängig gemacht werden.';
}

// Path: auth
class _TranslationsAuthEn {
	_TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Bearth Timer';
	String get email => 'E-Mail';
	String get password => 'Passwort';
	String get enterEmail => 'E-Mail eingeben';
	String get enterPassword => 'Passwort eingeben';
	String get invalidEmail => 'Ungültiges E-Mail-Format';
	String get minCharacters => 'Min. 6 Zeichen';
	String get syncDataAcross => 'Daten zwischen Geräten synchronisieren';
	String get accessYourData => 'Zugriff auf Ihre Daten überall';
	String get supabaseNotConfigured => 'Supabase nicht konfiguriert';
	String get signUp => 'Registrieren';
	String get signIn => 'Anmelden';
	String get resendEmail => 'E-Mail erneut senden';
	String get forgot => 'Vergessen?';
	String get haveAccount => 'Konto vorhanden? Anmelden';
	String get needAccount => 'Konto benötigt? Registrieren';
	String get skip => 'Überspringen';
}

// Path: deleteAccount
class _TranslationsDeleteAccountEn {
	_TranslationsDeleteAccountEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Konto löschen';
	String get verifyDeletion => 'Löschung bestätigen';
	String get iUnderstand => 'Ich verstehe, fortfahren';
	String get sendVerificationCode => 'Bestätigungscode senden';
	String get verificationCode => 'Bestätigungscode';
	String get resendIn => 'Erneut senden in {seconds}s';
	String get resendCode => 'Code erneut senden';
}

// Path: forgotPassword
class _TranslationsForgotPasswordEn {
	_TranslationsForgotPasswordEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Passwort zurücksetzen';
	String get enterEmailToReset => 'E-Mail eingeben, um Reset-Code zu erhalten';
	String get sendCode => 'Code senden';
	String get back => 'Zurück';
	String get invalidEmail => 'Ungültige E-Mail';
}

// Path: resetPassword
class _TranslationsResetPasswordEn {
	_TranslationsResetPasswordEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Passwort zurücksetzen';
	String get newPassword => 'Neues Passwort';
	String get enterCode => 'Code eingeben';
	String get chooseStrong => 'Wählen Sie ein starkes Passwort';
	String get codeSentTo => 'Code gesendet an {email}';
	String get code => 'Code';
	String get password => 'Passwort';
	String get confirm => 'Bestätigen';
	String get verify => 'Überprüfen';
	String get update => 'Aktualisieren';
	String get passwordRequirements => 'Passwort-Anforderungen:';
	String get resendCode => 'Code erneut senden';
}

// Path: verifySignup
class _TranslationsVerifySignupEn {
	_TranslationsVerifySignupEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'E-Mail bestätigen';
	String get checkYourEmail => 'Überprüfen Sie Ihre E-Mail';
	String get codeSentTo => 'Code gesendet an {email}';
	String get verificationCode => 'Bestätigungscode';
	String get createAccount => 'Konto erstellen';
	String get resendCode => 'Code erneut senden';
	String get back => 'Zurück';
}

// Path: importExport
class _TranslationsImportExportEn {
	_TranslationsImportExportEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get exportSuccessful => 'Übung erfolgreich exportiert';
	String get exportCancelled => 'Export abgebrochen';
	String get exportFailed => 'Export fehlgeschlagen';
	String get failedToExport => 'Fehler beim Exportieren der Übung';
	String get importSuccessful => 'Import erfolgreich';
	String get importFailed => 'Import fehlgeschlagen';
	String get failedToImport => 'Fehler beim Importieren der Übung';
	String get importedExercise => 'Übung importiert: {exerciseName}';
	String get noFileSelected => 'Keine Datei ausgewählt';
	String get couldNotReadFile => 'Datei konnte nicht gelesen werden';
	String get unsupportedVersion => 'Nicht unterstützte Export-Version: {version}';
	String get invalidFileType => 'Ungültiger Dateityp. Einzelübungs-Export erwartet.';
	String get noExerciseData => 'Keine Übungsdaten in der Datei gefunden';
	String get failedToParse => 'Fehler beim Analysieren der Übungsdaten';
	String get failedToAdd => 'Fehler beim Hinzufügen der Übung zum Speicher';
}

// Path: dialogs
class _TranslationsDialogsEn {
	_TranslationsDialogsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get ok => 'OK';
	String get cancel => 'Abbrechen';
	String get deleteExercise => 'Übung löschen';
	String get deleteConfirmation => 'Sind Sie sicher, dass Sie "{exerciseName}" löschen möchten?';
	String get yes => 'Ja';
	String get no => 'Nein';
}

// Path: validation
class _TranslationsValidationEn {
	_TranslationsValidationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Dieses Feld ist erforderlich';
	String get emailRequired => 'E-Mail ist erforderlich';
	String get passwordRequired => 'Passwort ist erforderlich';
	String get invalidEmailFormat => 'Ungültiges E-Mail-Format';
	String get passwordTooShort => 'Passwort muss mindestens 6 Zeichen haben';
	String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.title': return 'Bearth Timer';
			case 'app.loading': return 'Lädt...';
			case 'app.unknown': return 'Unbekannt';
			case 'app.error': return 'Fehler';
			case 'app.unknownEmail': return 'Unbekannte E-Mail';
			case 'navigation.exercises': return 'Übungen';
			case 'navigation.timer': return 'Timer';
			case 'navigation.history': return 'Verlauf';
			case 'navigation.settings': return 'Einstellungen';
			case 'navigation.breathTraining': return 'Atemtraining';
			case 'exercises.title': return 'Übungen';
			case 'exercises.noExercisesYet': return 'Noch keine Übungen';
			case 'exercises.createFirstExercise': return 'Erstellen Sie Ihre erste Übung';
			case 'exercises.newExercise': return 'Neue Übung';
			case 'exercises.customBreathingExercise': return 'Benutzerdefinierte Atemübung';
			case 'exercises.edit': return 'Bearbeiten';
			case 'exercises.duplicate': return 'Duplizieren';
			case 'exercises.export': return 'Exportieren';
			case 'exercises.delete': return 'Löschen';
			case 'exercises.importExercise': return 'Übung importieren';
			case 'exercises.exportExercise': return 'Übung exportieren';
			case 'exercises.addExercise': return 'Übung hinzufügen';
			case 'exercises.cycles': return 'Zyklen';
			case 'exercises.duration': return 'Dauer';
			case 'exercises.errorLoading': return 'Fehler beim Laden der Übungen: {error}';
			case 'exercises.editExercise': return 'Übung bearbeiten';
			case 'exercises.information': return 'Information';
			case 'exercises.name': return 'Name';
			case 'exercises.description': return 'Beschreibung';
			case 'exercises.configuration': return 'Konfiguration';
			case 'exercises.min': return 'Min';
			case 'exercises.max': return 'Max';
			case 'exercises.step': return 'Schritt';
			case 'exercises.phases': return 'Phasen';
			case 'exercises.addPhase': return 'Phase hinzufügen';
			case 'exercises.cycleDuration': return 'Zyklusdauer';
			case 'exercises.minimum': return 'Minimum';
			case 'exercises.current': return 'Aktuell';
			case 'exercises.maximum': return 'Maximum';
			case 'exercises.total': return 'Gesamt';
			case 'exercises.clap': return 'Klatschen';
			case 'exercises.claps': return 'Klatschen';
			case 'timer.exercise': return 'Übung';
			case 'timer.noDescription': return 'Für diese Übung ist keine Beschreibung verfügbar.';
			case 'timer.exerciseDetails': return 'Übungsdetails:';
			case 'timer.cycles': return 'Zyklen';
			case 'timer.cycleDuration': return 'Zyklusdauer';
			case 'timer.totalDuration': return 'Gesamtdauer';
			case 'timer.phases': return 'Phasen';
			case 'timer.close': return 'Schließen';
			case 'timer.customize': return 'Anpassen';
			case 'timer.stop': return 'Stop';
			case 'timer.start': return 'Start';
			case 'timer.time': return 'Zeit';
			case 'timer.range': return 'Bereich:';
			case 'timer.currentCycle': return 'Zyklus {current} / {total}';
			case 'timer.oneClap': return '1 Klatschen';
			case 'timer.multipleClaps': return '{count} Klatschen';
			case 'history.title': return 'Verlauf';
			case 'history.overview': return 'Überblick';
			case 'history.sessions': return 'Sitzungen';
			case 'history.time': return 'Zeit';
			case 'history.avg': return 'Durchschn.';
			case 'history.cycles': return 'Zyklen';
			case 'history.noHistoryYet': return 'Noch kein Verlauf';
			case 'history.completeSessionToSee': return 'Schließen Sie eine Sitzung ab, um den Fortschritt zu sehen';
			case 'history.sessionsLabel': return 'Sitzungen';
			case 'history.today': return 'Heute';
			case 'history.yesterday': return 'Gestern';
			case 'history.daysAgo': return 'vor {days} Tagen';
			case 'settings.title': return 'Einstellungen';
			case 'settings.account': return 'Konto';
			case 'settings.signedInAs': return 'Angemeldet als';
			case 'settings.signOut': return 'Abmelden';
			case 'settings.signOutAndWork': return 'Abmelden und offline arbeiten';
			case 'settings.deleteAccount': return 'Konto löschen';
			case 'settings.permanentlyDelete': return 'Konto und Daten dauerhaft löschen';
			case 'settings.workingOffline': return 'Offline arbeiten';
			case 'settings.signInToSync': return 'Anmelden, um zwischen Geräten zu synchronisieren';
			case 'settings.signIn': return 'Anmelden';
			case 'settings.accessDataAnywhere': return 'Daten überall verfügbar';
			case 'settings.sync': return 'Synchronisierung';
			case 'settings.retrySync': return 'Synchronisierung wiederholen';
			case 'settings.syncWithCloud': return 'Mit Cloud synchronisieren';
			case 'settings.sound': return 'Ton';
			case 'settings.transitionSound': return 'Übergangston';
			case 'settings.playSoundWhenPhases': return 'Ton bei Phasenwechsel abspielen';
			case 'settings.dataManagement': return 'Datenverwaltung';
			case 'settings.exportData': return 'Daten exportieren';
			case 'settings.saveDataToFile': return 'Daten in Datei speichern';
			case 'settings.importData': return 'Daten importieren';
			case 'settings.loadDataFromFile': return 'Daten aus Datei laden';
			case 'settings.clearAllData': return 'Alle Daten löschen';
			case 'settings.deleteAllData': return 'Alle Daten dauerhaft löschen';
			case 'settings.appearance': return 'Erscheinungsbild';
			case 'settings.darkMode': return 'Dunkler Modus';
			case 'settings.useDarkTheme': return 'Dunkles Design verwenden';
			case 'settings.about': return 'Über';
			case 'settings.version': return 'Version {version}';
			case 'settings.confirmClearData': return 'Sind Sie sicher, dass Sie alle Daten löschen möchten? Dies kann nicht rückgängig gemacht werden.';
			case 'settings.confirmDeleteAccount': return 'Sind Sie sicher, dass Sie Ihr Konto löschen möchten? Dies kann nicht rückgängig gemacht werden.';
			case 'auth.title': return 'Bearth Timer';
			case 'auth.email': return 'E-Mail';
			case 'auth.password': return 'Passwort';
			case 'auth.enterEmail': return 'E-Mail eingeben';
			case 'auth.enterPassword': return 'Passwort eingeben';
			case 'auth.invalidEmail': return 'Ungültiges E-Mail-Format';
			case 'auth.minCharacters': return 'Min. 6 Zeichen';
			case 'auth.syncDataAcross': return 'Daten zwischen Geräten synchronisieren';
			case 'auth.accessYourData': return 'Zugriff auf Ihre Daten überall';
			case 'auth.supabaseNotConfigured': return 'Supabase nicht konfiguriert';
			case 'auth.signUp': return 'Registrieren';
			case 'auth.signIn': return 'Anmelden';
			case 'auth.resendEmail': return 'E-Mail erneut senden';
			case 'auth.forgot': return 'Vergessen?';
			case 'auth.haveAccount': return 'Konto vorhanden? Anmelden';
			case 'auth.needAccount': return 'Konto benötigt? Registrieren';
			case 'auth.skip': return 'Überspringen';
			case 'deleteAccount.title': return 'Konto löschen';
			case 'deleteAccount.verifyDeletion': return 'Löschung bestätigen';
			case 'deleteAccount.iUnderstand': return 'Ich verstehe, fortfahren';
			case 'deleteAccount.sendVerificationCode': return 'Bestätigungscode senden';
			case 'deleteAccount.verificationCode': return 'Bestätigungscode';
			case 'deleteAccount.resendIn': return 'Erneut senden in {seconds}s';
			case 'deleteAccount.resendCode': return 'Code erneut senden';
			case 'forgotPassword.title': return 'Passwort zurücksetzen';
			case 'forgotPassword.enterEmailToReset': return 'E-Mail eingeben, um Reset-Code zu erhalten';
			case 'forgotPassword.sendCode': return 'Code senden';
			case 'forgotPassword.back': return 'Zurück';
			case 'forgotPassword.invalidEmail': return 'Ungültige E-Mail';
			case 'resetPassword.title': return 'Passwort zurücksetzen';
			case 'resetPassword.newPassword': return 'Neues Passwort';
			case 'resetPassword.enterCode': return 'Code eingeben';
			case 'resetPassword.chooseStrong': return 'Wählen Sie ein starkes Passwort';
			case 'resetPassword.codeSentTo': return 'Code gesendet an {email}';
			case 'resetPassword.code': return 'Code';
			case 'resetPassword.password': return 'Passwort';
			case 'resetPassword.confirm': return 'Bestätigen';
			case 'resetPassword.verify': return 'Überprüfen';
			case 'resetPassword.update': return 'Aktualisieren';
			case 'resetPassword.passwordRequirements': return 'Passwort-Anforderungen:';
			case 'resetPassword.resendCode': return 'Code erneut senden';
			case 'verifySignup.title': return 'E-Mail bestätigen';
			case 'verifySignup.checkYourEmail': return 'Überprüfen Sie Ihre E-Mail';
			case 'verifySignup.codeSentTo': return 'Code gesendet an {email}';
			case 'verifySignup.verificationCode': return 'Bestätigungscode';
			case 'verifySignup.createAccount': return 'Konto erstellen';
			case 'verifySignup.resendCode': return 'Code erneut senden';
			case 'verifySignup.back': return 'Zurück';
			case 'importExport.exportSuccessful': return 'Übung erfolgreich exportiert';
			case 'importExport.exportCancelled': return 'Export abgebrochen';
			case 'importExport.exportFailed': return 'Export fehlgeschlagen';
			case 'importExport.failedToExport': return 'Fehler beim Exportieren der Übung';
			case 'importExport.importSuccessful': return 'Import erfolgreich';
			case 'importExport.importFailed': return 'Import fehlgeschlagen';
			case 'importExport.failedToImport': return 'Fehler beim Importieren der Übung';
			case 'importExport.importedExercise': return 'Übung importiert: {exerciseName}';
			case 'importExport.noFileSelected': return 'Keine Datei ausgewählt';
			case 'importExport.couldNotReadFile': return 'Datei konnte nicht gelesen werden';
			case 'importExport.unsupportedVersion': return 'Nicht unterstützte Export-Version: {version}';
			case 'importExport.invalidFileType': return 'Ungültiger Dateityp. Einzelübungs-Export erwartet.';
			case 'importExport.noExerciseData': return 'Keine Übungsdaten in der Datei gefunden';
			case 'importExport.failedToParse': return 'Fehler beim Analysieren der Übungsdaten';
			case 'importExport.failedToAdd': return 'Fehler beim Hinzufügen der Übung zum Speicher';
			case 'dialogs.ok': return 'OK';
			case 'dialogs.cancel': return 'Abbrechen';
			case 'dialogs.deleteExercise': return 'Übung löschen';
			case 'dialogs.deleteConfirmation': return 'Sind Sie sicher, dass Sie "{exerciseName}" löschen möchten?';
			case 'dialogs.yes': return 'Ja';
			case 'dialogs.no': return 'Nein';
			case 'validation.required': return 'Dieses Feld ist erforderlich';
			case 'validation.emailRequired': return 'E-Mail ist erforderlich';
			case 'validation.passwordRequired': return 'Passwort ist erforderlich';
			case 'validation.invalidEmailFormat': return 'Ungültiges E-Mail-Format';
			case 'validation.passwordTooShort': return 'Passwort muss mindestens 6 Zeichen haben';
			case 'validation.passwordsDoNotMatch': return 'Passwörter stimmen nicht überein';
			default: return null;
		}
	}
}
