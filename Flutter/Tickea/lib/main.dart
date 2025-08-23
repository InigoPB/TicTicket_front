import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'app.dart'; // Aqui usamos go_router y montamos la app

//Vamos a usar app.dart solo para iniciar la aplicación a partir de aqi se irá, "repartiendo" las diferentes acciones.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //es asincrono porque queremos que flutter espere a firebese para arrancar
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // opcional (volteado vertical)
  ]);
  runApp(const TickeaApp());
}
