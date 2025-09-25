import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tickea/core/theme/app_styles.dart';

import 'app_componentes.dart';

/*class AppPopup {
  static void popupDosBotones({
    required BuildContext context,
    required String titulo,
    required String contenido,
    required String goBotonA,
    required String goBotonB,
    required bool exito,
    required String textoIr,
    required String textoVolver,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "popup",
      transitionDuration: const Duration(milliseconds: 1000),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox(); // obligatorio aunque no se usa
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedValue = Curves.easeInOut.transform(animation.value);
        return Transform.translate(
          offset: Offset(0, -400 + 400 * curvedValue), // desde arriba
          child: Opacity(
            opacity: animation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              shape: LinearBorder.bottom(),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColores.fondo,
                  borderRadius: BorderRadius.circular(AppTamanios.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppTamanios.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTexto.titulo(titulo),
                    const SizedBox(height: AppTamanios.sm),
                    AppTexto.textoCuerpo(contenido, align: TextAlign.center),
                    const SizedBox(height: AppTamanios.md),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: AppBotonPrimario(
                            tamAncho: double.infinity,
                            tamAlto: 48,
                            texto: textoIr,
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.go(goBotonA);
                            },
                          ),
                        ),
                        const SizedBox(height: AppTamanios.sm),
                        SizedBox(
                          width: double.infinity,
                          child: AppBotonPrimario(
                            tamAncho: double.infinity,
                            tamAlto: 48,
                            texto: textoVolver,
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.go(goBotonB);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:tickea/core/theme/app_styles.dart';

class AppPopup {
  // Base interna para no repetir
  static Future<void> _basicosPopup({
    required BuildContext context,
    required String titulo,
    required String contenido,
    required List<Widget> acciones,
    bool boolAlerta = true, //controla si es una alerta o no
    bool barrierDismissible = false, //controla si se puede ono cerrar tocando fuera
    Duration transitionDuration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,

    ///TODO: hacer el desplazaciento responsive.
    double desplazamientoY = 400, // desde arriba hacia su sitio
  }) {
    return showGeneralDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: barrierDismissible,
      barrierLabel: "popup",
      transitionDuration: transitionDuration,
      pageBuilder: (context, a, b) => const SizedBox(), //es obligatorio, metemos datos "falsos" y seguimos.
      transitionBuilder: (dialogCtx, animacion, animacionSecundaria, child) {
        final curvedValue = curve.transform(animacion.value);
        return Transform.translate(
          offset: Offset(0, -desplazamientoY + desplazamientoY * curvedValue),
          child: Opacity(
            opacity: animacion.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: AppTamanios.lg, vertical: AppTamanios.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColores.fondo,
                  border: Border.all(color: boolAlerta ? AppColores.error : AppColores.acierto, width: 3.0),
                  borderRadius: BorderRadius.circular(AppTamanios.md),
                  boxShadow: [
                    BoxShadow(
                      color: boolAlerta ? AppColores.error.withOpacity(0.3) : AppColores.acierto.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 5,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppTamanios.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTexto.titulo(titulo),
                    const SizedBox(height: AppTamanios.sm),
                    AppTexto.textoCuerpo(contenido, align: TextAlign.center),
                    const SizedBox(height: AppTamanios.md),
                    Column(children: acciones),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ----- Alerta simple: 1 botón ------
  static Future<void> alerta({
    required BuildContext context,
    required String titulo,
    required String contenido,
    String textoOk = 'OK',
    final Future<void> Function()? onOk,
    bool barrierDismissible = false,
    bool alerta = true,
  }) {
    return _basicosPopup(
      context: context,
      titulo: titulo,
      contenido: contenido,
      barrierDismissible: barrierDismissible,
      boolAlerta: alerta,
      acciones: [
        Builder(builder: (dialogCtx) {
          return SizedBox(
            width: double.infinity,
            child: AppBotonPrimario(
              tamAncho: double.infinity,
              tamAlto: 48,
              texto: textoOk,
              autoFocus: true,
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                onOk?.call();
              },
            ),
          );
        }),
      ],
    );
  }

  // ----- Confirmación: 2 botones (Sí/No) ---------
  static Future<void> confirmacion({
    required BuildContext context,
    required String titulo,
    required String contenido,
    String textoSi = 'Sí',
    String textoNo = 'No',
    Future<void> Function()? onSi,
    Future<void> Function()? onNo,
    bool barrierDismissible = false,
    bool alerta = true,
  }) {
    return _basicosPopup(
      context: context,
      titulo: titulo,
      contenido: contenido,
      barrierDismissible: barrierDismissible,
      boolAlerta: alerta,
      acciones: [
        Builder(builder: (dialogCtx) {
          return SizedBox(
            width: double.infinity,
            child: AppBotonPrimario(
              tamAncho: double.infinity,
              tamAlto: 48,
              texto: textoSi,
              autoFocus: true,
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                await onSi?.call();
              },
            ),
          );
        }),
        const SizedBox(height: AppTamanios.sm),
        Builder(builder: (dialogCtx) {
          return SizedBox(
            width: double.infinity,
            child: AppBotonPrimario(
              tamAncho: double.infinity,
              tamAlto: 48,
              texto: textoNo,
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                onNo?.call();
              },
            ),
          );
        }),
      ],
    );
  }

  // ------- Dos botones genérico ----------
  /*static Future<void> dosBotones({
    required BuildContext context,
    required String titulo,
    required String contenido,
    required String textoBotonA,
    required String textoBotonB,
    required VoidCallback onBotonA,
    required VoidCallback onBotonB,
    bool barrierDismissible = false,
  }) {
    return _basicosPopup(
      context: context,
      titulo: titulo,
      contenido: contenido,
      barrierDismissible: barrierDismissible,
      acciones: [
        SizedBox(
          width: double.infinity,
          child: AppBotonPrimario(
            tamAncho: double.infinity,
            tamAlto: 48,
            texto: textoBotonA,
            onPressed: () {
              Navigator.of(context).pop();
              onBotonA();
            },
          ),
        ),
        const SizedBox(height: AppTamanios.sm),
        SizedBox(
          width: double.infinity,
          child: AppBotonPrimario(
            tamAncho: double.infinity,
            tamAlto: 48,
            texto: textoBotonB,
            onPressed: () {
              Navigator.of(context).pop();
              onBotonB();
            },
          ),
        ),
      ],
    );
  }*/
}
