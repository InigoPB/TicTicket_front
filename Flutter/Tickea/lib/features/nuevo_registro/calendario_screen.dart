import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tickea/core/formateadores/fecha_formato.dart';
import 'package:tickea/core/theme/app_styles.dart';
//import 'package:tickea/mocks/registro/registros_mock.dart';
import 'package:tickea/widgets/app_popups.dart';
import 'package:tickea/widgets/app_componentes.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:tickea/core/responsive/app_responsive.dart';
import 'package:tickea/core/layouts/app_box_responsive.dart';
import 'package:tickea/core/archivos/carpeta_temporal.dart';
import 'package:tickea/features/registro/registro_provider.dart';
import 'dart:developer' as dev;

///TODO: Contemplar el tema de vacaciones. Que va a pasar cuando esta persona esté de vacaciones?

class NuevoRegistroScreen extends StatefulWidget {
  const NuevoRegistroScreen({super.key});

  @override
  State<NuevoRegistroScreen> createState() => _NuevoRegistroScreenState();
}

class _NuevoRegistroScreenState extends State<NuevoRegistroScreen> with SingleTickerProviderStateMixin {
  late bool Function(DateTime) _contieneDia;
  late AnimationController _controller;
  final DateTime _diaHoy = DateTime.now();
  DateTime _diaInicio = DateTime.now();
  DateTime? _diaSeleccionado;
  String? strFecha;
  //Funciones.

  bool _isMismoDia(DateTime fechaHoy, DateTime fechaSeleccionada) =>
      fechaHoy.day == fechaSeleccionada.day &&
      fechaHoy.year == fechaSeleccionada.year &&
      fechaHoy.month == fechaSeleccionada.month;

//Booleano para saber si un dia es mayor o menor
  bool _isDiaMayor(DateTime fechaHoy, DateTime otraFecha) => formatoDia(fechaHoy).isBefore(
        formatoDia(otraFecha),
      );

  ///TODO: Cambiar el Mock a dato real cuando tenga que ser.
  bool _isDiaRegistrado(DateTime dia) => _contieneDia(formatoDia(dia));

  void _hoyBtn() {
    final DateTime hoy = DateTime.now();
    final DateTime soloFecha = formatoDia(hoy);
    context.read<RegistroProvider>().setFecha(soloFecha);
    setState(() {
      _diaInicio = soloFecha;
      _diaSeleccionado = soloFecha;
      strFecha = fmtFecha(soloFecha);
    });
    dev.log('Botón Hoy pulsado | fecha=$strFecha', name: 'NR.Calendario', level: 500);
  }

  void goToFoto() {
    dev.log('Navegación a /nuevaFoto', name: 'NR.Nav', level: 500);
    context.go('/nuevaFoto');
  }

