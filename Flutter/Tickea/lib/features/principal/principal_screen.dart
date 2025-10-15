import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/widgets/app_componentes.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  void goToRute(String ruta) {
    context.go(ruta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: const AppCabecero(
        ruta: '/login',
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppBotonImagen(
              tamAncho: 200,
              tamAlto: 200,
              textoTitulo: 'Nuevo Registro',
              imagenNormal: 'assets/img/icon_CAMARA_btn_inicio.png',
              imagenPulsado: 'assets/img/icon_CAMARA_btn_inicio_CLICK.png',
              onPressed: () => goToRute('/nuevoRegistro'),
            ),
            AppBotonImagen(
              tamAncho: 200,
              tamAlto: 200,
              textoTitulo: 'Historico',
              imagenNormal: 'assets/img/icon_CALENDARIO_btn_inicio.png',
              imagenPulsado: 'assets/img/icon_CALENDARIO_btn_inicio_CLICK.png',
              onPressed: () => goToRute('/historico'),
            ),
          ],
        ),
      ),
    );
  }
}
