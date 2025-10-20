import 'package:tickea/features/historico/datos/modelos/producto.dart';

class ResHistorico {
  final List<Producto> productos;

  const ResHistorico({
    required this.productos,
  });

  factory ResHistorico.fromJson(Map<String, dynamic> json) {
    final productosJson = json['productos'] as List? ?? [];
    final productosList = productosJson.map((e) => Producto.fromJson(e as Map<String, dynamic>)).toList();

    return ResHistorico(
      productos: productosList,
    );
  }
  bool get isEmpty => productos.isEmpty;
}
