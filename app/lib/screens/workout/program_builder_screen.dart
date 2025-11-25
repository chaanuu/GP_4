import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/program_provider.dart';
import './single_exercise_list_screen.dart';

class ProgramBuilderScreen extends ConsumerWidget {
  const ProgramBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programState = ref.watch(programBuilderProvider);

    final List<Exercise> availableExercises = [
      Exercise(name: '데드리프트', imagePath: 'assets/images/deadlift.png'),
      Exercise(name: '스쿼트', imagePath: 'assets/images/squat.png'),
      Exercise(name: '벤치프레스', imagePath: 'assets/images/bench_press.png'),
      Exercise(name: '숄더프레스', imagePath: 'assets/images/shoulder_press.png'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로그램에 운동 추가'),
        actions: [
          TextButton(
            onPressed: programState.exercises.isNotEmpty
                ? () async {
              final result = await Navigator.pushNamed(context, '/save_program');
              if (result != null && context.mounted) {
                Navigator.of(context).pop(result);
              }
            }
                : null,
            child: const Text('완료'),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: availableExercises.length,
              itemBuilder: (context, index) {
                final exercise = availableExercises[index];
                return GestureDetector(
                  onTap: () {
                    //  수정됨: Map 형식으로 데이터 포장
                    final arguments = {
                      'exercise': exercise,
                      'isSingleWorkout': false, // 프로그램 추가임을 표시
                    };
                    Navigator.pushNamed(context, '/exercise_setup', arguments: arguments);
                  },
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(exercise.imagePath, height: 60),
                        const SizedBox(height: 8),
                        Text(exercise.name),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (programState.exercises.isNotEmpty)
            Container(
              height: 200,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('추가된 운동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: programState.exercises.length,
                      itemBuilder: (context, index) {
                        final addedExercise = programState.exercises[index];
                        return ListTile(
                          dense: true,
                          leading: Image.asset(addedExercise.imagePath, width: 30),
                          title: Text(addedExercise.name),
                          subtitle: Text('${addedExercise.sets}세트 x ${addedExercise.reps}회, ${addedExercise.weight}kg'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}