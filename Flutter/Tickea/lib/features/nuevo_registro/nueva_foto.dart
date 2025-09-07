import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tickea/core/ocr/captura_proveedor.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/widgets/app_componentes.dart';
import 'package:tickea/widgets/app_popups.dart';
import '../registro/registro_provider.dart';
import 'package:flutter/material.dart';

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
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controlador.initialize();
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

  Future<void> _dispararFoto() async {
    final camara = _camara;
    if (camara == null || !camara.value.isInitialized || camara.value.isTakingPicture) {
      return;
    }
    try {
      final foto = await camara.takePicture();
      if (!mounted) return;
      context.read<CapturaProveedor>().agregarFoto(foto);
    } catch (e) {
      debugPrint('Error al tomar foto: $e');
      if (!mounted) return;
      await AppPopup.alerta(
        context: context,
        titulo: 'Error',
        contenido: 'No se pudo tomar la foto: $e',
        textoOk: 'Cerrar',
      );
    }
  }

  void _borrarUltima() {
    context.read<CapturaProveedor>().borrarUltima();
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

  //usamos el dispose para liberar recursos
  @override
  void dispose() {
    _camara?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalFotos = context.watch<CapturaProveedor>().totalFotos;
    final isFoto = totalFotos > 0;
    debugPrint(' Capturas en RAM: $totalFotos');
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
                          //esto es para que no se deforme la imagen
                          aspectRatio: _camara!.value.aspectRatio,
                          child: CameraPreview(_camara!),
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
                      bottom: AppTamanios.md,
                      left: AppTamanios.md,
                      child: ElevatedButton.icon(
                        onPressed: isFoto ? _borrarUltima : null,
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.transparent,
                          backgroundColor: isFoto ? AppColores.primario : AppColores.grisClaro.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTamanios.base,
                            vertical: AppTamanios.base,
                          ),
                          side: BorderSide(color: isFoto ? AppColores.grisClaro : AppColores.textoOscuro),
                        ),
                        icon: Icon(Icons.undo,
                            color: isFoto ? AppColores.grisClaro : AppColores.textoOscuro), // icono de deshacer
                        label: Text(
                          'Borrar última',
                          style: AppEstiloTexto.notaXS.copyWith(
                              color: isFoto ? AppColores.grisClaro : AppColores.textoOscuro,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )),
      floatingActionButton: _inicializada && _error == null
          ? FloatingActionButton(
              backgroundColor: AppColores.secundariOscuro,
              onPressed: _dispararFoto,
              child: const Icon(
                Icons.camera,
                color: AppColores.fondo,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
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
