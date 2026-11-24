import 'esquema_nodo_sdui.dart';

class TraductorStitchASdui {
  const TraductorStitchASdui();

  Map<String, dynamic> traducirEstructura(Map<String, dynamic> stitchRaw) {
    return _convertirNodo(stitchRaw, profundidad: 0).aMapaGenerico();
  }

  NodoSduiGenerico _convertirNodo(dynamic origen, {required int profundidad}) {
    if (profundidad > 25) {
      return NodoSduiGenerico.nodoFallbackSeguro('limite_profundidad_25');
    }
    if (origen is NodoSduiGenerico) return origen.clonarSeguro();
    if (origen is String) {
      return NodoSduiGenerico(
        tipo: 'text',
        propiedades: <String, dynamic>{'texto': origen, 'color': '#FFFFFF', 'size': 13},
      );
    }
    if (origen is! Map) {
      return NodoSduiGenerico.nodoFallbackSeguro(origen.runtimeType.toString());
    }

    final Map<String, dynamic> mapa = Map<String, dynamic>.from(origen);
    if (mapa.containsKey('tipo') && !mapa.containsKey('tag') && !mapa.containsKey('styles')) {
      return NodoSduiGenerico.desdeMapa(mapa);
    }

    final String etiqueta = (mapa['tag'] ?? mapa['type'] ?? mapa['tipo'] ?? 'div')
        .toString()
        .toLowerCase()
        .trim();
    final Map<String, dynamic> estilos = mapa['styles'] is Map
        ? Map<String, dynamic>.from(mapa['styles'] as Map)
        : <String, dynamic>{};
    final Map<String, dynamic> props = mapa['props'] is Map
        ? Map<String, dynamic>.from(mapa['props'] as Map)
        : <String, dynamic>{};
    final List<dynamic> hijosRaw = (mapa['children'] ?? mapa['hijos']) is List
        ? List<dynamic>.from((mapa['children'] ?? mapa['hijos']) as List)
        : <dynamic>[];

    String tipoSdui = 'column';
    final Map<String, dynamic> propSdui = <String, dynamic>{};
    final List<Map<String, dynamic>> flujoSdui = <Map<String, dynamic>>[];

    if (mapa['flujo_acciones'] is List) {
      for (final a in (mapa['flujo_acciones'] as List)) {
        if (a is Map) flujoSdui.add(Map<String, dynamic>.from(a));
      }
    }

    if (<String>['div', 'section', 'main', 'header', 'nav', 'container', 'box', 'card'].contains(etiqueta)) {
      final String display = (estilos['display'] ?? '').toString().toLowerCase();
      final String flexDir = (estilos['flexDirection'] ?? '').toString().toLowerCase();
      final bool tieneGlass = estilos['backdropFilter'] != null || estilos['glass'] == true || props['glass'] == true;
      final List<String> gradiente = _extraerGradienteCss(estilos['background'] ?? estilos['backgroundImage']);
      final bool esTarjeta = etiqueta == 'card' ||
          tieneGlass ||
          gradiente.isNotEmpty ||
          estilos['border'] != null ||
          estilos['borderColor'] != null ||
          estilos['boxShadow'] != null ||
          estilos['backgroundColor'] != null;

      if (display == 'grid' || etiqueta == 'grid') {
        tipoSdui = 'gridview';
        propSdui['columnas'] = props['columns'] ?? props['columnas'] ?? 2;
      } else if ((display == 'flex' && flexDir == 'row') || etiqueta == 'row' || etiqueta == 'nav') {
        tipoSdui = 'row';
      } else if (esTarjeta) {
        tipoSdui = 'card';
        propSdui['color_borde'] = _extraerColorHex(estilos['borderColor']) ??
            _extraerColorHex(estilos['border']) ??
            '#00F3FF';
        if (props['titulo'] != null || props['title'] != null) {
          propSdui['titulo'] = (props['titulo'] ?? props['title']).toString();
        }
        if (props['subtitulo'] != null || props['subtitle'] != null) {
          propSdui['subtitulo'] = (props['subtitulo'] ?? props['subtitle']).toString();
        }
        if (tieneGlass) propSdui['glass'] = true;
        if (gradiente.isNotEmpty) propSdui['gradiente'] = gradiente;
        if (estilos['animation'] != null || props['animar'] == true) propSdui['animar'] = true;
      } else {
        tipoSdui = 'column';
      }
    } else if (<String>['button', 'a', 'btn'].contains(etiqueta)) {
      tipoSdui = 'button';
      propSdui['texto'] = (props['texto'] ?? props['text'] ?? _extraerTextoDeHijos(hijosRaw) ?? 'ACCIÓN').toString();
      propSdui['color'] = _extraerColorHex(estilos['backgroundColor']) ?? '#00FF66';
      propSdui['color_texto'] = _extraerColorHex(estilos['color']) ?? '#000000';
      if (flujoSdui.isEmpty) {
        if (props['href'] != null) {
          flujoSdui.add(<String, dynamic>{'accion': 'NAVEGAR', 'pantalla_destino': props['href'].toString()});
        } else if (props['rpc'] != null || props['action'] != null) {
          flujoSdui.add(<String, dynamic>{'accion': 'LLAMAR_RPC_NANO', 'rpc': (props['rpc'] ?? props['action']).toString()});
        }
      }
    } else if (<String>['span', 'p', 'label', 'h1', 'h2', 'h3', 'text'].contains(etiqueta)) {
      tipoSdui = 'text';
      propSdui['texto'] = (props['texto'] ?? props['text'] ?? _extraerTextoDeHijos(hijosRaw) ?? '').toString();
      propSdui['color'] = _extraerColorHex(estilos['color']) ?? '#FFFFFF';
      if (estilos['fontSize'] != null) {
        propSdui['size'] = double.tryParse(estilos['fontSize'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 13;
      } else {
        propSdui['size'] = etiqueta == 'h1' ? 22 : (etiqueta == 'h2' ? 18 : (etiqueta == 'h3' ? 15 : 13));
      }
    } else if (<String>['img', 'image', 'avatar'].contains(etiqueta)) {
      tipoSdui = 'image';
      propSdui['url'] = (props['src'] ?? props['url'] ?? '').toString();
      propSdui['altura'] = props['height'] ?? props['altura'] ?? 150;
      if (etiqueta == 'avatar' || estilos['borderRadius'] == '50%' || estilos['borderRadius'] == '9999px') {
        propSdui['circular'] = true;
      }
    } else if (<String>['icon', 'icono', 'svg', 'i'].contains(etiqueta)) {
      tipoSdui = 'icono';
      propSdui['nombre'] = (props['name'] ?? props['nombre'] ?? 'circle').toString();
      propSdui['color'] = _extraerColorHex(estilos['color']) ?? '#00F3FF';
      propSdui['size'] = props['size'] ?? 24;
    } else if (<String>['input', 'textarea', 'textfield'].contains(etiqueta)) {
      tipoSdui = 'input';
      propSdui['campo'] = (props['name'] ?? props['campo'] ?? 'campo_stitch').toString();
      propSdui['label'] = (props['label'] ?? '').toString();
      propSdui['placeholder'] = (props['placeholder'] ?? '').toString();
      if (props['type'] == 'password') propSdui['password'] = true;
      if (etiqueta == 'textarea') {
        propSdui['multiline'] = true;
        propSdui['lineas'] = props['rows'] ?? 4;
      }
    } else if (<String>['ul', 'ol', 'list', 'listview'].contains(etiqueta)) {
      tipoSdui = 'listview';
      propSdui['modo'] = props['modo'] ?? 'action_buttons';
      if (props['titulo'] != null) propSdui['titulo'] = props['titulo'];
      propSdui['items'] = hijosRaw.map((h) {
        if (h is Map) {
          final Map<String, dynamic> hp = h['props'] is Map ? Map<String, dynamic>.from(h['props'] as Map) : <String, dynamic>{};
          return hp['text'] ?? hp['titulo'] ?? _extraerTextoDeHijos((h['children'] as List?) ?? <dynamic>[]) ?? 'Elemento';
        }
        return h.toString();
      }).toList();
      return NodoSduiGenerico(tipo: tipoSdui, propiedades: propSdui);
    } else if (etiqueta == 'video' || etiqueta == 'iframe') {
      tipoSdui = 'video_universal';
      propSdui['url'] = (props['src'] ?? props['url'] ?? '').toString();
      propSdui['altura'] = props['height'] ?? 220;
    } else if (etiqueta == 'map' || etiqueta == 'flutter_map') {
      tipoSdui = 'flutter_map';
      propSdui['lat'] = props['lat'] ?? -17.9647;
      propSdui['lng'] = props['lng'] ?? -67.1060;
      propSdui['zoom'] = props['zoom'] ?? 14;
    } else if (etiqueta == 'qr' || etiqueta == 'escaner_qr') {
      tipoSdui = 'escaner_qr';
    } else {
      return NodoSduiGenerico.nodoFallbackSeguro(etiqueta);
    }

    final List<NodoSduiGenerico> hijosSdui = <NodoSduiGenerico>[];
    if (<String>['column', 'row', 'card', 'gridview', 'stack'].contains(tipoSdui)) {
      for (final dynamic hRaw in hijosRaw) {
        if (hRaw is Map && hRaw['tag'] == 'text_node') continue;
        hijosSdui.add(_convertirNodo(hRaw, profundidad: profundidad + 1));
      }
    }

    return NodoSduiGenerico(tipo: tipoSdui, propiedades: propSdui, hijos: hijosSdui, flujoAcciones: flujoSdui);
  }

  String? _extraerColorHex(dynamic valorCss) {
    if (valorCss == null) return null;
    final String str = valorCss.toString().trim().toUpperCase();
    final Match? match = RegExp(r'#(?:[0-9A-F]{3}|[0-9A-F]{6}|[0-9A-F]{8})\b').firstMatch(str);
    if (match != null) return match.group(0);
    const Map<String, String> mapaColores = <String, String>{
      'WHITE': '#FFFFFF',
      'BLACK': '#000000',
      'RED': '#FF4D4D',
      'GREEN': '#00FF66',
      'BLUE': '#00F3FF',
      'CYAN': '#00F3FF',
      'YELLOW': '#FFFF00',
    };
    return mapaColores[str];
  }

  List<String> _extraerGradienteCss(dynamic bgCss) {
    if (bgCss == null) return <String>[];
    return RegExp(r'#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\b')
        .allMatches(bgCss.toString())
        .map((m) => m.group(0)!.toUpperCase())
        .toList();
  }

  String? _extraerTextoDeHijos(List<dynamic> hijos) {
    if (hijos.isEmpty) return null;
    final dynamic primero = hijos.first;
    if (primero is String) return primero;
    if (primero is Map && primero['tag'] == 'text_node') return primero['content']?.toString();
    return null;
  }
}

