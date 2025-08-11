// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Bearth Timer';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get enterEmail => 'Ingrese el correo';

  @override
  String get enterPassword => 'Ingrese la contraseña';

  @override
  String get invalidEmailFormat => 'Formato de correo inválido';

  @override
  String get minCharacters => 'Mín 6 caracteres';

  @override
  String get signUp => 'Registrarse';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get skip => 'Omitir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get ok => 'Aceptar';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Volver';

  @override
  String get loading => 'Cargando...';

  @override
  String get syncDataAcrossDevices => 'Sincronizar datos entre dispositivos';

  @override
  String get accessDataAnywhere => 'Acceder a datos en cualquier lugar';

  @override
  String get haveAccountSignIn => '¿Tienes cuenta? Iniciar sesión';

  @override
  String get needAccountSignUp => '¿Necesitas cuenta? Registrarse';

  @override
  String get forgot => '¿Olvidaste?';

  @override
  String get emailSent => '¡Correo enviado! Revisa tu bandeja de entrada.';

  @override
  String get sendingEmail => 'Enviando correo...';

  @override
  String get signupEmailSent =>
      '¡Correo de registro enviado! Revisa tu bandeja de entrada y establece tu contraseña.';

  @override
  String get failedToSendEmail =>
      'Error al enviar correo. Verifica el formato del correo.';

  @override
  String get supabaseNotConfigured => 'Supabase no configurado';

  @override
  String get updateSupabaseConstants =>
      'Actualiza SupabaseConstants con la URL de tu proyecto y la clave anónima';

  @override
  String get settings => 'Configuración';

  @override
  String get account => 'Cuenta';

  @override
  String get sync => 'Sincronización';

  @override
  String get sound => 'Sonido';

  @override
  String get dataManagement => 'Gestión de datos';

  @override
  String get appearance => 'Apariencia';

  @override
  String get about => 'Acerca de';

  @override
  String get signedInAs => 'Sesión iniciada como';

  @override
  String get unknownEmail => 'Correo desconocido';

  @override
  String get signOutDescription => 'Cerrar sesión y trabajar sin conexión';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountDescription =>
      'Eliminar permanentemente la cuenta y los datos';

  @override
  String get workingOffline => 'Trabajando sin conexión';

  @override
  String get signInToSync =>
      'Inicia sesión para sincronizar entre dispositivos';

  @override
  String get accessDataAnywhereButton => 'Acceder a datos en cualquier lugar';

  @override
  String get retrySync => 'Reintentar sincronización';

  @override
  String get syncWithCloud => 'Sincronizar con la nube';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get saveDataToFile => 'Guardar datos en archivo';

  @override
  String get importData => 'Importar datos';

  @override
  String get loadDataFromFile => 'Cargar datos desde archivo';

  @override
  String get clearAllData => 'Limpiar todos los datos';

  @override
  String get deleteAllDataPermanently =>
      'Eliminar todos los datos permanentemente';

  @override
  String get transitionSound => 'Sonido de transición';

  @override
  String get playSoundWhenPhasesChange =>
      'Reproducir sonido cuando cambien las fases';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get useDarkTheme => 'Usar tema oscuro';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get signOutConfirmTitle => 'Cerrar sesión';

  @override
  String get signOutConfirmMessage =>
      '¿Estás seguro de que quieres cerrar sesión? Tus datos permanecerán en este dispositivo.';

  @override
  String get clearAllDataConfirmTitle => 'Limpiar todos los datos';

  @override
  String get clearAllDataConfirmMessage =>
      '¿Estás seguro de que quieres eliminar todos los resultados de entrenamiento? Esta acción no se puede deshacer y borrará datos de todos tus dispositivos.';

  @override
  String get clearAll => 'Limpiar todo';

  @override
  String get exercises => 'Ejercicios';

  @override
  String get importExercise => 'Importar ejercicio';

  @override
  String get addExercise => 'Añadir ejercicio';

  @override
  String get noExercisesYet => 'Aún no hay ejercicios';

  @override
  String get createFirstExercise => 'Crea tu primer ejercicio';

  @override
  String get createYourFirstExercise => 'Create your first exercise';

  @override
  String get cycles => 'Ciclos';

  @override
  String get duration => 'Duración';

  @override
  String cycleDurationSeconds(int cycles, int duration) {
    return '$cycles ciclos • ${duration}s duración';
  }

  @override
  String get edit => 'Editar';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get export => 'Exportar';

  @override
  String errorLoadingExercises(String error) {
    return 'Error cargando ejercicios: $error';
  }

  @override
  String get deleteExercise => 'Eliminar ejercicio';

  @override
  String deleteExerciseConfirm(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"?';
  }

  @override
  String get exportFailed => 'Exportación fallida';

  @override
  String failedToExport(String error) {
    return 'Error al exportar ejercicio: $error';
  }

  @override
  String get importSuccessful => 'Importación exitosa';

  @override
  String get importFailed => 'Importación fallida';

  @override
  String failedToImport(String error) {
    return 'Error al importar ejercicio: $error';
  }

  @override
  String get exerciseDetails => 'Detalles del ejercicio:';

  @override
  String get cycleDuration => 'Duración del ciclo';

  @override
  String get totalDuration => 'Duración total';

  @override
  String get phases => 'Fases';

  @override
  String get noDescriptionAvailable =>
      'No hay descripción disponible para este ejercicio.';

  @override
  String get description => 'Descripción';

  @override
  String get customize => 'Personalizar';

  @override
  String get time => 'Tiempo';

  @override
  String get stop => 'Detener';

  @override
  String get start => 'Iniciar';

  @override
  String cycleProgress(int current, int total) {
    return 'Ciclo $current / $total';
  }

  @override
  String get oneClap => '1 palmada';

  @override
  String clapsCount(int count) {
    return '$count palmadas';
  }

  @override
  String range(String range) {
    return 'Rango: $range';
  }

  @override
  String get name => 'Nombre';

  @override
  String get information => 'Información';

  @override
  String get configuration => 'Configuración';

  @override
  String get min => 'Mín';

  @override
  String get max => 'Máx';

  @override
  String get step => 'Paso';

  @override
  String get minimum => 'Mínimo';

  @override
  String get current => 'Actual';

  @override
  String get maximum => 'Máximo';

  @override
  String get total => 'Total';

  @override
  String get addPhase => 'Añadir fase';

  @override
  String get history => 'Historial';

  @override
  String get overview => 'Resumen';

  @override
  String get sessions => 'Sesiones';

  @override
  String get avg => 'Promedio';

  @override
  String get noHistoryYet => 'Aún no hay historial';

  @override
  String get completeSessionToSeeProgress =>
      'Completa una sesión para ver el progreso';

  @override
  String today(String time) {
    return 'Hoy $time';
  }

  @override
  String get yesterday => 'Ayer';

  @override
  String daysAgo(int days) {
    return 'hace $days días';
  }

  @override
  String cyclesAndDuration(int cycles, int duration) {
    return '$cycles ciclos • ${duration}s';
  }

  @override
  String get noTraining => 'Sin entrenamiento';

  @override
  String secondsUnit(int value) {
    return '${value}s';
  }

  @override
  String cyclesUnit(String value) {
    return '${value}c';
  }

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get enterEmailToGetResetCode =>
      'Ingresa el correo para obtener el código de restablecimiento';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get passwordResetCodeSent =>
      'Código de restablecimiento de contraseña enviado a tu correo';

  @override
  String get verifyEmail => 'Verificar correo';

  @override
  String get checkYourEmail => 'Revisa tu correo';

  @override
  String codeSentTo(String email) {
    return 'Código enviado a $email';
  }

  @override
  String get verificationCode => 'Código de verificación';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String resendInSeconds(int seconds) {
    return 'Reenviar en ${seconds}s';
  }

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get newCodeSentToEmail => 'Nuevo código enviado a tu correo';

  @override
  String get enterVerificationCode => 'Ingresa el código de verificación';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get verifyDeletion => 'Verificar eliminación';

  @override
  String get permanentDeleteWarning =>
      'Esto eliminará permanentemente tu cuenta y todos los datos.';

  @override
  String get deletionConsequences =>
      '• Se perderán todos los datos de entrenamiento\\n• Se borrarán las configuraciones de sincronización\\n• Esta acción no se puede deshacer';

  @override
  String get iUnderstandContinue => 'Entiendo, continuar';

  @override
  String accountEmail(String email) {
    return 'Cuenta: $email';
  }

  @override
  String get sendVerificationCodeDescription =>
      'Enviaremos un código de verificación para confirmar esta acción.';

  @override
  String get sendVerificationCode => 'Enviar código de verificación';

  @override
  String get noUserEmailFound =>
      'No se encontró correo de usuario. Por favor inicia sesión nuevamente.';

  @override
  String verificationCodeSentTo(String email) {
    return 'Código de verificación enviado a $email';
  }

  @override
  String get accountDataCleared =>
      'Datos de cuenta borrados. Has cerrado sesión.';

  @override
  String get failedToDeleteAccount =>
      'Error al eliminar cuenta. Por favor intenta nuevamente.';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get enterCode => 'Ingresar código';

  @override
  String get chooseStrongPassword => 'Elige una contraseña segura';

  @override
  String get code => 'Código';

  @override
  String get confirm => 'Confirmar';

  @override
  String get verify => 'Verificar';

  @override
  String get update => 'Actualizar';

  @override
  String get resendCode2 => 'Reenviar código';

  @override
  String get pleaseEnterPassword => 'Por favor ingresa una contraseña';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get passwordUppercase =>
      'La contraseña debe contener al menos una letra mayúscula';

  @override
  String get passwordLowercase =>
      'La contraseña debe contener al menos una letra minúscula';

  @override
  String get passwordNumber => 'La contraseña debe contener al menos un número';

  @override
  String get pleaseConfirmPassword => 'Por favor confirma tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordRequirements => 'Requisitos de contraseña:';

  @override
  String get atLeast6Characters => 'Al menos 6 caracteres';

  @override
  String get oneUppercaseLetter => 'Una letra mayúscula';

  @override
  String get oneLowercaseLetter => 'Una letra minúscula';

  @override
  String get oneNumber => 'Un número';

  @override
  String get pleaseEnterVerificationCode =>
      'Por favor ingresa el código de verificación';

  @override
  String get codeVerifiedCreatePassword =>
      '¡Código verificado! Ahora crea tu nueva contraseña.';

  @override
  String get newVerificationCodeSent =>
      'Nuevo código de verificación enviado a tu correo';

  @override
  String get breathTraining => 'Entrenamiento de respiración';

  @override
  String get unknown => 'Desconocido';

  @override
  String get timer => 'Temporizador';

  @override
  String get newExercise => 'Nuevo ejercicio';

  @override
  String exerciseSummary(int cycles, int duration) {
    return '$cycles ciclos • ${duration}s duración';
  }

  @override
  String failedToExportExercise(String error) {
    return 'Error al exportar ejercicio: $error';
  }

  @override
  String failedToImportExercise(String error) {
    return 'Error al importar ejercicio: $error';
  }

  @override
  String confirmDeleteExercise(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"?';
  }
}
