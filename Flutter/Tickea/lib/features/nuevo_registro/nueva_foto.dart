import 'package:provider/provider.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/widgets/app_componentes.dart';

import '../registro/registro_provider.dart';
import 'package:flutter/material.dart';

class NuevaFoto extends StatefulWidget {
  const NuevaFoto({super.key});

  @override
  State<NuevaFoto> createState() => _NuevaFotoState();
}

class _NuevaFotoState extends State<NuevaFoto> {
  @override
  void initState() {
    super.initState();
    final prov = context.read<RegistroProvider>();
    debugPrint('[NuevaFoto] Fecha=${prov.strFecha}, Carpeta=${prov.tempDirPath}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppCabecero(),
      body: Center(
        child: AppTexto.titulo('Foto'),
      ),
    );
  }
}
