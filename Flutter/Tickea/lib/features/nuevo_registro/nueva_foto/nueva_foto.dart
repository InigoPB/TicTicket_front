import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tickea/core/api/tickea_api.dart';
import 'package:tickea/core/ocr/ocr_servicio.dart';
import 'package:tickea/features/nuevo_registro/nueva_foto/ocr_provider.dart';
import 'package:tickea/features/registro/registro_provider.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/widgets/app_componentes.dart';
import 'package:tickea/widgets/app_popups.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NuevaFoto extends StatefulWidget {
  const NuevaFoto({super.key});

  @override
  State<NuevaFoto> createState() => _NuevaFotoState();
}

class _NuevaFotoState extends State<NuevaFoto> {
  CameraController? _camara;
  bool _inicializada = false;
  String? _error;
  bool _pidiendoPermiso = false;
  bool _flashOn = true;
  bool _flashSoportado = true;

  @override
  void initState() {
    super.initState();
    final prov = context.read<RegistroProvider>();
    debugPrint('[NuevaFoto] Fecha=${prov.strFecha}, Carpeta=${prov.tempDirPath}');
    _preparar();
  }

  Future<void> _preparar() async {
    try {
      setState(() => _pidiendoPermiso = true);
      final estadoActual = await Permission.camera.status;
      setState(() => _pidiendoPermiso = false);

      if (estadoActual.isGranted) {
        _error = null;
        return _inicializarCamara();
      }

      if (estadoActual.isDenied) {
        setState(() => _pidiendoPermiso = true);
        final req = await Permission.camera.request();
        setState(() => _pidiendoPermiso = false);

        if (req.isGranted) {
          _error = null;
          return _inicializarCamara();
        }
        if (req.isPermanentlyDenied || req.isRestricted) {
          return _mostrarPopupAjustes();
        }
        setState(() => _error = 'Permiso de cámara denegado');
        return;
      }

      if (estadoActual.isPermanentlyDenied || estadoActual.isRestricted) {
        return _mostrarPopupAjustes();
      }
    } catch (e) {
      setState(() {
        _error = 'Error al pedir permiso de cámara: $e';
      });
    }
  }

