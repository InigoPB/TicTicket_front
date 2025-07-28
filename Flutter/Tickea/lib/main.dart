import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart'; // Aquí usamos go_router y montamos la app

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TickeaApp());
}
