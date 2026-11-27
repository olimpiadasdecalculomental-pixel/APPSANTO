import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../nucleo/estado_global.dart';
import '../nucleo/ejecutor_flujos.dart';
import '../motores/widgets_stitch_media.dart';

class LegoOrbePosQr03 {
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
      case 'LEGO_CEDULA_QR_AMPLIADA':
        return _CedulaQrAmpliada03(nodoRaw: nodoRaw, onFeedback: onFeedback);

      case 'LEGO_ESCANER_POS_HUD':
        return _EscanerPosHud03(nodoRaw: nodoRaw, onNavegar: onNavegar, onRecargar: onRecargar, onFeedback: onFeedback);

      case 'LEGO_TICKET_COMPROBANTE':
        return _TicketComprobante03(nodoRaw: nodoRaw, onFeedback: onFeedback);

      case 'LEGO_ESCROW_FLUJO':
        final String producto = estado.interpolarTexto(nodoRaw['producto']?.toString() ?? 'Producto B2B');
        final String monto = estado.interpolarTexto(nodoRaw['monto']?.toString() ?? '10.00 MTO');
        final String comercio = estado.interpolarTexto(nodoRaw['comercio']?.toString() ?? 'Comercio Afiliado');
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('FIDEICOMISO ESCROW_B2B', style: GoogleFonts.jetBrainsMono(color: cyanNeon, fontSize: 11, fontWeight: FontWeight.w700)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: greenNeon.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(4)),
                    child: Text('GARANTÍA 7 DÍAS', style: GoogleFonts.jetBrainsMono(color: greenNeon, fontSize: 9.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('$producto · $monto', style: GoogleFonts.spaceGrotesk(color: onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _pasoEscrow(Icons.account_balance_wallet, '1. Tu Bóveda Personal', '-$monto retenidos', cyanNeon),
              const Icon(Icons.arrow_downward, color: onSurfaceVar, size: 16),
              _pasoEscrow(Icons.lock_clock, '2. Bóveda Fideicomiso ESCROW_B2B', 'Custodia criptográfica hasta escaneo QR en tienda', greenNeon),
              const Icon(Icons.arrow_downward, color: onSurfaceVar, size: 16),
              _pasoEscrow(Icons.storefront, '3. $comercio', 'Liberación instantánea al escanear tu ticket QR', magentaNeon),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: cyanNeon, foregroundColor: Colors.black),
                icon: const Icon(Icons.lock, size: 18),
                label: Text('CONFIRMAR Y CONGELAR EN ESCROW', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700)),
                onPressed: () => run((nodoRaw['flujo_acciones'] as List?) ?? []),
              ),
            ],
          ),
        );

      case 'LEGO_DISPARADOR_P2P_RAPIDO':
        return _DisparadorP2pRapido03(nodoRaw: nodoRaw, onNavegar: onNavegar, onRecargar: onRecargar, onFeedback: onFeedback);

      case 'LEGO_VITRINA_B2B_CATALOGO':
        return _VitrinaB2bCatalogo03(nodoRaw: nodoRaw, onNavegar: onNavegar, onRecargar: onRecargar, onFeedback: onFeedback);

      case 'LEGO_DESPACHO_LOTE_FISICO':
        return _DespachoLoteFisico03(nodoRaw: nodoRaw, onNavegar: onNavegar, onRecargar: onRecargar, onFeedback: onFeedback);

      case 'LEGO_MESA_OPTICA_RECARGAS':
      default:
        return _MesaOpticaRecargas03(nodoRaw: nodoRaw, onNavegar: onNavegar, onRecargar: onRecargar, onFeedback: onFeedback);
    }
  }

  static Widget _pasoEscrow(IconData icon, String titulo, String sub, Color col) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: surfaceCard, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, color: col, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: GoogleFonts.inter(color: onSurface, fontSize: 12.5, fontWeight: FontWeight.w700)),
                Text(sub, style: GoogleFonts.jetBrainsMono(color: col, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CedulaQrAmpliada03 extends StatefulWidget {
  final Map nodoRaw;
  final void Function(String) onFeedback;
  const _CedulaQrAmpliada03({required this.nodoRaw, required this.onFeedback});

  @override
  State<_CedulaQrAmpliada03> createState() => _CedulaQrAmpliada03State();
}

class _CedulaQrAmpliada03State extends State<_CedulaQrAmpliada03> {
  bool _brilloMax = false;

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String nombre = estado.interpolarTexto(widget.nodoRaw['nombre']?.toString() ?? '{{sesion.nombre}}');
    final String idP2p = estado.interpolarTexto(widget.nodoRaw['id_p2p']?.toString() ?? '{{sesion.usuario_id}}');
    final String qrData = estado.interpolarTexto(widget.nodoRaw['qr_data']?.toString() ?? 'ORBE_P2P:{{sesion.usuario_id}}');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: LegoOrbePosQr03.surfaceCard, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text('CÉDULA DIGITAL P2P // MODO MOSTRADOR', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.cyanNeon, fontSize: 10.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(nombre, style: GoogleFonts.spaceGrotesk(color: LegoOrbePosQr03.onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: _brilloMax ? [BoxShadow(color: LegoOrbePosQr03.cyanNeon.withValues(alpha: 0.6), blurRadius: 24)] : [],
            ),
            child: QrImageView(data: qrData.isEmpty ? 'ORBE_P2P' : qrData, size: _brilloMax ? 215 : 175),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ID P2P: $idP2p', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.greenNeon, fontSize: 13, fontWeight: FontWeight.w700)),
              IconButton(
                icon: const Icon(Icons.copy, color: LegoOrbePosQr03.cyanNeon, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: idP2p));
                  widget.onFeedback('ID P2P copiado: $idP2p');
                },
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brilloMax ? LegoOrbePosQr03.greenNeon : LegoOrbePosQr03.cyanNeon,
              foregroundColor: Colors.black,
            ),
            icon: Icon(_brilloMax ? Icons.flash_on : Icons.highlight, size: 18),
            label: Text(_brilloMax ? 'BRILLO MÁXIMO ACTIVO EN MOSTRADOR' : 'ACTIVAR MÁXIMO BRILLO DE LECTURA', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700)),
            onPressed: () => setState(() => _brilloMax = !_brilloMax),
          ),
        ],
      ),
    );
  }
}

