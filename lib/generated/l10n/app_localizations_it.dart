// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Bearth Timer';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Password';

  @override
  String get enterEmail => 'Inserisci e-mail';

  @override
  String get enterPassword => 'Inserisci password';

  @override
  String get invalidEmailFormat => 'Formato e-mail non valido';

  @override
  String get minCharacters => 'Min 6 caratteri';

  @override
  String get signUp => 'Registrati';

  @override
  String get signIn => 'Accedi';

  @override
  String get signOut => 'Esci';

  @override
  String get skip => 'Salta';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Chiudi';

  @override
  String get back => 'Indietro';

  @override
  String get loading => 'Caricamento...';

  @override
  String get syncDataAcrossDevices => 'Sincronizza dati tra dispositivi';

  @override
  String get accessDataAnywhere => 'Accedi ai dati ovunque';

  @override
  String get haveAccountSignIn => 'Hai un account? Accedi';

  @override
  String get needAccountSignUp => 'Serve un account? Registrati';

  @override
  String get forgot => 'Dimenticato?';

  @override
  String get emailSent => 'E-mail inviata! Controlla la tua casella di posta.';

  @override
  String get sendingEmail => 'Invio e-mail...';

  @override
  String get signupEmailSent =>
      'E-mail di registrazione inviata! Controlla la tua casella di posta e imposta la password.';

  @override
  String get failedToSendEmail =>
      'Invio e-mail fallito. Controlla il formato dell\'e-mail.';

  @override
  String get supabaseNotConfigured => 'Supabase non configurato';

  @override
  String get updateSupabaseConstants =>
      'Aggiorna SupabaseConstants con l\'URL del progetto e la chiave anonima';

  @override
  String get settings => 'Impostazioni';

  @override
  String get account => 'Account';

  @override
  String get sync => 'Sincronizzazione';

  @override
  String get sound => 'Suono';

  @override
  String get dataManagement => 'Gestione dati';

  @override
  String get appearance => 'Aspetto';

  @override
  String get about => 'Info';

  @override
  String get signedInAs => 'Connesso come';

  @override
  String get unknownEmail => 'E-mail sconosciuta';

  @override
  String get signOutDescription => 'Esci e lavora offline';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get deleteAccountDescription =>
      'Elimina definitivamente account e dati';

  @override
  String get workingOffline => 'Lavoro offline';

  @override
  String get signInToSync => 'Accedi per sincronizzare tra dispositivi';

  @override
  String get accessDataAnywhereButton => 'Accedi ai dati ovunque';

  @override
  String get retrySync => 'Riprova sincronizzazione';

  @override
  String get syncWithCloud => 'Sincronizza con il cloud';

  @override
  String get exportData => 'Esporta dati';

  @override
  String get saveDataToFile => 'Salva dati su file';

  @override
  String get importData => 'Importa dati';

  @override
  String get loadDataFromFile => 'Carica dati da file';

  @override
  String get clearAllData => 'Cancella tutti i dati';

  @override
  String get deleteAllDataPermanently => 'Elimina definitivamente tutti i dati';

  @override
  String get transitionSound => 'Suono di transizione';

  @override
  String get playSoundWhenPhasesChange => 'Riproduci suono al cambio fase';

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get useDarkTheme => 'Usa tema scuro';

  @override
  String version(String version) {
    return 'Versione $version';
  }

  @override
  String get signOutConfirmTitle => 'Esci';

  @override
  String get signOutConfirmMessage =>
      'Sei sicuro di voler uscire? I tuoi dati rimarranno su questo dispositivo.';

  @override
  String get clearAllDataConfirmTitle => 'Cancella tutti i dati';

  @override
  String get clearAllDataConfirmMessage =>
      'Sei sicuro di voler eliminare tutti i risultati di allenamento? Questa azione non può essere annullata e cancellerà i dati da tutti i tuoi dispositivi.';

  @override
  String get clearAll => 'Cancella tutto';

  @override
  String get exercises => 'Esercizi';

  @override
  String get importExercise => 'Importa esercizio';

  @override
  String get addExercise => 'Aggiungi esercizio';

  @override
  String get noExercisesYet => 'Nessun esercizio ancora';

  @override
  String get createFirstExercise => 'Crea il tuo primo esercizio';

  @override
  String get createYourFirstExercise => 'Create your first exercise';

  @override
  String get cycles => 'Cicli';

  @override
  String get duration => 'Durata';

  @override
  String cycleDurationSeconds(int cycles, int duration) {
    return '$cycles cicli • ${duration}s durata';
  }

  @override
  String get edit => 'Modifica';

  @override
  String get duplicate => 'Duplica';

  @override
  String get export => 'Esporta';

  @override
  String errorLoadingExercises(String error) {
    return 'Errore caricamento esercizi: $error';
  }

  @override
  String get deleteExercise => 'Elimina esercizio';

  @override
  String deleteExerciseConfirm(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"?';
  }

  @override
  String get exportFailed => 'Esportazione fallita';

  @override
  String failedToExport(String error) {
    return 'Esportazione esercizio fallita: $error';
  }

  @override
  String get importSuccessful => 'Importazione riuscita';

  @override
  String get importFailed => 'Importazione fallita';

  @override
  String failedToImport(String error) {
    return 'Importazione esercizio fallita: $error';
  }

  @override
  String get exerciseDetails => 'Dettagli esercizio:';

  @override
  String get cycleDuration => 'Durata ciclo';

  @override
  String get totalDuration => 'Durata totale';

  @override
  String get phases => 'Fasi';

  @override
  String get noDescriptionAvailable =>
      'Nessuna descrizione disponibile per questo esercizio.';

  @override
  String get description => 'Descrizione';

  @override
  String get customize => 'Personalizza';

  @override
  String get time => 'Tempo';

  @override
  String get stop => 'Ferma';

  @override
  String get start => 'Avvia';

  @override
  String cycleProgress(int current, int total) {
    return 'Ciclo $current / $total';
  }

  @override
  String get oneClap => '1 battito';

  @override
  String clapsCount(int count) {
    return '$count battiti';
  }

  @override
  String range(String range) {
    return 'Intervallo: $range';
  }

  @override
  String get name => 'Nome';

  @override
  String get information => 'Informazioni';

  @override
  String get configuration => 'Configurazione';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get step => 'Passo';

  @override
  String get minimum => 'Minimo';

  @override
  String get current => 'Corrente';

  @override
  String get maximum => 'Massimo';

  @override
  String get total => 'Totale';

  @override
  String get addPhase => 'Aggiungi fase';

  @override
  String get history => 'Cronologia';

  @override
  String get overview => 'Panoramica';

  @override
  String get sessions => 'Sessioni';

  @override
  String get avg => 'Media';

  @override
  String get noHistoryYet => 'Nessuna cronologia ancora';

  @override
  String get completeSessionToSeeProgress =>
      'Completa una sessione per vedere i progressi';

  @override
  String today(String time) {
    return 'Oggi $time';
  }

  @override
  String get yesterday => 'Ieri';

  @override
  String daysAgo(int days) {
    return '$days giorni fa';
  }

  @override
  String cyclesAndDuration(int cycles, int duration) {
    return '$cycles cicli • ${duration}s';
  }

  @override
  String get noTraining => 'Nessun allenamento';

  @override
  String secondsUnit(int value) {
    return '${value}s';
  }

  @override
  String cyclesUnit(String value) {
    return '${value}c';
  }

  @override
  String get resetPassword => 'Reimposta password';

  @override
  String get enterEmailToGetResetCode =>
      'Inserisci e-mail per ottenere il codice di reset';

  @override
  String get sendCode => 'Invia codice';

  @override
  String get passwordResetCodeSent =>
      'Codice di reset password inviato alla tua e-mail';

  @override
  String get verifyEmail => 'Verifica e-mail';

  @override
  String get checkYourEmail => 'Controlla la tua e-mail';

  @override
  String codeSentTo(String email) {
    return 'Codice inviato a $email';
  }

  @override
  String get verificationCode => 'Codice di verifica';

  @override
  String get createAccount => 'Crea account';

  @override
  String resendInSeconds(int seconds) {
    return 'Reinvia tra ${seconds}s';
  }

  @override
  String get resendCode => 'Reinvia codice';

  @override
  String get newCodeSentToEmail => 'Nuovo codice inviato alla tua e-mail';

  @override
  String get enterVerificationCode => 'Inserisci codice di verifica';

  @override
  String get deleteAccountTitle => 'Elimina account';

  @override
  String get verifyDeletion => 'Verifica eliminazione';

  @override
  String get permanentDeleteWarning =>
      'Questo eliminerà definitivamente il tuo account e tutti i dati.';

  @override
  String get deletionConsequences =>
      '• Tutti i dati di allenamento andranno persi\\n• Le impostazioni di sincronizzazione verranno cancellate\\n• Questa azione non può essere annullata';

  @override
  String get iUnderstandContinue => 'Capisco, continua';

  @override
  String accountEmail(String email) {
    return 'Account: $email';
  }

  @override
  String get sendVerificationCodeDescription =>
      'Invieremo un codice di verifica per confermare questa azione.';

  @override
  String get sendVerificationCode => 'Invia codice di verifica';

  @override
  String get noUserEmailFound =>
      'Nessuna e-mail utente trovata. Per favore accedi di nuovo.';

  @override
  String verificationCodeSentTo(String email) {
    return 'Codice di verifica inviato a $email';
  }

  @override
  String get accountDataCleared =>
      'Dati account cancellati. Sei stato disconnesso.';

  @override
  String get failedToDeleteAccount => 'Eliminazione account fallita. Riprova.';

  @override
  String get newPassword => 'Nuova password';

  @override
  String get enterCode => 'Inserisci codice';

  @override
  String get chooseStrongPassword => 'Scegli una password forte';

  @override
  String get code => 'Codice';

  @override
  String get confirm => 'Conferma';

  @override
  String get verify => 'Verifica';

  @override
  String get update => 'Aggiorna';

  @override
  String get resendCode2 => 'Reinvia codice';

  @override
  String get pleaseEnterPassword => 'Per favore inserisci una password';

  @override
  String get passwordMinLength => 'La password deve avere almeno 6 caratteri';

  @override
  String get passwordUppercase =>
      'La password deve contenere almeno una lettera maiuscola';

  @override
  String get passwordLowercase =>
      'La password deve contenere almeno una lettera minuscola';

  @override
  String get passwordNumber => 'La password deve contenere almeno un numero';

  @override
  String get pleaseConfirmPassword => 'Per favore conferma la password';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono';

  @override
  String get passwordRequirements => 'Requisiti password:';

  @override
  String get atLeast6Characters => 'Almeno 6 caratteri';

  @override
  String get oneUppercaseLetter => 'Una lettera maiuscola';

  @override
  String get oneLowercaseLetter => 'Una lettera minuscola';

  @override
  String get oneNumber => 'Un numero';

  @override
  String get pleaseEnterVerificationCode =>
      'Per favore inserisci il codice di verifica';

  @override
  String get codeVerifiedCreatePassword =>
      'Codice verificato! Ora crea la tua nuova password.';

  @override
  String get newVerificationCodeSent =>
      'Nuovo codice di verifica inviato alla tua e-mail';

  @override
  String get breathTraining => 'Allenamento respiratorio';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get timer => 'Timer';

  @override
  String get newExercise => 'Nuovo esercizio';

  @override
  String exerciseSummary(int cycles, int duration) {
    return '$cycles cicli • ${duration}s durata';
  }

  @override
  String failedToExportExercise(String error) {
    return 'Esportazione esercizio fallita: $error';
  }

  @override
  String failedToImportExercise(String error) {
    return 'Importazione esercizio fallita: $error';
  }

  @override
  String confirmDeleteExercise(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"?';
  }
}
