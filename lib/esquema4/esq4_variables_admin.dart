import 'package:flutter/material.dart';
import '../nucleo/estado_global.dart';
import '../nucleo/puente_supabase.dart';

class Esq4VariablesAdmin {
  static Future actualizarConfigGlobal({
    required BuildContext context,
    required String campo,
    required dynamic valor,
  }) async {
    final estado = EstadoGlobalSdui.instancia;
    final Map configActual = Map.from(estado.leerRuta('sistema.config_global') as Map? ?? {});
    
    configActual[campo] = valor;

    final Map payload = {
      'config_global': configActual,
    };

    final res = await PuenteSupabaseSdui.llamarRpcNano(
      'nano_transaccion_atomica',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_operacion': 'ACTUALIZAR_CONFIG_GLOBAL_ESQ4',
        'p_datos': payload,
      },
    );

    if (res['exito'] == true) {
      estado.escribirRuta('sistema.config_global', configActual, notificar: true);
    }
    return res;
  }

  static bool esPantallaVisible(Map arbolJson) {
    final estado = EstadoGlobalSdui.instancia;
    final String rol = estado.leerRuta('sesion.rol')?.toString().toUpperCase() ?? 'TODOS';
    final String visibilidad = arbolJson['visibilidad']?.toString().toUpperCase() ?? 'VISIBLE';
    
    if (rol == 'ADMIN') return true;
    return visibilidad != 'NO_VISIBLE';
  }

  static Color obtenerColorPorRol(String rol) {
    final estado = EstadoGlobalSdui.instancia;
    final Map colores = (estado.leerRuta('sistema.config_global.colores_por_rol') as Map?) ?? {};
    final String hex = colores[rol.toUpperCase()]?.toString() ?? '#FFFFFF';
    return _parsearColor(hex);
  }

  static Color _parsearColor(String hex) {
    String limpio = hex.replaceAll('#', '').trim();
    if (limpio.length == 6) limpio = 'FF$limpio';
    final val = int.tryParse(limpio, radix: 16);
    return val != null ? Color(val) : Colors.white;
  }
}