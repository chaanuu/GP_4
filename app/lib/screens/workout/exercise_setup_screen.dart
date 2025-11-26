import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/program_provider.dart';

class ExerciseSetupScreen extends ConsumerStatefulWidget {
  const ExerciseSetupScreen({super.key});

  @override
  ConsumerState<ExerciseSetupScreen> createState() =>
      _ExerciseSetupScreenState();
}

class _ExerciseSetupScreenState extends ConsumerState<ExerciseSetupScreen> {
  late Map<String, dynamic> exercise; // 서버에서 받은 운동 정보

  final TextEditingController weightController = TextEditingController();
  final TextEditingController setsController = TextEditingController(text: "3");
  final TextEditingController repsController = TextEditingController(text: "10");

  bool loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    exercise = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  Future<void> _saveExercise() async {
    setState(() => loading = true);

    final api = ref.read(apiServiceProvider);

    final int sets = int.tryParse(setsController.text) ?? 0;
    final int reps = int.tryParse(repsController.text) ?? 0;

    final success = await api.saveExerciseLog(
      {
        "exerciseId": exercise["id"],
        "sets": sets,
        "reps": reps,
        "durationMinutes": 0, // 나중에 수정 가능
      },
    );

    setState(() => loading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("운동이 기록되었습니다.")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("운동 기록에 실패했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = exercise["name"] ?? "이름 없음";
    final String mainMuscle = exercise["mainMuscle"] ?? "-";
    final String subMuscle = exercise["subMuscle"] ?? "-";

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // 운동 기본 정보
            Text(
              name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              "주 근육: $mainMuscle",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              "보조 근육: $subMuscle",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // 입력 폼
            _buildNumberField("세트 수", setsController),
            const SizedBox(height: 16),
            _buildNumberField("횟수 (reps)", repsController),
            const SizedBox(height: 16),
            _buildNumberField("무게 (kg)", weightController),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                final int sets = int.tryParse(setsController.text) ?? 0;
                final int reps = int.tryParse(repsController.text) ?? 0;
                final double weight = double.tryParse(weightController.text) ?? 0;

                Navigator.pushNamed(
                  context,
                  '/workout_reps',
                  arguments: {
                    "id": exercise["id"],
                    "name": exercise["name"],
                    "sets": sets,
                    "reps": reps,
                    "weight": weight,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "운동 시작하기",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
