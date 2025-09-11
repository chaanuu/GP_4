import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DietInsightsScreen extends ConsumerWidget {
  const DietInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = {
      '칼로리(kcal)': 1850,
      '탄수화물(g)': 250,
      '단백질(g)': 90,
      '지방(g)': 55
    };
    final target = {
      '칼로리(kcal)': 2200,
      '탄수화물(g)': 300,
      '단백질(g)': 110,
      '지방(g)': 60
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('식습관 분석'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: target.keys.map((k) {
            final cur = today[k]!.toDouble();
            final tar = target[k]!.toDouble();
            final ratio = (cur / tar).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(k),
                      Text('${cur.toStringAsFixed(0)} / ${tar.toStringAsFixed(0)}'),
                    ],
                  ),
                  LinearProgressIndicator(value: ratio),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

