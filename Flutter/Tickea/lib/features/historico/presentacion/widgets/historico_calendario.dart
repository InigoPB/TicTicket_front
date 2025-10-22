import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/features/historico/presentacion/providers/historico_provider.dart';

class HistoricoCalendario extends StatelessWidget {
  final DateTime? rangoFin;
  final HistoricoModo modo;
  final DateTime? rangoInicio;
  final DateTime? diaSeleccionado;
  final void Function(DateTime) onDiaSeleccionado;
  final void Function(DateTime inicio, DateTime fin) onRangoSeleccionado;

  const HistoricoCalendario({
    super.key,
    required this.modo,
    required this.rangoFin,
    required this.rangoInicio,
    required this.diaSeleccionado,
    required this.onDiaSeleccionado,
    required this.onRangoSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final primerDia = DateTime(hoy.year - 2, 1, 1);
    final ultimoDia = DateTime(hoy.year + 2, 12, 31);

    final rangoSeleccionado =
        modo == HistoricoModo.rango ? RangeSelectionMode.toggledOn : RangeSelectionMode.toggledOff;

    return TableCalendar(
      firstDay: primerDia,
      lastDay: ultimoDia,
      focusedDay: diaSeleccionado ?? rangoInicio ?? hoy,
      currentDay: DateTime(hoy.year, hoy.month, hoy.day),
      selectedDayPredicate: (day) =>
          modo == HistoricoModo.dia && isSameDay(day, diaSeleccionado) && diaSeleccionado != null,
      rangeStartDay: modo == HistoricoModo.rango ? rangoInicio : null,
      rangeEndDay: modo == HistoricoModo.rango ? rangoFin : null,
      rangeSelectionMode: rangoSeleccionado,
      onDaySelected: (diaSelecionado, focusDia) {
        if (modo == HistoricoModo.dia) {
          onDiaSeleccionado(diaSelecionado);
        }
      },
      onRangeSelected: (inicio, fin, focusDia) {
        if (modo == HistoricoModo.rango && inicio != null && fin != null) {
          onRangoSeleccionado(inicio, fin);
        }
      },
      calendarStyle: CalendarStyle(
        defaultTextStyle: AppEstiloTexto.cuerpo.copyWith(color: AppColores.falsoBlanco, fontWeight: FontWeight.w900),
        rangeHighlightColor: AppColores.grisPrimari.withOpacity(0.3),
        rangeStartDecoration: const BoxDecoration(
          color: AppColores.secundario,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTamanios.xxl),
            bottomLeft: Radius.circular(AppTamanios.xxl),
          ),
        ),
        rangeEndDecoration: const BoxDecoration(
          color: AppColores.secundario,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppTamanios.xxl),
            bottomRight: Radius.circular(AppTamanios.xxl),
          ),
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColores.secundariOscuro,
          shape: BoxShape.circle,
        ),
        todayDecoration: const BoxDecoration(
          color: AppColores.primariOscuro,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    ); // Placeholder
  }
}
