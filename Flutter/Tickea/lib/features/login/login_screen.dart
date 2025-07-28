import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      setState(() {
        mensaje = '✅ Login exitoso, bienvenido compi';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        mensaje = '💥 Error al iniciar sesión: ${e.message}';
      });
    }
  }

  Future<void> register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );
      setState(() {
        mensaje = '🎉 Usuario creado con éxito';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        mensaje = '❌ Error al registrarse: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tickea Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text('Iniciar sesión')),
            ElevatedButton(onPressed: register, child: const Text('Registrarse')),
            const SizedBox(height: 20),
            Text(mensaje, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
