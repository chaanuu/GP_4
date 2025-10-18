import 'package:flutter/material.dart';

// 운동 데이터를 담을 간단한 모델 클래스를 정의합니다.
class Exercise {
  final String name;
  final String imagePath;

  Exercise({required this.name, required this.imagePath});
}

class SingleExerciseListScreen extends StatelessWidget {
  const SingleExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 표시할 운동 목록 데이터를 만듭니다.
    final List<Exercise> exercises = [
      Exercise(name: '데드리프트', imagePath: 'assets/images/deadlift.png'),
      Exercise(name: '스쿼트', imagePath: 'assets/images/squat.png'),
      Exercise(name: '벤치프레스', imagePath: 'assets/images/bench_press.png'),
      Exercise(name: '숄더프레스', imagePath: 'assets/images/shoulder_press.png'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('단일 운동 선택'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1,
        ),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return GestureDetector(
            onTap: () {
              // ✅ 이 부분이 수정되었습니다!
              // Exercise 객체와 isSingleWorkout 플래그를 Map으로 묶어서 전달합니다.
              final arguments = {
                'exercise': exercise,
                'isSingleWorkout': true,
              };
              Navigator.pushNamed(context, '/exercise_setup', arguments: arguments);
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(exercise.imagePath, height: 80),
                  const SizedBox(height: 12),
                  Text(exercise.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}