  void _onAceptar() {
    final DateTime? seleccion = _diaSeleccionado;
    dev.log('Click Aceptar | seleccion=${_diaSeleccionado != null}', name: 'NR.Flujo', level: 500);

    // 1) Fecha no seleccionada
    if (seleccion == null) {
      AppPopup.alerta(
        context: context,
        titulo: 'Falta la fecha',
        contenido: 'Selecciona una fecha antes de continuar.',
        textoOk: 'Entendido',
      );
      return;
    }

    // 2) Día ya registrado (mock)
    if (_isDiaRegistrado(seleccion)) {
      dev.log('Bloqueado: día ya registrado | fecha=${fmtFecha(formatoDia(seleccion))}', name: 'NR.Flujo', level: 900);
      AppPopup.alerta(
        context: context,
        titulo: 'Día ya registrado',
        contenido: 'Selecciona una fecha que no esté ya registrada.',
        textoOk: 'Vale',
      );
      return;
    }

    // 3) Confirmación si la fecha es distinta de hoy

    final now = DateTime.now();
    final hoy = formatoDia(now);
    final sel = formatoDia(seleccion);
    final esMismoDia = _isMismoDia(hoy, sel);
    final strFechaFmt = fmtFecha(sel);
    final strDiaSemana = DateFormat.EEEE('es').format(sel);

    if (!esMismoDia) {
      dev.log('Confirmado día no-hoy | fecha=$strFechaFmt', name: 'NR.Flujo', level: 500);
      AppPopup.confirmacion(
        context: context,
        alerta: false,
        titulo: 'No es hoy!',
        contenido: 'El dia seleccionado es $strDiaSemana $strFechaFmt. ¿Quieres continuar?',
        textoSi: 'Sí, continuar',
        textoNo: 'No, cambiar',
        onSi: () async {
          setState(() => strFecha = strFechaFmt);
          context.read<RegistroProvider>().setFecha(sel);
          final dir = await obtenerOCrearCarpetaTemporal(strFechaFmt);
          if (!mounted) return;
          context.read<RegistroProvider>().setTempDirPath(dir.path);
          goToFoto();
        },
        onNo: () async {},
        barrierDismissible: false,
      );
      return;
    }

    // 4) Si es hoy → seguimos (por ahora solo informamos)
    AppPopup.alerta(
      context: context,
      alerta: false,
      titulo: 'Has seleccionado hoy',
      contenido: '$strDiaSemana $strFechaFmt.',
      textoOk: 'Continuar',
      onOk: () async {
        setState(() => strFecha = strFechaFmt);
        context.read<RegistroProvider>().setFecha(sel);
        final dir = await obtenerOCrearCarpetaTemporal(strFechaFmt);
        if (!mounted) return;
        context.read<RegistroProvider>().setTempDirPath(dir.path);
        dev.log('Carpeta temporal creada (ok) | carpeta=$strFechaFmt', name: 'NR.Storage', level: 500);
        goToFoto();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    final prov = context.read<RegistroProvider>();
    _contieneDia = prov.contieneDiaRegistrado;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: const AppCabecero(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTamanios.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ///TODO: tendremos que meter un cabecero aqui
              const SizedBox(height: AppTamanios.xl * 2),

              // Marco que permite medir altura y aplicar el responsive genérico
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.60,
                child: AppBoxResponsive(
                  fraccion: 0.80, // % del alto del body
                  minAlto: 300,
                  maxAlto: 520,
                  funcionResponsive: ({required double altoAsignado}) {
                    final escalaTexto = MediaQuery.of(context).textScaler.scale(1);
                    final altoCab = AppResponsive.altoCabecera(escalaTexto);
                    final altoDOW = AppResponsive.altoFilaSemanas(escalaTexto);
                    final altoFila = AppResponsive.altoCalendario(
                      altoTotal: altoAsignado,
                      altoCabecera: altoCab,
                      altoSemanas: altoDOW,
                    );

                    return TableCalendar(
                      locale: 'es_ES',
                      focusedDay: _diaInicio,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      rowHeight: altoFila,
                      daysOfWeekHeight: altoDOW * 2,
                      selectedDayPredicate: (dia) => _diaSeleccionado != null && _isMismoDia(dia, _diaSeleccionado!),
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
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
                        leftChevronIcon:
                            const Icon(Icons.arrow_circle_left, color: AppColores.primario, size: AppTamanios.xl),
                        rightChevronIcon:
                            const Icon(Icons.arrow_circle_right, color: AppColores.primario, size: AppTamanios.xl),
                        titleTextStyle: AppEstiloTexto.subtitulo.copyWith(fontSize: AppTamanios.lg),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTamanios.sm),
                          border: Border.all(color: AppColores.secundariOscuro, width: 2),
                        ),
                      ),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: AppEstiloTexto.subtitulo,
                        weekendStyle: AppEstiloTexto.subtitulo.copyWith(
                          shadows: AppExtraBold.extraBold(AppColores.primariOscuro, .5),
                        ),
                      ),
                      calendarStyle: const CalendarStyle(isTodayHighlighted: true),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, dia, diaInicio) {
                          final isDiaRegistrado = _isDiaRegistrado(dia);
                          return Stack(
                            children: [
                              Center(
                                child: Text(
                                  '${dia.day}',
                                  style: AppEstiloTexto.cuerpo.copyWith(
                                    fontSize:
                                        _isDiaMayor(_diaHoy, dia) ? AppTamanios.base * 1.5 : AppTamanios.base * 2.0,
                                    color: isDiaRegistrado ? AppColores.grisClaro : AppColores.primario,
                                    shadows: AppExtraBold.extraBold(
                                        AppColores.primario, _isDiaMayor(_diaHoy, dia) ? .1 : 0.3),
                                  ),
                                ),
                              ),
                              if (isDiaRegistrado)
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
                                if (isDiaRegistrado)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: Image.asset('assets/img/tachado.png', fit: BoxFit.contain),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                        todayBuilder: (context, dia, diaInicio) {
                          bool isRegistrado = _isDiaRegistrado(dia);
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              boxShadow: AppSombra.contenedores(
                                color: AppColores.secundariOscuro,
                                difuminado: 2,
                                ejeH: -.5,
                                ejeV: -.5,
                                opacidad: .2,
                                direccion: BlurStyle.solid,
                              ),
                              color: AppColores.fondo,
                              border: Border.all(
                                  width: 2, color: !isRegistrado ? AppColores.secundariOscuro : AppColores.grisClaro),
                              borderRadius: BorderRadius.circular(12),
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
                                if (_isDiaRegistrado(dia))
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: Image.asset('assets/img/tachado.png', fit: BoxFit.contain),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      onDaySelected: (diaSeleccionado, diaInicio) {
                        if (_isDiaRegistrado(diaSeleccionado)) {
                          AppPopup.alerta(
                            context: context,
                            titulo: 'Día ya registrado',
                            contenido: 'Lo siento, este día ya está registrado.',
                            textoOk: 'Ok',
                            barrierDismissible: false,
                            alerta: true, // borde rojo
                          );
                          return;
                        }
                        if (_isDiaMayor(_diaHoy, diaSeleccionado)) {
                          AppPopup.alerta(
                            context: context,
                            titulo: 'Ojito Nostradamus',
                            contenido: 'No puedes seleccionar un día en el futuro.',
                            textoOk: 'Entendido',
                            barrierDismissible: false,
                            alerta: true, // borde rojo
                          );
                          return;
                        }
                        setState(() {
                          _diaSeleccionado = diaSeleccionado;
                          _diaInicio = diaInicio;
                          strFecha = fmtFecha(diaSeleccionado);
                        });
                        //Logs para los debugs
                        dev.log(_isDiaMayor(_diaHoy, diaSeleccionado).toString());
                        dev.log('Día seleccionado | fecha=$strFecha', name: 'NR.Calendario', level: 500);
                      },
                      onPageChanged: (diaInicio) => _diaInicio = diaInicio,
                    );
                  },
                ),
              ),

              // Botones
              Column(
                children: [
                  AppBotonPrimario(tamAncho: 200, tamAlto: 48, texto: 'Hoy', onPressed: _hoyBtn),
                  const SizedBox(height: AppTamanios.lg),
                  AppBotonPrimario(tamAncho: 200, tamAlto: 48, texto: 'Aceptar', onPressed: _onAceptar),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
