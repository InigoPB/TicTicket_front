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
  bool isOk = false;

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
          AppPopup.confirmacion(
            context: context,
            titulo: '¡¡Cuidado!!',
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
          mensaje = 'Las contraseñas no coinciden';
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

      //Guardamos el documento en Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);

      //Limpiamos los campos del formulario
      clearFields();

      //Mensaje de éxito
      setState(() {
        AppPopup.confirmacion(
          context: context,
          titulo: '✔️ Éxito',
          contenido: 'Usuario creado con éxito. Ya puedes iniciar sesión.',
          textoSi: 'Ir a Login',
          onSi: () async {
            context.go('/login');
          },
        );
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          mensaje = 'Este correo ya está registrado';
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          mensaje = 'Formato de email inválido';
        });
      } else if (e.code == 'weak-password') {
        setState(() {
          mensaje = 'La contraseña es demasiado débil. Necesitas al menos 6 caracteres';
        });
      } else {
        setState(() {
          mensaje = 'Error al registrarse: ${e.message}';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error inesperado: ${e.toString()}';
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
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColores.fondo,
      appBar: const AppCabecero(
        ruta: '/login',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
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
                    AppCampoTexto(
                      tamAncho: double.infinity,
                      titulo: 'Email *',
                      controlador: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    AppCampoTexto(
                      tamAncho: double.infinity,
                      titulo: 'Contraseña *',
                      controlador: passwordCtrl,
                      modoClave: true,
                    ),
                    AppCampoTexto(
                      tamAncho: double.infinity,
                      titulo: 'Repite Contraseña *',
                      controlador: repasswordCtrl,
                      modoClave: true,
                    ),
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
            ),
          );
        },
      ),
    );
  }
}
