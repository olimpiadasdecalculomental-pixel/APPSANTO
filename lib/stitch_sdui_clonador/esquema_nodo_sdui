import 'dart:convert';

/// Abstracción genérica e inmutable de un Nodo SDUI 100% compatible
/// con RenderizadorAtomicoSdui y esquema4.pantallas_ui.
class NodoSduiGenerico {
  final String tipo;
  final Map<String, dynamic> propiedades;
  final List<NodoSduiGenerico> hijos;
  final List<Map<String, dynamic>> flujoAcciones;

  NodoSduiGenerico({
    required this.tipo,
    Map<String, dynamic>? propiedades,
    List<NodoSduiGenerico>? hijos,
    List<Map<String, dynamic>>? flujoAcciones,
  })  : propiedades = Map<String, dynamic>.from(propiedades ?? const {}),
        hijos = List<NodoSduiGenerico>.from(hijos ?? const []),
        flujoAcciones = (flujoAcciones ?? const [])
            .map((a) => Map<String, dynamic>.from(a))
            .toList();

  factory NodoSduiGenerico.desdeMapa(Map<String, dynamic> mapa) {
    final String tipoRaw =
        (mapa['tipo'] ?? mapa['type'] ?? 'column').toString().trim();
    final String tipoNormalizado = tipoRaw.isEmpty ? 'column' : tipoRaw;

    final Map<String, dynamic> props = <String, dynamic>{};
    mapa.forEach((clave, valor) {
      if (clave != 'tipo' &&
          clave != 'type' &&
          clave != 'children' &&
          clave != 'hijos' &&
          clave != 'flujo_acciones') {
        props[clave] = valor;
      }
    });

    final List<NodoSduiGenerico> hijosParseados = <NodoSduiGenerico>[];
    final dynamic rawHijos = mapa['children'] ?? mapa['hijos'];
    if (rawHijos is List) {
      for (final item in rawHijos) {
        if (item is Map) {
          hijosParseados.add(
            NodoSduiGenerico.desdeMapa(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final List<Map<String, dynamic>> accionesParseadas = <Map<String, dynamic>>[];
    final dynamic rawAcciones = mapa['flujo_acciones'];
    if (rawAcciones is List) {
      for (final accion in rawAcciones) {
        if (accion is Map) {
          accionesParseadas.add(Map<String, dynamic>.from(accion));
        }
      }
    }

    return NodoSduiGenerico(
      tipo: tipoNormalizado,
      propiedades: props,
      hijos: hijosParseados,
      flujoAcciones: accionesParseadas,
    );
  }

  /// Convierte el árbol al formato exacto que espera RenderizadorAtomicoSdui.
  Map<String, dynamic> aMapaGenerico() {
    final Map<String, dynamic> mapa = <String, dynamic>{
      'tipo': tipo,
    };

    propiedades.forEach((clave, valor) {
      if (valor != null &&
          clave != 'tipo' &&
          clave != 'type' &&
          clave != 'children' &&
          clave != 'hijos' &&
          clave != 'flujo_acciones') {
        mapa[clave] = valor;
      }
    });

    if (flujoAcciones.isNotEmpty) {
      mapa['flujo_acciones'] =
          flujoAcciones.map((a) => Map<String, dynamic>.from(a)).toList();
    }

    if (hijos.isNotEmpty) {
      mapa['children'] = hijos.map((h) => h.aMapaGenerico()).toList();
    }

    return mapa;
  }

  String aJsonString({bool indentado = false}) {
    final Map<String, dynamic> datos = aMapaGenerico();
    if (indentado) {
      return const JsonEncoder.withIndent('  ').convert(datos);
    }
    return jsonEncode(datos);
  }

  NodoSduiGenerico clonarSeguro() {
    return NodoSduiGenerico.desdeMapa(aMapaGenerico());
  }

  /// Nodo de respaldo seguro usando widgets reales de tu RenderizadorAtomicoSdui.
  static NodoSduiGenerico nodoFallbackSeguro(String pistaOriginal) {
    final String pistaLimpia =
        pistaOriginal.trim().isEmpty ? 'desconocido' : pistaOriginal.trim();
    return NodoSduiGenerico(
      tipo: 'card',
      propiedades: <String, dynamic>{
        'color_borde': '#FF4D4D',
        'titulo': 'Elemento No Mapeado',
        'subtitulo': 'Etiqueta Stitch: $pistaLimpia',
      },
      hijos: <NodoSduiGenerico>[
        NodoSduiGenerico(
          tipo: 'text',
          propiedades: <String, dynamic>{
            'texto': 'Nodo convertido automáticamente para evitar fallos de renderizado.',
            'color': '#FFFFFF',
            'size': 11,
          },
        ),
      ],
    );
  }
}