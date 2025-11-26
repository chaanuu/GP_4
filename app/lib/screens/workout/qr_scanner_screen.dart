import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/program_provider.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  bool _isProcessing = false;

  // QR 감지 처리
  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final String? qrCodeValue = capture.barcodes.first.rawValue;

    if (qrCodeValue != null) {
      setState(() {
        _isProcessing = true;
      });

      print("QR 코드 감지: $qrCodeValue");

      await _handleQrCode(qrCodeValue);

      // 다시 스캔 가능하도록
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // 서버에서 운동 정보 조회 및 화면 이동
  Future<void> _handleQrCode(String qrCode) async {
    final api = ref.read(apiServiceProvider);

    // 서버에서 운동 조회
    final exerciseData = await api.getExerciseByCode(qrCode);

    if (!mounted) return;

    if (exerciseData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("등록되지 않은 운동입니다.")),
      );
      return;
    }

    // 성공 시 운동 설정 화면으로 이동
    Navigator.pushReplacementNamed(
      context,
      '/exercise_setup',
      arguments: exerciseData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 코드 스캔'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),

          // 중앙 스캔 UI
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // 로딩 화면
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
