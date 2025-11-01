import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tickea/core/routes/app_router.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/features/historico/presentacion/providers/historico_provider.dart';
import 'package:tickea/features/registro/registro_provider.dart';
import 'package:tickea/widgets/app_popups.dart';

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
    final fechasRegistradas = context.select<RegistroProvider, Set<DateTime>>(
      (p) => p.diasRegistrados,
    );

    bool _isDiaRegistrado(DateTime dia) {
      final diaSinHora = DateTime(dia.year, dia.month, dia.day);
      return fechasRegistradas.contains(diaSinHora);
    }

    bool _isDiaMayor(DateTime dia1, DateTime dia2) {
      final d1 = DateTime(dia1.year, dia1.month, dia1.day);
      final d2 = DateTime(dia2.year, dia2.month, dia2.day);
      return d1.isBefore(d2);
    }

    final rangoSeleccionado =
        modo == HistoricoModo.rango ? RangeSelectionMode.toggledOn : RangeSelectionMode.toggledOff;

    return TableCalendar(
      enabledDayPredicate: (dia) => _isDiaRegistrado(dia),
      locale: 'es_ES',
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
        disabledTextStyle: AppEstiloTexto.cuerpo.copyWith(
          color: AppColores.grisClaro,
        ),
        isTodayHighlighted: true,
        defaultTextStyle: AppEstiloTexto.cuerpo.copyWith(fontWeight: FontWeight.w900),
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
          color: AppColores.primario,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(AppTamanios.sm)),
          border: Border.fromBorderSide(
            BorderSide(
              color: AppColores.primariOscuro,
              width: 2,
            ),
          ),
        ),
        todayDecoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(AppTamanios.sm)),
          border: Border.fromBorderSide(
            BorderSide(
              color: AppColores.secundariOscuro,
              width: 2,
            ),
          ),
        ),
      ),
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextFormatter: (date, locale) {
          final mes = DateFormat.MMMM(locale).format(date);
          final anio = DateFormat.y(locale).format(date);
          return '${mes[0].toUpperCase()}${mes.substring(1)} $anio';
        },
        rightChevronPadding: const EdgeInsets.only(
          right: AppTamanios.sm,
          bottom: AppTamanios.sm,
          top: AppTamanios.sm,
        ),
        leftChevronPadding: const EdgeInsets.only(
          left: AppTamanios.sm,
          bottom: AppTamanios.sm,
          top: AppTamanios.sm,
        ),
        leftChevronIcon: const Icon(Icons.arrow_circle_left, color: AppColores.primario, size: AppTamanios.xl),
        rightChevronIcon: const Icon(Icons.arrow_circle_right, color: AppColores.primario, size: AppTamanios.xl),
        titleTextStyle: AppEstiloTexto.subtitulo.copyWith(fontSize: AppTamanios.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTamanios.sm),
          border: Border.all(color: AppColores.secundariOscuro, width: 2),
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppEstiloTexto.subtitulo,
        weekendStyle: AppEstiloTexto.subtitulo.copyWith(
          shadows: AppExtraBold.extraBold(AppColores.primariOscuro, .5),
        ),
      ),
      daysOfWeekHeight: AppTamanios.xl,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, dia, eventos) {
          if (!isSameDay(dia, DateTime.now())) {
            return const SizedBox.shrink();
          }
          return IgnorePointer(
            ignoring: true,
            child: SizedBox.expand(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColores.primario, width: 2),
                  borderRadius: BorderRadius.circular(AppTamanios.sm),
                ),
              ),
            ),
          );
        },
        defaultBuilder: (context, dia, diaInicio) {
          final isDiaRegistrado = _isDiaRegistrado(dia);
          return Stack(
            children: [
              Center(
                child: Text(
                  '${dia.day}',
                  style: AppEstiloTexto.cuerpo.copyWith(
                    fontSize: AppTamanios.base * 2.5,
                    color: AppColores.primario,
                    shadows: AppExtraBold.extraBold(AppColores.secundariOscuro, .2),
                  ),
                ),
              ),
              if (!isDiaRegistrado)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.8,
                      child: Image.asset('assets/img/tachado.png', fit: BoxFit.scaleDown),
                    ),
                  ),
                ),
            ],
          );
        },
        selectedBuilder: (context, dia, diaInicio) {
          final isDiaRegistrado = _isDiaRegistrado(dia);
          return Container(
            decoration: BoxDecoration(
              color: AppColores.primario,
              borderRadius: BorderRadius.circular(AppTamanios.base),
              border: Border.all(width: 2, color: AppColores.primariOscuro),
              boxShadow: AppSombra.contenedores(),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '${dia.day}',
                    style: AppEstiloTexto.subtitulo.copyWith(
                      color: AppColores.fondo,
                      shadows: AppExtraBold.extraBold(AppColores.fondo, .5),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        todayBuilder: (context, dia, diaInicio) {
          bool isRegistrado = _isDiaRegistrado(dia);
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColores.fondo,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '${dia.day}',
                    style: AppEstiloTexto.cuerpo.copyWith(
                      fontSize: AppTamanios.base * 2.5,
                      color: AppColores.secundariOscuro,
                      shadows: AppExtraBold.extraBold(AppColores.secundariOscuro, .2),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        disabledBuilder: (context, day, focusedDay) {
          // UI por defecto de "deshabilitado" + interceptar el tap
          final textStyle = AppEstiloTexto.cuerpo.copyWith(
            fontSize: AppTamanios.md,
            color: AppColores.grisClaro,
            shadows: AppExtraBold.extraBold(AppColores.grisClaro, .2),
          );

          final child = Center(
            child: Text('${day.day}', style: textStyle),
          );

          if (HistoricoModo.rango == modo) return child;

          return InkWell(
            onTap: () => AppPopup.alerta(
              context: context,
              titulo: 'Día no registrado',
              contenido: 'No hay registros para el día seleccionado. Por favor, selecciona otro día.',
              textoOk: 'Entendido',
            ),
            borderRadius: BorderRadius.circular(8),
            child: child,
          );
        },
      ),
    ); // Placeholder
  }
}
