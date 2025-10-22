import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/workout_program.dart';
import '../../providers/program_provider.dart';

class SaveProgramScreen extends ConsumerStatefulWidget {
  const SaveProgramScreen({super.key});

  @override
  ConsumerState<SaveProgramScreen> createState() => _SaveProgramScreenState();
}

class _SaveProgramScreenState extends ConsumerState<SaveProgramScreen> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로그램 저장'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '프로그램 제목',
                hintText: '예: 3대 운동 루틴',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // 1. 현재 추가된 운동 목록을 provider에서 가져오기
                final exercises = ref.read(programBuilderProvider).exercises;
                // 2. 최종 WorkoutProgram 객체 생성
                final newProgram = WorkoutProgram(
                  title: _titleController.text.isNotEmpty ? _titleController.text : '이름 없는 프로그램',
                  date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  exercises: exercises,
                );
                // 3. provider 상태 초기화
                ref.read(programBuilderProvider.notifier).clear();

                // 4. ✅ 현재 화면만 닫고, 이전 화면으로 newProgram을 전달합니다.
                Navigator.of(context).pop(newProgram);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('저장하기', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}