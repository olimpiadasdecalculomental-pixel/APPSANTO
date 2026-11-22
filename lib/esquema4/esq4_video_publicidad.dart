
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../nucleo/estado_global.dart';
import 'esq4_rpcs.dart';

class Esq4VideoPublicidad extends StatefulWidget {
  final Map nodoRaw;
  final void Function(String) onFeedback;
  const Esq4VideoPublicidad({super.key, required this.nodoRaw, required this.onFeedback});

  @override
  State<Esq4VideoPublicidad> createState() => _Esq4VideoPublicidadState();
}

class _Esq4VideoPublicidadState extends State<Esq4VideoPublicidad> {
  VideoPlayerController? _vpCtrl;
  bool _videoFinalizado = false;
  bool _procesandoCobro = false;
  bool _errorCarga = false;
  double _progresoReal = 0.0;

  @override
  void initState() {
    super.initState();
    final url = EstadoGlobalSdui.instancia.interpolarTexto(widget.nodoRaw['url']?.toString() ?? '');
    if (url.isNotEmpty) {
      _vpCtrl = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          _vpCtrl!.addListener(_revisarAvance);
          _vpCtrl!.play();
          if (mounted) setState(() {});
        }).catchError((_) {
          if (mounted) setState(() => _errorCarga = true);
        });
    } else {
      _errorCarga = true;
    }
  }

  void _revisarAvance() {
    if (_vpCtrl == null || !_vpCtrl!.value.isInitialized) return;

    final pos = _vpCtrl!.value.position.inMilliseconds;
    final dur = _vpCtrl!.value.duration.inMilliseconds;

    if (dur > 0) {
      final nuevoProg = (pos / dur).clamp(0.0, 1.0);
      if ((nuevoProg - _progresoReal).abs() >= 0.05 && mounted) {
        setState(() => _progresoReal = nuevoProg);
      }

      if (pos >= (dur - 300) && !_videoFinalizado) {
        if (mounted) {
          setState(() {
            _progresoReal = 1.0;
            _videoFinalizado = true;
          });
          widget.onFeedback('Video completado. Ya puedes reclamar tus puntos.');
        }
      }
    }
  }

  @override
  void dispose() {
    _vpCtrl?.removeListener(_revisarAvance);
    _vpCtrl?.dispose();
    super.dispose();
  }

  Future<void> _reclamarPuntosPublicidad() async {
    setState(() => _procesandoCobro = true);
    final String campanaId = widget.nodoRaw['campana_id']?.toString() ?? '';
    final res = await Esq4Rpcs.publicidadReclamarVista(campanaId: campanaId);
    widget.onFeedback(res['mensaje']?.toString() ?? 'Respuesta procesada');
    if (mounted) setState(() => _procesandoCobro = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_errorCarga) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF05101A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent),
        ),
        child: const Text('No se pudo cargar el video publicitario.', style: TextStyle(color: Colors.white70)),
      );
    }

    if (_vpCtrl == null || !_vpCtrl!.value.isInitialized) {
      return Container(
        height: 200,
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF00FF66))),
      );
    }

    final String puntosRestantes = widget.nodoRaw['puntos_restantes']?.toString() ?? '0';
    final String vistasCompletas = widget.nodoRaw['vistas_completas']?.toString() ?? '0';
    final String alcance = widget.nodoRaw['alcance']?.toString() ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF05101A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF142033),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Puntos: $puntosRestantes', style: const TextStyle(color: Color(0xFF00FF66), fontSize: 10, fontWeight: FontWeight.bold)),
                Text('Vistas: $vistasCompletas', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold)),
                Text('Alcance: $alcance', style: const TextStyle(color: Color(0xFF00F3FF), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          AspectRatio(aspectRatio: _vpCtrl!.value.aspectRatio, child: VideoPlayer(_vpCtrl!)),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _videoFinalizado ? const Color(0xFFFFD700) : Colors.grey,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: (_videoFinalizado && !_procesandoCobro) ? _reclamarPuntosPublicidad : null,
              child: _procesandoCobro
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black))
                  : Text(
                      _videoFinalizado ? 'RECLAMAR PUNTOS' : 'MIRA EL VIDEO COMPLETO (${(_progresoReal * 100).toInt()}%)',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
