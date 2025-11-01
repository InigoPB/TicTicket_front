import 'package:flutter/material.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/widgets/app_componentes.dart';

class BotonOnOff extends StatelessWidget {
  final double tamAncho;
  final double tamAlto;
  final String texto;
  final VoidCallback? onPressed;
  final bool activo;

  const BotonOnOff({
    super.key,
    required this.tamAncho,
    required this.tamAlto,
    required this.texto,
    required this.onPressed,
    required this.activo,
  });

  @override
  Widget build(BuildContext context) {
    return activo
        ? SizedBox(
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
                  final color =
                      states.contains(WidgetState.pressed) ? AppColores.secundariOscuro : AppColores.primariOscuro;
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
          )
        : SizedBox(
            width: tamAncho,
            height: tamAlto,
            child: ElevatedButton(
              style: ButtonStyle(
                // Fondo gris para deshabilitado
                backgroundColor: WidgetStateProperty.all(AppColores.grisSecundari),

                // Borde gris para deshabilitado
                side: WidgetStateProperty.all(const BorderSide(
                  color: AppColores.grisSecundari,
                  width: 2.0,
                )),

                // Sombra ligera
                elevation: WidgetStateProperty.all(2),
                shadowColor: WidgetStateProperty.all(AppColores.grisSecundari.withOpacity(0.5)),

                // Forma del botón
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTamanios.sm),
                  ),
                ),
              ),
              onPressed: null,
              child: AppTexto.textoBoton(
                texto,
                align: TextAlign.center,
              ),
            ),
          );
  }
}

/*class BotonOnOff extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const BotonOnOff({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AppBotonPrimario(
      tamAncho: AppTamanios.xxxl * 6,
      tamAlto: AppTamanios.xxxl,
      texto: text,
      onPressed: onPressed,
    );
  }
}*/

class VerRegistrosButton extends StatelessWidget {
  final bool enabled;
  final String text;
  final VoidCallback? onPressed;

  const VerRegistrosButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return BotonOnOff(
      onPressed: enabled ? onPressed : null,
      tamAncho: AppTamanios.xxxl * 6,
      tamAlto: AppTamanios.xxxl,
      texto: text,
      activo: enabled,
    );
  }
}
