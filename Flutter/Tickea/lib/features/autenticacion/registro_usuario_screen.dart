import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/widgets/app_componentes.dart';
import 'package:tickea/widgets/app_popups.dart';

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
      //Cierra el teclado por si el usuario lo dejó abierto
      FocusScope.of(context).unfocus();

      //Validación de campos vacíos
      if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty || repasswordCtrl.text.isEmpty || userCtrl.text.isEmpty) {
        setState(() {
          /*AppPopup.popupDosBotones(
              context: context,
              titulo: ,
              contenido: 'Rellena todos los campos obligatorios',
              goBotonA: '/register',
              goBotonB: '/login',
              exito: false,
              textoIr: 'Reintentar',
              textoVolver: 'Login')*/
          AppPopup.confirmacion(
            context: context,
            titulo: '⚠️ ¡¡Cuidado!!',
            contenido: 'Rellena todos los campos obligatorios',
            textoSi: 'Reintentar',
            onSi: () async {
              Navigator.of(context).pop();
            },
            textoNo: 'Inicio',
            onNo: () async {
              context.go('/login');
            },
          );
        });
        return;
      }

      //Validación de contraseñas que no coinciden
      if (passwordCtrl.text != repasswordCtrl.text) {
        setState(() {
          mensaje = '❌ Las contraseñas no coinciden';
        });
        return;
      }

      //Registro del usuario en Firebase Authentication
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      //UID único del usuario creado
      final uid = credential.user!.uid;

      //Datos a guardar en Firestore (colección 'users')
      final userData = {
        'email': emailCtrl.text.trim(),
        'usuario': userCtrl.text.trim(),
        'telefono': phoneCtrl.text.trim(),
        'fechaRegistro': Timestamp.now(),
      };

      //Guardamos el documento en Firestore con el UID como ID
      await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);

      // 🧹 Limpiamos los campos del formulario
      clearFields();

      // 🎉 Mensaje de éxito
      setState(() {
        mensaje = '🎉 Usuario creado con éxito';
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          mensaje = '⚠️ Este correo ya está registrado';
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          mensaje = '❗ Formato de email inválido';
        });
      } else if (e.code == 'weak-password') {
        setState(() {
          mensaje = '🔒 La contraseña es demasiado débil. Necesitas al menos 6 caracteres';
        });
      } else {
        setState(() {
          mensaje = '❌ Error al registrarse: ${e.message}';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = '💥 Error inesperado: ${e.toString()}';
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
      backgroundColor: AppColores.fondo,
      appBar: const AppCabecero(
        ruta: '/login',
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /*TextField(
              controller: userCtrl,
              decoration: const InputDecoration(labelText: 'Usuario *'),
            ),*/
            AppCampoTexto(
              tamAncho: double.infinity,
              titulo: 'Usuario *',
              controlador: userCtrl,
            ),
            AppCampoTexto(
              tamAncho: double.infinity,
              titulo: 'Telefono',
              controlador: phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            /*TextField(
              keyboardType: TextInputType.phone,
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Telefono'),
            ),*/
            AppCampoTexto(
              tamAncho: double.infinity,
              titulo: 'Email *',
              controlador: emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            /*TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email *'),
            ),*/
            AppCampoTexto(
              tamAncho: double.infinity,
              titulo: 'Contraseña *',
              controlador: passwordCtrl,
              modoClave: true,
            ),
            /*TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: 'Contraseña *'),
              obscureText: true,
            ),*/
            AppCampoTexto(
              tamAncho: double.infinity,
              titulo: 'Repite Contraseña *',
              controlador: repasswordCtrl,
              modoClave: true,
            ),
            /*TextField(
              controller: repasswordCtrl,
              decoration: const InputDecoration(labelText: 'Repite Contraseña *'),
              obscureText: true,
            ),*/
            const SizedBox(height: AppTamanios.xxxl),
            AppBotonPrimario(
              texto: 'Aceptar',
              onPressed: register,
              tamAncho: double.infinity,
              tamAlto: AppTamanios.xxxl,
            ),
            /*ElevatedButton(onPressed: register, child: const Text('Aceptar')),*/
            const SizedBox(height: AppTamanios.md),
            TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: AppTexto.textoNotaM('¿Ya tienes cuenta? Inicia sesión')
                //const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
            const SizedBox(height: 16),
            AppTexto.textoError(mensaje),
            //Text(mensaje, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
