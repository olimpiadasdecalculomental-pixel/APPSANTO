import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../nucleo/estado_global.dart';
import '../nucleo/ejecutor_flujos.dart';

class LegoOrbeBovedas02 {
  static const Color bgVoid = Color(0xFF111124);
  static const Color surfaceLowest = Color(0xFF0C0C1E);
  static const Color surfaceLow = Color(0xFF1A1A2C);
  static const Color surfaceCard = Color(0xFF1E1E31);
  static const Color surfaceHigh = Color(0xFF28283B);
  static const Color surfaceHighest = Color(0xFF333347);
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
      case 'LEGO_ORBE_HEADER_MTO':
        final String marca = estado.interpolarTexto(nodoRaw['marca']?.toString() ?? 'ORBE // IMPERIO');
        final String sub = estado.interpolarTexto(nodoRaw['subtitulo']?.toString() ?? 'MIS TALENTOS');
        final String saldo = estado.interpolarTexto(nodoRaw['saldo']?.toString() ?? '0.00');
        final String rol = estado.interpolarTexto(nodoRaw['rol_badge']?.toString() ?? 'ORBE');
        final String fx = estado.interpolarTexto(nodoRaw['fx_texto']?.toString() ?? '1\$ = 6.86 Bs = 100 MTO');
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surfaceLowest.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: cyanNeon.withValues(alpha: 0.14), blurRadius: 16)],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: surfaceCard, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.token, color: cyanNeon, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(marca.toUpperCase(), style: GoogleFonts.spaceGrotesk(color: cyanNeon, fontSize: 15, fontWeight: FontWeight.w700)),
                          Text(sub.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: onSurfaceVar, fontSize: 9.5, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(color: magentaNeon.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(99)),
                        child: Text(rol.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: const Color(0xFFFFABF2), fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => run([{'accion': 'LIMPIAR_CACHE_Y_RECARGAR'}]),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: surfaceHigh, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.sync, color: cyanNeon, size: 17),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: surfaceHigh.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ORBE: $saldo MTO', style: GoogleFonts.jetBrainsMono(color: cyanNeon, fontSize: 11.5, fontWeight: FontWeight.w700)),
                    Text(fx, style: GoogleFonts.jetBrainsMono(color: greenNeon, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        );

      case 'LEGO_BOVEDA_MTO_CARD':
        return _BovedaMtoCard02(nodoRaw: nodoRaw, onNavegar: onNavegar, onRecargar: onRecargar, onFeedback: onFeedback);

      case 'LEGO_LISTA_MOVIMIENTOS_FILTRABLE':
        return _ListaMovimientosFiltrable02(nodoRaw: nodoRaw, onFeedback: onFeedback);

      case 'LEGO_PARTIDA_DOBLE_LEDGER':
        return _PartidaDobleLedger02(nodoRaw: nodoRaw, onFeedback: onFeedback);

      case 'LEGO_GRAFICO_SPARKLINE_RESERVA':
      default:
        return _GraficoSparklineReserva02(nodoRaw: nodoRaw, onNavegar: onNavegar, onRecargar: onRecargar, onFeedback: onFeedback);
    }
  }
}

class _BovedaMtoCard02 extends StatefulWidget {
  final Map nodoRaw;
  final void Function(String) onNavegar;
  final Future Function() onRecargar;
  final void Function(String) onFeedback;
  const _BovedaMtoCard02({required this.nodoRaw, required this.onNavegar, required this.onRecargar, required this.onFeedback});

  @override
  State<_BovedaMtoCard02> createState() => _BovedaMtoCard02State();
}

