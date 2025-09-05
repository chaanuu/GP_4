import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/primary_button.dart';

class BodyAnalysisScreen extends ConsumerStatefulWidget {
  const BodyAnalysisScreen({super.key});
  @override
  ConsumerState<BodyAnalysisScreen> createState() => _BodyAnalysisScreenState();
}

class _BodyAnalysisScreenState extends ConsumerState<BodyAnalysisScreen> {
  String? beforePath;
  String? afterPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('체형 변화 분석'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('정해진 자세로 Before/After 사진을 업로드하세요.'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _imageSlot(context, 'Before', beforePath, () => setState(() => beforePath = 'path/to/before.jpg'))),
                const SizedBox(width: 12),
                Expanded(child: _imageSlot(context, 'After', afterPath, () => setState(() => afterPath = 'path/to/after.jpg'))),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'AI 분석 실행 (더미)',
              onPressed: (beforePath != null && afterPath != null)
                  ? () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('분석 결과 (예시)'),
                    content: const Text('어깨 정렬 +2° 개선\n골반 기울기 -1°\n상완 둘레 +0.6cm 추정'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인'))],
                  ),
                );
              }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSlot(BuildContext context, String label, String? path, VoidCallback onPick) {
    return InkWell(
      onTap: onPick,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Text(path == null ? '$label 이미지 선택' : '$label 선택됨')),
        ),
      ),
    );
  }
}

