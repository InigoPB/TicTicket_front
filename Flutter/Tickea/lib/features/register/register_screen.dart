import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController(); //crea un objeto para controlar el campo de texto con texteditingcontroller
  final passwordCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final repasswordCtrl = TextEditingController();
  String mensaje = '';

  void clearFields() {
    emailCtrl.clear();
    passwordCtrl.clear();
    userCtrl.clear();
    phoneCtrl.clear();
    repasswordCtrl.clear();
  }

  Future<void> register() async {
    try {
      FocusScope.of(context).unfocus();

      if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty || repasswordCtrl.text.isEmpty) {
        setState(() {
          mensaje = '❗ Rellena todos los campos obligatorios';
        });
        return;
      }

      if (passwordCtrl.text != repasswordCtrl.text) {
        setState(() {
          mensaje = '❌ Las contraseñas no coinciden';
        });
        return;
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );
      setState(() {
        mensaje = '🎉 Usuario creado con éxito';
        clearFields();
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        mensaje = '❌ Error al registrarse: ${e.message}';
      });
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    userCtrl.dispose();
    phoneCtrl.dispose();
    repasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Registro TICKea')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: userCtrl,
              decoration: const InputDecoration(labelText: 'Usuario *'),
            ),
            TextField(
              keyboardType: TextInputType.phone,
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Telefono'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email *'),
            ),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: 'Contraseña *'),
              obscureText: true,
            ),
            TextField(
              controller: repasswordCtrl,
              decoration: const InputDecoration(labelText: 'Repite Contraseña *'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: register, child: const Text('Aceptar')),
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('¿Ya tienes cuenta? Inicia sesión'),
            ),
            const SizedBox(height: 16),
            Text(mensaje, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
