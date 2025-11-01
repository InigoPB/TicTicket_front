import 'package:flutter/cupertino.dart';
import 'package:tickea/features/historico/datos/historico_api.dart';
import 'package:tickea/features/historico/datos/modelos/producto.dart';
import 'package:tickea/features/historico/datos/modelos/res_historico.dart';

enum HistoricoModo { dia, rango }

//Estado
class HistoricoState {
  final HistoricoModo modo;
  final DateTime? diaSeleccionado;
  final DateTime? rangoDesde;
  final DateTime? rangoHasta;

  final bool confirmacionAceptada;
  final bool cargando;
  final String? error;

  final List<Producto> productos;

  const HistoricoState({
    required this.modo,
    required this.diaSeleccionado,
    required this.rangoDesde,
    required this.rangoHasta,
    required this.confirmacionAceptada,
    required this.cargando,
    required this.error,
    required this.productos,
  });

  factory HistoricoState.initial() {
    final now = DateTime.now();
    final diaInicio = DateTime(now.year, now.month, now.day);
    return HistoricoState(
      modo: HistoricoModo.dia,
      diaSeleccionado: diaInicio,
      rangoDesde: null,
      rangoHasta: null,
      confirmacionAceptada: false,
      cargando: false,
      error: null,
      productos: const [],
    );
  }

  bool get isDiaValido => diaSeleccionado != null;
  bool get isRangoValido => rangoDesde != null && rangoHasta != null;
  bool get esApto =>
      confirmacionAceptada &&
      (modo == HistoricoModo.dia && isDiaValido || modo == HistoricoModo.rango && isRangoValido);

  HistoricoState copyWith({
    HistoricoModo? modo,
    DateTime? diaSeleccionado,
    DateTime? rangoDesde,
    DateTime? rangoHasta,
    bool? confirmacionAceptada,
    bool? cargando,
    String? error,
    List<Producto>? productos,
  }) {
    return HistoricoState(
      modo: modo ?? this.modo,
      diaSeleccionado: diaSeleccionado ?? this.diaSeleccionado,
      rangoDesde: rangoDesde ?? this.rangoDesde,
      rangoHasta: rangoHasta ?? this.rangoHasta,
      confirmacionAceptada: confirmacionAceptada ?? this.confirmacionAceptada,
      cargando: cargando ?? this.cargando,
      error: error,
      productos: productos ?? this.productos,
    );
  }
}

class HistoricoNotificador extends ChangeNotifier {
  final HistoricoApi api;
  final String Function() obtenerUid;

  HistoricoState _state = HistoricoState.initial();
  HistoricoState get state => _state;

  HistoricoNotificador({
    required this.api,
    required this.obtenerUid,
  });

  void setMode(HistoricoModo modo) {
    _state = _state.copyWith(
      modo: modo,
      diaSeleccionado: modo == HistoricoModo.dia ? _state.diaSeleccionado : null,
      rangoDesde: modo == HistoricoModo.rango ? _state.rangoDesde : null,
      rangoHasta: modo == HistoricoModo.rango ? _state.rangoHasta : null,
      confirmacionAceptada: false,
      error: null,
    );
    notifyListeners();
  }

  void seleccionarDia(DateTime dia) {
    final d = DateTime(dia.year, dia.month, dia.day);
    _state = _state.copyWith(diaSeleccionado: d, error: null);
    notifyListeners();
  }

  void selaccionarRango(DateTime? desde, DateTime? hasta) {
    DateTime? dsd = desde != null ? DateTime(desde.year, desde.month, desde.day) : null;
    DateTime? hst = hasta != null ? DateTime(hasta.year, hasta.month, hasta.day) : null;
    _state = _state.copyWith(rangoDesde: dsd, rangoHasta: hst, error: null);
    notifyListeners();
  }

  void confirmarSeleccion() {
    _state = _state.copyWith(confirmacionAceptada: true, error: null);
    notifyListeners();
  }

  void _setLoading(bool cargando) {
    _state = _state.copyWith(cargando: cargando);
    notifyListeners();
  }

  void _setError(String? error) {
    _state = _state.copyWith(error: error);
    notifyListeners();
  }

  void _setProductos(List<Producto> productos) {
    _state = _state.copyWith(productos: productos);
    notifyListeners();
  }

  void reset() {
    _state = HistoricoState.initial();
    notifyListeners();
  }

  Future<ResHistorico?> buscar() async {
    if (!_state.esApto) return null;
    _setLoading(true);
    _setError(null);
    try {
      final uid = obtenerUid();
      ResHistorico res;
      if (_state.modo == HistoricoModo.dia) {
        res = await api.listarPorDia(uid: uid, fecha: _state.diaSeleccionado!);
        _setProductos(res.productos);
        _setLoading(false);
        return res;
      } else {
        res = await api.listarPorRango(
          uid: uid,
          desde: _state.rangoDesde!,
          hasta: _state.rangoHasta!,
        );
        _setProductos(res.productos);
        _setLoading(false);
        return res;
      }
    } on HistoricoFailure catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setLoading(false);
    }
  }
}

/*abstract class HistoricoProvider {
  void setMode(HistoricoModo modo);
  void selectDay(DateTime day);
  void selectRange(DateTime? start, DateTime? end);
  void confirmSelection();
  void reset();

  Future<void> buscaYDame();*/
