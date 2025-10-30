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
                text: clave.padRight(16), style: AppEstiloTexto.cuerpo.copyWith(shadows: AppEstiloTexto.shadows(0.5))),
            const TextSpan(text: '  '),
            TextSpan(text: valor, style: AppEstiloTexto.cuerpo),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: AppTamanios.lg, right: AppTamanios.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              producto.nombre.toUpperCase(),
              style: AppEstiloTexto.subtitulo
                  .copyWith(color: AppColores.primariOscuro, shadows: AppEstiloTexto.shadows(0.5)),
            ),
          ),
          const SizedBox(height: AppTamanios.base),
          textClaveValor('Operaciones:', '${producto.operaciones}'),
          textClaveValor('Total Impor:', '${producto.importeTotal}'),
          textClaveValor('Peso:', '${producto.peso}'),
          textClaveValor('Unidades:', '${producto.unidades}'),
          const SizedBox(height: AppTamanios.base),
          const Center(child: Text(separacion, style: AppEstiloTexto.cuerpo)),
        ],
      ),
    );
  }
}
