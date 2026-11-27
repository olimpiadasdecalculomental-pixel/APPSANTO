import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../nucleo/estado_global.dart';
import '../nucleo/ejecutor_flujos.dart';

class LegoOrbeMundo3Vr04 {
  static const Color surfaceLowest = Color(0xFF0C0C1E);
  static const Color surfaceLow = Color(0xFF1A1A2C);
  static const Color surfaceCard = Color(0xFF1E1E31);
  static const Color surfaceHigh = Color(0xFF28283B);
  static const Color cyanNeon = Color(0xFF00F3FF);
  static const Color greenNeon = Color(0xFF00FD65);
  static const Color magentaNeon = Color(0xFFFE00FB);
  static const Color goldNeon = Color(0xFFFFD700);
  static const Color redNeon = Color(0xFFFF4D4D);
  static const Color onSurface = Color(0xFFE2E0FA);
  static const Color onSurfaceVar = Color(0xFFB9CACB);

  static Widget construirPieza({
    required BuildContext context,
    required Map nodoRaw,
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
      case 'LEGO_MATRIZ_8_NODOS':
        final List nodos = [
          {'tit': 'MEDIA', 'sub': 'FILMS', 'icon': Icons.movie, 'col': cyanNeon, 'dest': nodoRaw['dest_media'] ?? 'P14_USR_VER_PUBLICIDAD'},
          {'tit': 'ARCADE', 'sub': 'RETRO', 'icon': Icons.sports_esports, 'col': magentaNeon, 'dest': nodoRaw['dest_arcade'] ?? 'P07_USR_CANJE_Y_SORTEOS'},
          {'tit': 'CEREBRO', 'sub': 'CURSOS', 'icon': Icons.psychology, 'col': cyanNeon, 'dest': nodoRaw['dest_cerebro'] ?? 'P08_USR_VOTACIONES_EN_VIVO'},
          {'tit': 'CHAT', 'sub': 'RED MTO', 'icon': Icons.forum, 'col': greenNeon, 'dest': nodoRaw['dest_chat'] ?? 'P04_USR_COMPARTIR_REFERIDOS'},
          {'tit': 'BÓVEDA', 'sub': 'VIP PASS', 'icon': Icons.shield, 'col': goldNeon, 'dest': nodoRaw['dest_boveda'] ?? 'P03_USR_HOME_BILLETERA'},
          {'tit': 'DEALERS', 'sub': 'P2P NODE', 'icon': Icons.groups, 'col': magentaNeon, 'dest': nodoRaw['dest_dealers'] ?? 'P06_USR_INVENTARIO_PREMIOS_P2P'},
          {'tit': 'AR / VR', 'sub': '360° HOLO', 'icon': Icons.view_in_ar, 'col': cyanNeon, 'dest': nodoRaw['dest_arvr'] ?? 'P10_EMP_TERMINAL_QUEMA_QR'},
          {'tit': 'DIARIO', 'sub': 'REFLEXIÓN', 'icon': Icons.lightbulb, 'col': greenNeon, 'dest': nodoRaw['dest_diario'] ?? 'P09_USR_REDES_Y_ACTUALIZACION'},
        ];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MATRIZ DE NAVEGACIÓN ECOSISTEMA', style: GoogleFonts.jetBrainsMono(color: cyanNeon, fontSize: 10.5, fontWeight: FontWeight.w700)),
                  Text('8/8 ONLINE', style: GoogleFonts.jetBrainsMono(color: greenNeon, fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 0.9),
                itemCount: nodos.length,
                itemBuilder: (ctx, i) {
                  final Map n = nodos[i];
                  final Color c = n['col'] as Color;
                  return InkWell(
                    onTap: () => onNavegar(n['dest'].toString()),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: surfaceHigh, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(n['icon'] as IconData, color: c, size: 22),
                          const SizedBox(height: 4),
                          Text(n['tit'].toString(), style: GoogleFonts.spaceGrotesk(color: c, fontSize: 10.5, fontWeight: FontWeight.w700)),
                          Text(n['sub'].toString(), style: GoogleFonts.jetBrainsMono(color: onSurfaceVar, fontSize: 8)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );

      case 'LEGO_CINETV_VIP':
        return _CineTvVip04(nodoRaw: nodoRaw, onNavegar: onNavegar, onRecargar: onRecargar, onFeedback: onFeedback);

      case 'LEGO_KAHOOT_COMBATE':
        return _KahootCombate04(nodoRaw: nodoRaw, onNavegar: onNavegar, onRecargar: onRecargar, onFeedback: onFeedback);

      case 'LEGO_FORJADOR_KAHOOT_DOCENTE':
        return _ForjadorKahootDocente04(nodoRaw: nodoRaw, onNavegar: onNavegar, onRecargar: onRecargar, onFeedback: onFeedback);

      case 'LEGO_VISOR_AR_VR_360':
        return _VisorArVr04(nodoRaw: nodoRaw, onFeedback: onFeedback);

      case 'LEGO_REGLAS_TASAS_CARD':
        final String clave = nodoRaw['clave']?.toString() ?? 'puntos_bienvenida';
        final String titulo = estado.interpolarTexto(nodoRaw['titulo']?.toString() ?? clave);
        final String valorActual = estado.interpolarTexto(nodoRaw['valor']?.toString() ?? '');
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: surfaceCard, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: GoogleFonts.inter(color: onSurface, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('Clave: $clave · Actual: $valorActual', style: GoogleFonts.jetBrainsMono(color: cyanNeon, fontSize: 10)),
                  ],
                ),
              ),
              SizedBox(
                width: 90,
                child: TextField(
                  style: GoogleFonts.jetBrainsMono(color: greenNeon, fontSize: 13, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: valorActual,
                    filled: true,
                    fillColor: surfaceLowest,
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => estado.escribirRuta('form.regla_$clave', v, notificar: false),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.save, color: greenNeon),
                onPressed: () => run([
                  {'accion': 'EJECUTAR_REGLA_SQL', 'regla_id': 'REG_ACTUALIZAR_VARIABLE_GLOBAL', 'payload': {'clave': clave, 'valor': '{{form.regla_$clave}}'}, 'recargar_pantallas': true}
                ]),
              ),
            ],
          ),
        );

      case 'LEGO_CIRCULAR_EDU_CARD':
      default:
        final String tit = estado.interpolarTexto(nodoRaw['titulo']?.toString() ?? 'Comunicado Oficial');
        final String cuerpo = estado.interpolarTexto(nodoRaw['cuerpo']?.toString() ?? '');
        final String bonoTxt = estado.interpolarTexto(nodoRaw['texto_boton']?.toString() ?? 'CONFIRMAR LECTURA Y RECLAMAR BONO');
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: surfaceCard, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(tit, style: GoogleFonts.spaceGrotesk(color: goldNeon, fontSize: 16, fontWeight: FontWeight.w700)),
              if (cuerpo.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(cuerpo, style: GoogleFonts.inter(color: onSurface, fontSize: 12.5, height: 1.4)),
              ],
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: goldNeon, foregroundColor: Colors.black),
                icon: const Icon(Icons.verified, size: 17),
                label: Text(bonoTxt, style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700)),
                onPressed: () => run((nodoRaw['flujo_acciones'] as List?) ?? []),
              ),
            ],
          ),
        );
    }
  }
}

