import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isProcessing = false; // 중복 스캔 방지를 위한 플래그

  // QR 코드가 감지되었을 때 호출될 함수
  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return; // 이미 처리 중이면 무시

    final String? qrCodeValue = capture.barcodes.first.rawValue;

    if (qrCodeValue != null) {
      setState(() {
        _isProcessing = true; // 처리 시작
      });
      print("QR 코드 감지: $qrCodeValue");
      _handleQrCode(qrCodeValue);
    }
  }

  // 감지된 QR 코드를 처리하는 함수 (백엔드 연동을 시뮬레이션)
  Future<void> _handleQrCode(String qrCode) async {
    // --- 여기부터가 Dummy 백엔드 통신 부분 ---
    // 로딩 중인 것처럼 보이게 1초간 딜레이를 줍니다.
    await Future.delayed(const Duration(seconds: 1));

    // 실제로는 여기서 백엔드 API를 호출합니다.
    // final exerciseData = await ApiService.getExerciseByQr(qrCode);

    // QR 코드 값에 따라 더미 데이터를 반환합니다.
    Map<String, dynamic>? exerciseData;
    if (qrCode == 'deadlift_machine_01') {
      exerciseData = {'name': '데드리프트', 'sets': 3, 'reps': 10, 'weight': 50.0};
    } else if (qrCode == 'squat_rack_02') {
      exerciseData = {'name': '스쿼트', 'sets': 3, 'reps': 12, 'weight': 40.0};
    } else {
      // 인식할 수 없는 QR 코드 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인식할 수 없는 운동기구 QR 코드입니다.')),
      );
      setState(() {
        _isProcessing = false; // 처리 완료
      });
      return;
    }
    // --- 여기까지 Dummy 백엔드 통신 ---

    // 데이터를 가지고 운동 진행 화면으로 이동합니다.
    // arguments로 데이터를 전달합니다.
    if (mounted) { // 화면이 아직 활성화 상태인지 확인
      Navigator.pushReplacementNamed(context, '/workout_reps', arguments: exerciseData);
    }
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
          // 화면 중앙에 스캔 영역을 표시해주는 UI
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
          // 처리 중일 때 로딩 인디케이터 표시
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}