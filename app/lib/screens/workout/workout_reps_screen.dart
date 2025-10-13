import 'package:flutter/material.dart';

class WorkoutRepsScreen extends StatelessWidget {
  const WorkoutRepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 이전 화면에서 운동 종류, 목표 세트/횟수/무게 데이터 받아오기
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TODO: 운동에 맞는 아이콘 또는 이미지 표시
            const Icon(Icons.fitness_center, size: 120),
            const SizedBox(height: 32),
            const Text('운동 - 등 진행중', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const Text('데드리프트', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 48),
            _buildSetInfo('1세트 - 10/10, 50kg'),
            _buildSetInfo('2세트 - 8/10, 50kg'),
            _buildSetInfo('3세트 - 0/10, 50kg'), // 진행중인 세트는 다르게 표시 가능
            const Spacer(),
            // TODO: '운동 완료', '세트 완료' 등 인터랙션 버튼 추가
          ],
        ),
      ),
    );
  }

  Widget _buildSetInfo(String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        info,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}