import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tickea/features/autenticacion/login_screen.dart';
import 'package:tickea/features/autenticacion/registro_usuario_screen.dart';
import 'package:tickea/features/nuevo_registro/calendario_screen.dart';
import 'package:tickea/features/historico/presentacion/historico_screen.dart';
import 'package:tickea/features/nuevo_registro/nueva_foto/nueva_foto.dart';
import 'package:tickea/features/principal/principal_screen.dart';
import 'package:tickea/features/splash/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
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
    GoRoute(
      path: '/nuevaFoto',
      name: 'nuevaFoto',
      builder: (BuildContext context, GoRouterState state) {
        return const NuevaFoto();
      },
    ),
  ],
);
