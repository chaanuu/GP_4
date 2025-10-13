import 'package:flutter/material.dart';

class WorkoutProgramScreen extends StatelessWidget {
  const WorkoutProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        title: const Text('프로그램', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('오늘의 프로그램', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text('-', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text('등 집중 훈련', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _buildSectionTitle('1. 준비 운동 및 유산소 (10분)'),
            _buildListItem('가벼운 조깅 또는 걷기 (5분): 몸을 예열합니다.'),
            _buildListItem('동적 스트레칭 (5분): 어깨, 등, 허리 위주로 가볍게 풀어줍니다.'),
            const SizedBox(height: 24),
            _buildSectionTitle('2. 본 운동 (45분)'),
            _buildListItem('랫풀다운 (4세트): 15회 - 12회 - 10회 - 8~10회\n팁: 광배근에 집중하며 팔꿈치를 당깁니다.'),
            _buildListItem('바벨 로우 (4세트): 15회 - 12회 - 10회 - 8~10회\n팁: 허리를 곧게 펴고, 등 근육을 쥐어짜듯 수축합니다.'),
            const SizedBox(height: 24),
            _buildSectionTitle('3. 마무리 운동 (5분)'),
            _buildListItem('정적 스트레칭 (5분): 운동 후 늘어난 등 근육을 스트레칭으로 이완시킵니다.'),
            _buildListItem('참고: 세트 사이 휴식 시간은 1분~1분 30초로 설정하세요.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, height: 1.5))),
        ],
      ),
    );
  }
}