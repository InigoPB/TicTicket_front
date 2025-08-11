// Archivo: lib/core/widgets/app_componentes.dart

import 'package:flutter/material.dart';
import 'package:tickea/core/theme/app_styles.dart';

// Botón Primario
class AppBotonPrimario extends StatelessWidget {
  final double tamAncho;
  final double tamAlto;
  final String texto;
  final VoidCallback onPressed;

  const AppBotonPrimario({
    super.key,
    required this.tamAncho,
    required this.tamAlto,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamAncho,
      height: tamAlto,
      child: ElevatedButton(
        style: ButtonStyle(
          // Fondo dinámico según estado
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColores.secundario;
            }
            return AppColores.primario;
          }),

          // Borde dinámico según estado
          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
            final color = states.contains(WidgetState.pressed) ? AppColores.secundariOscuro : AppColores.primariOscuro;
            return BorderSide(color: color, width: 2.0);
          }),

          // Sombra ligera
          elevation: WidgetStateProperty.all(4),
          shadowColor: WidgetStateProperty.all(AppColores.primariOscuro.withOpacity(0.8)),

          // Forma del botón
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTamanios.sm),
            ),
          ),

          // Brillo al pulsar
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColores.secundario.withOpacity(0.15);
            }
            return null;
          }),
        ),
        onPressed: onPressed,
        child: AppTexto.textoBoton(texto, align: TextAlign.center),
      ),
    );
  }
}

// Texto superior + botón con imagen intercambiable
class AppBotonImagen extends StatefulWidget {
  final double tamAncho;
  final double tamAlto;
  final String textoTitulo;
  final String imagenNormal;
  final String imagenPulsado;
  final VoidCallback onPressed;
  final Color? color;

  const AppBotonImagen({
    super.key,
    required this.tamAncho,
    required this.tamAlto,
    required this.textoTitulo,
    required this.imagenNormal,
    required this.imagenPulsado,
    required this.onPressed,
    this.color,
  });

  @override
  State<AppBotonImagen> createState() => _AppBotonImagenState();
}

class _AppBotonImagenState extends State<AppBotonImagen> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center, // 👈 centra verticalmente dentro de su contenedor padre
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() => _presionado = true),
            onTapUp: (_) {
              setState(() => _presionado = false);
              widget.onPressed();
            },
            onTapCancel: () => setState(() => _presionado = false),
            child: Container(
              width: widget.tamAncho,
              height: widget.tamAlto,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: _presionado ? AppColores.fondo : AppColores.secundario,
                  width: _presionado ? 1 : 3,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _presionado ? widget.imagenPulsado : widget.imagenNormal,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppTamanios.sm),
            child: AppTexto.titulo(widget.textoTitulo, color: _presionado ? AppColores.secundariOscuro : null),
          ),
        ],
      ),
    );
  }
}

// Campo de texto con estilo TICKea
class AppCampoTexto extends StatefulWidget {
  final double tamAncho;
  final String titulo;
  final TextEditingController controlador;
  final bool modoClave;

  const AppCampoTexto({
    super.key,
    required this.tamAncho,
    required this.titulo,
    required this.controlador,
    this.modoClave = false,
  });

  @override
  State<AppCampoTexto> createState() => _AppCampoTextoState();
}

class _AppCampoTextoState extends State<AppCampoTexto> {
  late FocusNode _focusNode;
  bool estaActivo = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        estaActivo = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // el dispose lo metemos para resetear, limpia para no dejar cosas por el camino y ahorrar memoria.
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorBorde = estaActivo ? AppColores.secundario : AppColores.grisClaro;
    final colorTitulo = estaActivo ? AppColores.primario : AppColores.grisClaro;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppTamanios.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppTamanios.xs),
            child: AppTexto.subtitulo(widget.titulo, align: TextAlign.start, color: colorTitulo),
          ),
          Container(
            width: widget.tamAncho,
            height: 48,
            decoration: BoxDecoration(
              color: AppColores.falsoBlanco,
              borderRadius: BorderRadius.circular(AppTamanios.sm),
              border: Border.all(
                color: colorBorde,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controlador,
              style: AppEstiloTexto.cuerpo,
              obscureText: widget.modoClave,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
