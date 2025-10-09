import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/widgets/app_popups.dart';
import 'package:tickea/widgets/app_componentes.dart';
import '../registro/registro_provider.dart';
import 'package:tickea/features/registro/registro_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final uidCtrl = TextEditingController();
  String mensaje = '';
  String uidUser = '';

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );
      if (FirebaseAuth.instance.currentUser != null) {
        uidUser = FirebaseAuth.instance.currentUser!.uid;
      }
      if (mounted) {
        Provider.of<RegistroProvider>(context, listen: false).setUidUser(uidUser);
      }

      ///TODO: meter un spinner de carga para la espera
      const CircularProgressIndicator();
      goToPrincipal();
    } on FirebaseAuthException catch (e) {
      setState(
        () {
          AppPopup.confirmacion(
            context: context,
            titulo: '💥 Ups!',
            contenido: 'Error al iniciar sesión: ${e.message}',
            textoSi: 'Registrarse',
            onSi: () async {
              context.go('/register');
            },
            textoNo: 'Volver',
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

              ///TODO: meter un spinner de carga para la espera
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
