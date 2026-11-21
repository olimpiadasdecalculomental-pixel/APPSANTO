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
        'p_datos': datosPerfil
      },
    );
  }

  static Future crearYAsignarPremio(String destinoId, Map datosPremio) async {
    return await PuenteSupabaseSdui.llamarRpcNano(
      'esq4_crear_y_asignar_premio',
      {
        'p_app_id': PuenteSupabaseSdui.appIdActivo,
        'p_usuario_destino': destinoId,
        'p_datos_premio': datosPremio
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
        'p_destino': destinoId
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
        'p_datos_operador': datosOperador
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
        'p_datos': datos
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
        'p_usuario_id': id
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
        'p_tipo_marcacion': tipoMarcacion
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
        'p_voto': voto
      },
    );
  }
}