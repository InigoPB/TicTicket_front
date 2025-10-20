import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tickea/features/historico/datos/modelos/res_historico.dart';

abstract class HistoricoApi {
  Future<ResHistorico> listarPorDia({
    required String uid,
    required DateTime fecha,
  });

  Future<ResHistorico> listarPorRango({
    required String uid,
    required DateTime desde,
    required DateTime hasta,
  });
}

class HistoricoHttpApi implements HistoricoApi {
  final String baseUrl;
  final http.Client client;

  HistoricoHttpApi({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  String _formateoFecha(DateTime dia) {
    // dd_MM_yyyy
    final dd = dia.day.toString().padLeft(2, '0');
    final mm = dia.month.toString().padLeft(2, '0');
    final yyyy = dia.year.toString();
    return '$dd\_$mm\_$yyyy';
  }

// Construimos la URI con parámetros de forma mas o menos dinamica.
  Uri _constructorUri(String ruta, Map<String, String> parametros) {
    return Uri.parse('$baseUrl$ruta').replace(queryParameters: parametros);
  }

// Manejo de respuestas
  Future<ResHistorico> _mensajesRes(http.Response res) async {
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return ResHistorico.fromJson(json);
    }
    if (res.statusCode == 404) {
      throw HistoricoNotFound('No se encontraron registros');
    }
    throw HistoricoServerError('Error del servidor (${res.statusCode})');
  }

// Listar por dia
  @override
  Future<ResHistorico> listarPorDia({
    required String uid,
    required DateTime fecha,
  }) async {
    final fechaFormateada = _formateoFecha(fecha);
    final uri = _constructorUri('/historico/dia', {
      'uid': uid,
      'fecha': fechaFormateada,
    });
    try {
      final res = await client.get(uri).timeout(const Duration(seconds: 15));
      return _mensajesRes(res);
    } on HistoricoFailure {
      rethrow;
    } on Exception catch (e) {
      throw HistoricoNetworkError('Fallo de red: $e');
    }
  }

// Listar por rango de fechas
  @override
  Future<ResHistorico> listarPorRango({
    required String uid,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final desdeFormateada = _formateoFecha(desde);
    final hastaFormateada = _formateoFecha(hasta);
    final uri = _constructorUri('/historico/rango', {
      'uid': uid,
      'desde': desdeFormateada,
      'hasta': hastaFormateada,
    });
    try {
      final res = await client.get(uri).timeout(const Duration(seconds: 15));
      return _mensajesRes(res);
    } on HistoricoFailure {
      rethrow;
    } on Exception catch (e) {
      throw HistoricoNetworkError('Fallo de red: $e');
    }
  }
}

//Excepciones tipadas para controlar la UI
sealed class HistoricoFailure implements Exception {
  final String message;
  HistoricoFailure(this.message);
  @override
  String toString() => message;
}

class HistoricoNotFound extends HistoricoFailure {
  HistoricoNotFound(super.message);
}

class HistoricoServerError extends HistoricoFailure {
  HistoricoServerError(super.message);
}

class HistoricoNetworkError extends HistoricoFailure {
  HistoricoNetworkError(super.message);
}
