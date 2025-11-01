import 'dart:convert';

class Producto {
  final String nombre;
  final String codigo;
  final int operaciones;
  final double importeTotal; // €
  final double peso; // kg
  final int unidades;

  const Producto({
    required this.nombre,
    required this.codigo,
    required this.operaciones,
    required this.importeTotal,
    required this.peso,
    required this.unidades,
  });
// deserializar desde JSON

  factory Producto.fromJson(Map<String, dynamic> json) {
    // Formateo de datos a double e int
    double _toDouble(dynamic datoD) {
      if (datoD == null) return 0;
      if (datoD is num) return datoD.toDouble();
      final dato = datoD.toString().trim().replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(dato) ?? 0.0;
    }

    int _toInt(dynamic datoI) {
      if (datoI == null) return 0;
      if (datoI is num) return datoI.toInt();
      return int.tryParse(datoI.toString().trim()) ?? 0;
    }

    return Producto(
      nombre: (json['nombreProducto'] ?? '').toString(),
      codigo: (json['codigoProducto'] ?? '').toString(),
      operaciones: _toInt(json['operaciones']),
      importeTotal: _toDouble(json['totalImporte'] ?? json['importe_total']),
      peso: _toDouble(json['peso']),
      unidades: _toInt(json['unidades']),
    );
  }

// serializar a JSON
  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'codigo': codigo,
        'operaciones': operaciones,
        'importeTotal': importeTotal,
        'peso': peso,
        'unidades': unidades,
      };

  static List<Producto> listFromJsonString(String fuenteOriginal) {
    final map = jsonDecode(fuenteOriginal) as Map<String, dynamic>;
    final list = (map['productos'] as List? ?? []);
    return list.map((e) => Producto.fromJson(e as Map<String, dynamic>)).toList();
  }
}
