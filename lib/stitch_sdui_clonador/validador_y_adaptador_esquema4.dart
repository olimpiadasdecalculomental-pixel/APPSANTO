import '../nucleo/puente_supabase.dart';
import 'esquema_nodo_sdui.dart';
import 'traductor_stitch_a_sdui.dart';

class ValidadorYAdaptadorEsquema4 {
  final TraductorStitchASdui _traductor;

  const ValidadorYAdaptadorEsquema4({
    TraductorStitchASdui traductor = const TraductorStitchASdui(),
  }) : _traductor = traductor;

  Map<String, dynamic> sanearArbolSdui(
    Map<String, dynamic> arbolOriginal, {
    int maxProfundidad = 25,
  }) {
    return _sanearNodo(
      arbolOriginal,
      profundidadActual: 0,
      maxProfundidad: maxProfundidad,
    ).aMapaGenerico();
  }

  Future<Map<String, dynamic>> clonarYGuardarPantallaStitch({
    required String nuevaPantallaId,
    required String tituloPantalla,
    required Map<String, dynamic> stitchJsonExport,
    String rolRequerido = 'TODOS',
    int orden = 999,
    bool activa = true,
  }) async {
    final String pantallaLimpia = nuevaPantallaId.trim();
    if (pantallaLimpia.isEmpty) {
      return <String, dynamic>{
        'exito': false,
        'mensaje': 'El pantalla_id no puede estar vacío.',
      };
    }

    final Map<String, dynamic> sduiCrudo =
        _traductor.traducirEstructura(stitchJsonExport);
    final Map<String, dynamic> sduiValidado = sanearArbolSdui(sduiCrudo);

    final dynamic resRpc = await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_guardar_pantalla_stitch',
      <String, dynamic>{
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_pantalla_id': pantallaLimpia,
        'p_orden': orden,
        'p_titulo': tituloPantalla.trim(),
        'p_rol_requerido': rolRequerido.trim().toUpperCase(),
        'p_activa': activa,
        'p_arbol_json': sduiValidado,
      },
    );

    final bool exito = resRpc is Map && resRpc['exito'] == true;
    if (exito) {
      await PuenteSupabaseSdui.limpiarCacheYRecargar();
    }

    return <String, dynamic>{
      'exito': exito,
      'pantalla_id': pantallaLimpia,
      'mensaje': exito
          ? 'Diseño de Stitch clonado y guardado en $pantallaLimpia'
          : (resRpc is Map ? resRpc['mensaje'] : 'Error al guardar pantalla.'),
      'arbol_generado': sduiValidado,
    };
  }

  NodoSduiGenerico _sanearNodo(
    dynamic entrada, {
    required int profundidadActual,
    required int maxProfundidad,
  }) {
    if (profundidadActual > maxProfundidad) {
      return NodoSduiGenerico.nodoFallbackSeguro('max_profundidad_alcanzada');
    }

    if (entrada is! Map) {
      return NodoSduiGenerico.nodoFallbackSeguro('mapa_invalido');
    }

    final Map<String, dynamic> mapa = Map<String, dynamic>.from(entrada);
    final String tipoRaw =
        (mapa['tipo'] ?? mapa['type'] ?? '').toString().trim();
    final String tipoFinal = tipoRaw.isEmpty ? 'column' : tipoRaw;

    final Map<String, dynamic> propsLimpias = <String, dynamic>{};
    mapa.forEach((k, v) {
      final String clave = k.toString();
      if (v != null &&
          clave != 'tipo' &&
          clave != 'type' &&
          clave != 'children' &&
          clave != 'hijos' &&
          clave != 'flujo_acciones') {
        propsLimpias[clave] = _sanearValor(v);
      }
    });

    final List<NodoSduiGenerico> hijosSaneados = <NodoSduiGenerico>[];
    final dynamic rawHijos = mapa['children'] ?? mapa['hijos'];
    if (rawHijos is List) {
      for (final dynamic hijo in rawHijos) {
        hijosSaneados.add(
          _sanearNodo(
            hijo,
            profundidadActual: profundidadActual + 1,
            maxProfundidad: maxProfundidad,
          ),
        );
      }
    }

    final List<Map<String, dynamic>> accionesSaneadas =
        <Map<String, dynamic>>[];
    final dynamic rawAcciones = mapa['flujo_acciones'];
    if (rawAcciones is List) {
      for (final dynamic accion in rawAcciones) {
        if (accion is Map) {
          accionesSaneadas.add(Map<String, dynamic>.from(accion));
        }
      }
    }

    return NodoSduiGenerico(
      tipo: tipoFinal,
      propiedades: propsLimpias,
      hijos: hijosSaneados,
      flujoAcciones: accionesSaneadas,
    );
  }

  dynamic _sanearValor(dynamic valor) {
    if (valor is Map) {
      final Map<String, dynamic> out = <String, dynamic>{};
      valor.forEach((k, v) {
        if (v != null) out[k.toString()] = _sanearValor(v);
      });
      return out;
    }
    if (valor is List) {
      return valor.where((e) => e != null).map(_sanearValor).toList();
    }
    return valor;
  }
}