class _CineTvVip04 extends StatefulWidget {
  final Map nodoRaw;
  final void Function(String) onNavegar;
  final Future Function() onRecargar;
  final void Function(String) onFeedback;
  const _CineTvVip04({required this.nodoRaw, required this.onNavegar, required this.onRecargar, required this.onFeedback});

  @override
  State<_CineTvVip04> createState() => _CineTvVip04State();
}

class _CineTvVip04State extends State<_CineTvVip04> {
  bool _verBovedaVip = false;
  int _episodio = 1;

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String obra = estado.interpolarTexto(widget.nodoRaw['titulo']?.toString() ?? 'Nuera del Billonario');
    final String costo = estado.interpolarTexto(widget.nodoRaw['costo']?.toString() ?? '50 MTO');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LegoOrbeMundo3Vr04.surfaceLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_verBovedaVip ? LegoOrbeMundo3Vr04.cyanNeon : LegoOrbeMundo3Vr04.surfaceHigh,
                    foregroundColor: !_verBovedaVip ? Colors.black : LegoOrbeMundo3Vr04.onSurface,
                  ),
                  onPressed: () => setState(() => _verBovedaVip = false),
                  child: Text('🌐 GLOBAL', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _verBovedaVip ? LegoOrbeMundo3Vr04.magentaNeon : LegoOrbeMundo3Vr04.surfaceHigh,
                    foregroundColor: _verBovedaVip ? Colors.black : LegoOrbeMundo3Vr04.onSurface,
                  ),
                  onPressed: () => setState(() => _verBovedaVip = true),
                  child: Text('💼 BÓVEDA VIP', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: LegoOrbeMundo3Vr04.surfaceLowest, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('VR / 360 NATIVO · 4K HDR', style: GoogleFonts.jetBrainsMono(color: LegoOrbeMundo3Vr04.cyanNeon, fontSize: 9.5, fontWeight: FontWeight.w700)),
                    Text('👑 VIP $costo', style: GoogleFonts.jetBrainsMono(color: LegoOrbeMundo3Vr04.goldNeon, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('$obra - Ep. $_episodio', style: GoogleFonts.spaceGrotesk(color: LegoOrbeMundo3Vr04.onSurface, fontSize: 17, fontWeight: FontWeight.w700)),
                Text('Regalías: 15% Creador · 5% Mantenimiento App · 80% Inversor', style: GoogleFonts.jetBrainsMono(color: LegoOrbeMundo3Vr04.greenNeon, fontSize: 9.5)),
                const SizedBox(height: 8),
                Row(
                  children: [1, 2, 3, 4].map((ep) {
                    final bool act = _episodio == ep;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text('EP.$ep', style: GoogleFonts.jetBrainsMono(color: act ? Colors.black : LegoOrbeMundo3Vr04.onSurface, fontSize: 9.5, fontWeight: FontWeight.w700)),
                        selected: act,
                        selectedColor: LegoOrbeMundo3Vr04.cyanNeon,
                        backgroundColor: LegoOrbeMundo3Vr04.surfaceHigh,
                        onSelected: (_) => setState(() => _episodio = ep),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: LegoOrbeMundo3Vr04.goldNeon, foregroundColor: Colors.black),
            icon: const Icon(Icons.key, size: 18),
            label: Text(_verBovedaVip ? 'REPRODUCIR LICENCIA VIP ACTIVA' : 'DESBLOQUEAR LICENCIA VIP ($costo · 7 DÍAS)', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700)),
            onPressed: () => EjecutorFlujosSdui.ejecutarCadena(
              context: context,
              flujoAcciones: (widget.nodoRaw['flujo_acciones'] as List?) ?? [],
              onNavegar: widget.onNavegar,
              onRecargarPantallas: widget.onRecargar,
              onFeedback: widget.onFeedback,
            ),
          ),
        ],
      ),
    );
  }
}

