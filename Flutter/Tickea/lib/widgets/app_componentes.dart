// Archivo: lib/core/widgets/app_componentes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tickea/core/responsive/app_responsive.dart';
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
    bool autoFocus = false,
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
  final String? textoTitulo;
  final String imagenNormal;
  final String imagenPulsado;
  final VoidCallback onPressed;
  final bool? isBorde;

  const AppBotonImagen({
    super.key,
    required this.tamAncho,
    required this.tamAlto,
    this.textoTitulo,
    required this.imagenNormal,
    required this.imagenPulsado,
    required this.onPressed,
    this.isBorde = true, // Si no se quiere borde, se puede pasar false
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
                border: widget.isBorde!
                    ? Border.all(
                        color: _presionado ? AppColores.fondo : AppColores.secundario,
                        width: _presionado ? 1 : 3,
                      )
                    : null,
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
          if ((widget.textoTitulo ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTamanios.sm),
              child: AppTexto.titulo(
                widget.textoTitulo!,
              ), /*Ojo este que bonito:
              decimos que si el titulo existe pinta el titulo, sino, lo pinta vacio;
              En la misma orden Trimeamos y le decimos que si contiene algo, pinte ese algo
              haciendo su widget. aseguramos que va a ir un widget aunque antes venga null porque en caso
              de ser null le hemos dicho que será un campo vacio y en caso de ser un campo vacio,
              no creará widget... */
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

SnackBar snackBarTickea({required Color colorFondo, required String texto}) {
  return SnackBar(
    content: Text(texto),
    backgroundColor: colorFondo,
    duration: const Duration(seconds: 3),
  );
}

class AppCabecero extends StatelessWidget implements PreferredSizeWidget {
  //Vamos a intentar hacerlo responsive para otros tamaños.
  const AppCabecero({
    super.key,
    this.mostrarAtras = true,
    this.onAtras,
    this.backgroundColor = AppColores.fondo,
    this.alturaBase = 64.0,
    this.logoAsset = 'assets/img/logo_bar.png',
  });

  final bool mostrarAtras;
  final VoidCallback? onAtras;
  final Color backgroundColor;
  final double alturaBase;
  final String logoAsset;

  @override
  Size get preferredSize => Size.fromHeight(alturaBase);

  @override
  Widget build(BuildContext context) {
    final escalaTexto = MediaQuery.of(context).textScaler.scale(1.0).clamp(1.0, 1.2);
    final alto = preferredSize.height;
    final flechaH = (40.0).clamp(32.0, 48.0);
    final flechaW = (64.0).clamp(56.0, 72.0);

    return SafeArea(
      top: true,
      child: Container(
        height: alto,
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).padding.left + AppTamanios.md,
          right: MediaQuery.of(context).padding.right + AppTamanios.md,
        ), //EdgeInsets.symmetric(horizontal: paddingH),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: const Border(
            bottom: BorderSide(
              color: AppColores.grisClaro,
              style: BorderStyle.solid, // solid
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Izquierda: botón atrás (opcional)
            if (mostrarAtras)
              AppBotonImagen(
                tamAncho: flechaH,
                tamAlto: flechaH,
                isBorde: false,
                imagenNormal: 'assets/img/flecha_1.png',
                imagenPulsado: 'assets/img/flecha_2.png',
                onPressed: onAtras ??
                    () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/principal');
                      }
                    },
              )
            else
              SizedBox(width: flechaW + AppTamanios.sm), // Espacio porsi flecha no está
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tickea',
                  style: AppEstiloTexto.subtitulo.copyWith(
                    fontSize: (AppTamanios.md * escalaTexto).clamp(14, 18),
                    color: AppColores.primario,
                  ),
                ),
                const SizedBox(width: AppTamanios.base),
                Image.asset(logoAsset),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
