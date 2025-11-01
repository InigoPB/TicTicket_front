import 'package:flutter/material.dart';
import '../responsive/app_responsive.dart';

class AppBoxResponsive extends StatelessWidget {
  const AppBoxResponsive({
    super.key,
    required this.funcionResponsive,
    this.fraccion = 0.55, // % del alto del body
    this.minAlto = 280,
    this.maxAlto = 520,
    this.margenInferiorScroll = 16,
    this.scrollSiNoCabe = true,
  });

  final Widget Function({required double altoAsignado}) funcionResponsive;
  final double fraccion;
  final double minAlto;
  final double maxAlto;
  final double margenInferiorScroll;
  final bool scrollSiNoCabe;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, box) {
        // 1) Alto disponible robusto
        double altoDisp;
        if (box.maxHeight.isFinite) {
          altoDisp = box.maxHeight;
        } else {
          final mq = MediaQuery.of(ctx);
          altoDisp = mq.size.height - mq.padding.vertical;
        }

        // 2) Alto asignado según responsive
        final altoAsignado = AppResponsive.altoComponente(
          ctx,
          altoDisponible: altoDisp,
          fraccion: fraccion,
          min: minAlto,
          max: maxAlto,
        );

        // 3) Hijo a altura fija
        final childSized = SizedBox(
          height: altoAsignado,
          child: funcionResponsive(altoAsignado: altoAsignado),
        );

        // 4) Scroll opcional
        if (!scrollSiNoCabe) return childSized;

        final necesitaScroll = altoDisp < (altoAsignado + margenInferiorScroll);
        return necesitaScroll
            ? SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: margenInferiorScroll),
                  child: childSized,
                ),
              )
            : childSized;
      },
    );
  }
}
