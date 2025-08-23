import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tickea/features/nuevo_registro/nuevo_registro_screen.dart';
import 'package:tickea/features/historico/historico_screen.dart';
import 'package:tickea/features/login/login_screen.dart';
import 'package:tickea/features/principal/principal_screen.dart';
import 'package:tickea/features/register/register_screen.dart';
import 'package:tickea/features/splash/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/nuevoRegistro',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),
    GoRoute(
      path: '/principal',
      builder: (BuildContext context, GoRouterState state) {
        return const PrincipalScreen();
      },
    ),
    GoRoute(
      path: '/nuevoRegistro',
      builder: (BuildContext context, GoRouterState state) {
        return const NuevoRegistroScreen();
      },
    ),
    GoRoute(
      path: '/historico',
      builder: (BuildContext context, GoRouterState state) {
        return const HistoricoScreen();
      },
    ),
  ],
);
