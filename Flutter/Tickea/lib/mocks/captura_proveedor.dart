import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CapturaProveedor with ChangeNotifier {
  final List<XFile> _buffer = [];

  List<XFile> get buffer => List.unmodifiable(_buffer);

  int get totalFotos => _buffer.length;

  void agregarFoto(XFile foto) {
    _buffer.add(foto);
    notifyListeners();
  }

  void borrarUltima() {
    if (_buffer.isNotEmpty) {
      _buffer.removeLast();
      notifyListeners();
    }
  }

  void limpiarBuffer() {
    _buffer.clear();
    notifyListeners();
  }

  List<XFile> cogerYVaciar() {
    final fotos = List<XFile>.from(_buffer);
    limpiarBuffer();
    return fotos;
  }
}
