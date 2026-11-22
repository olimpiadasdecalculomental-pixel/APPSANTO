import '../nucleo/estado_global.dart';
import '../nucleo/puente_supabase.dart';

class Esq4Rpcs {
  static Future registrarOActualizarUsuario(Map datosPerfil) async {
    final estado = EstadoGlobalSdui.instancia;
    final String id = estado.leerRuta('sesion.usuario_id')?.toString() ?? 'ANONIMO';
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_registrar_o_actualizar_usuario',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_usuario_id': id,
        'p_datos': datosPerfil,
      },
    );
  }

  static Future crearYAsignarPremio(String destinoId, Map datosPremio) async {
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_crear_y_asignar_premio',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_usuario_destino': destinoId,
        'p_datos_premio': datosPremio,
      },
    );
  }

  static Future transferirPremioP2p(String premioId, String destinoId) async {
    final estado = EstadoGlobalSdui.instancia;
    final String idOrigen = estado.leerRuta('sesion.usuario_id')?.toString() ?? 'ANONIMO';
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_transferir_premio_p2p',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_premio_id': premioId,
        'p_origen': idOrigen,
        'p_destino': destinoId,
      },
    );
  }

  static Future entregarPremioEmpresa(String empresaId, String premioId, Map datosOperador) async {
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_entregar_premio_empresa',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_empresa_id': empresaId,
        'p_premio_id': premioId,
        'p_datos_operador': datosOperador,
      },
    );
  }

  static Future registrarCapturaOAporte(Map datos) async {
    final estado = EstadoGlobalSdui.instancia;
    final String id = estado.leerRuta('sesion.usuario_id')?.toString() ?? 'ANONIMO';
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_registrar_captura_o_aporte',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_usuario_id': id,
        'p_datos': datos,
      },
    );
  }

  static Future publicidadReclamarVista({required String campanaId}) async {
    final estado = EstadoGlobalSdui.instancia;
    final String id = estado.leerRuta('sesion.usuario_id')?.toString() ?? 'ANONIMO';
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_publicidad_reclamar_vista',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_campana_id': campanaId,
        'p_usuario_id': id,
      },
    );
  }

  static Future asistenciaYAccesos({
    required String selfieBase64,
    required String tipoMarcacion,
    String qrDetectado = '',
  }) async {
    final estado = EstadoGlobalSdui.instancia;
    final String id = estado.leerRuta('sesion.usuario_id')?.toString() ?? 'ANONIMO';
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_asistencia_y_accesos_diarios',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_usuario_id': id,
        'p_datos_selfie': {'selfie': selfieBase64, 'qr': qrDetectado},
        'p_tipo_marcacion': tipoMarcacion,
      },
    );
  }

  static Future votarEnVivo(String votacionId, String voto) async {
    final estado = EstadoGlobalSdui.instancia;
    final String id = estado.leerRuta('sesion.usuario_id')?.toString() ?? 'ANONIMO';
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_votar_en_vivo',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_votacion_id': votacionId,
        'p_usuario_id': id,
        'p_voto': voto,
      },
    );
  }

  static Future resolverRevisionCola({
    required String registroId,
    required String estadoResolucion,
    required Map datosRespuesta,
  }) async {
    final estado = EstadoGlobalSdui.instancia;
    final String verificadorId = estado.leerRuta('sesion.usuario_id')?.toString() ?? 'ANONIMO';
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_resolver_revision_cola',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_registro_id': registroId,
        'p_verificador_id': verificadorId,
        'p_estado': estadoResolucion,
        'p_datos_res': datosRespuesta,
      },
    );
  }

  static Future resumenVotacion(String votacionId) async {
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_resumen_votacion',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_votacion_id': votacionId,
      },
    );
  }

  static Future ejecutarCorteYSorteoDiario() async {
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_ejecutar_corte_y_sorteo_diario',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
      },
    );
  }

  static Future buscarTop10(String coleccion, Map filtro, String? cursorFecha) async {
    return await PuenteSupabaseSdui.llamarRpcNano(
      'nano_buscar_top10',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_coleccion': coleccion,
        'p_filtro': filtro,
        'p_cursor_fecha': cursorFecha,
      },
    );
  }

  static Future cambiarRolUsuario(
    String usuarioDestinoId,
    String nuevoRol, {
    String nuevoEstado = 'ACTIVO',
  }) async {
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_cambiar_rol_usuario',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_usuario_id': usuarioDestinoId,
        'p_nuevo_rol': nuevoRol,
        'p_nuevo_estado': nuevoEstado,
      },
    );
  }

  static Future crearVotacion(
    String nuevaVotacionId,
    String titulo, {
    String tipo = 'LIBRE',
    num umbralPct = 51,
    int diasGanador = 7,
  }) async {
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_crear_votacion',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_votacion_id': nuevaVotacionId,
        'p_titulo': titulo,
        'p_tipo': tipo,
        'p_umbral_pct': umbralPct,
        'p_dias_ganador': diasGanador,
      },
    );
  }
}