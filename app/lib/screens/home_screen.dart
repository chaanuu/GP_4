import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _HomeItem('운동 QR 코드 인식', Icons.qr_code_scanner, '/qr'),
      _HomeItem('운동 보조', Icons.fitness_center, '/assist'),
      _HomeItem('체형 변화 분석', Icons.accessibility_new, '/body'),
      _HomeItem('활동대사량(METs)', Icons.directions_walk, '/mets'),
      _HomeItem('음식 사진 분석', Icons.restaurant, '/food'),
      _HomeItem('식습관 분석', Icons.insights, '/diet'),
      _HomeItem('인바디 연동', Icons.biotech, '/inbody'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FitAssist — Graduation Project')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.05,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final it = items[i];
          return InkWell(
            onTap: () => context.push(it.route), // ← push 사용
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(it.icon, size: 48),
                    const SizedBox(height: 12),
                    Text(it.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeItem {
  final String title;
  final IconData icon;
  final String route;
  _HomeItem(this.title, this.icon, this.route);
}

