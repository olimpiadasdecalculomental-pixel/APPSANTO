import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../nucleo/estado_global.dart';
import '../nucleo/ejecutor_flujos.dart';
import '../motores/widgets_stitch_media.dart';
import 'esq4_camara_qr_asistencia.dart';
import 'esq4_video_publicidad.dart';
import 'esq4_visibilidad_pantallas.dart';
import 'esq4_variables_admin.dart';

class LegoStitchKit {
  static const Color bgCanvas = Color(0xFF0B1326);
  static const Color surfaceLowest = Color(0xFF060E20);
  static const Color surfaceLow = Color(0xFF131B2E);
  static const Color surfaceCard = Color(0xFF171F33);
  static const Color surfaceHigh = Color(0xFF222A3D);
  static const Color surfaceHighest = Color(0xFF2D3449);
  static const Color neonGreen = Color(0xFF00FF66);
  static const Color onNeonGreen = Color(0xFF003911);
  static const Color neonCyan = Color(0xFF00F1FD);
  static const Color neonYellow = Color(0xFFFFFF00);
  static const Color neonPurple = Color(0xFFA855F7);
  static const Color neonPink = Color(0xFFEC4899);
  static const Color neonRed = Color(0xFFFF4D4D);
  static const Color onSurface = Color(0xFFDAE2FD);
  static const Color onSurfaceVar = Color(0xFFB9CCB5);

static Color colorPorRol(String rol) {
    final Color defecto;
    switch (rol.toUpperCase().trim()) {
      case 'USUARIO':
        defecto = neonCyan;
        break;
      case 'USUARIO_INCHA':
        defecto = const Color(0xFF10B981);
        break;
      case 'USUARIO_INCHA_SUPER':
        defecto = const Color(0xFFF59E0B);
        break;
      case 'EMPRESA':
      case 'EMPRESARIO':
        defecto = neonYellow;
        break;
      case 'VERIFICADOR':
        defecto = neonPurple;
        break;
      case 'PUBLICIDAD':
        defecto = neonPink;
        break;
      case 'ADMIN':
        defecto = neonRed;
        break;
      default:
        defecto = const Color(0xFF38BDF8);
    }
    return Esq4VariablesAdmin.obtenerColorPorRol(rol, fallback: defecto);
  }

