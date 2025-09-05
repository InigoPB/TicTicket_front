import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/registro/registro_provider.dart'; // Aqui usamos go_router y montamos la app
import 'package:provider/provider.dart';
import 'package:tickea/core/ocr/captura_proveedor.dart';

//Vamos a usar app.dart solo para iniciar la aplicación a partir de aqi se irá, "repartiendo" las diferentes acciones.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //es asincrono porque queremos que flutter espere a firebese para arrancar
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // opcional (volteado vertical)
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegistroProvider()),
        ChangeNotifierProvider(create: (_) => CapturaProveedor()),
      ],
      child: const TickeaApp(),
    ),
  );
}
