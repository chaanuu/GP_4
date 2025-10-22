import 'package:flutter/material.dart';
import '../../models/workout_program.dart';

class ProgramDetailScreen extends StatelessWidget {
  const ProgramDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 이전 화면에서 전달받은 WorkoutProgram 객체를 가져옵니다.
    final program = ModalRoute.of(context)!.settings.arguments as WorkoutProgram;

    return Scaffold(
      appBar: AppBar(
        title: Text(program.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: program.exercises.length,
              itemBuilder: (context, index) {
                final exercise = program.exercises[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: Image.asset(exercise.imagePath, width: 40),
                    title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${exercise.sets}세트 x ${exercise.reps}회, ${exercise.weight}kg'),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 프로그램의 첫 운동부터 시작하는 로직 구현
                  // 예를 들어, program.exercises[0] 데이터를 workout_reps_screen으로 전달
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('이 프로그램 시작하기', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}