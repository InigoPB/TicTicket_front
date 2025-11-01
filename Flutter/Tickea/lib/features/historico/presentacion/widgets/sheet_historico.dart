import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/features/historico/datos/modelos/producto.dart';
import 'package:tickea/features/historico/datos/modelos/res_historico.dart';
import 'package:tickea/features/historico/presentacion/widgets/producto_estetica_ticket.dart';
import 'package:tickea/widgets/app_componentes.dart';

class HistoricoSheet extends StatelessWidget {
  final bool cargando;
  final String? error;
  final ResHistorico? datos;
  final VoidCallback onReintento;
  final String titulo;

  const HistoricoSheet({
    super.key,
    required this.cargando,
    required this.error,
    required this.datos,
    required this.onReintento,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    final euros = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    final numEs = NumberFormat.decimalPattern('es_ES');

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColores.fondo,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTamanios.md),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: AppTamanios.base),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColores.textoOscuro.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppTamanios.base / 2),
                  ),
                ),
                const SizedBox(height: AppTamanios.md),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColores.grisPrimari.withOpacity(0.06), // opcional, tu estilo
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      titulo,
                      softWrap: true,
                      maxLines: null,
                      overflow: TextOverflow.visible,
                      style: AppEstiloTexto.titulo.copyWith(
                        color: AppColores.primariOscuro,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (cargando) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: AppColores.secundario,
                        ));
                      }
                      if (error != null) {
                        return _ErrorView(mensaje: error!, onReintento: onReintento);
                      }
                      final productos = datos?.productos ?? <Producto>[];
                      if (productos.isEmpty) {
                        return const _EmptyView();
                      }
                      return ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: productos.length,
                        itemBuilder: (_, i) => ProductoEsteticaTicket(
                          producto: productos[i],
                          precio: euros,
                          cantidad: numEs,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintento;

  const _ErrorView({
    required this.mensaje,
    required this.onReintento,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
          padding: EdgeInsets.all(AppTamanios.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTexto.textoError(mensaje, align: TextAlign.center),
              Text(mensaje, style: AppEstiloTexto.cuerpo),
              const SizedBox(height: AppTamanios.base),
              AppBotonPrimario(
                tamAncho: AppTamanios.xxxl * 3,
                tamAlto: AppTamanios.xxl,
                texto: 'Reintentar',
                onPressed: onReintento,
              ),
            ],
          )),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppTexto.textoError(
        'No hay datos disponibles para el rango seleccionado.',
        align: TextAlign.center,
      ),
    );
  }
}
