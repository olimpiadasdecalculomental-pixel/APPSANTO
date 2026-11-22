
import 'package:flutter/material.dart';
import '../nucleo/estado_global.dart';
import '../nucleo/ejecutor_flujos.dart';

class Esq4PanelVisibilidadAdmin extends StatefulWidget {
  final Map arbolJsonPantalla;
  final String pantallaId;
  final Future Function()? onRecargarPantallas;
  final void Function(String)? onFeedback;

  const Esq4PanelVisibilidadAdmin({
    super.key,
    required this.arbolJsonPantalla,
    required this.pantallaId,
    this.onRecargarPantallas,
    this.onFeedback,
  });

  @override
  State<Esq4PanelVisibilidadAdmin> createState() => _Esq4PanelVisibilidadAdminState();
}

class _Esq4PanelVisibilidadAdminState extends State<Esq4PanelVisibilidadAdmin> {
  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String rol = estado.leerRuta('sesion.rol')?.toString().toUpperCase() ?? 'TODOS';

    if (rol != 'ADMIN') return const SizedBox.shrink();

    final bool esVisible = widget.arbolJsonPantalla['visibilidad']?.toString().toUpperCase() != 'NO_VISIBLE';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C0A0A),
        border: Border.all(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'PANEL ADMIN · Visibilidad [${widget.pantallaId}]',
              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          Switch(
            value: esVisible,
            activeColor: Colors.redAccent,
            onChanged: (val) {
              if (widget.pantallaId.trim().isEmpty) {
                widget.onFeedback?.call('Error: pantalla_id vacío en nodo de visibilidad.');
                return;
              }
              final Map nuevoArbol = Map.from(widget.arbolJsonPantalla);
              nuevoArbol['visibilidad'] = val ? 'VISIBLE' : 'NO_VISIBLE';
              EjecutorFlujosSdui.ejecutarCadena(
                context: context,
                onRecargarPantallas: widget.onRecargarPantallas,
                onFeedback: widget.onFeedback,
                flujoAcciones: [
                  {
                    'accion': 'LLAMAR_RPC_NANO',
                    'rpc': 'nano_transaccion_atomica',
                    'operacion': 'ACTUALIZAR_VISIBILIDAD_PANTALLA',
                    'datos': {
                      'pantalla_id': widget.pantallaId,
                      'arbol_json': nuevoArbol,
                    },
                    'mensaje': val ? 'Pantalla Visible para todos' : 'Pantalla Oculta (NO_VISIBLE)',
                  },
                  {
                    'accion': 'LIMPIAR_CACHE_Y_RECARGAR',
                  }
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
