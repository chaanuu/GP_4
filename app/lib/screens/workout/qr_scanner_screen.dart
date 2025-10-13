import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart'; // QR 라이브러리 추가 후 사용

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 코드 스캔'),
      ),
      body: const Center(
        child: Text('QR 스캐너가 표시될 화면입니다.'),
      ),
    );
  }
}