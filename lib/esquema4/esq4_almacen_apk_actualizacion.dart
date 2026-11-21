import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../nucleo/estado_global.dart';
import 'esq4_rpcs.dart';

class Esq4AlmacenActualizacion {
  static Future<String> _obtenerDirectorioPrivado() async {
    final dir = await getApplicationDocumentsDirectory();
    final String pathFinal = '\/esq4_boveda_archivos';
    final directory = Directory(pathFinal);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return pathFinal;
  }

  static Future<void> limpiarArchivosVencidos() async {
    final estado = EstadoGlobalSdui.instancia;
    final int diasRetencion = int.tryParse(estado.leerRuta('sistema.config_global.ventana_dias_retencion')?.toString() ?? '7') ?? 7;
    
    try {
      final String dirPath = await _obtenerDirectorioPrivado();
      final dir = Directory(dirPath);
      final List<FileSystemEntity> archivos = dir.listSync();
      final DateTime umbral = DateTime.now().subtract(Duration(days: diasRetencion));

      for (var archivo in archivos) {
        if (archivo is File) {
          final stat = await archivo.stat();
          if (stat.modified.isBefore(umbral)) {
            await archivo.delete();
          }
        }
      }
    } catch (_) {}
  }

  static Future compartirApkWhatsApp(String msjReferido) async {
    try {
      final estado = EstadoGlobalSdui.instancia;
      final String usuarioId = estado.leerRuta('sesion.usuario_id')?.toString() ?? '';
      if (usuarioId.isEmpty || usuarioId == 'USR_ANONIMO') {
        return {'exito': false, 'mensaje': 'Debes registrarte para ganar puntos por compartir.'};
      }

      await Share.share(msjReferido);

      final resAuditoria = await Esq4Rpcs.registrarCapturaOAporte({
        'tipo': 'COMPARTIR_APP',
        'fecha': DateTime.now().toIso8601String().split('T').first,
        'plataforma': 'WHATSAPP'
      });

      return resAuditoria;
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error compartiendo APK: \'};
    }
  }

  static Widget construirBotonActualizacion(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String versionActualLocal = '5.0.0';
    final String versionNube = estado.leerRuta('sistema.config_global.version_apk_actual')?.toString() ?? '5.0.0';
    final String urlDescarga = estado.leerRuta('sistema.config_global.url_apk_nuevo')?.toString() ?? '';

    if (versionActualLocal == versionNube) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF0F1A3A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFD700))),
      child: Column(
        children: [
          const Text('¡Nueva Actualización Disponible!', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF66), foregroundColor: Colors.black),
            onPressed: () async {
              if (urlDescarga.isNotEmpty) {
                final Uri url = Uri.parse(urlDescarga);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                  final puntos = int.tryParse(estado.leerRuta('sistema.config_global.puntos_por_actualizacion_apk')?.toString() ?? '250') ?? 250;
                  await Esq4Rpcs.registrarCapturaOAporte({'tipo': 'ACTUALIZAR_APK', 'puntos_asignados': puntos});
                }
              }
            },
            child: const Text('ACTUALIZAR APK Y GANAR PUNTOS', style: TextStyle(fontWeight: FontWeight.w900)),
          )
        ],
      ),
    );
  }
}