import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tickea/features/historico/datos/modelos/res_historico.dart';

import 'modelos/producto.dart';

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
    final yyyy = dia.year.toString().padLeft(4, '0');
    final mm = dia.month.toString().padLeft(2, '0');
    final dd = dia.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

// Construimos la URI con parámetros de forma mas o menos dinamica.
  Uri _constructorUri(String ruta, Map<String, String> parametros) {
    return Uri.parse('$baseUrl$ruta').replace(queryParameters: parametros);
  }

  Future<ResHistorico> _mensajesRes(http.Response res) async {
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      _logHttp('PARSED JSON', payload: json);
      if (json is List) {
        // El endpoint devuelve un array de productos
        final productos = json.whereType<Map<String, dynamic>>().map((e) => Producto.fromJson(e)).toList();
        return ResHistorico(productos: productos);
      } else if (json is Map<String, dynamic>) {
        //Me aseguro la compatibilidad con esto
        return ResHistorico.fromJson(json);
      } else {
        throw HistoricoServerError('Formato de respuesta no reconocido');
      }
    }
    if (res.statusCode == 404) {
      _logHttp('PARSE_ERROR', payload: res.body);
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
    final uri = _constructorUri('/tickea/ticket-items', {
      'uid': uid,
      'fecha': fechaFormateada,
    });
    _logHttp('GET', uri: uri);
    final sw = Stopwatch()..start();
    final res = await http.get(uri);
    sw.stop();
    _logHttp('RES', uri: uri, status: res.statusCode, payload: res.body, took: sw.elapsed);

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
    final uri = _constructorUri('/tickea/ticket-items/rango', {
      'uid': uid,
      'fechaInicio': desdeFormateada,
      'fechaFin': hastaFormateada,
    });

    _logHttp('GET', uri: uri);
    final sw = Stopwatch()..start();
    final res = await http.get(uri);
    sw.stop();
    _logHttp('RES', uri: uri, status: res.statusCode, payload: res.body, took: sw.elapsed);

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

void _logHttp(
  String label, {
  Uri? uri,
  int? status,
  Object? payload,
  Duration? took,
}) {
  if (!kDebugMode) return;

  final buffer = StringBuffer('[HistoricoApi] $label');
  if (uri != null) buffer.writeln('\n  URI: $uri');
  if (status != null) buffer.writeln('  Status: $status');
  if (took != null) buffer.writeln('  Took: ${took.inMilliseconds} ms');
  log(buffer.toString());
  if (payload != null) {
    try {
      final pretty = const JsonEncoder.withIndent('  ').convert(
        payload is String ? jsonDecode(payload) : payload,
      );
      debugPrint(pretty); // respeta ancho y evita cortar
    } catch (_) {
      debugPrint(payload.toString());
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
