import 'package:flutter/material.dart';

class WorkoutRepsScreen extends StatelessWidget {
  const WorkoutRepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 이전 화면에서 arguments로 전달한 데이터를 받습니다.
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // 데이터가 없는 경우를 대비한 기본값 설정
    final String exerciseName = arguments?['name'] ?? '운동 이름 없음';
    final String? imagePath = arguments?['imagePath'];
    final int sets = arguments?['sets'] ?? 3;
    final int reps = arguments?['reps'] ?? 10;
    final double weight = arguments?['weight'] ?? 50.0;


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // ✅ SizedBox.expand를 사용해 Column이 화면 전체를 차지하게 만듭니다.
      body: SizedBox.expand(
        child: Column(
          // ✅ MainAxisAlignment와 CrossAxisAlignment를 모두 center로 설정해
          // 모든 자식 위젯을 화면의 정중앙에 위치시킵니다.
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(imagePath, height: 120, width: 120)
            else
              const Icon(Icons.fitness_center, size: 120),

            const SizedBox(height: 32),

            const Text('운동 진행중', style: TextStyle(fontSize: 18, color: Colors.grey)),

            Text(exerciseName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),

            const SizedBox(height: 48),

            // ✅ 불필요한 내부 Column을 제거하고 직접 for 루프를 사용합니다.
            for (int i = 1; i <= sets; i++)
              _buildSetInfo('$i세트 - 0/$reps, ${weight}kg'),
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