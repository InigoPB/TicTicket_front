import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';

class OcrElemento {
  final String texto;
  final Rect caja;
  OcrElemento({required this.texto, required this.caja});

  double get centroY => caja.top + caja.height / 2;
  double get alto => caja.height;
  double get ancho => caja.width;
}

class OcrServicio {
  TextRecognizer? _textRecognizer;

  Future<void> inicializar() async {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
  }

  Future<String> ocrYDescarta({required String imagenPath}) async {
    final (enBruto, _) = await ocrBrutoYElementosYDescarta(imagenPath: imagenPath);
    return enBruto;
  }

  Future<(String, List<OcrElemento>)> ocrBrutoYElementosYDescarta({
    required String imagenPath,
  }) async {
    await inicializar();
    final file = File(imagenPath);
    try {
      final inputImage = InputImage.fromFile(file);
      final RecognizedText resultadoTexto = await _textRecognizer!.processImage(inputImage);

      final elementos = <OcrElemento>[];
      for (final b in resultadoTexto.blocks) {
        for (final l in b.lines) {
          for (final e in l.elements) {
            final rect = e.boundingBox ?? Rect.zero;
            elementos.add(OcrElemento(texto: e.text, caja: rect));
          }
        }
      }
      return (resultadoTexto.text, elementos);
    } catch (e, st) {
      debugPrint('OCR error: $e\n$st');
      rethrow;
    } finally {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('No se pudo borrar la imagen temporal: $e');
      }
    }
  }

  Future<void> dispose() async {
    await _textRecognizer?.close();
    _textRecognizer = null;
  }
}
