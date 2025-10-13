import 'package:flutter/material.dart';

class MuscleConditionScreen extends StatelessWidget {
  const MuscleConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 백엔드에서 부위별 피로도 데이터 받아오기
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        title: const Text('부위별 상태', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              // TODO: 실제 근육 부위 이미지를 Stack으로 겹쳐서 색상 표시
              child: Image.asset('assets/images/muscles.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 32),
            const Text(
              '오늘은 어깨와 등 운동 어때요?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildMuscleStatus('이두, 전완근', '휴식이 필요합니다!'),
            _buildMuscleStatus('삼두', '단련하셔도 좋습니다!'),
            _buildMuscleStatus('하체', '휴식이 필요합니다!'),
            _buildMuscleStatus('어깨', '단련하셔도 좋습니다!'),
            _buildMuscleStatus('등', '단련하셔도 좋습니다!'),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleStatus(String part, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 16, height: 1.5),
          children: [
            TextSpan(text: '$part - ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: status),
          ],
        ),
      ),
    );
  }
}