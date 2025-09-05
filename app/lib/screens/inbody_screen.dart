import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/primary_button.dart';

class InbodyScreen extends StatelessWidget {
  const InbodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wtController = TextEditingController();
    final smmController = TextEditingController();
    final bfpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('인바디 연동/입력'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(controller: wtController, decoration: const InputDecoration(labelText: '체중(kg)')),
            const SizedBox(height: 8),
            TextFormField(controller: smmController, decoration: const InputDecoration(labelText: '골격근량(kg)')),
            const SizedBox(height: 8),
            TextFormField(controller: bfpController, decoration: const InputDecoration(labelText: '체지방률(%)')),
            const SizedBox(height: 16),
            PrimaryButton(
              label: '저장(더미)',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장 완료'))),
            ),
          ],
        ),
      ),
    );
  }
}