class _BovedaMtoCard02State extends State<_BovedaMtoCard02> {
  bool _oculto = false;

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String titular = estado.interpolarTexto(widget.nodoRaw['titular']?.toString() ?? 'Titular Orbe');
    final String badge = estado.interpolarTexto(widget.nodoRaw['badge']?.toString() ?? 'EN LÍNEA');
    final String saldo = estado.interpolarTexto(widget.nodoRaw['saldo']?.toString() ?? '0.00');
    final String unidad = estado.interpolarTexto(widget.nodoRaw['unidad']?.toString() ?? 'MTO');
    final String fiat = estado.interpolarTexto(widget.nodoRaw['equivalente_fiat']?.toString() ?? '≈ 0.00 USD • 0.00 BOB');
    final String k1L = estado.interpolarTexto(widget.nodoRaw['k1_label']?.toString() ?? 'Saldo Previo');
    final String k1V = estado.interpolarTexto(widget.nodoRaw['k1_valor']?.toString() ?? '0.00 MTO');
    final String k2L = estado.interpolarTexto(widget.nodoRaw['k2_label']?.toString() ?? 'Último Mov.');
    final String k2V = estado.interpolarTexto(widget.nodoRaw['k2_valor']?.toString() ?? '0.00 MTO');
    final String k3L = estado.interpolarTexto(widget.nodoRaw['k3_label']?.toString() ?? 'Estado');
    final String k3V = estado.interpolarTexto(widget.nodoRaw['k3_valor']?.toString() ?? 'ACTIVO');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LegoOrbeBovedas02.surfaceLow,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: LegoOrbeBovedas02.cyanNeon.withValues(alpha: 0.16), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titular, style: GoogleFonts.spaceGrotesk(color: LegoOrbeBovedas02.onSurface, fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('SALDO TOTAL DISPONIBLE', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.onSurfaceVar, fontSize: 9.5)),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: LegoOrbeBovedas02.greenNeon.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(99)),
                    child: Text(badge, style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.greenNeon, fontSize: 9.5, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    icon: Icon(_oculto ? Icons.visibility_off : Icons.visibility, color: LegoOrbeBovedas02.cyanNeon, size: 19),
                    onPressed: () => setState(() => _oculto = !_oculto),
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(_oculto ? '••••••' : saldo, style: GoogleFonts.spaceGrotesk(color: LegoOrbeBovedas02.greenNeon, fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Text(unidad, style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.cyanNeon, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          Text(_oculto ? '••••••' : fiat, style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.onSurfaceVar, fontSize: 11)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: LegoOrbeBovedas02.surfaceLowest, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(child: _miniKpi(k1L, _oculto ? '•••' : k1V, LegoOrbeBovedas02.onSurface)),
                Expanded(child: _miniKpi(k2L, _oculto ? '•••' : k2V, LegoOrbeBovedas02.cyanNeon)),
                Expanded(child: _miniKpi(k3L, k3V, LegoOrbeBovedas02.greenNeon)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniKpi(String l, String v, Color c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.onSurfaceVar, fontSize: 9)),
        const SizedBox(height: 2),
        Text(v, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.jetBrainsMono(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ListaMovimientosFiltrable02 extends StatefulWidget {
  final Map nodoRaw;
  final void Function(String) onFeedback;
  const _ListaMovimientosFiltrable02({required this.nodoRaw, required this.onFeedback});

  @override
  State<_ListaMovimientosFiltrable02> createState() => _ListaMovimientosFiltrable02State();
}

class _ListaMovimientosFiltrable02State extends State<_ListaMovimientosFiltrable02> {
  String _filtro = 'TODOS';
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String titulo = estado.interpolarTexto(widget.nodoRaw['titulo']?.toString() ?? 'Movimientos de Bóveda');
    final List filtros = (widget.nodoRaw['filtros'] as List?) ?? ['TODOS', 'BONOS (+)', 'P2P', 'CANJES B2B'];
    final List itemsRaw = (widget.nodoRaw['items'] as List?) ?? [
      {'tipo': 'BONOS (+)', 'titulo': 'Bono Ascenso Tutor Centinela', 'sub': 'Auditoría SIE Bimestre 1 · Hoy 09:35', 'monto': '+50.00 MTO', 'positivo': true, 'txid': 'TX-9941A', 'origen': 'DIRECCION_GENERAL', 'destino': 'Bóveda Familiar'},
      {'tipo': 'P2P', 'titulo': 'Transferencia P2P Robótica M3', 'sub': 'Mateo Quispe Condori · Bloque #884,924', 'monto': '-50.00 MTO', 'positivo': false, 'txid': 'TX-P2P-8849-004', 'origen': 'Mariela Flores', 'destino': 'Mateo Quispe'},
      {'tipo': 'CANJES B2B', 'titulo': 'Canje Fideicomiso #B2B-991', 'sub': 'Combo Gamer Burger Cuántica · CyberBurgers', 'monto': '+9.90 MTO', 'positivo': true, 'txid': 'TX-ESCROW-991', 'origen': 'ESCROW_B2B', 'destino': 'EMP-884'},
    ];

    final List filtrados = itemsRaw.where((e) {
      if (e is! Map) return false;
      final String t = (e['tipo'] ?? '').toString().toUpperCase();
      final String tit = (e['titulo'] ?? '').toString().toLowerCase();
      final String sub = (e['sub'] ?? '').toString().toLowerCase();
      final bool okCat = _filtro == 'TODOS' || t.contains(_filtro.replaceAll(' (+)', '').trim());
      final bool okSearch = _busqueda.isEmpty || tit.contains(_busqueda) || sub.contains(_busqueda);
      return okCat && okSearch;
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LegoOrbeBovedas02.surfaceLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titulo, style: GoogleFonts.spaceGrotesk(color: LegoOrbeBovedas02.onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
              Text('${filtrados.length} REGISTROS', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.cyanNeon, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.onSurface, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Buscar por TXID, comercio o alumno...',
              hintStyle: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.onSurfaceVar.withValues(alpha: 0.5), fontSize: 11),
              prefixIcon: const Icon(Icons.search, color: LegoOrbeBovedas02.cyanNeon, size: 18),
              filled: true,
              fillColor: LegoOrbeBovedas02.surfaceLowest,
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => _busqueda = v.toLowerCase().trim()),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filtros.map((f) {
                final String label = f.toString().toUpperCase();
                final bool activo = _filtro == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(label, style: GoogleFonts.jetBrainsMono(color: activo ? Colors.black : LegoOrbeBovedas02.onSurface, fontSize: 10, fontWeight: FontWeight.w700)),
                    selected: activo,
                    selectedColor: LegoOrbeBovedas02.cyanNeon,
                    backgroundColor: LegoOrbeBovedas02.surfaceHigh,
                    onSelected: (_) => setState(() => _filtro = label),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          ...filtrados.map((item) {
            final Map m = item as Map;
            final bool pos = m['positivo'] == true || (m['monto']?.toString().startsWith('+') ?? false);
            final Color colMonto = pos ? LegoOrbeBovedas02.greenNeon : LegoOrbeBovedas02.redNeon;
            return InkWell(
              onTap: () => _mostrarInspectorRecibo(context, m),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(color: LegoOrbeBovedas02.surfaceCard, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: colMonto.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
                      child: Icon(pos ? Icons.south_west : Icons.north_east, color: colMonto, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(estado.interpolarTexto(m['titulo']?.toString() ?? ''), maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: LegoOrbeBovedas02.onSurface, fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(estado.interpolarTexto(m['sub']?.toString() ?? ''), maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.onSurfaceVar, fontSize: 9.5)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(estado.interpolarTexto(m['monto']?.toString() ?? ''), style: GoogleFonts.jetBrainsMono(color: colMonto, fontSize: 12.5, fontWeight: FontWeight.w700)),
                        Text('VER RECIBO >', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.cyanNeon, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _mostrarInspectorRecibo(BuildContext context, Map m) {
    final String txid = m['txid']?.toString() ?? 'TX-ORBE-001';
    final String titulo = m['titulo']?.toString() ?? 'Operación Orbe';
    final String monto = m['monto']?.toString() ?? '0.00 MTO';
    showModalBottomSheet(
      context: context,
      backgroundColor: LegoOrbeBovedas02.surfaceLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('RECIBO CRIPTOGRÁFICO AUDITADO', style: GoogleFonts.spaceGrotesk(color: LegoOrbeBovedas02.cyanNeon, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: LegoOrbeBovedas02.surfaceLowest, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(monto, style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.greenNeon, fontSize: 24, fontWeight: FontWeight.w700)),
                  Text(titulo, style: GoogleFonts.inter(color: LegoOrbeBovedas02.onSurface, fontSize: 13.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('TXID: $txid', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.cyanNeon, fontSize: 10.5)),
                  Text('Origen: ${m['origen'] ?? 'Bóveda Orbe'}', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.onSurfaceVar, fontSize: 10)),
                  Text('Destino: ${m['destino'] ?? 'Red Imperio'}', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.onSurfaceVar, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: LegoOrbeBovedas02.cyanNeon, side: const BorderSide(color: LegoOrbeBovedas02.cyanNeon)),
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text('COPIAR TXID', style: GoogleFonts.jetBrainsMono(fontSize: 10.5)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: txid));
                      widget.onFeedback('TXID copiado: $txid');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: LegoOrbeBovedas02.greenNeon, foregroundColor: Colors.black),
                    icon: const Icon(Icons.share, size: 16),
                    label: Text('COMPARTIR', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700)),
                    onPressed: () => Share.share('Recibo Orbe $txid · $titulo · $monto'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PartidaDobleLedger02 extends StatelessWidget {
  final Map nodoRaw;
  final void Function(String) onFeedback;
  const _PartidaDobleLedger02({required this.nodoRaw, required this.onFeedback});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String bloque = estado.interpolarTexto(nodoRaw['bloque']?.toString() ?? '#884,913');
    final String hash = estado.interpolarTexto(nodoRaw['block_hash']?.toString() ?? '0x991f48c90b0e27188420e6f77c01a913');
    final String merkle = estado.interpolarTexto(nodoRaw['merkle_root']?.toString() ?? '0x7e88b901fc4e2b810d7a0499e120d31a');
    final List asientos = (nodoRaw['asientos'] as List?) ?? [
      {'cuenta': 'Débito Custodia ESCROW_B2B', 'debe': '-10.00 MTO', 'haber': '0.00'},
      {'cuenta': 'Crédito Comercio EMP-884', 'debe': '0.00', 'haber': '+9.90 MTO'},
      {'cuenta': 'Tasa Red RESERVA_MTO', 'debe': '0.00', 'haber': '+0.10 MTO'},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LegoOrbeBovedas02.surfaceLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('BLOQUE LEDGER $bloque', style: GoogleFonts.spaceGrotesk(color: LegoOrbeBovedas02.onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: LegoOrbeBovedas02.greenNeon.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text('INMUTABLE & MINADO', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.greenNeon, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: LegoOrbeBovedas02.surfaceLowest, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SHA-256 BLOCK HASH', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.onSurfaceVar, fontSize: 9)),
                      Text(hash, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.cyanNeon, fontSize: 10.5)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: LegoOrbeBovedas02.cyanNeon, size: 17),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: hash));
                    onFeedback('Block Hash copiado.');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: LegoOrbeBovedas02.surfaceCard, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(flex: 5, child: Text('CUENTA / CONCEPTO', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.onSurfaceVar, fontSize: 9, fontWeight: FontWeight.w700))),
                    Expanded(flex: 3, child: Text('DEBE (-)', textAlign: TextAlign.right, style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.redNeon, fontSize: 9, fontWeight: FontWeight.w700))),
                    Expanded(flex: 3, child: Text('HABER (+)', textAlign: TextAlign.right, style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.greenNeon, fontSize: 9, fontWeight: FontWeight.w700))),
                  ],
                ),
                const Divider(color: Colors.white12),
                ...asientos.map((a) {
                  final Map row = a as Map;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(flex: 5, child: Text(row['cuenta']?.toString() ?? '', style: GoogleFonts.inter(color: LegoOrbeBovedas02.onSurface, fontSize: 11.5))),
                        Expanded(flex: 3, child: Text(row['debe']?.toString() ?? '0.00', textAlign: TextAlign.right, style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.redNeon, fontSize: 10.5, fontWeight: FontWeight.w700))),
                        Expanded(flex: 3, child: Text(row['haber']?.toString() ?? '0.00', textAlign: TextAlign.right, style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.greenNeon, fontSize: 10.5, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  );
                }),
                const Divider(color: Colors.white12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('BALANCE NETO FINAL', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.greenNeon, fontSize: 10, fontWeight: FontWeight.w700)),
                    Text('0.00 MTO · PARIDAD 100%', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.cyanNeon, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('MERKLE ROOT: $merkle', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.onSurfaceVar, fontSize: 9.5)),
        ],
      ),
    );
  }
}

class _GraficoSparklineReserva02 extends StatelessWidget {
  final Map nodoRaw;
  final void Function(String) onNavegar;
  final Future Function() onRecargar;
  final void Function(String) onFeedback;
  const _GraficoSparklineReserva02({required this.nodoRaw, required this.onNavegar, required this.onRecargar, required this.onFeedback});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String saldo = estado.interpolarTexto(nodoRaw['saldo_reserva']?.toString() ?? '14,892.55');
    final List barras = (nodoRaw['barras_7d'] as List?) ?? [0.40, 0.55, 0.35, 0.70, 0.60, 0.80, 0.98];
    final List dias = ['L', 'M', 'M', 'J', 'V', 'S', 'HOY'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LegoOrbeBovedas02.surfaceLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TESORERÍA // RESERVA_MTO', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.cyanNeon, fontSize: 10.5, fontWeight: FontWeight.w700)),
              Text('SOLVENCIA 100%', style: GoogleFonts.jetBrainsMono(color: LegoOrbeBovedas02.greenNeon, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text('$saldo MTO', style: GoogleFonts.spaceGrotesk(color: LegoOrbeBovedas02.onSurface, fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Container(
            height: 84,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: LegoOrbeBovedas02.surfaceLowest, borderRadius: BorderRadius.circular(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(barras.length.clamp(1, 7), (i) {
                final double h = (double.tryParse(barras[i].toString()) ?? 0.5).clamp(0.1, 1.0);
                final bool hoy = i == barras.length - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 46 * h,
                          decoration: BoxDecoration(
                            color: hoy ? LegoOrbeBovedas02.greenNeon : LegoOrbeBovedas02.cyanNeon.withValues(alpha: 0.45),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(dias[i], style: GoogleFonts.jetBrainsMono(color: hoy ? LegoOrbeBovedas02.greenNeon : LegoOrbeBovedas02.onSurfaceVar, fontSize: 8.5, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: LegoOrbeBovedas02.cyanNeon, foregroundColor: Colors.black),
            icon: const Icon(Icons.account_balance_wallet, size: 18),
            label: Text('RETIRAR TESORERÍA A CUENTA PERSONAL', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700)),
            onPressed: () => EjecutorFlujosSdui.ejecutarCadena(
              context: context,
              flujoAcciones: (nodoRaw['flujo_retiro'] as List?) ?? [],
              onNavegar: onNavegar,
              onRecargarPantallas: onRecargar,
              onFeedback: onFeedback,
            ),
          ),
        ],
      ),
    );
  }
}