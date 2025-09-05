import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/stat_card.dart';
import '../widgets/primary_button.dart';

class WorkoutAssistScreen extends ConsumerStatefulWidget {
  const WorkoutAssistScreen({super.key});
  @override
  ConsumerState<WorkoutAssistScreen> createState() => _WorkoutAssistScreenState();
}

final intensityProvider = StateProvider<String>((_) => '보통');
final setCountProvider = StateProvider<int>((_) => 3);
final repsProvider = StateProvider<int>((_) => 10);
final detectedWeightProvider = StateProvider<double>((_) => 20.0);
final currentSetProvider = StateProvider<int>((_) => 1);
final currentRepProvider = StateProvider<int>((_) => 0);
final isRunningProvider = StateProvider<bool>((_) => false);

class _WorkoutAssistScreenState extends ConsumerState<WorkoutAssistScreen> {
  @override
  Widget build(BuildContext context) {
    final intensity = ref.watch(intensityProvider);
    final sets = ref.watch(setCountProvider);
    final reps = ref.watch(repsProvider);
    final weight = ref.watch(detectedWeightProvider);
    final curSet = ref.watch(currentSetProvider);
    final curRep = ref.watch(currentRepProvider);
    final running = ref.watch(isRunningProvider);

    final totalTarget = sets * reps;
    final currentProgress = ((curSet - 1) * reps + curRep).clamp(0, totalTarget);
    final progressValue = totalTarget == 0 ? 0.0 : currentProgress / totalTarget;

    return WillPopScope(
      onWillPop: () async {
        if (running) {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('종료할까요?'),
              content: const Text('진행 중인 세트가 있습니다. 나가시겠어요?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('나가기')),
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
          title: const Text('운동 보조'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: StatCard(title: '강도 모드', value: intensity)),
                  const SizedBox(width: 12),
                  Expanded(child: StatCard(title: '자동 인식 무게(kg)', value: weight.toStringAsFixed(1))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: StatCard(title: '세트 수', value: '$sets')),
                  const SizedBox(width: 12),
                  Expanded(child: StatCard(title: '횟수/세트', value: '$reps')),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('진행 상태', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progressValue),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('현재: ${curSet}세트 ${curRep}회'),
                          Text('총 목표: ${sets}세트 × ${reps}회'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              label: running ? '일시정지' : '시작',
                              onPressed: () => ref.read(isRunningProvider.notifier).state = !running,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryButton(
                              label: '1회 추가',
                              onPressed: running
                                  ? () {
                                final nextRep = curRep + 1;
                                if (nextRep > reps) {
                                  if (curSet < sets) {
                                    ref.read(currentSetProvider.notifier).state = curSet + 1;
                                    ref.read(currentRepProvider.notifier).state = 0;
                                  } else {
                                    ref.read(isRunningProvider.notifier).state = false;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('모든 세트 완료! 수고하셨습니다.')),
                                    );
                                  }
                                } else {
                                  ref.read(currentRepProvider.notifier).state = nextRep;
                                }
                              }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerLeft, child: Text('설정', style: Theme.of(context).textTheme.titleMedium)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: intensity,
                      decoration: const InputDecoration(labelText: '강도 모드'),
                      items: const [
                        DropdownMenuItem(value: '가볍게', child: Text('가볍게')),
                        DropdownMenuItem(value: '보통', child: Text('보통')),
                        DropdownMenuItem(value: '강하게', child: Text('강하게')),
                      ],
                      onChanged: (v) => ref.read(intensityProvider.notifier).state = v ?? '보통',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: '$sets',
                      decoration: const InputDecoration(labelText: '세트 수'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => ref.read(setCountProvider.notifier).state = int.tryParse(v) ?? sets,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: '$reps',
                      decoration: const InputDecoration(labelText: '횟수/세트'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => ref.read(repsProvider.notifier).state = int.tryParse(v) ?? reps,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: weight.toStringAsFixed(1),
                      decoration: const InputDecoration(labelText: '자동 인식 무게(kg) (더미)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => ref.read(detectedWeightProvider.notifier).state = double.tryParse(v) ?? weight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('※ 실제 구현: 카메라 → YOLO 가중치로 플레이트/원판 인식 → 무게 합산'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



