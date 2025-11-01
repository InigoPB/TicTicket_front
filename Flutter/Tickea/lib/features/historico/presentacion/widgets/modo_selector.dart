import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tickea/core/theme/app_styles.dart';
import 'package:tickea/features/historico/presentacion/providers/historico_provider.dart';

class ModoSelector extends StatelessWidget {
  final HistoricoModo modo;
  final ValueChanged<HistoricoModo> onCambiar;

  const ModoSelector({
    super.key,
    required this.modo,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    final isDia = modo == HistoricoModo.dia;
    return Row(
      children: [
        Expanded(
          child: _ToggleButton(
            texto: 'Día',
            seleccionado: isDia,
            onTap: () => onCambiar(HistoricoModo.dia),
          ),
        ),
        const SizedBox(width: AppTamanios.base),
        Expanded(
          child: _ToggleButton(
            texto: 'Rango',
            seleccionado: !isDia,
            onTap: () => onCambiar(HistoricoModo.rango),
          ),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.texto,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTamanios.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTamanios.md,
        ),
        decoration: BoxDecoration(
          color: seleccionado ? AppColores.primario : AppColores.fondo,
          borderRadius: BorderRadius.circular(AppTamanios.md),
          border: Border.all(
            color: seleccionado ? AppColores.primariOscuro : AppColores.textoOscuro,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          texto,
          style: AppEstiloTexto.boton.copyWith(
            color: seleccionado ? AppColores.falsoBlanco : AppColores.textoOscuro,
          ),
        ),
      ),
    );
  }
}
