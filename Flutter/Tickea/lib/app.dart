import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';

class TickeaApp extends StatelessWidget {
  const TickeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      title: 'TICKea',
      theme: ThemeData.dark(),
    );
  }
}