  Future<void> _inicializarCamara() async {
    try {
      final camaras = await availableCameras();
      if (camaras.isEmpty) {
        setState(() => _error = 'No hay cámaras disponibles');
        return;
      }
      final camaraTrasera = camaras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => camaras.first,
      );
      final controlador = CameraController(
        camaraTrasera,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controlador.initialize();
      //_camara!.setFlashMode(FlashMode.always);
      try {
        // Torch = luz continua para mejor enfoque y lectura
        await controlador.setFlashMode(FlashMode.torch);
        _flashOn = true;
        _flashSoportado = true;
      } catch (e) {
        debugPrint('No se pudo activar el flash: $e');
        _flashOn = false;
        _flashSoportado = false;
      }
      if (!mounted) return;
      setState(() {
        _camara = controlador;
        _inicializada = true;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _mostrarPopupAjustes() async {
    // Ofrece 2 caminos: reintentar o abrir ajustes
    await AppPopup.confirmacion(
      context: context,
      titulo: 'Permiso de cámara',
      contenido: 'Has denegado el permiso. Si fue “No volver a preguntar” (Android) o en iOS, '
          'debes activarlo en Ajustes.',
      textoSi: 'Abrir Ajustes',
      textoNo: 'Volver a pedir',
      onSi: () async {
        await openAppSettings();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Al volver pulsa reintentar permisos ;)')),
        );
        // Al volver, didChangeAppLifecycleState -> re-chequea
      },
      onNo: () async {
        // Reintentar petición si no era permanentlyDenied
        final permisoCamara = await Permission.camera.request();
        if (permisoCamara.isGranted) {
          _error = null;
          await _inicializarCamara();
        } else if (permisoCamara.isPermanentlyDenied) {
          // Vuelve a ofrecer Ajustes
          await openAppSettings();
        } else {
          setState(() => _error = 'Permiso de cámara denegado');
        }
      },
    );
  }

  Future<void> _dispararYLeer(OcrProvider ocrProv, RegistroProvider regProv) async {
    final camara = _camara;
    if (camara == null || !camara.value.isInitialized || camara.value.isTakingPicture) {
      return;
    }
    try {
      await ocrProv.capturarYOcr(camara);
      if (!mounted) return;
      debugPrint('[NuevaFoto] Foto capturada y procesada por OCR');
      log('Texto OCR acumulado:\n${ocrProv.ocrPorFilas}\n\n[Texto Bruto:\n${ocrProv.ocrBruto}]');
      await _postCapturaPopup(ocrProv, regProv);
    } catch (e) {
      debugPrint('Error capturarYOcr: $e');
    }
  }

  Future<void> _toggleFlash() async {
    final cam = _camara;
    if (cam == null || !cam.value.isInitialized || !_flashSoportado) return;
    try {
      if (_flashOn) {
        await cam.setFlashMode(FlashMode.off);
        setState(() => _flashOn = false);
      } else {
        await cam.setFlashMode(FlashMode.torch);
        setState(() => _flashOn = true);
      }
    } catch (e) {
      debugPrint('Error al cambiar flash: $e');
      setState(() {
        _flashOn = false;
        _flashSoportado = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este dispositivo no permite controlar el flash')),
      );
    }
  }

  void _reintentarPermisos() {
    _error = null;
    _inicializada = false;
    _preparar();
    setState(() {}); // refresca
  }

  Future<void> _reintentarCamara() async {
    _error = null;
    _inicializada = false;
    setState(() {});
    await _inicializarCamara();
  }

  Future<void> _confirmarBorrarUltimoOcr(OcrProvider ocrProv) async {
    await AppPopup.confirmacion(
      context: context,
      titulo: "Borrar última captura",
      contenido: '¿Seguro que quieres borrar la última foto procesada (OCR)?',
      textoSi: 'Borrar',
      textoNo: 'Cancelar',
      barrierDismissible: true,
      onSi: () async {
        ocrProv.borrarUltimoOcr();
        debugPrint('[NuevaFoto] Última captura OCR borrada');
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBarTickea(colorFondo: AppColores.primario, texto: 'Último texto OCR borrado'));
      },
      onNo: () async {},
    );
  }

  Future<void> _postCapturaPopup(OcrProvider ocrProv, RegistroProvider regProv) async {
    await AppPopup.confirmacion(
        context: context,
        titulo: '¿Otra foto?',
        contenido: 'Llevas ${ocrProv.fotosProcesadas} fotos. ¿Quieres capturar otra?',
        textoSi: 'Otra foto',
        textoNo: 'Ticket terminado',
        barrierDismissible: true,
        onSi: () async {
          debugPrint('[NuevaFoto] Usuario continúa para sacar otra foto');
        },
        onNo: () async {
          await _enviarResultadosSpring(ocrProv, regProv); //pasamos provs
          if (!mounted) return;
        });
  }

  String _fechaFormatoBack(String fecha) {
    //Convierte "dd_MM_yyyy" a "yyyy-MM-dd"
    try {
      final partes = fecha.split('_');
      if (partes.length != 3) return fecha; // Formato inesperado, devolver original
      final dia = partes[0];
      final mes = partes[1];
      final anio = partes[2];
      return '$anio-$mes-$dia';
    } catch (e) {
      debugPrint('Error al convertir fecha para Spring: $e');
      return fecha; // En caso de error, devolver original
    }
  }

  //usamos el dispose para liberar recursos

  @override
  void dispose() {
    _camara?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OcrProvider(ocrServicio: OcrServicio()),
      child: Consumer<OcrProvider>(
        builder: (context, ocrProv, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ocrProv.estado == OcrEstado.error && ocrProv.ultimoError.isNotEmpty) {
              AppPopup.alerta(
                context: context,
                titulo: 'Error de lectura OCR',
                contenido: '${ocrProv.ultimoError}\n\nPrueba con más luz y mejor enfoque.',
                textoOk: 'Reintentar',
                onOk: () async {
                  ocrProv.limpiarErrores();
                },
              );
            }
          });
          final totalFotos = ocrProv.fotosProcesadas;
          final ocupado = ocrProv.estado == OcrEstado.capturando;

          debugPrint('[NuevaFoto] Fotos procesadas (OCR): $totalFotos');

          return Scaffold(
            backgroundColor: AppColores.fondo,
            appBar: const AppCabecero(),
            body: _error != null // si hay error
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ErrorView(mensaje: _error!),
                      const SizedBox(height: AppTamanios.md),
                      botonFlotante(
                        onPressed: _reintentarPermisos,
                        texto: 'Reintentar permisos',
                        esAcierto: false,
                      ),
                      const SizedBox(height: AppTamanios.sm),
                      botonFlotante(
                        onPressed: _reintentarCamara,
                        texto: 'Reintentar cámara',
                        esAcierto: true,
                      ),
                    ], // mostramos error
                  )
                : (!_inicializada //si no hay error y no está inicializada
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _pidiendoPermiso
                              ? const _CargandoView(texto: 'Solicitando permisos')
                              // si no hay error, no está inicializada y estamos pidiendo permiso
                              : const _CargandoView(texto: 'Inicializando cámara...'),
                          const SizedBox(height: AppTamanios.md),
                          botonFlotante(
                            onPressed: _reintentarPermisos,
                            texto: 'Reintentar permisos',
                            esAcierto: true,
                          ),
                        ],
                      ) // si no hay error, no está inicializada y no estamos pidiendo permiso
                    // si no hay error y está inicializada aqui despliega la camara.
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_camara != null)
                            Center(
                              child: AspectRatio(
                                aspectRatio: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height,
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _camara!.value.previewSize!.height,
                                    height: _camara!.value.previewSize!
                                        .width, // Truco, para engañar a la camara de que estams en portrait
                                    child: CameraPreview(_camara!),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: AppTamanios.md,
                            right: AppTamanios.md,
                            child: Semantics(
                              label: 'Fotos capturadas',
                              child: AppChipCamara(totalFotos: totalFotos),
                            ),
                          ),
                          Positioned(
                            top: AppTamanios.md,
                            left: AppTamanios.md,
                            child: Opacity(
                              opacity: _flashSoportado ? 1 : 0.5,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: _flashSoportado ? _toggleFlash : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColores.fondo.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _flashOn ? AppColores.secundariOscuro : AppColores.textoOscuro,
                                      ),
                                    ),
                                    child: Icon(
                                      _flashOn ? Icons.flash_on : Icons.flash_off,
                                      color: _flashOn ? AppColores.secundariOscuro : AppColores.textoOscuro,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: AppTamanios.md,
                            left: AppTamanios.md,
                            child: ElevatedButton.icon(
                              onPressed: totalFotos > 0
                                  ? () {
                                      botonVerTexto(context, ocrProv);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                backgroundColor:
                                    totalFotos > 0 ? AppColores.primario : AppColores.grisClaro.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTamanios.base,
                                  vertical: AppTamanios.base,
                                ),
                                side: BorderSide(
                                  color: totalFotos > 0 ? AppColores.grisClaro : AppColores.textoOscuro,
                                ),
                              ),
                              icon: Icon(
                                Icons.description,
                                color: totalFotos > 0 ? AppColores.grisClaro : AppColores.textoOscuro,
                              ), // icono de deshacer
                              label: Text(
                                'Ver texto',
                                style: AppEstiloTexto.notaXS.copyWith(
                                    color: totalFotos > 0 ? AppColores.grisClaro : AppColores.textoOscuro,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          // Derecha: botón "Borrar última"
                          Positioned(
                            bottom: AppTamanios.md,
                            right: AppTamanios.md,
                            child: ElevatedButton.icon(
                              onPressed:
                                  (ocrProv.fotosProcesadas > 0) ? () => _confirmarBorrarUltimoOcr(ocrProv) : null,
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                backgroundColor: (context.watch<OcrProvider>().fotosProcesadas > 0)
                                    ? AppColores.secundario
                                    : AppColores.grisClaro.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTamanios.base,
                                  vertical: AppTamanios.base,
                                ),
                                side: BorderSide(
                                  color: (context.watch<OcrProvider>().fotosProcesadas > 0)
                                      ? AppColores.grisClaro
                                      : AppColores.textoOscuro,
                                ),
                              ),
                              icon: Icon(
                                Icons.undo,
                                color: (context.watch<OcrProvider>().fotosProcesadas > 0)
                                    ? AppColores.grisClaro
                                    : AppColores.textoOscuro,
                              ),
                              label: Text(
                                'Borrar última',
                                style: AppEstiloTexto.notaXS.copyWith(
                                  color: (context.watch<OcrProvider>().fotosProcesadas > 0)
                                      ? AppColores.grisClaro
                                      : AppColores.textoOscuro,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          if (ocrProv.estado == OcrEstado.reconociendo) ...[
                            ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.4)),
                            const Center(
                              child: Card(
                                elevation: 8,
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 12),
                                      Text('Leyendo ticket…'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      )),
            floatingActionButton: _inicializada && _error == null
                ? FloatingActionButton(
                    backgroundColor: AppColores.secundariOscuro,
                    onPressed: (ocrProv.estado == OcrEstado.capturando ||
                            ocrProv.estado == OcrEstado.reconociendo ||
                            _camara == null)
                        ? null
                        : () => _dispararYLeer(ocrProv, context.read<RegistroProvider>()),
                    child: const Icon(Icons.camera, color: AppColores.fondo),
                  )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }

  Future<dynamic> botonVerTexto(BuildContext context, OcrProvider ocrProv) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColores.fondo,
      sheetAnimationStyle: AnimationStyle(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 300),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTamanios.lg)),
      ),
      builder: (ctx) {
        //var modo = _VistaTexto.bruto;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          shouldCloseOnMinExtent: true,
          builder: (ctx, scrollCtrl) => StatefulBuilder(
            builder: (ctx, setState) {
              return Padding(
                padding: const EdgeInsets.all(AppTamanios.sm),
                child: RawScrollbar(
                  padding: const EdgeInsets.only(right: -4),
                  controller: scrollCtrl,
                  thumbVisibility: false,
                  thickness: AppTamanios.sm,
                  radius: const Radius.circular(AppTamanios.sm),
                  minThumbLength: AppTamanios.md,
                  //crossAxisMargin: 2,
                  mainAxisMargin: AppTamanios.md,
                  trackVisibility: false,
                  thumbColor: AppColores.secundariOscuro.withOpacity(0.1),
                  child: ListView(
                    padding: const EdgeInsets.all(AppTamanios.sm),
                    controller: scrollCtrl,
                    children: [
                      Text(
                        'Texto Recogido',
                        style: AppEstiloTexto.titulo.copyWith(color: AppColores.primario),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTamanios.sm),
                      Text(
                        'Número de Fotos: ${ocrProv.fotosProcesadas}',
                        style: AppEstiloTexto.subtitulo,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: AppTamanios.sm),

                      // Selector de modo de visualización (Bruto/Filas/Marcado/Compacto).
                      /* Wrap(
                        spacing: AppTamanios.sm,
                        runSpacing: AppTamanios.sm,
                        children: [
                          ChoiceChip(
                            label: const Text('Bruto'),
                            selected: modo == _VistaTexto.bruto,
                            onSelected: (_) => setState(() => modo = _VistaTexto.bruto),
                          ),
                          ChoiceChip(
                            label: const Text('Por filas (--> )'),
                            selected: modo == _VistaTexto.filas,
                            onSelected: (_) => setState(() => modo = _VistaTexto.filas),
                          ),
                          ChoiceChip(
                            label: const Text('Por filas (\\_/)'),
                            selected: modo == _VistaTexto.filasMarcado,
                            onSelected: (_) => setState(() => modo = _VistaTexto.filasMarcado),
                          ),
                          ChoiceChip(
                            label: const Text('Compacto (sin sep.)'),
                            selected: modo == _VistaTexto.compacto,
                            onSelected: (_) => setState(() => modo = _VistaTexto.compacto),
                          ),
                        ],
                      ),*/

                      const Divider(color: AppColores.secundario),

                      SelectableText(
                        ocrProv.ocrPorFilas,
                        style: AppEstiloTexto.notaM,
                      ),

                      const SizedBox(height: AppTamanios.lg),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _enviarResultadosSpring(OcrProvider ocrProv, RegistroProvider regProv) async {
    try {
      final api = TickeaApi();
      final fecha = _fechaFormatoBack(regProv.strFecha); // de dd_MM_yyyy -> yyyy-MM-dd
      final lineas = ocrProv.ocrPorFilas;

      debugPrint('[NuevaFoto] Enviando ticket: uid=${regProv.uidUser}, fecha=$fecha, lineas=${lineas.length}');

      final respuesta = await api.enviarTicket(
        uidUsuario: regProv.uidUser,
        fecha: fecha,
        productos: lineas.split("\n").map((linea) => {'texto': linea}).toList(),
      );

      if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
        if (!mounted) return;
        await AppPopup.alerta(
          context: context,
          titulo: 'Enviado',
          contenido: 'Datos enviados correctamente.',
          textoOk: 'OK',
          alerta: false,
        );
      } else {
        if (!mounted) return;
        await AppPopup.alerta(
          context: context,
          titulo: 'Error al enviar',
          contenido: 'El servidor respondió con ${respuesta.statusCode}.',
          textoOk: 'Cerrar',
          alerta: true,
        );
      }
    } catch (e) {
      debugPrint('[NuevaFoto] Error al enviar ticket: $e');
      if (!mounted) return;
      await AppPopup.alerta(
        context: context,
        titulo: 'Error de conexión',
        contenido: 'No se pudo conectar con el backend.\n$e',
        textoOk: 'Cerrar',
        alerta: true,
      );
    }

    if (mounted) {
      final prov = Provider.of<RegistroProvider>(context, listen: false);
      final uidUser = prov.getUidUser;
      final dias = await TickeaApi.listarFechasRegistradas(uidUser);
      prov.setDiasRegistrados(dias);
    }
  }

  ElevatedButton botonFlotante({
    required Function onPressed,
    required String texto,
    bool esAcierto = true,
  }) {
    return ElevatedButton(
      onPressed: onPressed == null ? null : () => onPressed(),
      style: ElevatedButton.styleFrom(
        backgroundColor: esAcierto ? AppColores.primario.withOpacity(0.1) : AppColores.secundario.withOpacity(0.1),
        side: BorderSide(color: esAcierto ? AppColores.primariOscuro : AppColores.secundariOscuro),
        shadowColor: Colors.transparent,
      ),
      child: Text(
        texto,
        style: TextStyle(color: esAcierto ? AppColores.primariOscuro : AppColores.secundariOscuro),
      ),
    );
  }
}

class _CargandoView extends StatelessWidget {
  const _CargandoView({required this.texto});
  final String texto;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(
          color: AppColores.secundariOscuro,
        ),
        const SizedBox(height: 12),
        Text(texto, style: AppEstiloTexto.notaM),
      ]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.mensaje});
  final String mensaje;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Error cámara: $mensaje',
        style: AppEstiloTexto.error,
        textAlign: TextAlign.center,
      ),
    );
  }
}
