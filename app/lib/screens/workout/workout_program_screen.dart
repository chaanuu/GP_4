import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/program_provider.dart';
import '../../providers/nav_provider.dart';

class WorkoutProgramScreen extends ConsumerWidget {
  const WorkoutProgramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsyncValue = ref.watch(programsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('나의 운동 프로그램'),
      ),
      body: Column(
        children: [
          Expanded(
            child: programsAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('에러 발생: $err')),
              data: (programs) {
                if (programs.isEmpty) {
                  return const Center(
                    child: Text("저장된 프로그램이 없습니다.\n새로운 프로그램을 만들어보세요!"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: programs.length,
                  itemBuilder: (context, index) {
                    final program = programs[index] as Map<String, dynamic>;

                    final title = program['title'] ?? '이름 없는 프로그램';
                    final createdAt = program['createdAt']?.toString() ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(createdAt),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/program_detail',
                            arguments: program['id'],
                          );
                        },
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editProgram(context, program);
                            } else if (value == 'delete') {
                              _deleteProgram(context, ref, program['id']);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('수정'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('삭제'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 하단 프로그램 추가 버튼
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/program_builder');
                  ref.invalidate(programsProvider); // 새로고침
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text("나의 운동프로그램 만들기"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔧 프로그램 수정
  void _editProgram(BuildContext context, Map<String, dynamic> program) {
    Navigator.pushNamed(
      context,
      '/program_builder',
      arguments: {
        "mode": "edit",
        "program": program,
      },
    );
  }

  // ❌ 프로그램 삭제
  Future<void> _deleteProgram(BuildContext context, WidgetRef ref, int programId) async {
    final api = ref.read(apiServiceProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("프로그램 삭제"),
        content: const Text("정말 삭제하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("삭제", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await api.deleteProgram(programId);

    if (success) {
      ref.invalidate(programsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("프로그램이 삭제되었습니다.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("삭제에 실패했습니다.")),
      );
    }
  }
}
