import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/program_provider.dart';

class ProgramBuilderScreen extends ConsumerStatefulWidget {
  const ProgramBuilderScreen({super.key});

  @override
  ConsumerState<ProgramBuilderScreen> createState() =>
      _ProgramBuilderScreenState();
}

class _ProgramBuilderScreenState
    extends ConsumerState<ProgramBuilderScreen> {

  List<Map<String, dynamic>> selectedExercises = [];

  void _addExercise(Map<String, dynamic> exercise) {
    setState(() {
      selectedExercises.add({
        "exerciseId": exercise["id"],
        "name": exercise["name"],
        "sets": exercise["sets"],
        "reps": exercise["reps"],
        "weight": exercise["weight"],
      });
    });
  }

  void _openExercisePicker() {
    Navigator.pushNamed(
      context,
      '/single_exercise_list',
      arguments: {"mode": "program"},
    ).then((result) {
      if (result is Map<String, dynamic>) {
        _addExercise(result);
      }
    });
  }

  void _editExercise(int index) {
    final item = selectedExercises[index];

    TextEditingController setCtrl =
    TextEditingController(text: item["sets"].toString());
    TextEditingController repCtrl =
    TextEditingController(text: item["reps"].toString());
    TextEditingController weightCtrl =
    TextEditingController(text: item["weight"].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${item["name"]} 설정"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: setCtrl,
              decoration: const InputDecoration(labelText: "세트 수"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: repCtrl,
              decoration: const InputDecoration(labelText: "횟수"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightCtrl,
              decoration: const InputDecoration(labelText: "무게 (kg)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedExercises[index]["sets"] =
                    int.tryParse(setCtrl.text) ?? 3;
                selectedExercises[index]["reps"] =
                    int.tryParse(repCtrl.text) ?? 10;
                selectedExercises[index]["weight"] =
                    double.tryParse(weightCtrl.text) ?? 0.0;
              });
              Navigator.pop(context);
            },
            child: const Text("확인"),
          )
        ],
      ),
    );
  }

  void _goToSaveScreen() {
    Navigator.pushNamed(context, '/save_program',
        arguments: selectedExercises);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("프로그램 구성"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (selectedExercises.isNotEmpty)
            TextButton(
              onPressed: _goToSaveScreen,
              child: const Text(
                "다음",
                style: TextStyle(color: Colors.black),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openExercisePicker,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: selectedExercises.isEmpty
          ? const Center(child: Text("운동을 추가해보세요."))
          : ListView.builder(
        itemCount: selectedExercises.length,
        itemBuilder: (_, i) {
          final item = selectedExercises[i];
          return ListTile(
            title: Text(item["name"]),
            subtitle: Text(
              "${item["sets"]}세트 · ${item["reps"]}회 · ${item["weight"]}kg",
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editExercise(i),
            ),
          );
        },
      ),
    );
  }
}

