import 'package:flutter/widgets.dart';

class AppResponsive {
  /// true si estamos en móvil muy pequeño (ancho < 360dp)
  static bool movilXS(BuildContext c) => MediaQuery.sizeOf(c).shortestSide < 360;

  /// Alto recomendado para un widget “alto” (calendario, mapa, chart…)
  /// - Usa % del alto disponible
  /// - Aplica topes min/max
  static double altoComponente(
    BuildContext c, {
    required double altoDisponible,
    double fraccion = 0.55, // 55% del alto de la pantalla
    double min = 280,
    double max = 520,
  }) {
    final h = altoDisponible * fraccion;
    return h.clamp(min, max);
  }

  static double altoCabecera(double escalaTexto) => 72.0 * escalaTexto.clamp(1.0, 1.2);

  /// Deriva alturas internas típicas para cabeceras del componente
  static double altoFilaSemanas(double escalaTexto) => 26.0 * escalaTexto.clamp(1.0, 1.2);

  /// Para componentes con 6 filas (ej. calendario mensual)
  static double altoCalendario({
    required double altoTotal,
    required double altoCabecera,
    required double altoSemanas,
  }) =>
      ((altoTotal - altoCabecera - altoSemanas).clamp(180.0, 420.0)) / 6.0;
}
