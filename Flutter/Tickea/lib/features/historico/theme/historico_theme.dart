import 'dart:ui';

import 'package:tickea/core/theme/app_styles.dart';

class HistoricoTheme {
  static const double separadorTicket = 1;
  static const double radioSheet = AppTamanios.md;

  static const Color rellenoRango = AppColores.grisPrimari;
  static const Color bordeRango = AppColores.primario;
  static const double opacidadRellenoRango = 0.15;

  static Color rellenoRangoConOpacidad() {
    return rellenoRango.withOpacity(opacidadRellenoRango);
  }
}