  static Future<bool> mostrarModalValidarPin4({
    required BuildContext context,
    String titulo = 'Confirmar PIN de Seguridad (4 Dígitos)',
  }) async {
    final estado = EstadoGlobalSdui.instancia;
    final String pinGuardado = estado.leerRuta('sesion.pin_4_digitos')?.toString().trim() ?? '';
    final TextEditingController ctrl = TextEditingController();
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(titulo, style: GoogleFonts.spaceGrotesk(color: onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          maxLength: 4,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: GoogleFonts.jetBrainsMono(color: neonGreen, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 10),
          decoration: InputDecoration(
            hintText: '••••',
            filled: true,
            fillColor: surfaceLowest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('CANCELAR', style: GoogleFonts.jetBrainsMono(color: onSurfaceVar)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: neonGreen, foregroundColor: onNeonGreen),
            onPressed: () {
              final String ingresado = ctrl.text.trim();
              if (ingresado.length != 4) return;
              if (pinGuardado.isNotEmpty && ingresado != pinGuardado) {
                Navigator.of(ctx).pop(false);
                return;
              }
              estado.escribirRuta('form.pin_confirmado', ingresado, notificar: false);
              Navigator.of(ctx).pop(true);
            },
            child: Text('CONFIRMAR PIN', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    return res == true;
  }

  static Future<String?> seleccionarCapturaEnBovedaPrivada({
    required String campoDestino,
    bool soloCamara = false,
  }) async {
    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(
      source: soloCamara ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
    if (foto == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final String folderPath = '${dir.path}/esq4_boveda_archivos';
    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final String destinoPath = '$folderPath/evid_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(foto.path).copy(destinoPath);
    EstadoGlobalSdui.instancia.escribirRuta('form.$campoDestino', destinoPath, notificar: true);
    return destinoPath;
  }

  static Widget construirPieza({
    required BuildContext context,
    required Map nodoRaw,
    required Map arbolRaiz,
    required String pantallaId,
    required void Function(String) onNavegar,
    required Future Function() onRecargar,
    required void Function(String) onFeedback,
  }) {
    final String tipo = (nodoRaw['tipo'] ?? nodoRaw['type'] ?? '').toString().toUpperCase().trim();
    final estado = EstadoGlobalSdui.instancia;

    Future<void> run(List flujo) async {
      await EjecutorFlujosSdui.ejecutarCadena(
        context: context,
        flujoAcciones: flujo,
        onNavegar: onNavegar,
        onRecargarPantallas: onRecargar,
        onFeedback: onFeedback,
      );
    }

    switch (tipo) {
      case 'LEGO_HEADER_HUD':
        final String titulo = estado.interpolarTexto(nodoRaw['titulo']?.toString() ?? 'CLUB HOME');
        final String rolActivo = (estado.leerRuta('sesion.rol')?.toString() ?? 'TODOS').toUpperCase();
        final Color colRol = colorPorRol(rolActivo);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: surfaceLow.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 14, offset: Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 7, height: 7, decoration: const BoxDecoration(color: neonGreen, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text('SDUI CORE', style: GoogleFonts.jetBrainsMono(color: neonGreen, fontSize: 10, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Text(titulo.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: onSurface, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final List rolesCiclo = ['TODOS', 'USUARIO', 'USUARIO_INCHA', 'EMPRESA', 'VERIFICADOR', 'PUBLICIDAD', 'ADMIN'];
                      final int idx = rolesCiclo.indexOf(rolActivo);
                      final String sigRol = rolesCiclo[(idx + 1) % rolesCiclo.length].toString();
                      await run([
                        {'accion': 'GUARDAR_ESTADO', 'ruta': 'sesion.rol', 'valor': sigRol, 'mensaje': 'Vista previa de rol: $sigRol'},
                        {'accion': 'LIMPIAR_CACHE_Y_RECARGAR'}
                      ]);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(color: colRol.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(6)),
                      child: Text(rolActivo, style: GoogleFonts.jetBrainsMono(color: colRol, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => run([{'accion': 'LIMPIAR_CACHE_Y_RECARGAR'}]),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(color: surfaceHigh, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.sync, color: onSurface, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'LEGO_NODE_SUBDOCK':
        final String pid = estado.interpolarTexto(nodoRaw['pantalla_id']?.toString() ?? pantallaId);
        final String rolTag = estado.interpolarTexto(nodoRaw['rol_tag']?.toString() ?? 'TODOS');
        final Color colRol = colorPorRol(rolTag);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: neonGreen, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('NODE: $pid', overflow: TextOverflow.ellipsis, style: GoogleFonts.jetBrainsMono(color: neonCyan, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: colRol.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text(rolTag, style: GoogleFonts.jetBrainsMono(color: colRol, fontSize: 9.5, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: neonGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text('VISIBLE', style: GoogleFonts.jetBrainsMono(color: neonGreen, fontSize: 9.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'LEGO_TX_BANNER':
        final Map rpc = (estado.leerRuta('sistema.ultima_respuesta_rpc') as Map?) ?? {};
        final Map regla = (estado.leerRuta('sistema.ultima_regla_sql') as Map?) ?? {};
        final Map fuente = rpc.isNotEmpty ? rpc : regla;
        final String estadoOp = fuente['estado_operacion']?.toString() ?? 'LISTO';
        final String refId = fuente['referencia_id']?.toString() ?? 'ESQ4-SYNC';
        final String mensaje = estado.leerRuta('sistema.ultimo_mensaje')?.toString() ?? 'Motor SDUI conectado a esquema4.';
        final Map saldos = (fuente['saldos_actualizados'] as Map?) ?? {};
        final bool esError = ['REPROBADO', 'RECHAZADO', 'BLOQUEADO', 'ERROR', 'TOPE_DIARIO', 'DOBLE_VOTO'].contains(estadoOp);
        final Color colEstado = esError ? neonRed : neonGreen;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: colEstado.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(esError ? Icons.error_outline : Icons.verified, color: colEstado, size: 19),
                      const SizedBox(width: 6),
                      Text('ESTADO: $estadoOp', style: GoogleFonts.jetBrainsMono(color: colEstado, fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: surfaceLowest, borderRadius: BorderRadius.circular(4)),
                    child: Text(refId, style: GoogleFonts.jetBrainsMono(color: neonCyan, fontSize: 9.5)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(mensaje, style: GoogleFonts.inter(color: onSurface, fontSize: 12.5, height: 1.35)),
              if (saldos.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: surfaceLowest, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('PUNTOS: ${saldos['puntos'] ?? 0}', style: GoogleFonts.jetBrainsMono(color: neonGreen, fontSize: 10.5, fontWeight: FontWeight.w700)),
                      Text('CUPONES: ${saldos['cupones'] ?? 0}', style: GoogleFonts.jetBrainsMono(color: neonCyan, fontSize: 10.5, fontWeight: FontWeight.w700)),
                      Text('DÍAS: ${saldos['dias_suscripcion'] ?? 0}', style: GoogleFonts.jetBrainsMono(color: onSurface, fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );

      case 'LEGO_HERO_WELCOME':
        final String badge = estado.interpolarTexto(nodoRaw['badge']?.toString() ?? 'PÚBLICO SIN LOGIN');
        final String schema = estado.interpolarTexto(nodoRaw['schema']?.toString() ?? 'SCHEMA v5.0');
        final String titulo = estado.interpolarTexto(nodoRaw['titulo']?.toString() ?? '¡Bienvenido al Club SDUI Universal!');
        final String sub = estado.interpolarTexto(nodoRaw['subtitulo']?.toString() ?? '');
        final String btn1 = estado.interpolarTexto(nodoRaw['btn_primario']?.toString() ?? 'Registrarme');
        final String btn2 = estado.interpolarTexto(nodoRaw['btn_secundario']?.toString() ?? 'Ingresar');
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: neonCyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(99)),
                    child: Text(badge, style: GoogleFonts.jetBrainsMono(color: neonCyan, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                  Text(schema, style: GoogleFonts.jetBrainsMono(color: onSurfaceVar, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 10),
              Text(titulo, style: GoogleFonts.spaceGrotesk(color: onSurface, fontSize: 22, fontWeight: FontWeight.w700, height: 1.2)),
              const SizedBox(height: 6),
              Text(sub, style: GoogleFonts.inter(color: onSurfaceVar, fontSize: 13, height: 1.4)),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: neonGreen, foregroundColor: onNeonGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  icon: const Icon(Icons.stars, size: 18),
                  label: Text(btn1, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  onPressed: () => run((nodoRaw['flujo_primario'] as List?) ?? []),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: surfaceHigh, foregroundColor: neonCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  icon: const Icon(Icons.login, size: 17),
                  label: Text(btn2, style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600, fontSize: 12)),
                  onPressed: () => run((nodoRaw['flujo_secundario'] as List?) ?? []),
                ),
              ),
            ],
          ),
        );

      case 'LEGO_WALLET_KPI_CARD':
        final String etiq = estado.interpolarTexto(nodoRaw['etiqueta']?.toString() ?? 'SALDO DISPONIBLE');
        final String val = estado.interpolarTexto(nodoRaw['valor_principal']?.toString() ?? '0');
        final String uni = estado.interpolarTexto(nodoRaw['unidad']?.toString() ?? 'TIVOS');
        final String sub = estado.interpolarTexto(nodoRaw['subtitulo']?.toString() ?? '');
        final double prog = (double.tryParse(nodoRaw['progreso']?.toString() ?? '0.6') ?? 0.6).clamp(0.0, 1.0);
        final String k1L = estado.interpolarTexto(nodoRaw['kpi1_label']?.toString() ?? 'CUPONES');
        final String k1V = estado.interpolarTexto(nodoRaw['kpi1_valor']?.toString() ?? '0');
        final String k2L = estado.interpolarTexto(nodoRaw['kpi2_label']?.toString() ?? 'ESTADO');
        final String k2V = estado.interpolarTexto(nodoRaw['kpi2_valor']?.toString() ?? 'ACTIVO');
        final String btnTxt = estado.interpolarTexto(nodoRaw['btn_texto']?.toString() ?? '');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: surfaceCard, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(etiq, style: GoogleFonts.jetBrainsMono(color: onSurfaceVar, fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: surfaceLowest, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(val.isEmpty ? '0' : val, style: GoogleFonts.jetBrainsMono(color: neonGreen, fontSize: 28, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        Text(uni, style: GoogleFonts.jetBrainsMono(color: neonCyan, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (sub.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(sub, style: GoogleFonts.jetBrainsMono(color: onSurfaceVar, fontSize: 10.5)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(value: prog, minHeight: 7, backgroundColor: surfaceHighest, valueColor: const AlwaysStoppedAnimation<Color>(neonGreen)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: surfaceHigh, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(k1L, style: GoogleFonts.jetBrainsMono(color: onSurfaceVar, fontSize: 9.5)),
                          Text(k1V, style: GoogleFonts.jetBrainsMono(color: onSurface, fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: surfaceHigh, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(k2L, style: GoogleFonts.jetBrainsMono(color: onSurfaceVar, fontSize: 9.5)),
                          Text(k2V, style: GoogleFonts.jetBrainsMono(color: neonCyan, fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (btnTxt.isNotEmpty) ...[
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: neonCyan, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => run((nodoRaw['flujo_boton'] as List?) ?? []),
                  child: Text(btnTxt, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
        );

      case 'LEGO_QR_CROSSHAIR':
        final String tit = estado.interpolarTexto(nodoRaw['titulo']?.toString() ?? 'Credencial QR');
        final String tag = estado.interpolarTexto(nodoRaw['tag']?.toString() ?? 'QR_SDUI');
        final String data = estado.interpolarTexto(nodoRaw['data']?.toString() ?? 'APP_ESQUEMA4_CLUB');
        final String sub = estado.interpolarTexto(nodoRaw['subtitulo']?.toString() ?? '');
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: surfaceCard, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tit, style: GoogleFonts.spaceGrotesk(color: onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: surfaceHighest, borderRadius: BorderRadius.circular(5)),
                    child: Text(tag, style: GoogleFonts.jetBrainsMono(color: neonCyan, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: surfaceLowest, borderRadius: BorderRadius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: QrImageView(data: data.isEmpty ? 'SDUI' : data, size: 155),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(data, overflow: TextOverflow.ellipsis, style: GoogleFonts.jetBrainsMono(color: neonGreen, fontSize: 11, fontWeight: FontWeight.w700))),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: data));
                      onFeedback('Código copiado: $data');
                    },
                    icon: const Icon(Icons.copy, color: neonCyan, size: 15),
                    label: Text('COPIAR', style: GoogleFonts.jetBrainsMono(color: neonCyan, fontSize: 10.5)),
                  ),
                ],
              ),
              if (sub.isNotEmpty) Text(sub, style: GoogleFonts.inter(color: onSurfaceVar, fontSize: 11.5)),
            ],
          ),
        );

      case 'LEGO_PIN_4_PAD':
        final String modoAuth = estado.leerRuta('sistema.config_global.modo_autenticacion')?.toString() ?? 'PIN_4_DIGITOS';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('IDENTIDAD DIGITAL', style: GoogleFonts.spaceGrotesk(color: onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: neonCyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text(modoAuth, style: GoogleFonts.jetBrainsMono(color: neonCyan, fontSize: 9.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _campoDark('apodo_o_iniciales', 'Apodo o Iniciales', 'Ej. Alex_99'),
              _campoDark('codigo_pais', 'Código País', '+591'),
              _campoDark('pais', 'País', 'Bolivia'),
              _campoDark('celular', 'Celular (ID Socio)', '77012345'),
              _campoDark('pin_4_digitos', 'PIN de Seguridad (4 Dígitos)', '7429', esPassword: true, maxLen: 4),
              if (modoAuth != 'PIN_4_DIGITOS') ...[
                _campoDark('email', 'Correo Electrónico (Supabase Auth)', 'socio@club.com'),
                _campoDark('password_auth', 'Contraseña Supabase Auth', '••••••••', esPassword: true),
              ],
              _campoDark('referido_por', 'Código Referido (Opcional · Auto-referido bloqueado)', 'REF-A1B2C3'),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: surfaceHigh, foregroundColor: neonCyan),
                icon: const Icon(Icons.add_a_photo, size: 17),
                label: Text('Seleccionar Foto de Perfil (Opcional)', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                onPressed: () async {
                  final path = await seleccionarCapturaEnBovedaPrivada(campoDestino: 'foto_usuario');
                  if (path != null) onFeedback('Foto guardada en bóveda privada.');
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: neonGreen, foregroundColor: onNeonGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () => run([
                          {'accion': 'GUARDAR_ESTADO', 'ruta': 'form.operacion_auth', 'valor': 'REGISTRO'},
                          {'accion': 'EJECUTAR_REGLA_SQL', 'regla_id': 'REG_AUTH_REGISTRO_LOGIN', 'recargar_pantallas': true}
                        ]),
                        child: Text(
                          estado.interpolarTexto('CREAR CUENTA (+{{sistema.config_global.puntos_bienvenida}} PTS)'),
                          style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: surfaceHigh, foregroundColor: neonCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () => run([
                          {'accion': 'GUARDAR_ESTADO', 'ruta': 'form.operacion_auth', 'valor': 'LOGIN'},
                          {'accion': 'EJECUTAR_REGLA_SQL', 'regla_id': 'REG_AUTH_REGISTRO_LOGIN', 'recargar_pantallas': true}
                        ]),
                        child: Text('INGRESAR', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'LEGO_SCANNER_CAMARA':
        final String modo = (nodoRaw['modo']?.toString() ?? 'QR').toUpperCase();
        if (modo == 'ASISTENCIA_SELFIE') {
          return Esq4CamaraQrAsistencia(nodoRaw: nodoRaw, onFeedback: onFeedback);
        }
        return EscanerQrSdui(nodoRaw: nodoRaw, onFeedback: onFeedback);

      case 'LEGO_MEDIA_STREAM':
        final String modo = (nodoRaw['modo']?.toString() ?? 'VITRINA_STREAMS').toUpperCase();
        if (modo == 'VIDEO_BLOQUEADO') {
          return Esq4VideoPublicidad(nodoRaw: nodoRaw, onFeedback: onFeedback);
        }
        final String img1 = nodoRaw['img1']?.toString() ?? '';
        final String img2 = nodoRaw['img2']?.toString() ?? '';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Comunidad & Streams', style: GoogleFonts.spaceGrotesk(color: onSurface, fontSize: 18, fontWeight: FontWeight.w600)),
                  Text('@club_sdui', style: GoogleFonts.jetBrainsMono(color: neonCyan, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _cardStream('EN VIVO · 1.4K', 'TikTok Live Show', 'Previa Sorteo Oficial', img1, neonRed, () => run([
                      {'accion': 'EJECUTAR_REGLA_SQL', 'regla_id': 'REG_CANAL_OFICIAL_PUBLICO', 'payload': {'canal': 'TikTok Live Show (1.4K)'}}
                    ])),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _cardStream('REEL · 892', 'Entrega de Premio', 'Ganador #8492 Balón', img2, neonGreen, () => run([
                      {'accion': 'EJECUTAR_REGLA_SQL', 'regla_id': 'REG_CANAL_OFICIAL_PUBLICO', 'payload': {'canal': 'Reel Entrega #8492 (892)'}}
                    ])),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'LEGO_GRID_ACCESOS':
        final List items = [
          {'id': 'P04_USR_COMPARTIR_REFERIDOS', 'cod': 'P04', 'tit': 'Compartir y Ganar', 'sub': '+20 pts / envío', 'icon': Icons.share, 'col': neonGreen},
          {'id': 'P05_USR_APORTES_SUSCRIPCION', 'cod': 'P05', 'tit': 'Aportes y Planes', 'sub': 'BASIC / PLUS / VIP', 'icon': Icons.account_balance_wallet, 'col': neonCyan},
          {'id': 'P06_USR_INVENTARIO_PREMIOS_P2P', 'cod': 'P06', 'tit': 'Mis Premios P2P', 'sub': 'Transferencia Balón', 'icon': Icons.military_tech, 'col': neonPurple},
          {'id': 'P07_USR_CANJE_Y_SORTEOS', 'cod': 'P07', 'tit': 'Canje y Sorteos', 'sub': 'Corte 06:00 AM', 'icon': Icons.casino, 'col': const Color(0xFFF59E0B)},
          {'id': 'P08_USR_VOTACIONES_EN_VIVO', 'cod': 'P08', 'tit': 'Votaciones en Vivo', 'sub': '1 voto por usuario', 'icon': Icons.how_to_vote, 'col': neonCyan},
          {'id': 'P14_USR_VER_PUBLICIDAD', 'cod': 'P14', 'tit': 'Ver Publicidad', 'sub': '+15 pts / video', 'icon': Icons.smart_display, 'col': neonPink},
        ];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Terminal de Acciones', style: GoogleFonts.spaceGrotesk(color: onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.35),
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final Map it = items[i];
                  final Color c = it['col'] as Color;
                  return InkWell(
                    onTap: () => onNavegar(it['id'].toString()),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: surfaceHigh, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(it['icon'] as IconData, color: c, size: 22),
                              Text(it['cod'].toString(), style: GoogleFonts.jetBrainsMono(color: onSurfaceVar, fontSize: 10)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(it['tit'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: onSurface, fontSize: 13, fontWeight: FontWeight.w600)),
                              Text(it['sub'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.jetBrainsMono(color: onSurfaceVar, fontSize: 9.5)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );

      case 'LEGO_BOTTOM_DOCK':
        final String activo = (nodoRaw['activo']?.toString() ?? 'CORE').toUpperCase();
        return Container(
          margin: const EdgeInsets.only(top: 6, bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(14)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navBtn(Icons.dashboard, 'Core', activo == 'CORE', () => onNavegar('P01_PUB_INICIO_CLUB')),
              _navBtn(Icons.widgets, 'Nodes', activo == 'NODES', () => onNavegar('P17_ADM_GESTOR_PANTALLAS_VIS')),
              _navBtn(Icons.terminal, 'Ops', activo == 'OPS', () => onNavegar('P12_VER_COLA_REVISION')),
              _navBtn(Icons.badge, 'Access', activo == 'ACCESS', () => onNavegar('P02_PUB_REGISTRO_ACCESO')),
              _navBtn(Icons.tune, 'Config', activo == 'CONFIG', () => onNavegar('P18_ADM_VARIABLES_GLOBALES')),
            ],
          ),
        );

      case 'LEGO_QUEUE_ITEM_CARD':
      default:
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: surfaceCard, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(estado.interpolarTexto(nodoRaw['titulo']?.toString() ?? 'Módulo SDUI'), style: GoogleFonts.spaceGrotesk(color: onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
              if (nodoRaw['subtitulo'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(estado.interpolarTexto(nodoRaw['subtitulo'].toString()), style: GoogleFonts.inter(color: onSurfaceVar, fontSize: 12)),
                ),
            ],
          ),
        );
    }
  }

  static Widget _campoDark(String campo, String label, String hint, {bool esPassword = false, int? maxLen}) {
    final estado = EstadoGlobalSdui.instancia;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.jetBrainsMono(color: onSurfaceVar, fontSize: 10.5)),
          const SizedBox(height: 4),
          TextField(
            obscureText: esPassword,
            maxLength: maxLen,
            style: GoogleFonts.jetBrainsMono(color: onSurface, fontSize: 13),
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              hintStyle: GoogleFonts.jetBrainsMono(color: onSurfaceVar.withValues(alpha: 0.4), fontSize: 12),
              filled: true,
              fillColor: surfaceHigh,
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            onChanged: (v) => estado.escribirRuta('form.$campo', v, notificar: false),
          ),
        ],
      ),
    );
  }

  static Widget _cardStream(String badge, String etiq, String tit, String url, Color col, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: surfaceCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 9 / 11,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: surfaceHighest, child: Icon(Icons.play_circle, color: col, size: 36))),
                    Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [surfaceLowest, Colors.transparent]))),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: surfaceLowest.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(4)),
                        child: Text(badge, style: GoogleFonts.jetBrainsMono(color: col, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(etiq, style: GoogleFonts.jetBrainsMono(color: col, fontSize: 10, fontWeight: FontWeight.w700)),
                          Text(tit, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _navBtn(IconData icon, String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? neonGreen : onSurfaceVar, size: 20),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.jetBrainsMono(color: active ? neonGreen : onSurfaceVar, fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  static Future<void> compartirEnlaceExterno(String texto, String url) async {
    if (url.trim().isNotEmpty) {
      final uri = Uri.tryParse(url.trim());
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    await Share.share(texto);
  }
}