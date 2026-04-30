import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'YomuGo'**
  String get appTitle;

  /// No description provided for @authTabLogin.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authTabLogin;

  /// No description provided for @authTabRegister.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authTabRegister;

  /// No description provided for @authHeadline.
  ///
  /// In es, this message translates to:
  /// **'Aprende japonés a tu ritmo'**
  String get authHeadline;

  /// No description provided for @authSubheadline.
  ///
  /// In es, this message translates to:
  /// **'Practica con IA, refuerza con minijuegos y sigue tu progreso en tiempo real.'**
  String get authSubheadline;

  /// No description provided for @authFeatureChatAi.
  ///
  /// In es, this message translates to:
  /// **'Chat IA para practicar conversación'**
  String get authFeatureChatAi;

  /// No description provided for @authFeatureMiniGames.
  ///
  /// In es, this message translates to:
  /// **'12 minijuegos educativos'**
  String get authFeatureMiniGames;

  /// No description provided for @authFeatureProgress.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento de progreso detallado'**
  String get authFeatureProgress;

  /// No description provided for @authFeatureLessons.
  ///
  /// In es, this message translates to:
  /// **'Lecciones estructuradas por nivel'**
  String get authFeatureLessons;

  /// No description provided for @authQuoteJa.
  ///
  /// In es, this message translates to:
  /// **'千里の道も一歩から'**
  String get authQuoteJa;

  /// No description provided for @authQuoteSub.
  ///
  /// In es, this message translates to:
  /// **'— Un viaje de mil millas comienza con un solo paso.'**
  String get authQuoteSub;

  /// No description provided for @authFormTitleRegister.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get authFormTitleRegister;

  /// No description provided for @authFormSubtitleRegister.
  ///
  /// In es, this message translates to:
  /// **'Empieza tu viaje con el japonés hoy'**
  String get authFormSubtitleRegister;

  /// No description provided for @authFormTitleLogin.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get authFormTitleLogin;

  /// No description provided for @authFormSubtitleLogin.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para continuar'**
  String get authFormSubtitleLogin;

  /// No description provided for @authLabelUsername.
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario'**
  String get authLabelUsername;

  /// No description provided for @authHintUsername.
  ///
  /// In es, this message translates to:
  /// **'Tu_nombre_de_usuario'**
  String get authHintUsername;

  /// No description provided for @authLabelEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authLabelEmail;

  /// No description provided for @authHintEmail.
  ///
  /// In es, this message translates to:
  /// **'tu@email.com'**
  String get authHintEmail;

  /// No description provided for @authLabelPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authLabelPassword;

  /// No description provided for @authHintPassword.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get authHintPassword;

  /// No description provided for @authLabelPasswordConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get authLabelPasswordConfirm;

  /// No description provided for @authHintPasswordConfirm.
  ///
  /// In es, this message translates to:
  /// **'Repite tu contraseña'**
  String get authHintPasswordConfirm;

  /// No description provided for @authLabelIdentifier.
  ///
  /// In es, this message translates to:
  /// **'Usuario o correo'**
  String get authLabelIdentifier;

  /// No description provided for @authHintIdentifier.
  ///
  /// In es, this message translates to:
  /// **'usuario o correo@ejemplo.com'**
  String get authHintIdentifier;

  /// No description provided for @authButtonRegister.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authButtonRegister;

  /// No description provided for @authButtonLogin.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get authButtonLogin;

  /// No description provided for @authLegalBeforeTerms.
  ///
  /// In es, this message translates to:
  /// **'Al crear una cuenta aceptas nuestros '**
  String get authLegalBeforeTerms;

  /// No description provided for @authTermsOfUse.
  ///
  /// In es, this message translates to:
  /// **'Términos de uso'**
  String get authTermsOfUse;

  /// No description provided for @authLegalBetweenTermsPrivacy.
  ///
  /// In es, this message translates to:
  /// **' y '**
  String get authLegalBetweenTermsPrivacy;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get authPrivacyPolicy;

  /// No description provided for @authLegalAfter.
  ///
  /// In es, this message translates to:
  /// **'.'**
  String get authLegalAfter;

  /// No description provided for @authInfoBox.
  ///
  /// In es, this message translates to:
  /// **'Al ingresar podrás configurar tu nivel inicial y personalizar tu experiencia de aprendizaje.'**
  String get authInfoBox;

  /// No description provided for @authApiResponseTitle.
  ///
  /// In es, this message translates to:
  /// **'Respuesta de la API'**
  String get authApiResponseTitle;

  /// No description provided for @authLoginComingSoon.
  ///
  /// In es, this message translates to:
  /// **'El inicio de sesión se conectará a la API en un siguiente paso.'**
  String get authLoginComingSoon;

  /// No description provided for @authLoading.
  ///
  /// In es, this message translates to:
  /// **'Enviando…'**
  String get authLoading;

  /// No description provided for @validationUsernameShort.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 2 caracteres'**
  String get validationUsernameShort;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Introduce un correo válido'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordShort.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get validationPasswordShort;

  /// No description provided for @validationPasswordMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get validationPasswordMatch;

  /// No description provided for @authUiLanguageTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cambiar idioma de la interfaz'**
  String get authUiLanguageTooltip;

  /// No description provided for @authLabelAccountLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma de tu cuenta'**
  String get authLabelAccountLanguage;

  /// No description provided for @authAccountLanguageDescription.
  ///
  /// In es, this message translates to:
  /// **'Se guardará en tu perfil para el contenido de estudio.'**
  String get authAccountLanguageDescription;

  /// No description provided for @authAccountLanguageEs.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get authAccountLanguageEs;

  /// No description provided for @authAccountLanguagePt.
  ///
  /// In es, this message translates to:
  /// **'Português'**
  String get authAccountLanguagePt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
