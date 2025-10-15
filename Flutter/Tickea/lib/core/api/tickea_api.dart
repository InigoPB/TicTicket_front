import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tickea/core/formateadores/fecha_formato.dart';

class TickeaApi {
  static const String baseUrl = 'http://192.168.137.1:8080';

  //Lista de fechas ya tratadas
  static Future<Set<DateTime>> listarFechasRegistradas(String uid) async {
    final uri = Uri.parse('$baseUrl/tickea/fechas-registradas?uid=$uid');
    debugPrint('[TickeaApi] GET $uri');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('[TickeaApi] body=${response.body}');
      throw Exception('Error ${response.statusCode}al obtener las fechas registradas');
    }
    final List<dynamic> fechas = jsonDecode(response.body) as List<dynamic>;
    final fechasFormateadas = <DateTime>{};
    for (final fecha in fechas) {
      final d = DateTime.parse(fecha as String);
      fechasFormateadas.add(DateTime(d.year, d.month, d.day));
    }
    debugPrint('[TickeaApi] fechasFormateadas=$fechasFormateadas');
    return fechasFormateadas;
  }
}