class _KahootCombate04 extends StatefulWidget {
  final Map nodoRaw;
  final void Function(String) onNavegar;
  final Future Function() onRecargar;
  final void Function(String) onFeedback;
  const _KahootCombate04({required this.nodoRaw, required this.onNavegar, required this.onRecargar, required this.onFeedback});

  @override
  State<_KahootCombate04> createState() => _KahootCombate04State();
}

class _KahootCombate04State extends State<_KahootCombate04> {
  String _seleccionada = '';

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String pregunta = estado.interpolarTexto(widget.nodoRaw['pregunta']?.toString() ?? '¿Cuál es la primera ley de la termodinámica en un sistema adiabático?');
    final List opciones = [
      {'simbolo': '▲', 'texto': widget.nodoRaw['op1']?.toString() ?? 'ΔU = -W (donde Q = 0)', 'col': const Color(0xFFE21B3C), 'val': 'A'},
      {'simbolo': '◆', 'texto': widget.nodoRaw['op2']?.toString() ?? 'ΔU = Q + W', 'col': const Color(0xFF1368CE), 'val': 'B'},
      {'simbolo': '●', 'texto': widget.nodoRaw['op3']?.toString() ?? 'PV = nRT constante', 'col': const Color(0xFFD89E00), 'val': 'C'},
      {'simbolo': '★', 'texto': widget.nodoRaw['op4']?.toString() ?? 'ΔS = 0 siempre', 'col': const Color(0xFF26890C), 'val': 'D'},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LegoOrbeMundo3Vr04.surfaceCard, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: LegoOrbeMundo3Vr04.redNeon.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
            child: Text('🚨 ANTI-TRAMPAS ACTIVO // SENSOR ENFOQUE ON', style: GoogleFonts.jetBrainsMono(color: LegoOrbeMundo3Vr04.redNeon, fontSize: 9.5, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          Text(pregunta, style: GoogleFonts.spaceGrotesk(color: LegoOrbeMundo3Vr04.onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.5),
            itemCount: opciones.length,
            itemBuilder: (ctx, i) {
              final Map op = opciones[i];
              final bool sel = _seleccionada == op['val'];
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: op['col'] as Color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: sel ? const BorderSide(color: Colors.white, width: 2.5) : BorderSide.none,
                  ),
                ),
                onPressed: () {
                  setState(() => _seleccionada = op['val'].toString());
                  estado.escribirRuta('form.respuesta_kahoot', op['val'], notificar: false);
                  widget.onFeedback('Respuesta ${op['simbolo']} fijada en disco.');
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(op['simbolo'].toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(op['texto'].toString(), maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: LegoOrbeMundo3Vr04.greenNeon, foregroundColor: Colors.black),
            icon: const Icon(Icons.send, size: 18),
            label: Text('ENVIAR RESPUESTA AL SERVIDOR M3', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700)),
            onPressed: () => EjecutorFlujosSdui.ejecutarCadena(
              context: context,
              flujoAcciones: (widget.nodoRaw['flujo_enviar'] as List?) ?? [],
              onNavegar: widget.onNavegar,
              onRecargarPantallas: widget.onRecargar,
              onFeedback: widget.onFeedback,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForjadorKahootDocente04 extends StatefulWidget {
  final Map nodoRaw;
  final void Function(String) onNavegar;
  final Future Function() onRecargar;
  final void Function(String) onFeedback;
  const _ForjadorKahootDocente04({required this.nodoRaw, required this.onNavegar, required this.onRecargar, required this.onFeedback});

  @override
  State<_ForjadorKahootDocente04> createState() => _ForjadorKahootDocente04State();
}

class _ForjadorKahootDocente04State extends State<_ForjadorKahootDocente04> {
  String _tiempo = '15 MIN';
  String _correcta = 'A';

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LegoOrbeMundo3Vr04.surfaceLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('FORJADOR DE COMBATE // KAHOOT DOCENTE', style: GoogleFonts.spaceGrotesk(color: LegoOrbeMundo3Vr04.cyanNeon, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: ['5 MIN', '10 MIN', '15 MIN', '30 MIN'].map((t) {
              final bool sel = _tiempo == t;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ChoiceChip(
                    label: Center(child: Text(t, style: GoogleFonts.jetBrainsMono(color: sel ? Colors.black : LegoOrbeMundo3Vr04.onSurface, fontSize: 9.5, fontWeight: FontWeight.w700))),
                    selected: sel,
                    selectedColor: LegoOrbeMundo3Vr04.greenNeon,
                    backgroundColor: LegoOrbeMundo3Vr04.surfaceHigh,
                    onSelected: (_) {
                      setState(() => _tiempo = t);
                      estado.escribirRuta('form.tiempo_kahoot', t, notificar: false);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextField(
            style: GoogleFonts.inter(color: LegoOrbeMundo3Vr04.onSurface, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Enunciado de la Pregunta',
              filled: true,
              fillColor: LegoOrbeMundo3Vr04.surfaceLowest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            onChanged: (v) => estado.escribirRuta('form.enunciado_kahoot', v, notificar: false),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['A', 'B', 'C', 'D'].map((op) {
              final bool sel = _correcta == op;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ChoiceChip(
                    label: Center(child: Text('OP $op ${sel ? "✓" : ""}', style: GoogleFonts.jetBrainsMono(color: sel ? Colors.black : LegoOrbeMundo3Vr04.onSurface, fontSize: 9.5, fontWeight: FontWeight.w700))),
                    selected: sel,
                    selectedColor: LegoOrbeMundo3Vr04.greenNeon,
                    backgroundColor: LegoOrbeMundo3Vr04.surfaceHigh,
                    onSelected: (_) {
                      setState(() => _correcta = op);
                      estado.escribirRuta('form.opcion_correcta', op, notificar: false);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: LegoOrbeMundo3Vr04.greenNeon, foregroundColor: Colors.black),
            icon: const Icon(Icons.rocket_launch, size: 18),
            label: Text('GUARDAR Y ACTIVAR MISIÓN EN EL MURO', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700)),
            onPressed: () => EjecutorFlujosSdui.ejecutarCadena(
              context: context,
              flujoAcciones: (widget.nodoRaw['flujo_publicar'] as List?) ?? [],
              onNavegar: widget.onNavegar,
              onRecargarPantallas: widget.onRecargar,
              onFeedback: widget.onFeedback,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisorArVr04 extends StatefulWidget {
  final Map nodoRaw;
  final void Function(String) onFeedback;
  const _VisorArVr04({required this.nodoRaw, required this.onFeedback});

  @override
  State<_VisorArVr04> createState() => _VisorArVr04State();
}

class _VisorArVr04State extends State<_VisorArVr04> {
  bool _modoVr = false;
  double _ipd = 64.0;
  double _rotY = 0.3;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LegoOrbeMundo3Vr04.surfaceLowest, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_modoVr ? LegoOrbeMundo3Vr04.greenNeon : LegoOrbeMundo3Vr04.surfaceHigh,
                    foregroundColor: !_modoVr ? Colors.black : LegoOrbeMundo3Vr04.onSurface,
                  ),
                  onPressed: () => setState(() => _modoVr = false),
                  child: Text('🎯 MODO AR (Holograma)', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _modoVr ? LegoOrbeMundo3Vr04.magentaNeon : LegoOrbeMundo3Vr04.surfaceHigh,
                    foregroundColor: _modoVr ? Colors.black : LegoOrbeMundo3Vr04.onSurface,
                  ),
                  onPressed: () => setState(() => _modoVr = true),
                  child: Text('🥽 MODO VR 360°', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onHorizontalDragUpdate: (d) => setState(() => _rotY += d.delta.dx * 0.02),
            child: Container(
              height: 175,
              decoration: BoxDecoration(color: LegoOrbeMundo3Vr04.surfaceCard, borderRadius: BorderRadius.circular(12)),
              child: _modoVr
                  ? Row(
                      children: [
                        Expanded(child: Center(child: Text('OJO IZQ (L)\nIPD ${_ipd.toInt()}mm', textAlign: TextAlign.center, style: GoogleFonts.jetBrainsMono(color: LegoOrbeMundo3Vr04.magentaNeon, fontSize: 11, fontWeight: FontWeight.w700)))),
                        Container(width: (_ipd - 54).clamp(2, 20).toDouble(), color: Colors.black),
                        Expanded(child: Center(child: Text('OJO DER (R)\nFOV 110°', textAlign: TextAlign.center, style: GoogleFonts.jetBrainsMono(color: LegoOrbeMundo3Vr04.cyanNeon, fontSize: 11, fontWeight: FontWeight.w700)))),
                      ],
                    )
                  : Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(_rotY),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.view_in_ar, color: LegoOrbeMundo3Vr04.greenNeon, size: 56),
                            const SizedBox(height: 6),
                            Text('HOLOGRAMA 3D ACTIVO · DESLIZA PARA ROTAR', style: GoogleFonts.jetBrainsMono(color: LegoOrbeMundo3Vr04.cyanNeon, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          if (_modoVr)
            Slider(
              value: _ipd,
              min: 55,
              max: 75,
              activeColor: LegoOrbeMundo3Vr04.cyanNeon,
              onChanged: (v) => setState(() => _ipd = v),
            ),
        ],
      ),
    );
  }
}