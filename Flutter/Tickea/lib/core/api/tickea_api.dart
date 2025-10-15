import 'dart:convert';

class TickeaApi {
  static const String baseUrl = 'http://localhost:8080/tickea';
  static get http => null;

  //Lista de fechas ya tratadas
  Future<Set<DateTime>> listarFechasRegistradas(String uid) async {
    final uri = Uri.parse('$baseUrl/fechas-registradas?uid=$uid');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}al obtener las fechas registradas');
    }
    final List<dynamic> fechas = jsonDecode(response.body) as List<dynamic>;
    final fechasFormateadas = <DateTime>{};
    for (final fecha in fechas) {
      fechasFormateadas.add(_formatoDia(fecha));
    }
    return fechasFormateadas;
  }

  DateTime _formatoDia(DateTime d) => DateTime(d.year, d.month, d.day);
}
