import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workout_program.dart';
import '../../providers/program_provider.dart';

// StatefulWidget을 ConsumerWidget으로 변경
class WorkoutProgramScreen extends ConsumerWidget {
  const WorkoutProgramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. FutureProvider를 watch하여 데이터의 상태(loading, data, error)를 감시
    final programsAsyncValue = ref.watch(programsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        title: const Text('나의 운동 프로그램'),
      ),
      body: Column(
        children: [
          Expanded(
            // 2. when을 사용하여 상태에 따라 다른 UI를 보여줌
            child: programsAsyncValue.when(
              // 로딩 중일 때
              loading: () => const Center(child: CircularProgressIndicator()),
              // 에러 발생 시
              error: (err, stack) => Center(child: Text('에러 발생: $err')),
              // 데이터 로딩 성공 시
              data: (programs) {
                return programs.isEmpty
                    ? const Center(child: Text('저장된 프로그램이 없습니다.\n새로운 프로그램을 만들어보세요!'))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: programs.length,
                  itemBuilder: (context, index) {
                    final program = programs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        title: Text(program.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${program.exercises.length}개의 운동'),
                        trailing: Text(program.date),
                        onTap: () {
                          Navigator.pushNamed(context, '/program_detail', arguments: program);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  final newProgram = await Navigator.pushNamed(context, '/program_builder');
                  if (newProgram != null && newProgram is WorkoutProgram) {
                    // 3. ApiService를 통해 서버에 데이터 생성 요청
                    await ref.read(apiServiceProvider).createProgram(newProgram);
                    // 4. 데이터 생성이 성공하면, 목록을 새로고침하도록 provider를 무효화
                    ref.invalidate(programsProvider);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('나의 운동프로그램 만들기', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}