class _EscanerPosHud03 extends StatelessWidget {
  final Map nodoRaw;
  final void Function(String) onNavegar;
  final Future Function() onRecargar;
  final void Function(String) onFeedback;
  const _EscanerPosHud03({required this.nodoRaw, required this.onNavegar, required this.onRecargar, required this.onFeedback});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String titulo = estado.interpolarTexto(nodoRaw['titulo']?.toString() ?? 'OPTRÓNICA ACTIVA // ESCÁNER POS');
    final String btnTxt = estado.interpolarTexto(nodoRaw['texto_boton']?.toString() ?? 'CONFIRMAR QUEMA Y DESPACHO');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: LegoOrbePosQr03.surfaceLowest, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titulo, style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.greenNeon, fontSize: 10.5, fontWeight: FontWeight.w700)),
              Text('60 FPS // LÁSER ON', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.cyanNeon, fontSize: 9.5)),
            ],
          ),
          const SizedBox(height: 8),
          EscanerQrSdui(nodoRaw: nodoRaw, onFeedback: onFeedback),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: LegoOrbePosQr03.greenNeon, foregroundColor: Colors.black),
            icon: const Icon(Icons.local_fire_department, size: 18),
            label: Text(btnTxt, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700)),
            onPressed: () => EjecutorFlujosSdui.ejecutarCadena(
              context: context,
              flujoAcciones: (nodoRaw['flujo_acciones'] as List?) ?? [],
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

class _TicketComprobante03 extends StatefulWidget {
  final Map nodoRaw;
  final void Function(String) onFeedback;
  const _TicketComprobante03({required this.nodoRaw, required this.onFeedback});

  @override
  State<_TicketComprobante03> createState() => _TicketComprobante03State();
}

class _TicketComprobante03State extends State<_TicketComprobante03> {
  bool _pinVisible = false;

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String titulo = estado.interpolarTexto(widget.nodoRaw['titulo']?.toString() ?? 'Comprobante Digital');
    final String monto = estado.interpolarTexto(widget.nodoRaw['monto']?.toString() ?? '0.00 MTO');
    final String folio = estado.interpolarTexto(widget.nodoRaw['folio']?.toString() ?? '#TX-ORBE-8849');
    final String receptor = estado.interpolarTexto(widget.nodoRaw['receptor']?.toString() ?? '');
    final String detalle = estado.interpolarTexto(widget.nodoRaw['detalle']?.toString() ?? '');
    final String pinUssd = estado.interpolarTexto(widget.nodoRaw['pin_ussd']?.toString() ?? '');
    final String telefono = estado.interpolarTexto(widget.nodoRaw['telefono']?.toString() ?? '');
    final bool quemado = widget.nodoRaw['quemado'] == true;

    final String pinEnmascarado = pinUssd.length > 4 ? '•••• •••• •••• ${pinUssd.substring(pinUssd.length - 4)}' : pinUssd;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LegoOrbePosQr03.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: (quemado ? LegoOrbePosQr03.redNeon : LegoOrbePosQr03.greenNeon).withValues(alpha: 0.16), blurRadius: 18)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(titulo, style: GoogleFonts.spaceGrotesk(color: LegoOrbePosQr03.onSurface, fontSize: 16, fontWeight: FontWeight.w700))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: (quemado ? LegoOrbePosQr03.redNeon : LegoOrbePosQr03.greenNeon).withValues(alpha: 0.18), borderRadius: BorderRadius.circular(6)),
                child: Text(quemado ? 'QUEMADO // BURNED' : 'VALIDADO', style: GoogleFonts.jetBrainsMono(color: quemado ? LegoOrbePosQr03.redNeon : LegoOrbePosQr03.greenNeon, fontSize: 9.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: LegoOrbePosQr03.surfaceLowest, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(monto, style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.cyanNeon, fontSize: 22, fontWeight: FontWeight.w700)),
                      if (receptor.isNotEmpty) Text('Beneficiario: $receptor', style: GoogleFonts.inter(color: LegoOrbePosQr03.onSurface, fontSize: 12)),
                      if (detalle.isNotEmpty) Text(detalle, style: GoogleFonts.inter(color: LegoOrbePosQr03.onSurfaceVar, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('FOLIO: $folio', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.greenNeon, fontSize: 10)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: QrImageView(data: folio, size: 68),
                ),
              ],
            ),
          ),
          if (pinUssd.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: LegoOrbePosQr03.surfaceLowest, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_pinVisible ? pinUssd : pinEnmascarado, style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.goldNeon, fontSize: 13, fontWeight: FontWeight.w700)),
                  TextButton.icon(
                    onPressed: () => setState(() => _pinVisible = !_pinVisible),
                    icon: Icon(_pinVisible ? Icons.visibility_off : Icons.visibility, color: LegoOrbePosQr03.cyanNeon, size: 15),
                    label: Text(_pinVisible ? 'OCULTAR' : 'REVELAR PIN', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.cyanNeon, fontSize: 9.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: LegoOrbePosQr03.cyanNeon, foregroundColor: Colors.black),
              icon: const Icon(Icons.dialpad, size: 17),
              label: Text('CARGAR VÍA USSD (*109*$pinUssd#)', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700)),
              onPressed: () async {
                final uri = Uri.parse('tel:*109*$pinUssd%23');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: LegoOrbePosQr03.cyanNeon, side: const BorderSide(color: LegoOrbePosQr03.cyanNeon)),
                  icon: const Icon(Icons.copy, size: 15),
                  label: Text('COPIAR HASH', style: GoogleFonts.jetBrainsMono(fontSize: 10)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: folio));
                    widget.onFeedback('Hash copiado: $folio');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: LegoOrbePosQr03.greenNeon, foregroundColor: Colors.black),
                  icon: const Icon(Icons.share, size: 15),
                  label: Text('WHATSAPP / COMPARTIR', style: GoogleFonts.jetBrainsMono(fontSize: 9.5, fontWeight: FontWeight.w700)),
                  onPressed: () => Share.share('Comprobante Orbe $folio · $titulo · $monto ${telefono.isNotEmpty ? "($telefono)" : ""}'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DisparadorP2pRapido03 extends StatefulWidget {
  final Map nodoRaw;
  final void Function(String) onNavegar;
  final Future Function() onRecargar;
  final void Function(String) onFeedback;
  const _DisparadorP2pRapido03({required this.nodoRaw, required this.onNavegar, required this.onRecargar, required this.onFeedback});

  @override
  State<_DisparadorP2pRapido03> createState() => _DisparadorP2pRapido03State();
}

class _DisparadorP2pRapido03State extends State<_DisparadorP2pRapido03> {
  double _monto = 50.0;
  String _receptor = 'Mateo Quispe (@mateo_sainz)';

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final List contactos = (widget.nodoRaw['contactos'] as List?) ?? [
      'Mateo Quispe (@mateo_sainz)',
      'Rodrigo Paz (@rodrigo_paz_01)',
      'MayorAdmin #MAY-101',
    ];
    final double usd = _monto / 100.0;
    final double bob = usd * 6.86;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LegoOrbePosQr03.surfaceLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('DISPARO P2P INMEDIATO', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.cyanNeon, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: contactos.map((c) {
                final String nom = c.toString();
                final bool sel = _receptor == nom;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(nom, style: GoogleFonts.jetBrainsMono(color: sel ? Colors.black : LegoOrbePosQr03.onSurface, fontSize: 10, fontWeight: FontWeight.w700)),
                    selected: sel,
                    selectedColor: LegoOrbePosQr03.greenNeon,
                    backgroundColor: LegoOrbePosQr03.surfaceHigh,
                    onSelected: (_) {
                      setState(() => _receptor = nom);
                      estado.escribirRuta('form.receptor_p2p', nom, notificar: false);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: LegoOrbePosQr03.surfaceLowest, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text('${_monto.toStringAsFixed(2)} MTO', style: GoogleFonts.spaceGrotesk(color: LegoOrbePosQr03.cyanNeon, fontSize: 30, fontWeight: FontWeight.w700)),
                Text('≈ \$${usd.toStringAsFixed(2)} USD • ${bob.toStringAsFixed(2)} BOB', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.onSurfaceVar, fontSize: 10.5)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [5.0, 10.0, 20.0, 50.0, 100.0].map((v) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: LegoOrbePosQr03.cyanNeon, padding: EdgeInsets.zero),
                    onPressed: () {
                      setState(() => _monto = v);
                      estado.escribirRuta('form.monto_p2p', v, notificar: false);
                    },
                    child: Text('+${v.toInt()}', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: LegoOrbePosQr03.cyanNeon, foregroundColor: Colors.black),
            icon: const Icon(Icons.bolt, size: 19),
            label: Text('TRANSFERIR ${_monto.toStringAsFixed(2)} MTO A $_receptor', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w700)),
            onPressed: () => EjecutorFlujosSdui.ejecutarCadena(
              context: context,
              flujoAcciones: (widget.nodoRaw['flujo_enviar'] as List?) ?? [],
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

class _VitrinaB2bCatalogo03 extends StatelessWidget {
  final Map nodoRaw;
  final void Function(String) onNavegar;
  final Future Function() onRecargar;
  final void Function(String) onFeedback;
  const _VitrinaB2bCatalogo03({required this.nodoRaw, required this.onNavegar, required this.onRecargar, required this.onFeedback});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String comercio = estado.interpolarTexto(nodoRaw['comercio']?.toString() ?? 'CyberBurgers Neo-Oruro #EMP-884');
    final String plan = estado.interpolarTexto(nodoRaw['plan_saas']?.toString() ?? 'PLAN PRO (3/5 SLOTS)');
    final List productos = (nodoRaw['productos'] as List?) ?? [
      {'nombre': 'Combo Gamer Burger Cuántica', 'precio': '10.00 MTO', 'fiat': '≈ 0.69 Bs', 'stock': '28 DISP.'},
      {'nombre': '2x CyberTacos Neón Al Pastor', 'precio': '19.80 MTO', 'fiat': '≈ 1.36 Bs', 'stock': '15 DISP.'},
      {'nombre': 'Mega Boss Burger Matrix XXL', 'precio': '25.00 MTO', 'fiat': '≈ 1.72 Bs', 'stock': '8 DISP.'},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LegoOrbePosQr03.surfaceLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(comercio, style: GoogleFonts.spaceGrotesk(color: LegoOrbePosQr03.onSurface, fontSize: 16, fontWeight: FontWeight.w700))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: LegoOrbePosQr03.magentaNeon.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(6)),
                child: Text(plan, style: GoogleFonts.jetBrainsMono(color: const Color(0xFFFFABF2), fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...productos.map((p) {
            final Map prod = p as Map;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: LegoOrbePosQr03.surfaceCard, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prod['nombre']?.toString() ?? '', style: GoogleFonts.inter(color: LegoOrbePosQr03.onSurface, fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('${prod['precio']} (${prod['fiat']}) · ${prod['stock']}', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.cyanNeon, fontSize: 10)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: LegoOrbePosQr03.cyanNeon, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 10)),
                    onPressed: () {
                      estado.escribirRuta('form.producto_b2b_sel', prod['nombre'], notificar: false);
                      EjecutorFlujosSdui.ejecutarCadena(
                        context: context,
                        flujoAcciones: (nodoRaw['flujo_canje'] as List?) ?? [],
                        onNavegar: onNavegar,
                        onRecargarPantallas: onRecargar,
                        onFeedback: onFeedback,
                      );
                    },
                    child: Text('CANJEAR', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DespachoLoteFisico03 extends StatelessWidget {
  final Map nodoRaw;
  final void Function(String) onNavegar;
  final Future Function() onRecargar;
  final void Function(String) onFeedback;
  const _DespachoLoteFisico03({required this.nodoRaw, required this.onNavegar, required this.onRecargar, required this.onFeedback});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final String lote = estado.interpolarTexto(nodoRaw['lote']?.toString() ?? 'Lote ENTEL 10 Bs x20 UNID');
    final String destino = estado.interpolarTexto(nodoRaw['destino']?.toString() ?? 'Carlos Mamani (#REC-774002)');
    final String total = estado.interpolarTexto(nodoRaw['total']?.toString() ?? '180.00 Bs (2,623.90 MTO)');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LegoOrbePosQr03.surfaceCard, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('DESPACHO / RECEPCIÓN DE LOTE HSM', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.goldNeon, fontSize: 10.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(lote, style: GoogleFonts.spaceGrotesk(color: LegoOrbePosQr03.onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
          Text('Nodo: $destino', style: GoogleFonts.inter(color: LegoOrbePosQr03.onSurfaceVar, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: LegoOrbePosQr03.surfaceLowest, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Liquidación: $total', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.greenNeon, fontSize: 11.5, fontWeight: FontWeight.w700)),
                Text('Muestra PINs HSM: #ENT-8849-001 al #020 (ECDSA OK)', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.cyanNeon, fontSize: 9.5)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: LegoOrbePosQr03.greenNeon, foregroundColor: Colors.black),
            icon: const Icon(Icons.verified, size: 18),
            label: Text('CONFIRMAR FIRMA HSM E INGRESAR STOCK', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700)),
            onPressed: () => EjecutorFlujosSdui.ejecutarCadena(
              context: context,
              flujoAcciones: (nodoRaw['flujo_confirmar'] as List?) ?? [],
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

class _MesaOpticaRecargas03 extends StatefulWidget {
  final Map nodoRaw;
  final void Function(String) onNavegar;
  final Future Function() onRecargar;
  final void Function(String) onFeedback;
  const _MesaOpticaRecargas03({required this.nodoRaw, required this.onNavegar, required this.onRecargar, required this.onFeedback});

  @override
  State<_MesaOpticaRecargas03> createState() => _MesaOpticaRecargas03State();
}

class _MesaOpticaRecargas03State extends State<_MesaOpticaRecargas03> {
  String _operadora = 'ENTEL';
  double _montoBs = 50.0;
  String _pin = '88492091773412';

  @override
  Widget build(BuildContext context) {
    final estado = EstadoGlobalSdui.instancia;
    final int mtoCalc = (_montoBs * 10).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LegoOrbePosQr03.surfaceLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('AUDITORÍA // MESA ÓPTICA RECARGAS', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.magentaNeon, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: ['ENTEL', 'TIGO', 'VIVA'].map((op) {
              final bool sel = _operadora == op;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ChoiceChip(
                    label: Center(child: Text(op, style: GoogleFonts.jetBrainsMono(color: sel ? Colors.black : LegoOrbePosQr03.onSurface, fontSize: 10.5, fontWeight: FontWeight.w700))),
                    selected: sel,
                    selectedColor: LegoOrbePosQr03.cyanNeon,
                    backgroundColor: LegoOrbePosQr03.surfaceHigh,
                    onSelected: (_) {
                      setState(() => _operadora = op);
                      estado.escribirRuta('form.operadora_mesa', op, notificar: false);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.onSurface, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Monto (Bs)',
                    filled: true,
                    fillColor: LegoOrbePosQr03.surfaceLowest,
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => _montoBs = double.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(color: LegoOrbePosQr03.surfaceLowest, borderRadius: BorderRadius.circular(8)),
                child: Text('$mtoCalc MTO', style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.greenNeon, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            style: GoogleFonts.jetBrainsMono(color: LegoOrbePosQr03.cyanNeon, fontSize: 13, letterSpacing: 1.5),
            decoration: InputDecoration(
              labelText: 'PIN Identificado (${_pin.length} dígitos)',
              filled: true,
              fillColor: LegoOrbePosQr03.surfaceLowest,
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            onChanged: (v) {
              setState(() => _pin = v.trim());
              estado.escribirRuta('form.pin_mesa', _pin, notificar: false);
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: LegoOrbePosQr03.greenNeon, foregroundColor: Colors.black),
            icon: const Icon(Icons.verified, size: 18),
            label: Text('VALIDAR Y APROBAR SALDO ($mtoCalc MTO)', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700)),
            onPressed: () => EjecutorFlujosSdui.ejecutarCadena(
              context: context,
              flujoAcciones: (widget.nodoRaw['flujo_aprobar'] as List?) ?? [],
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