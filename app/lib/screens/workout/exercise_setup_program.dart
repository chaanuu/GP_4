import 'package:flutter/material.dart';

class ExerciseSetupProgramScreen extends StatefulWidget {
  const ExerciseSetupProgramScreen({super.key});

  @override
  State<ExerciseSetupProgramScreen> createState() =>
      _ExerciseSetupProgramScreenState();
}

class _ExerciseSetupProgramScreenState
    extends State<ExerciseSetupProgramScreen> {

  late Map<String, dynamic> exercise;

  final setsController = TextEditingController(text: "3");
  final repsController = TextEditingController(text: "10");
  final weightController = TextEditingController(text: "0");

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    exercise = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${exercise["name"]} 설정")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(exercise["name"],
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            _buildField("세트", setsController),
            const SizedBox(height: 15),

            _buildField("횟수", repsController),
            const SizedBox(height: 15),

            _buildField("무게 (kg)", weightController),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "id": exercise["id"],
                  "name": exercise["name"],
                  "sets": int.tryParse(setsController.text) ?? 3,
                  "reps": int.tryParse(repsController.text) ?? 10,
                  "weight": double.tryParse(weightController.text) ?? 0,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("이 운동 추가하기",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
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
