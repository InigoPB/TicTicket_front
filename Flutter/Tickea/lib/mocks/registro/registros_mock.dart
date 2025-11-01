import 'package:flutter/foundation.dart';

//Helper para unificar el formato de las fechas en los mocks e ignorar las horas y los minutos

DateTime _formatoDia(DateTime d) => DateTime(d.year, d.month, d.day);

class DiasRegistradosMock {
  static final Set<DateTime> dias = {
    _formatoDia(DateTime(2025, 8, 10)),
    _formatoDia(DateTime(2025, 8, 11)),
    _formatoDia(DateTime(2025, 8, 12)),
    _formatoDia(DateTime(2025, 8, 15)),
  };
  static bool contiene(DateTime d) => dias.any((x) => x.year == d.year && x.month == d.month && x.day == d.day);
}
