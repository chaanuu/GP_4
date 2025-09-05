import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/primary_button.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});
  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  String? scannedText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 QR 코드 인식'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: scannedText == null
                    ? const Text('미리보기 (실제 스캐너 연동 예정)')
                    : Text('스캔 결과: $scannedText'),
              ),
            ),
            PrimaryButton(
              label: 'QR 스캔 시뮬레이션',
              onPressed: () {
                setState(() => scannedText = 'MACHINE:CHEST_PRESS');
                context.push('/assist'); // ← push 사용
              },
            ),
          ],
        ),
      ),
    );
  }
}

