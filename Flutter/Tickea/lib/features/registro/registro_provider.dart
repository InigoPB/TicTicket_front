import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:tickea/core/formateadores/fecha_formato.dart';

/* registro_provider.dart se va a encargar de manejar el estado de la fecha seleccionada en el registro asi nos
 ahorramos tener que pasar de uan pantalla a otra. es como una variable global.
 */

class RegistroProvider extends ChangeNotifier {
  String uidUser = 'uEvA26nZ9IRxPf7m2wDkV0CgtSi1';
  String get getUidUser => uidUser;

  String _strFecha = '';
  String get strFecha => _strFecha;

  String? _tempDirPath;
  String? get tempDirPath => _tempDirPath;

  Set<DateTime> _diasRegistrados = <DateTime>{};
  Set<DateTime> get diasRegistrados => _diasRegistrados;

  bool contieneDiaRegistrado(DateTime dia) {
    return _diasRegistrados.any((i) => i.year == dia.year && i.month == dia.month && i.day == dia.day);
  }

  void setFecha(DateTime fecha) {
    final nueva = fmtFecha(fecha);
    if (nueva == _strFecha) return;
    _strFecha = nueva;
    notifyListeners();
  }

  void setTempDirPath(String path) {
    if (_tempDirPath == path) return;
    _tempDirPath = path;
    notifyListeners();
  }

  void setUidUser(String uid) {
    if (uidUser == uid) return;
    uidUser = uid;
    notifyListeners();
  }

  void setDiasRegistrados(Set<DateTime> dias) {
    _diasRegistrados = dias;
    notifyListeners();
  }

  void clear() {
    if (_strFecha.isEmpty && _tempDirPath == null) return;
    _strFecha = '';
    _tempDirPath = null;
    _diasRegistrados.clear();
    notifyListeners();
  }
}
