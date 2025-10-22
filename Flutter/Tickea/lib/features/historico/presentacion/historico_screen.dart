import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/features/historico/datos/historico_api.dart';
import 'package:tickea/features/historico/presentacion/providers/historico_provider.dart';
import 'package:tickea/features/historico/presentacion/widgets/historico_calendario.dart';
import 'package:tickea/features/historico/presentacion/widgets/modo_selector.dart';
import 'package:tickea/features/historico/presentacion/widgets/sheet_historico.dart';
import 'package:tickea/features/historico/presentacion/widgets/ver_registros_boton.dart';
import 'package:tickea/widgets/app_componentes.dart';

class HistoricoScreen extends StatelessWidget {
  final HistoricoApi api;
  final String Function() obtenerUid;

  const HistoricoScreen({
    super.key,
    required this.api,
    required this.obtenerUid,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoricoNotificador(api: api, obtenerUid: obtenerUid),
      child: const _HistoricoView(),
    );
  }
}

class _HistoricoView extends StatelessWidget {
  const _HistoricoView();

  @override
  Widget build(BuildContext context) {
    final notificacion = context.watch<HistoricoNotificador>();
    final estado = notificacion.state;
    final fecha = DateFormat('dd/MM/yyyy', 'es_ES');

    Future<void> _abrirSheet() async {
      final respuesta = await notificacion.buscar();
      final estado = notificacion.state;
      final titulo = estado.modo == HistoricoModo.dia
          ? 'Histórico del ${fecha.format(estado.diaSeleccionado!)}'
          : 'Histórico del ${fecha.format(estado.rangoDesde!)} al ${fecha.format(estado.rangoHasta!)}';
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ChangeNotifierProvider.value(
          value: notificacion,
          child: Consumer<HistoricoNotificador>(
            builder: (_, prov, __) => HistoricoSheet(
              cargando: prov.state.cargando,
              error: prov.state.error,
              datos: respuesta,
              onReintento: () {
                Navigator.of(context).pop();
                _abrirSheet();
              },
              titulo: titulo,
            ),
          ),
        ),
      );
      notificacion.reset();
    }

    Future<void> _confirmacionPopup() async {
      final estado = notificacion.state;
      final texto = estado.modo == HistoricoModo.dia
          ? '¿Deseas ver el histórico del ${fecha.format(estado.diaSeleccionado!)} ?'
          : '¿Deseas ver el histórico desde el ${fecha.format(estado.rangoDesde!)} hasta el ${fecha.format(estado.rangoHasta!)}?';
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirmar selección'),
          content: Text(texto),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
      if (ok == true) {
        notificacion.confirmarSeleccion();
      }
    }

    return Scaffold(
      appBar: const AppCabecero(
        ruta: '/principal',
      ),
      backgroundColor: AppColores.fondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ModoSelector(modo: estado.modo, onCambiar: notificacion.setMode),
              const SizedBox(height: AppTamanios.lg),
              Expanded(
                child: HistoricoCalendario(
                    modo: estado.modo,
                    rangoFin: estado.rangoHasta,
                    rangoInicio: estado.rangoDesde,
                    diaSeleccionado: estado.diaSeleccionado,
                    onDiaSeleccionado: notificacion.seleccionarDia,
                    onRangoSeleccionado: notificacion.selaccionarRango),
              ),
              const SizedBox(height: AppTamanios.base),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () async {
                        final valid = estado.modo == HistoricoModo.dia ? estado.isDiaValido : estado.isRangoValido;
                        if (!valid) return;
                        await _confirmacionPopup();
                      },
                      child: const Text('Confirmar selección'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTamanios.base),
              VerRegistrosButton(
                enabled: estado.esApto && !estado.cargando,
                onPressed: _abrirSheet,
                text: 'Ver registros',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
