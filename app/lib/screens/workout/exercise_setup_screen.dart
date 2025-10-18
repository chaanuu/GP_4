import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workout_program.dart';
import '../../providers/program_provider.dart';
import './single_exercise_list_screen.dart';

class ExerciseSetupScreen extends ConsumerStatefulWidget {
  const ExerciseSetupScreen({super.key});

  @override
  ConsumerState<ExerciseSetupScreen> createState() => _ExerciseSetupScreenState();
}

class _ExerciseSetupScreenState extends ConsumerState<ExerciseSetupScreen> {
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');
  final _weightController = TextEditingController(text: '50.0');

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. 전달받은 arguments를 Map 형태로 가져옵니다.
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final exercise = arguments['exercise'] as Exercise;
    final isSingleWorkout = arguments['isSingleWorkout'] as bool;

    // 2. 흐름에 따라 버튼 텍스트와 동작을 결정합니다.
    final String buttonText = isSingleWorkout ? '운동 시작' : '프로그램에 추가';
    final VoidCallback onPressedAction = isSingleWorkout
        ? () { // 단일 운동일 때의 동작
      final workoutData = {
        'name': exercise.name,
        'imagePath': exercise.imagePath,
        'sets': int.tryParse(_setsController.text) ?? 3,
        'reps': int.tryParse(_repsController.text) ?? 10,
        'weight': double.tryParse(_weightController.text) ?? 50.0,
      };
      Navigator.pushReplacementNamed(context, '/workout_reps', arguments: workoutData);
    }
        : () { // 프로그램 만들기일 때의 동작
      final newExercise = WorkoutExercise(
        name: exercise.name,
        imagePath: exercise.imagePath,
        sets: int.tryParse(_setsController.text) ?? 3,
        reps: int.tryParse(_repsController.text) ?? 10,
        weight: double.tryParse(_weightController.text) ?? 50.0,
      );
      ref.read(programBuilderProvider.notifier).addExercise(newExercise);
      Navigator.pop(context);
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('${exercise.name} 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(label: '세트', controller: _setsController),
            const SizedBox(height: 20),
            _buildInputField(label: '횟수', controller: _repsController),
            const SizedBox(height: 20),
            _buildInputField(label: '무게 (kg)', controller: _weightController),
            const Spacer(),
            ElevatedButton(
              onPressed: onPressedAction, // 3. 결정된 동작을 연결합니다.
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(buttonText, style: const TextStyle(fontSize: 18, color: Colors.white)), // 4. 결정된 텍스트를 표시합니다.
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    );
  }
}