// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Bearth Таймер';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get enterEmail => 'Введите email';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get invalidEmailFormat => 'Неверный формат email';

  @override
  String get minCharacters => 'Минимум 6 символов';

  @override
  String get signUp => 'Регистрация';

  @override
  String get signIn => 'Вход';

  @override
  String get signOut => 'Выход';

  @override
  String get skip => 'Пропустить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Закрыть';

  @override
  String get back => 'Назад';

  @override
  String get loading => 'Загрузка...';

  @override
  String get syncDataAcrossDevices => 'Синхронизация данных между устройствами';

  @override
  String get accessDataAnywhere => 'Доступ к данным где угодно';

  @override
  String get haveAccountSignIn => 'Есть аккаунт? Войти';

  @override
  String get needAccountSignUp => 'Нужен аккаунт? Регистрация';

  @override
  String get forgot => 'Забыли?';

  @override
  String get emailSent => 'Письмо отправлено! Проверьте почту.';

  @override
  String get sendingEmail => 'Отправка письма...';

  @override
  String get signupEmailSent =>
      'Письмо для регистрации отправлено! Проверьте почту и установите пароль.';

  @override
  String get failedToSendEmail =>
      'Не удалось отправить письмо. Проверьте формат email.';

  @override
  String get supabaseNotConfigured => 'Supabase не настроен';

  @override
  String get updateSupabaseConstants =>
      'Обновите SupabaseConstants с URL проекта и анонимным ключом';

  @override
  String get settings => 'Настройки';

  @override
  String get account => 'Аккаунт';

  @override
  String get sync => 'Синхронизация';

  @override
  String get sound => 'Звук';

  @override
  String get dataManagement => 'Управление данными';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get about => 'О программе';

  @override
  String get signedInAs => 'Вы вошли как';

  @override
  String get unknownEmail => 'Неизвестный email';

  @override
  String get signOutDescription => 'Выйти и работать оффлайн';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountDescription => 'Навсегда удалить аккаунт и данные';

  @override
  String get workingOffline => 'Работа оффлайн';

  @override
  String get signInToSync => 'Войдите для синхронизации между устройствами';

  @override
  String get accessDataAnywhereButton => 'Доступ к данным где угодно';

  @override
  String get retrySync => 'Повторить синхронизацию';

  @override
  String get syncWithCloud => 'Синхронизация с облаком';

  @override
  String get exportData => 'Экспорт данных';

  @override
  String get saveDataToFile => 'Сохранить данные в файл';

  @override
  String get importData => 'Импорт данных';

  @override
  String get loadDataFromFile => 'Загрузить данные из файла';

  @override
  String get clearAllData => 'Очистить все данные';

  @override
  String get deleteAllDataPermanently => 'Навсегда удалить все данные';

  @override
  String get transitionSound => 'Звук переходов';

  @override
  String get playSoundWhenPhasesChange => 'Воспроизводить звук при смене фаз';

  @override
  String get darkMode => 'Темная тема';

  @override
  String get useDarkTheme => 'Использовать темную тему';

  @override
  String version(String version) {
    return 'Версия $version';
  }

  @override
  String get signOutConfirmTitle => 'Выход';

  @override
  String get signOutConfirmMessage =>
      'Вы уверены, что хотите выйти? Ваши данные останутся на этом устройстве.';

  @override
  String get clearAllDataConfirmTitle => 'Очистить все данные';

  @override
  String get clearAllDataConfirmMessage =>
      'Вы уверены, что хотите удалить все результаты тренировок? Это действие нельзя отменить и оно очистит данные со всех ваших устройств.';

  @override
  String get clearAll => 'Очистить все';

  @override
  String get exercises => 'Упражнения';

  @override
  String get importExercise => 'Импорт упражнения';

  @override
  String get addExercise => 'Добавить упражнение';

  @override
  String get noExercisesYet => 'Пока нет упражнений';

  @override
  String get createFirstExercise => 'Создайте первое упражнение';

  @override
  String get createYourFirstExercise => 'Create your first exercise';

  @override
  String get cycles => 'Циклы';

  @override
  String get duration => 'Продолжительность';

  @override
  String cycleDurationSeconds(int cycles, int duration) {
    return '$cycles циклов • $durationс продолжительность';
  }

  @override
  String get edit => 'Редактировать';

  @override
  String get duplicate => 'Дублировать';

  @override
  String get export => 'Экспорт';

  @override
  String errorLoadingExercises(String error) {
    return 'Ошибка загрузки упражнений: $error';
  }

  @override
  String get deleteExercise => 'Удалить упражнение';

  @override
  String deleteExerciseConfirm(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get exportFailed => 'Экспорт не удался';

  @override
  String failedToExport(String error) {
    return 'Не удалось экспортировать упражнение: $error';
  }

  @override
  String get importSuccessful => 'Импорт успешен';

  @override
  String get importFailed => 'Импорт не удался';

  @override
  String failedToImport(String error) {
    return 'Не удалось импортировать упражнение: $error';
  }

  @override
  String get exerciseDetails => 'Детали упражнения:';

  @override
  String get cycleDuration => 'Продолжительность цикла';

  @override
  String get totalDuration => 'Общая продолжительность';

  @override
  String get phases => 'Фазы';

  @override
  String get noDescriptionAvailable =>
      'Описание для этого упражнения недоступно.';

  @override
  String get description => 'Описание';

  @override
  String get customize => 'Настроить';

  @override
  String get time => 'Время';

  @override
  String get stop => 'Стоп';

  @override
  String get start => 'Старт';

  @override
  String cycleProgress(int current, int total) {
    return 'Цикл $current / $total';
  }

  @override
  String get oneClap => '1 хлопок';

  @override
  String clapsCount(int count) {
    return '$count хлопков';
  }

  @override
  String range(String range) {
    return 'Диапазон: $range';
  }

  @override
  String get name => 'Название';

  @override
  String get information => 'Информация';

  @override
  String get configuration => 'Конфигурация';

  @override
  String get min => 'Мин';

  @override
  String get max => 'Макс';

  @override
  String get step => 'Шаг';

  @override
  String get minimum => 'Минимум';

  @override
  String get current => 'Текущий';

  @override
  String get maximum => 'Максимум';

  @override
  String get total => 'Всего';

  @override
  String get addPhase => 'Добавить фазу';

  @override
  String get history => 'История';

  @override
  String get overview => 'Обзор';

  @override
  String get sessions => 'Сессии';

  @override
  String get avg => 'Среднее';

  @override
  String get noHistoryYet => 'Пока нет истории';

  @override
  String get completeSessionToSeeProgress =>
      'Завершите сессию, чтобы увидеть прогресс';

  @override
  String today(String time) {
    return 'Сегодня $time';
  }

  @override
  String get yesterday => 'Вчера';

  @override
  String daysAgo(int days) {
    return '$days дней назад';
  }

  @override
  String cyclesAndDuration(int cycles, int duration) {
    return '$cycles циклов • $durationс';
  }

  @override
  String get noTraining => 'Нет тренировок';

  @override
  String secondsUnit(int value) {
    return '$valueс';
  }

  @override
  String cyclesUnit(String value) {
    return '$valueц';
  }

  @override
  String get resetPassword => 'Сброс пароля';

  @override
  String get enterEmailToGetResetCode =>
      'Введите email для получения кода сброса';

  @override
  String get sendCode => 'Отправить код';

  @override
  String get passwordResetCodeSent =>
      'Код сброса пароля отправлен на вашу почту';

  @override
  String get verifyEmail => 'Подтвердить email';

  @override
  String get checkYourEmail => 'Проверьте вашу почту';

  @override
  String codeSentTo(String email) {
    return 'Код отправлен на $email';
  }

  @override
  String get verificationCode => 'Код подтверждения';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String resendInSeconds(int seconds) {
    return 'Повторить через $secondsс';
  }

  @override
  String get resendCode => 'Повторить код';

  @override
  String get newCodeSentToEmail => 'Новый код отправлен на вашу почту';

  @override
  String get enterVerificationCode => 'Введите код подтверждения';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт';

  @override
  String get verifyDeletion => 'Подтвердить удаление';

  @override
  String get permanentDeleteWarning =>
      'Это навсегда удалит ваш аккаунт и все данные.';

  @override
  String get deletionConsequences =>
      '• Все данные тренировок будут потеряны\\n• Настройки синхронизации будут очищены\\n• Это действие нельзя отменить';

  @override
  String get iUnderstandContinue => 'Я понимаю, продолжить';

  @override
  String accountEmail(String email) {
    return 'Аккаунт: $email';
  }

  @override
  String get sendVerificationCodeDescription =>
      'Мы отправим код подтверждения для подтверждения этого действия.';

  @override
  String get sendVerificationCode => 'Отправить код подтверждения';

  @override
  String get noUserEmailFound =>
      'Email пользователя не найден. Пожалуйста, войдите снова.';

  @override
  String verificationCodeSentTo(String email) {
    return 'Код подтверждения отправлен на $email';
  }

  @override
  String get accountDataCleared =>
      'Данные аккаунта очищены. Вы вышли из системы.';

  @override
  String get failedToDeleteAccount =>
      'Не удалось удалить аккаунт. Пожалуйста, попробуйте снова.';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get enterCode => 'Введите код';

  @override
  String get chooseStrongPassword => 'Выберите надежный пароль';

  @override
  String get code => 'Код';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get verify => 'Проверить';

  @override
  String get update => 'Обновить';

  @override
  String get resendCode2 => 'Повторить код';

  @override
  String get pleaseEnterPassword => 'Пожалуйста, введите пароль';

  @override
  String get passwordMinLength => 'Пароль должен содержать не менее 6 символов';

  @override
  String get passwordUppercase =>
      'Пароль должен содержать хотя бы одну заглавную букву';

  @override
  String get passwordLowercase =>
      'Пароль должен содержать хотя бы одну строчную букву';

  @override
  String get passwordNumber => 'Пароль должен содержать хотя бы одну цифру';

  @override
  String get pleaseConfirmPassword => 'Пожалуйста, подтвердите пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get passwordRequirements => 'Требования к паролю:';

  @override
  String get atLeast6Characters => 'Не менее 6 символов';

  @override
  String get oneUppercaseLetter => 'Одна заглавная буква';

  @override
  String get oneLowercaseLetter => 'Одна строчная буква';

  @override
  String get oneNumber => 'Одна цифра';

  @override
  String get pleaseEnterVerificationCode =>
      'Пожалуйста, введите код подтверждения';

  @override
  String get codeVerifiedCreatePassword =>
      'Код подтвержден! Теперь создайте новый пароль.';

  @override
  String get newVerificationCodeSent =>
      'Новый код подтверждения отправлен на вашу почту';

  @override
  String get breathTraining => 'Тренировка дыхания';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get timer => 'Таймер';

  @override
  String get newExercise => 'Новое упражнение';

  @override
  String exerciseSummary(int cycles, int duration) {
    return '$cycles циклов • $durationс продолжительность';
  }

  @override
  String failedToExportExercise(String error) {
    return 'Не удалось экспортировать упражнение: $error';
  }

  @override
  String failedToImportExercise(String error) {
    return 'Не удалось импортировать упражнение: $error';
  }

  @override
  String confirmDeleteExercise(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }
}
