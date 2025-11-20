import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/program_provider.dart'; // apiServiceProvider
import '../../models/workout_program.dart'; // WorkoutExercise 모델

// ✅ API 호출을 위해 ConsumerWidget으로 변경
class WorkoutRepsScreen extends ConsumerWidget {
  const WorkoutRepsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 이전 화면에서 전달받은 데이터
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final String exerciseName = arguments?['name'] ?? '운동 이름 없음';
    final String? imagePath = arguments?['imagePath'];
    final int sets = arguments?['sets'] ?? 3;
    final int reps = arguments?['reps'] ?? 10;
    final double weight = arguments?['weight'] ?? 50.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // 화면 전체를 차지하도록 설정 (중앙 정렬을 위해)
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 운동 이미지 (없으면 기본 아이콘)
            if (imagePath != null)
              Image.asset(imagePath, height: 120, width: 120)
            else
              const Icon(Icons.fitness_center, size: 120),

            const SizedBox(height: 32),

            const Text('운동 진행중', style: TextStyle(fontSize: 18, color: Colors.grey)),
            Text(exerciseName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),

            const SizedBox(height: 48),

            // 세트 정보 표시
            for (int i = 1; i <= sets; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('$i세트 - $reps회, ${weight}kg', style: const TextStyle(fontSize: 24)),
              ),

            const Spacer(),

            //  운동 완료 및 서버 전송 버튼
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () async {
                  // 1. 저장할 운동 데이터 객체 생성
                  final exerciseLog = WorkoutExercise(
                    name: exerciseName,
                    imagePath: imagePath ?? '',
                    sets: sets,
                    reps: reps,
                    weight: weight,
                  );

                  // 2. ApiService를 통해 서버에 전송 (ExerciseLog 저장)
                  // (날짜는 현재 시간 기준)
                  final success = await ref.read(apiServiceProvider).saveExerciseLog(
                      exerciseLog,
                      DateTime.now()
                  );

                  // 3. 결과 처리
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('운동 기록이 서버에 저장되었습니다! ')),
                      );
                      Navigator.pop(context); // 목록으로 돌아가기
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('기록 저장 실패 (서버 연결 확인 필요)')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('운동 완료', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}