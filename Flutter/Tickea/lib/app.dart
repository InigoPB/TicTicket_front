import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/routes/app_router.dart';

class TickeaApp extends StatelessWidget {
  const TickeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      title: 'Tickea',
      theme: ThemeData.dark().copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: Color(0xFF305252),
        ),
      ),
      //Para poder usar diferentes bibliotecas en español
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
