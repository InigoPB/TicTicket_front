import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/login/login_screen.dart';
import '../../features/principal/principal_screen.dart';
import '../../features/register/register_screen.dart';
import '../../features/splash/splash_screen.dart';

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
  ],
);
