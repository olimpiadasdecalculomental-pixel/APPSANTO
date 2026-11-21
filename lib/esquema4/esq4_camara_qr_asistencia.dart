import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../nucleo/estado_global.dart';
import 'esq4_rpcs.dart';

class Esq4CamaraQrAsistencia extends StatefulWidget {
  final Map nodoRaw;
  final void Function(String) onFeedback;
  const Esq4CamaraQrAsistencia({super.key, required this.nodoRaw, required this.onFeedback});

  @override
  State<Esq4CamaraQrAsistencia> createState() => _Esq4CamaraQrAsistenciaState();
}

class _Esq4CamaraQrAsistenciaState extends State<Esq4CamaraQrAsistencia> {
  CameraController? _camCtrl;
  String _codigoQrDetectado = '';
  bool _qrEscaneado = false;
  String? _fotoBase64;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _iniciarCamaraFrontal();
  }

  Future<void> _iniciarCamaraFrontal() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
      _camCtrl = CameraController(front, ResolutionPreset.medium, enableAudio: false);
      await _camCtrl!.initialize();
      if (mounted) setState(() {});
    } catch (_) {
      widget.onFeedback('No se pudo inicializar la cámara frontal obligatoria.');
    }
  }

  @override
  void dispose() {
    _camCtrl?.dispose();
    super.dispose();
  }

  Future<void> _ejecutarMarcacion() async {
    if (_camCtrl == null || !_camCtrl!.value.isInitialized) return;
    if (_codigoQrDetectado.isEmpty) {
      widget.onFeedback('Falta escanear el QR de la oficina.');
      return;
    }
    
    setState(() => _procesando = true);
    try {
      final file = await _camCtrl!.takePicture();
      final bytes = await file.readAsBytes();
      _fotoBase64 = base64Encode(bytes);

      final String tipoMarcacion = widget.nodoRaw['tipo_marcacion']?.toString() ?? 'ENTRADA';
      
      final res = await Esq4Rpcs.asistenciaYAccesos(
        selfieBase64: _fotoBase64!,
        tipoMarcacion: tipoMarcacion,
        qrDetectado: _codigoQrDetectado,
      );

      widget.onFeedback(res['mensaje']?.toString() ?? 'Marcación Completada');
    } catch (_) {
      widget.onFeedback('Error procesando selfie o QR.');
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF0B132B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00F3FF))),
      child: Column(
        children: [
          const Text('MARCACIÓN CON SELFIE (EN VIVO)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (!_qrEscaneado)
            SizedBox(
              height: 200,
              child: MobileScanner(
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    setState(() {
                      _codigoQrDetectado = barcodes.first.rawValue!;
                      _qrEscaneado = true;
                    });
                    widget.onFeedback('QR Detectado: \');
                  }
                },
              ),
            )
          else if (_camCtrl != null && _camCtrl!.value.isInitialized)
            SizedBox(
              height: 250,
              child: CameraPreview(_camCtrl!),
            ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF66), foregroundColor: Colors.black),
            onPressed: _procesando || !_qrEscaneado ? null : _ejecutarMarcacion,
            child: _procesando ? const CircularProgressIndicator(color: Colors.black) : const Text('TOMAR SELFIE Y MARCAR', style: TextStyle(fontWeight: FontWeight.w900)),
          )
        ],
      ),
    );
  }
}