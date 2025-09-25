import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/widgets/app_popups.dart';
import '../../widgets/app_componentes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String mensaje = '';

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      goToPrincipal();
    } on FirebaseAuthException catch (e) {
      setState(
        () {
          /*AppPopup.popupDosBotones(
              context: context,
              contenido: 'Error al iniciar sesión: ${e.message}',
              exito: false,
              goBotonA: '/register',
              goBotonB: '/login',
              textoIr: "Registrarse",
              textoVolver: "Volver",
              titulo: '💥');*/
          AppPopup.confirmacion(
            context: context,
            titulo: '💥 Ups!',
            contenido: 'Error al iniciar sesión: ${e.message}',
            textoSi: 'Registrarse',
            onSi: () async {
              context.go('/register');
            },
            textoNo: 'Volver',
            onNo: () async {
              Navigator.of(context).pop();
            },
          );
        },
      );
      return;
    }
  }

  void goToRegister() {
    context.go('/register');
  }

  void goToPrincipal() {
    context.go('/principal');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppCabecero(
        mostrarAtras: false,
      ),
      backgroundColor: AppColores.fondo,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCampoTexto(
              controlador: emailCtrl,
              tamAncho: double.infinity,
              titulo: 'EMAIL',
            ),
            const SizedBox(height: 8),
            AppCampoTexto(
              controlador: passwordCtrl,
              tamAncho: double.infinity,
              titulo: 'CONTRASEÑA',
              modoClave: true,
            ),
            const SizedBox(height: 24),
            AppBotonPrimario(
              //Btn de inicio
              tamAncho: 240,
              tamAlto: 48,
              texto: 'Inicio',
              onPressed: login,
            ),
            const SizedBox(height: 24),
            AppBotonPrimario(
              //Btn de Registro
              tamAncho: 240,
              tamAlto: 48,
              texto: 'Registrarse',
              onPressed: goToRegister,
            ),
            const SizedBox(height: 20),
            Text(mensaje, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
