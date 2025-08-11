import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tickea/core/theme/app_styles.dart';

import 'app_componentes.dart';

class AppPopup {
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
}
