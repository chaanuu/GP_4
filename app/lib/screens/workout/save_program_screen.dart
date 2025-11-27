import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/program_provider.dart';
import '../../providers/nav_provider.dart';

class SaveProgramScreen extends ConsumerStatefulWidget {
  const SaveProgramScreen({super.key});

  @override
  ConsumerState<SaveProgramScreen> createState() =>
      _SaveProgramScreenState();
}

class _SaveProgramScreenState extends ConsumerState<SaveProgramScreen> {
  final TextEditingController _titleCtrl = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _items = (ModalRoute.of(context)!.settings.arguments
    as List<Map<String, dynamic>>);
  }

  Future<void> _saveProgram() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("프로그램 이름을 입력해주세요.")),
      );
      return;
    }

    setState(() => _saving = true);

    final api = ref.read(apiServiceProvider);

    final programData = {
      "title": _titleCtrl.text.trim(),
      "items": _items,
      // userId는 ApiService에서 자동으로 붙도록 설계함
    };

    final programId = await api.createProgram(programData);

    setState(() => _saving = false);

    if (!mounted) return;

    if (programId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("프로그램이 저장되었습니다!")),
      );

      // 운동 탭(3)으로 이동
      ref.read(navIndexProvider.notifier).state = 3;

      // 메인 화면으로 돌아가기
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("저장에 실패했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("프로그램 저장"),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: "프로그램 이름",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            _saving
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _saveProgram,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 30),
              ),
              child: const Text(
                "저장하기",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
