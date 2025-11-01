import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tickea/core/theme/app_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/tickea_logo.png', height: 100),
            const SizedBox(height: 20),
            const Text("Cargando TICKea...", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: AppColores.primario,
            ),
          ],
        ),
      ),
    );
  }
}
