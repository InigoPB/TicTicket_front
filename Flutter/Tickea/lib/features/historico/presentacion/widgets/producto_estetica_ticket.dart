import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/features/historico/datos/modelos/producto.dart';

class ProductoEsteticaTicket extends StatelessWidget {
  final Producto producto;
  final NumberFormat precio;
  final NumberFormat cantidad;

  const ProductoEsteticaTicket({
    super.key,
    required this.producto,
    required this.precio,
    required this.cantidad,
  });

  @override
  Widget build(BuildContext context) {
    const separacion = '------------------------';
    textClaveValor(String clave, String valor) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text: clave.padRight(AppTamanios.md as int),
                style: AppEstiloTexto.cuerpo.copyWith(shadows: AppEstiloTexto.shadows(0.5))),
            const TextSpan(text: '  '),
            TextSpan(text: valor, style: AppEstiloTexto.cuerpo),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTamanios.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textAlign: TextAlign.center,
            producto.nombre.toUpperCase(),
            style: AppEstiloTexto.subtitulo,
          ),
          const SizedBox(height: AppTamanios.base / 2),
          textClaveValor('Operaciones:', '${producto.operaciones}'),
          textClaveValor('Total Impor:', '${producto.importeTotal}'),
          textClaveValor('Peso:', '${producto.peso}'),
          textClaveValor('Unidades:', '${producto.unidades}'),
          const SizedBox(height: AppTamanios.sm),
          const Text(separacion, style: AppEstiloTexto.cuerpo),
        ],
      ),
    );
  }
}
