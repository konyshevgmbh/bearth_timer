// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Bearth Timer';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get enterEmail => 'E-Mail eingeben';

  @override
  String get enterPassword => 'Passwort eingeben';

  @override
  String get invalidEmailFormat => 'Ungültiges E-Mail-Format';

  @override
  String get minCharacters => 'Min. 6 Zeichen';

  @override
  String get signUp => 'Registrieren';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signOut => 'Abmelden';

  @override
  String get skip => 'Überspringen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Schließen';

  @override
  String get back => 'Zurück';

  @override
  String get loading => 'Lädt...';

  @override
  String get syncDataAcrossDevices =>
      'Daten geräteübergreifend synchronisieren';

  @override
  String get accessDataAnywhere => 'Zugriff auf Daten überall';

  @override
  String get haveAccountSignIn => 'Konto vorhanden? Anmelden';

  @override
  String get needAccountSignUp => 'Konto benötigt? Registrieren';

  @override
  String get forgot => 'Vergessen?';

  @override
  String get emailSent => 'E-Mail gesendet! Überprüfen Sie Ihr Postfach.';

  @override
  String get sendingEmail => 'E-Mail wird gesendet...';

  @override
  String get signupEmailSent =>
      'Registrierungs-E-Mail gesendet! Überprüfen Sie Ihr Postfach und setzen Sie Ihr Passwort.';

  @override
  String get failedToSendEmail =>
      'E-Mail senden fehlgeschlagen. Überprüfen Sie das E-Mail-Format.';

  @override
  String get supabaseNotConfigured => 'Supabase nicht konfiguriert';

  @override
  String get updateSupabaseConstants =>
      'Bitte aktualisieren Sie SupabaseConstants mit Ihrer Projekt-URL und dem Anon-Schlüssel';

  @override
  String get settings => 'Einstellungen';

  @override
  String get account => 'Konto';

  @override
  String get sync => 'Synchronisierung';

  @override
  String get sound => 'Ton';

  @override
  String get dataManagement => 'Datenverwaltung';

  @override
  String get appearance => 'Aussehen';

  @override
  String get about => 'Über';

  @override
  String get signedInAs => 'Angemeldet als';

  @override
  String get unknownEmail => 'Unbekannte E-Mail';

  @override
  String get signOutDescription => 'Abmelden und offline arbeiten';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountDescription => 'Konto und Daten dauerhaft löschen';

  @override
  String get workingOffline => 'Arbeitet offline';

  @override
  String get signInToSync =>
      'Anmelden zur geräteübergreifenden Synchronisierung';

  @override
  String get accessDataAnywhereButton => 'Zugriff auf Daten überall';

  @override
  String get retrySync => 'Synchronisierung wiederholen';

  @override
  String get syncWithCloud => 'Mit Cloud synchronisieren';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get saveDataToFile => 'Daten in Datei speichern';

  @override
  String get importData => 'Daten importieren';

  @override
  String get loadDataFromFile => 'Daten aus Datei laden';

  @override
  String get clearAllData => 'Alle Daten löschen';

  @override
  String get deleteAllDataPermanently => 'Alle Daten dauerhaft löschen';

  @override
  String get transitionSound => 'Übergangsgeräusch';

  @override
  String get playSoundWhenPhasesChange => 'Ton abspielen bei Phasenwechsel';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get useDarkTheme => 'Dunkles Design verwenden';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get signOutConfirmTitle => 'Abmelden';

  @override
  String get signOutConfirmMessage =>
      'Sind Sie sicher, dass Sie sich abmelden möchten? Ihre Daten bleiben auf diesem Gerät.';

  @override
  String get clearAllDataConfirmTitle => 'Alle Daten löschen';

  @override
  String get clearAllDataConfirmMessage =>
      'Sind Sie sicher, dass Sie alle Trainingsergebnisse löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden und löscht Daten von all Ihren Geräten.';

  @override
  String get clearAll => 'Alle löschen';

  @override
  String get exercises => 'Übungen';

  @override
  String get importExercise => 'Übung importieren';

  @override
  String get addExercise => 'Übung hinzufügen';

  @override
  String get noExercisesYet => 'Noch keine Übungen';

  @override
  String get createFirstExercise => 'Erstellen Sie Ihre erste Übung';

  @override
  String get createYourFirstExercise => 'Create your first exercise';

  @override
  String get cycles => 'Zyklen';

  @override
  String get duration => 'Dauer';

  @override
  String cycleDurationSeconds(int cycles, int duration) {
    return '$cycles Zyklen • ${duration}s Dauer';
  }

  @override
  String get edit => 'Bearbeiten';

  @override
  String get duplicate => 'Duplizieren';

  @override
  String get export => 'Exportieren';

  @override
  String errorLoadingExercises(String error) {
    return 'Fehler beim Laden der Übungen: $error';
  }

  @override
  String get deleteExercise => 'Übung löschen';

  @override
  String deleteExerciseConfirm(String name) {
    return 'Sind Sie sicher, dass Sie \"$name\" löschen möchten?';
  }

  @override
  String get exportFailed => 'Export fehlgeschlagen';

  @override
  String failedToExport(String error) {
    return 'Export der Übung fehlgeschlagen: $error';
  }

  @override
  String get importSuccessful => 'Import erfolgreich';

  @override
  String get importFailed => 'Import fehlgeschlagen';

  @override
  String failedToImport(String error) {
    return 'Import der Übung fehlgeschlagen: $error';
  }

  @override
  String get exerciseDetails => 'Übungsdetails:';

  @override
  String get cycleDuration => 'Zyklusdauer';

  @override
  String get totalDuration => 'Gesamtdauer';

  @override
  String get phases => 'Phasen';

  @override
  String get noDescriptionAvailable =>
      'Keine Beschreibung für diese Übung verfügbar.';

  @override
  String get description => 'Beschreibung';

  @override
  String get customize => 'Anpassen';

  @override
  String get time => 'Zeit';

  @override
  String get stop => 'Stopp';

  @override
  String get start => 'Start';

  @override
  String cycleProgress(int current, int total) {
    return 'Zyklus $current / $total';
  }

  @override
  String get oneClap => '1 Klatschen';

  @override
  String clapsCount(int count) {
    return '$count Klatschen';
  }

  @override
  String range(String range) {
    return 'Bereich: $range';
  }

  @override
  String get name => 'Name';

  @override
  String get information => 'Information';

  @override
  String get configuration => 'Konfiguration';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get step => 'Schritt';

  @override
  String get minimum => 'Minimum';

  @override
  String get current => 'Aktuell';

  @override
  String get maximum => 'Maximum';

  @override
  String get total => 'Gesamt';

  @override
  String get addPhase => 'Phase hinzufügen';

  @override
  String get history => 'Verlauf';

  @override
  String get overview => 'Übersicht';

  @override
  String get sessions => 'Sitzungen';

  @override
  String get avg => 'Durchschnitt';

  @override
  String get noHistoryYet => 'Noch kein Verlauf';

  @override
  String get completeSessionToSeeProgress =>
      'Schließen Sie eine Sitzung ab, um Fortschritt zu sehen';

  @override
  String today(String time) {
    return 'Heute $time';
  }

  @override
  String get yesterday => 'Gestern';

  @override
  String daysAgo(int days) {
    return 'vor $days Tagen';
  }

  @override
  String cyclesAndDuration(int cycles, int duration) {
    return '$cycles Zyklen • ${duration}s';
  }

  @override
  String get noTraining => 'Kein Training';

  @override
  String secondsUnit(int value) {
    return '${value}s';
  }

  @override
  String cyclesUnit(String value) {
    return '${value}z';
  }

  @override
  String get resetPassword => 'Passwort zurücksetzen';

  @override
  String get enterEmailToGetResetCode =>
      'E-Mail eingeben, um Reset-Code zu erhalten';

  @override
  String get sendCode => 'Code senden';

  @override
  String get passwordResetCodeSent =>
      'Passwort-Reset-Code an Ihre E-Mail gesendet';

  @override
  String get verifyEmail => 'E-Mail verifizieren';

  @override
  String get checkYourEmail => 'Überprüfen Sie Ihre E-Mail';

  @override
  String codeSentTo(String email) {
    return 'Code gesendet an $email';
  }

  @override
  String get verificationCode => 'Bestätigungscode';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String resendInSeconds(int seconds) {
    return 'Erneut senden in ${seconds}s';
  }

  @override
  String get resendCode => 'Code erneut senden';

  @override
  String get newCodeSentToEmail => 'Neuer Code an Ihre E-Mail gesendet';

  @override
  String get enterVerificationCode => 'Bestätigungscode eingeben';

  @override
  String get deleteAccountTitle => 'Konto löschen';

  @override
  String get verifyDeletion => 'Löschung bestätigen';

  @override
  String get permanentDeleteWarning =>
      'Dies wird Ihr Konto und alle Daten dauerhaft löschen.';

  @override
  String get deletionConsequences =>
      '• Alle Trainingsdaten gehen verloren\\n• Sync-Einstellungen werden gelöscht\\n• Diese Aktion kann nicht rückgängig gemacht werden';

  @override
  String get iUnderstandContinue => 'Ich verstehe, fortfahren';

  @override
  String accountEmail(String email) {
    return 'Konto: $email';
  }

  @override
  String get sendVerificationCodeDescription =>
      'Wir senden Ihnen einen Bestätigungscode zur Bestätigung dieser Aktion.';

  @override
  String get sendVerificationCode => 'Bestätigungscode senden';

  @override
  String get noUserEmailFound =>
      'Keine Benutzer-E-Mail gefunden. Bitte melden Sie sich erneut an.';

  @override
  String verificationCodeSentTo(String email) {
    return 'Bestätigungscode gesendet an $email';
  }

  @override
  String get accountDataCleared =>
      'Kontodaten gelöscht. Sie wurden abgemeldet.';

  @override
  String get failedToDeleteAccount =>
      'Konto löschen fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get enterCode => 'Code eingeben';

  @override
  String get chooseStrongPassword => 'Wählen Sie ein starkes Passwort';

  @override
  String get code => 'Code';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get verify => 'Bestätigen';

  @override
  String get update => 'Aktualisieren';

  @override
  String get resendCode2 => 'Code erneut senden';

  @override
  String get pleaseEnterPassword => 'Bitte geben Sie ein Passwort ein';

  @override
  String get passwordMinLength => 'Passwort muss mindestens 6 Zeichen haben';

  @override
  String get passwordUppercase =>
      'Passwort muss mindestens einen Großbuchstaben enthalten';

  @override
  String get passwordLowercase =>
      'Passwort muss mindestens einen Kleinbuchstaben enthalten';

  @override
  String get passwordNumber => 'Passwort muss mindestens eine Zahl enthalten';

  @override
  String get pleaseConfirmPassword => 'Bitte bestätigen Sie Ihr Passwort';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get passwordRequirements => 'Passwort-Anforderungen:';

  @override
  String get atLeast6Characters => 'Mindestens 6 Zeichen';

  @override
  String get oneUppercaseLetter => 'Ein Großbuchstabe';

  @override
  String get oneLowercaseLetter => 'Ein Kleinbuchstabe';

  @override
  String get oneNumber => 'Eine Zahl';

  @override
  String get pleaseEnterVerificationCode =>
      'Bitte geben Sie den Bestätigungscode ein';

  @override
  String get codeVerifiedCreatePassword =>
      'Code bestätigt! Erstellen Sie jetzt Ihr neues Passwort.';

  @override
  String get newVerificationCodeSent =>
      'Neuer Bestätigungscode an Ihre E-Mail gesendet';

  @override
  String get breathTraining => 'Atemtraining';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get timer => 'Timer';

  @override
  String get newExercise => 'Neue Übung';

  @override
  String exerciseSummary(int cycles, int duration) {
    return '$cycles Zyklen • ${duration}s Dauer';
  }

  @override
  String failedToExportExercise(String error) {
    return 'Export der Übung fehlgeschlagen: $error';
  }

  @override
  String failedToImportExercise(String error) {
    return 'Import der Übung fehlgeschlagen: $error';
  }

  @override
  String confirmDeleteExercise(String name) {
    return 'Sind Sie sicher, dass Sie \"$name\" löschen möchten?';
  }
}
