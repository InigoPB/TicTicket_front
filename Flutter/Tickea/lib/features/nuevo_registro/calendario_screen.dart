import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tickea/core/formateadores/fecha_formato.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/mocks/registro/registros_mock.dart';
import 'package:tickea/widgets/app_popups.dart';
import 'package:tickea/widgets/app_componentes.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:tickea/core/responsive/app_responsive.dart';
import 'package:tickea/core/layouts/app_box_responsive.dart';
import 'package:tickea/core/archivos/carpeta_temporal.dart';
import 'package:tickea/features/registro/registro_provider.dart';

///TODO: Contemplar el tema de vacaciones. Que va a pasar cuando esta persona esté de vacaciones?

class NuevoRegistroScreen extends StatefulWidget {
  const NuevoRegistroScreen({super.key});

  @override
  State<NuevoRegistroScreen> createState() => _NuevoRegistroScreenState();
}

class _NuevoRegistroScreenState extends State<NuevoRegistroScreen> with SingleTickerProviderStateMixin {
  //Variables
  late AnimationController _controller;
  final DateTime _diaHoy = DateTime.now();
  DateTime _diaInicio = DateTime.now();
  DateTime? _diaSeleccionado;
  String? strFecha;
  late final Set<DateTime> _diasRegistrados;
  final bool Function(DateTime) _contieneDia =
      DiasRegistradosMock.contiene; //esto lo cambiaremos por el dato real cuando toque.

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
    debugPrint('[NuevoRegistro] Hoy seleccionado: $strFecha');
    goToFoto();
  }

  void goToFoto() {
    context.go('/nuevaFoto');
  }

  void _onAceptar() {
    final DateTime? seleccion = _diaSeleccionado;
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
// Actualiza el estado con mismo valor
    setState(() => strFecha = strFechaFmt);

    if (!esMismoDia) {
      AppPopup.confirmacion(
        context: context,
        alerta: false,
        titulo: 'No es hoy!',
        contenido: 'El dia seleccionado es $strDiaSemana $strFechaFmt. ¿Quieres continuar?',
        textoSi: 'Sí, continuar',
        textoNo: 'No, cambiar',
        onSi: () async {
          context.read<RegistroProvider>().setFecha(sel);
          final dir = await obtenerOCrearCarpetaTemporal(strFechaFmt);
          debugPrint('[NuevoRegistro] Temp dir: ${dir.path}');
          if (!mounted) return; //mounted
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
        context.read<RegistroProvider>().setFecha(sel);
        final dir = await obtenerOCrearCarpetaTemporal(strFechaFmt);
        if (!mounted) return;
        context.read<RegistroProvider>().setTempDirPath(dir.path);
        debugPrint('[NuevoRegistro] Carpeta temporal creada: ${dir.path}');
        goToFoto();
      },
    );
  }
  // TODO: crear carpeta temporal con str_fecha y navegar a Tomar foto.
  // TODO: integrar navegación / creación de carpeta en pasos siguientes.

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
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
                                        _isDiaMayor(_diaHoy, dia) ? AppTamanios.base * 2.5 : AppTamanios.base * 2.0,
                                    color: isDiaRegistrado ? AppColores.secundariOscuro : AppColores.primario,
                                    shadows: AppExtraBold.extraBold(
                                        AppColores.primario, _isDiaMayor(_diaHoy, dia) ? .5 : 0.1),
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
                              border: Border.all(width: 2, color: AppColores.secundariOscuro),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${dia.day}',
                                style: AppEstiloTexto.cuerpo.copyWith(
                                  fontSize: AppTamanios.base * 2.5,
                                  color: AppColores.secundariOscuro,
                                  shadows: AppExtraBold.extraBold(AppColores.secundariOscuro, .2),
                                ),
                              ),
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
                        setState(() {
                          _diaSeleccionado = diaSeleccionado;
                          _diaInicio = diaInicio;
                          strFecha = fmtFecha(diaSeleccionado);
                        });
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
