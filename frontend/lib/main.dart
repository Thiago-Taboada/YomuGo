import 'package:flutter/material.dart';
import 'package:yomugo_frontend/l10n/app_localizations.dart';

import 'app/app_theme.dart';
import 'features/auth/auth_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YomuGoApp());
}

class YomuGoApp extends StatefulWidget {
  const YomuGoApp({super.key});

  @override
  State<YomuGoApp> createState() => _YomuGoAppState();
}

class _YomuGoAppState extends State<YomuGoApp> {
  Locale _locale = const Locale('es');

  void _toggleUiLocale() {
    setState(() {
      _locale = _locale.languageCode == 'es'
          ? const Locale('pt')
          : const Locale('es');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: buildDarkTheme(),
      home: AuthPage(onToggleUiLocale: _toggleUiLocale),
    );
  }
}
