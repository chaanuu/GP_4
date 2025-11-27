import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/program_provider.dart';

class SingleExerciseListScreen extends ConsumerStatefulWidget {
  const SingleExerciseListScreen({super.key});

  @override
  ConsumerState<SingleExerciseListScreen> createState() =>
      _SingleExerciseListScreenState();
}

class _SingleExerciseListScreenState
    extends ConsumerState<SingleExerciseListScreen> {

  bool _loading = true;
  List<Map<String, dynamic>> _exerciseList = [];

  late String mode; // ← normal / program 모드 구분

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    mode = args?["mode"] ?? "normal"; // 기본 normal
  }

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final api = ref.read(apiServiceProvider);
    final result = await api.getAllExercises();

    setState(() {
      _exerciseList = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mode == "program" ? "운동 선택" : "단일 운동"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _exerciseList.length,
        itemBuilder: (context, index) {
          final item = _exerciseList[index];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10),
            title: Text(
              item['name'] ?? '운동 이름 없음',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "주 근육: ${item['mainMuscle'] ?? '-'}",
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              if (mode == "program") {
                // 프로그램 구성 모드 → 운동 설정 화면으로 이동 후 결과를 받음
                final result = await Navigator.pushNamed(
                  context,
                  '/exercise_setup_program',
                  arguments: item,
                );

                // result에는 세트/횟수/무게 포함한 지도(Map)가 넘어옴
                Navigator.pop(context, result);
              } else {
                // 일반 단일 운동 흐름
                Navigator.pushNamed(
                  context,
                  '/exercise_setup',
                  arguments: item,
                );
              }
            },
          );
        },
      ),
    );
  }
}

