import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/stat_card.dart';
import '../widgets/primary_button.dart';

final isTrackingProvider = StateProvider<bool>((_) => false);
final distanceProvider = StateProvider<double>((_) => 0.0);
final elevationGainProvider = StateProvider<double>((_) => 0.0);
final speedKmhProvider = StateProvider<double>((_) => 0.0);
final kcalProvider = StateProvider<double>((_) => 0.0);

class ActivityMetsScreen extends ConsumerStatefulWidget {
  const ActivityMetsScreen({super.key});
  @override
  ConsumerState<ActivityMetsScreen> createState() => _ActivityMetsScreenState();
}

class _ActivityMetsScreenState extends ConsumerState<ActivityMetsScreen> {
  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(isTrackingProvider);
    final dist = ref.watch(distanceProvider);
    final elev = ref.watch(elevationGainProvider);
    final speed = ref.watch(speedKmhProvider);
    final kcal = ref.watch(kcalProvider);

    return WillPopScope(
      onWillPop: () async {
        if (tracking) {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('트래킹 종료'),
              content: const Text('트래킹이 진행 중입니다. 나가면 종료됩니다. 계속할까요?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('종료')),
              ],
            ),
          ) ??
              false;
          return ok;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('활동대사량(METs) 추정'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(children: [
                Expanded(child: StatCard(title: '이동 거리', value: '${dist.toStringAsFixed(2)} km')),
                const SizedBox(width: 12),
                Expanded(child: StatCard(title: '누적 상승고도', value: '${elev.toStringAsFixed(0)} m')),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: StatCard(title: '평균 속도', value: '${speed.toStringAsFixed(1)} km/h')),
                const SizedBox(width: 12),
                Expanded(child: StatCard(title: '소모 칼로리', value: '${kcal.toStringAsFixed(0)} kcal')),
              ]),
              const SizedBox(height: 16),
              PrimaryButton(
                label: tracking ? '트래킹 종료(더미)' : '트래킹 시작(더미)',
                onPressed: () {
                  ref.read(isTrackingProvider.notifier).state = !tracking;
                  if (ref.read(isTrackingProvider)) {
                    _simulateProgress();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _simulateProgress() async {
    for (int i = 0; i < 10 && mounted; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      ref.read(distanceProvider.notifier).state += 0.05;
      ref.read(elevationGainProvider.notifier).state += 2;
      ref.read(speedKmhProvider.notifier).state = 5.0 + (i % 3);
      final speed = ref.read(speedKmhProvider);
      final mets = 1.0 + 0.2 * speed + 0.5;
      final weightKg = 70.0;
      final hours = 0.5 / 60.0;
      ref.read(kcalProvider.notifier).state += mets * 1.05 * weightKg * hours;
    }
  }
}
