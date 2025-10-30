import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:tickea/core/ocr/ocr_servicio.dart';
import 'dart:math' as math;

enum OcrEstado { inactivo, capturando, reconociendo, error }

const int _ventanaFilas = 3;

// cuántas filas recientes
const double _facTolCentro = 0.65;

// factor para tolerancia por centro
const double _minOverlapFrac = 0.35;

// % mínimo de solape

class OcrProvider extends ChangeNotifier {
  OcrProvider({required OcrServicio ocrServicio}) : _ocrServicio = ocrServicio;
  final OcrServicio _ocrServicio;

  OcrEstado _estado = OcrEstado.inactivo;
  OcrEstado get estado => _estado;

  String _ultimoError = '';
  String get ultimoError => _ultimoError;

  // Almacenar cada captura por separado
  final List<String> _ocrFilasPorFoto = [];
  final List<String> _ocrBrutoPorFoto = [];

  int get fotosProcesadas => max(_ocrFilasPorFoto.length, _ocrBrutoPorFoto.length);
  bool get hayTexto => _ocrFilasPorFoto.isNotEmpty || _ocrBrutoPorFoto.isNotEmpty;
  String get ocrPorFilas => _ocrFilasPorFoto.join('\n');
  String get ocrBruto => _ocrBrutoPorFoto.join('\n');

  void _setEstado(OcrEstado nuevo) {
    _estado = nuevo;
    notifyListeners();
  }

  void _setError(String error) {
    _ultimoError = error;
    _setEstado(OcrEstado.error);
    notifyListeners();
  }

  Future<void> capturarYOcr(CameraController camCtrl) async {
    if (_estado == OcrEstado.capturando || _estado == OcrEstado.reconociendo) return;

    try {
      _setEstado(OcrEstado.capturando);
      final XFile foto = await camCtrl.takePicture();

      _setEstado(OcrEstado.reconociendo);
      final (texto, elementos) = await _ocrServicio.ocrBrutoYElementosYDescarta(imagenPath: foto.path);

      _logEnChunks('OCR resultado', texto);

      // Construir POR FILAS y acumular
      final filas = _aFilas(elementos);
// Guardar por-foto para poder borrar en caso necesario.
      _ocrFilasPorFoto.add(filas);
      _ocrBrutoPorFoto.add(texto);
      _setEstado(OcrEstado.inactivo);
      notifyListeners();
    } catch (e) {
      _setError('No se pudo leer el ticket. $e');
    }
  }

  void borrarUltimoOcr() {
    if (_ocrFilasPorFoto.isNotEmpty) _ocrFilasPorFoto.removeLast();
    if (_ocrBrutoPorFoto.isNotEmpty) _ocrBrutoPorFoto.removeLast();
    notifyListeners();
    _logEnChunks('OCR resultado', _ocrFilasPorFoto.join('\n'));
  }

  // Limpia el estado de error para permitir reintentar.
  void limpiarErrores() {
    if (_estado == OcrEstado.error) {
      _ultimoError = '';
      _setEstado(OcrEstado.inactivo);
    }
  }

  // Reinicia la sesión de OCR (borra textos acumulados y contadores).
  void resetSesion() {
    _ultimoError = '';
    _ocrFilasPorFoto.clear();
    _ocrBrutoPorFoto.clear();
    _setEstado(OcrEstado.inactivo);
  }

  @override
  void dispose() {
    _ocrServicio.dispose(); // no esperado; suficiente aquí
    super.dispose();
  }

  String _aFilas(
    List<OcrElemento> elems,
  ) {
    if (elems.isEmpty) return '';

    final alturas = elems.map((e) => e.alto).where((h) => h > 0).toList()..sort();
    final mediana = alturas.isEmpty
        ? 0.0
        : (alturas.length.isOdd
            ? alturas[alturas.length ~/ 2]
            : (alturas[alturas.length ~/ 2 - 1] + alturas[alturas.length ~/ 2]) / 2);
    final tolBaseCentro = (mediana * _facTolCentro).clamp(6.0, double.infinity);

    // Arriba es abajo
    final ordenados = List<OcrElemento>.from(elems)..sort((a, b) => a.centroY.compareTo(b.centroY));

    // Cada fila mantiene su banda vertical dinámica.
    final filas = <_FilaBand>[];
    for (final e in ordenados) {
      if (filas.isEmpty) {
        filas.add(_FilaBand.iniciaCon(e));
        continue;
      }

      final f = filas.last;
      bool _encaja(OcrElemento e, _FilaBand f) {
        final altFila = (f.bottom - f.top).clamp(1.0, double.infinity);
        // Tolerancia dinámica: base vs tamaños reales
        final tolCentro = math.max(tolBaseCentro, math.max(e.alto * 0.60, altFila * 0.60));
        final centerOk = (e.centroY - f.centro).abs() <= tolCentro;

        // Solape vertical relativo
        final overlap = math.max(0.0, math.min(f.bottom, e.caja.bottom) - math.max(f.top, e.caja.top));
        final overlapOk = overlap >= _minOverlapFrac * math.min(e.alto, altFila);

        return centerOk || overlapOk;
      }

      for (final e in ordenados) {
        if (filas.isEmpty) {
          filas.add(_FilaBand.iniciaCon(e));
          continue;
        }

        // Probar con las ultimas filas (para el bamboleo del papel).
        _FilaBand? candidata;
        for (final f in filas.reversed.take(_ventanaFilas)) {
          if (_encaja(e, f)) {
            candidata = f;
            break;
          }
        }

        if (candidata != null) {
          candidata.add(e);
        } else {
          filas.add(_FilaBand.iniciaCon(e));
        }
      }
      // Ordenar cada fila por X y unir con separador
      final sb = StringBuffer();
      for (var i = 0; i < filas.length; i++) {
        final fila = filas[i].elements..sort((a, b) => a.caja.left.compareTo(b.caja.left));
        sb.write(fila.map((w) => w.texto).join(" "));
        if (i < filas.length - 1) sb.write('\n');
      }
      return sb.toString();
    }

    // Dentro de cada fila: ordenar por X e imprimir con el separador.
    final sb = StringBuffer();
    for (var i = 0; i < filas.length; i++) {
      final filaOrdenada = filas[i].elements..sort((a, b) => a.caja.left.compareTo(b.caja.left));
      sb.write(filaOrdenada.map((w) => w.texto).join(" "));
      if (i < filas.length - 1) sb.write('\n');
    }
    return sb.toString();
  }

  // Logs largos en trozos
  void _logEnChunks(String titulo, String texto, {int chunk = 800}) {
    debugPrint('[$titulo] len=${texto.length}');
    for (int i = 0; i < texto.length; i += chunk) {
      final fin = (i + chunk < texto.length) ? i + chunk : texto.length;
      debugPrint(texto.substring(i, fin));
    }
  }
}

// Banda vertical de una fila (mínimo estado posible).
class _FilaBand {
  double top;
  double bottom;
  double _sumCentro;
  int _count;
  final List<OcrElemento> elements;

  double get centro => _sumCentro / _count;

  _FilaBand._(this.top, this.bottom, this._sumCentro, this._count, this.elements);

  //Crea la fila con el primer elemento.
  factory _FilaBand.iniciaCon(OcrElemento e) => _FilaBand._(e.caja.top, e.caja.bottom, e.centroY, 1, [e]);

  //Añade un elemento y expande la banda vertical.
  void add(OcrElemento e) {
    elements.add(e);
    top = math.min(top, e.caja.top);
    bottom = math.max(bottom, e.caja.bottom);
    _sumCentro += e.centroY;
    _count++;
  }
}
