// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Bearth Timer';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterEmail => 'Entrez l\'e-mail';

  @override
  String get enterPassword => 'Entrez le mot de passe';

  @override
  String get invalidEmailFormat => 'Format d\'e-mail invalide';

  @override
  String get minCharacters => 'Min 6 caractères';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get skip => 'Passer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get loading => 'Chargement...';

  @override
  String get syncDataAcrossDevices =>
      'Synchroniser les données entre appareils';

  @override
  String get accessDataAnywhere => 'Accéder aux données partout';

  @override
  String get haveAccountSignIn => 'Vous avez un compte ? Se connecter';

  @override
  String get needAccountSignUp => 'Besoin d\'un compte ? S\'inscrire';

  @override
  String get forgot => 'Oublié ?';

  @override
  String get emailSent => 'E-mail envoyé ! Vérifiez votre boîte de réception.';

  @override
  String get sendingEmail => 'Envoi de l\'e-mail...';

  @override
  String get signupEmailSent =>
      'E-mail d\'inscription envoyé ! Vérifiez votre boîte de réception et définissez votre mot de passe.';

  @override
  String get failedToSendEmail =>
      'Échec de l\'envoi de l\'e-mail. Vérifiez le format de l\'e-mail.';

  @override
  String get supabaseNotConfigured => 'Supabase non configuré';

  @override
  String get updateSupabaseConstants =>
      'Veuillez mettre à jour SupabaseConstants avec l\'URL de votre projet et la clé anonyme';

  @override
  String get settings => 'Paramètres';

  @override
  String get account => 'Compte';

  @override
  String get sync => 'Synchronisation';

  @override
  String get sound => 'Son';

  @override
  String get dataManagement => 'Gestion des données';

  @override
  String get appearance => 'Apparence';

  @override
  String get about => 'À propos';

  @override
  String get signedInAs => 'Connecté en tant que';

  @override
  String get unknownEmail => 'E-mail inconnu';

  @override
  String get signOutDescription => 'Se déconnecter et travailler hors ligne';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountDescription =>
      'Supprimer définitivement le compte et les données';

  @override
  String get workingOffline => 'Travail hors ligne';

  @override
  String get signInToSync => 'Connectez-vous pour synchroniser entre appareils';

  @override
  String get accessDataAnywhereButton => 'Accéder aux données partout';

  @override
  String get retrySync => 'Réessayer la synchronisation';

  @override
  String get syncWithCloud => 'Synchroniser avec le cloud';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get saveDataToFile => 'Enregistrer les données dans un fichier';

  @override
  String get importData => 'Importer les données';

  @override
  String get loadDataFromFile => 'Charger les données depuis un fichier';

  @override
  String get clearAllData => 'Effacer toutes les données';

  @override
  String get deleteAllDataPermanently =>
      'Supprimer définitivement toutes les données';

  @override
  String get transitionSound => 'Son de transition';

  @override
  String get playSoundWhenPhasesChange =>
      'Jouer un son lors des changements de phase';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get useDarkTheme => 'Utiliser le thème sombre';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get signOutConfirmTitle => 'Se déconnecter';

  @override
  String get signOutConfirmMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ? Vos données resteront sur cet appareil.';

  @override
  String get clearAllDataConfirmTitle => 'Effacer toutes les données';

  @override
  String get clearAllDataConfirmMessage =>
      'Êtes-vous sûr de vouloir supprimer tous les résultats d\'entraînement ? Cette action ne peut pas être annulée et effacera les données de tous vos appareils.';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get exercises => 'Exercices';

  @override
  String get importExercise => 'Importer un exercice';

  @override
  String get addExercise => 'Ajouter un exercice';

  @override
  String get noExercisesYet => 'Aucun exercice pour le moment';

  @override
  String get createFirstExercise => 'Créez votre premier exercice';

  @override
  String get createYourFirstExercise => 'Create your first exercise';

  @override
  String get cycles => 'Cycles';

  @override
  String get duration => 'Durée';

  @override
  String cycleDurationSeconds(int cycles, int duration) {
    return '$cycles cycles • ${duration}s durée';
  }

  @override
  String get edit => 'Modifier';

  @override
  String get duplicate => 'Dupliquer';

  @override
  String get export => 'Exporter';

  @override
  String errorLoadingExercises(String error) {
    return 'Erreur lors du chargement des exercices : $error';
  }

  @override
  String get deleteExercise => 'Supprimer l\'exercice';

  @override
  String deleteExerciseConfirm(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ?';
  }

  @override
  String get exportFailed => 'Échec de l\'exportation';

  @override
  String failedToExport(String error) {
    return 'Échec de l\'exportation de l\'exercice : $error';
  }

  @override
  String get importSuccessful => 'Importation réussie';

  @override
  String get importFailed => 'Échec de l\'importation';

  @override
  String failedToImport(String error) {
    return 'Échec de l\'importation de l\'exercice : $error';
  }

  @override
  String get exerciseDetails => 'Détails de l\'exercice :';

  @override
  String get cycleDuration => 'Durée du cycle';

  @override
  String get totalDuration => 'Durée totale';

  @override
  String get phases => 'Phases';

  @override
  String get noDescriptionAvailable =>
      'Aucune description disponible pour cet exercice.';

  @override
  String get description => 'Description';

  @override
  String get customize => 'Personnaliser';

  @override
  String get time => 'Temps';

  @override
  String get stop => 'Arrêter';

  @override
  String get start => 'Démarrer';

  @override
  String cycleProgress(int current, int total) {
    return 'Cycle $current / $total';
  }

  @override
  String get oneClap => '1 claquement';

  @override
  String clapsCount(int count) {
    return '$count claquements';
  }

  @override
  String range(String range) {
    return 'Plage : $range';
  }

  @override
  String get name => 'Nom';

  @override
  String get information => 'Information';

  @override
  String get configuration => 'Configuration';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get step => 'Étape';

  @override
  String get minimum => 'Minimum';

  @override
  String get current => 'Actuel';

  @override
  String get maximum => 'Maximum';

  @override
  String get total => 'Total';

  @override
  String get addPhase => 'Ajouter une phase';

  @override
  String get history => 'Historique';

  @override
  String get overview => 'Aperçu';

  @override
  String get sessions => 'Sessions';

  @override
  String get avg => 'Moyenne';

  @override
  String get noHistoryYet => 'Aucun historique pour le moment';

  @override
  String get completeSessionToSeeProgress =>
      'Terminez une session pour voir les progrès';

  @override
  String today(String time) {
    return 'Aujourd\'hui $time';
  }

  @override
  String get yesterday => 'Hier';

  @override
  String daysAgo(int days) {
    return 'il y a $days jours';
  }

  @override
  String cyclesAndDuration(int cycles, int duration) {
    return '$cycles cycles • ${duration}s';
  }

  @override
  String get noTraining => 'Aucun entraînement';

  @override
  String secondsUnit(int value) {
    return '${value}s';
  }

  @override
  String cyclesUnit(String value) {
    return '${value}c';
  }

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get enterEmailToGetResetCode =>
      'Entrez l\'e-mail pour obtenir le code de réinitialisation';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get passwordResetCodeSent =>
      'Code de réinitialisation du mot de passe envoyé à votre e-mail';

  @override
  String get verifyEmail => 'Vérifier l\'e-mail';

  @override
  String get checkYourEmail => 'Vérifiez votre e-mail';

  @override
  String codeSentTo(String email) {
    return 'Code envoyé à $email';
  }

  @override
  String get verificationCode => 'Code de vérification';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String resendInSeconds(int seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get newCodeSentToEmail => 'Nouveau code envoyé à votre e-mail';

  @override
  String get enterVerificationCode => 'Entrez le code de vérification';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get verifyDeletion => 'Vérifier la suppression';

  @override
  String get permanentDeleteWarning =>
      'Cela supprimera définitivement votre compte et toutes les données.';

  @override
  String get deletionConsequences =>
      '• Toutes les données d\'entraînement seront perdues\\n• Les paramètres de synchronisation seront effacés\\n• Cette action ne peut pas être annulée';

  @override
  String get iUnderstandContinue => 'Je comprends, continuer';

  @override
  String accountEmail(String email) {
    return 'Compte : $email';
  }

  @override
  String get sendVerificationCodeDescription =>
      'Nous enverrons un code de vérification pour confirmer cette action.';

  @override
  String get sendVerificationCode => 'Envoyer le code de vérification';

  @override
  String get noUserEmailFound =>
      'Aucun e-mail utilisateur trouvé. Veuillez vous reconnecter.';

  @override
  String verificationCodeSentTo(String email) {
    return 'Code de vérification envoyé à $email';
  }

  @override
  String get accountDataCleared =>
      'Données du compte effacées. Vous avez été déconnecté.';

  @override
  String get failedToDeleteAccount =>
      'Échec de la suppression du compte. Veuillez réessayer.';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get enterCode => 'Entrer le code';

  @override
  String get chooseStrongPassword => 'Choisissez un mot de passe fort';

  @override
  String get code => 'Code';

  @override
  String get confirm => 'Confirmer';

  @override
  String get verify => 'Vérifier';

  @override
  String get update => 'Mettre à jour';

  @override
  String get resendCode2 => 'Renvoyer le code';

  @override
  String get pleaseEnterPassword => 'Veuillez entrer un mot de passe';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get passwordUppercase =>
      'Le mot de passe doit contenir au moins une lettre majuscule';

  @override
  String get passwordLowercase =>
      'Le mot de passe doit contenir au moins une lettre minuscule';

  @override
  String get passwordNumber =>
      'Le mot de passe doit contenir au moins un chiffre';

  @override
  String get pleaseConfirmPassword => 'Veuillez confirmer votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordRequirements => 'Exigences du mot de passe :';

  @override
  String get atLeast6Characters => 'Au moins 6 caractères';

  @override
  String get oneUppercaseLetter => 'Une lettre majuscule';

  @override
  String get oneLowercaseLetter => 'Une lettre minuscule';

  @override
  String get oneNumber => 'Un chiffre';

  @override
  String get pleaseEnterVerificationCode =>
      'Veuillez entrer le code de vérification';

  @override
  String get codeVerifiedCreatePassword =>
      'Code vérifié ! Créez maintenant votre nouveau mot de passe.';

  @override
  String get newVerificationCodeSent =>
      'Nouveau code de vérification envoyé à votre e-mail';

  @override
  String get breathTraining => 'Entraînement respiratoire';

  @override
  String get unknown => 'Inconnu';

  @override
  String get timer => 'Minuteur';

  @override
  String get newExercise => 'Nouvel exercice';

  @override
  String exerciseSummary(int cycles, int duration) {
    return '$cycles cycles • ${duration}s durée';
  }

  @override
  String failedToExportExercise(String error) {
    return 'Échec de l\'exportation de l\'exercice : $error';
  }

  @override
  String failedToImportExercise(String error) {
    return 'Échec de l\'importation de l\'exercice : $error';
  }

  @override
  String confirmDeleteExercise(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ?';
  }
}
