import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/program_provider.dart';

class ProgramDetailScreen extends ConsumerStatefulWidget {
  const ProgramDetailScreen({super.key});

  @override
  ConsumerState<ProgramDetailScreen> createState() =>
      _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends ConsumerState<ProgramDetailScreen> {
  Map<String, dynamic>? programData;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final programId = ModalRoute.of(context)!.settings.arguments as int;
    _loadProgram(programId);
  }

  Future<void> _loadProgram(int programId) async {
    final api = ref.read(apiServiceProvider);

    final data = await api.getProgramDetail(programId);

    if (mounted) {
      setState(() {
        programData = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (programData == null) {
      return const Scaffold(
        body: Center(child: Text("프로그램 정보를 불러올 수 없습니다.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(programData!["title"]),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: programData!["items"].length,
              itemBuilder: (context, index) {
                final item = programData!["items"][index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: _buildExerciseThumbnail(item["exerciseId"]),
                    title: Text(
                      item["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${item["sets"]}세트 · ${item["reps"]}회 · ${item["weight"]}kg",
                    ),
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
                  final first = programData!["items"][0];

                  Navigator.pushNamed(
                    context,
                    '/workout_reps',
                    arguments: first,
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('이 프로그램 시작하기',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseThumbnail(int exerciseId) {
    final thumbnailPath = "assets/images/exercise/$exerciseId.png";

    return Image.asset(
      thumbnailPath,
      width: 40,
      height: 40,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.fitness_center, size: 40);
      },
    );
  }
}
