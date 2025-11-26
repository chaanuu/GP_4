import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/program_provider.dart';

class WorkoutRepsScreen extends ConsumerStatefulWidget {
  const WorkoutRepsScreen({super.key});

  @override
  ConsumerState<WorkoutRepsScreen> createState() =>
      _WorkoutRepsScreenState();
}

class _WorkoutRepsScreenState extends ConsumerState<WorkoutRepsScreen> {
  late Map<String, dynamic> exercise;

  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  DateTime? _startTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    exercise = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  void _startTimer() {
    if (_isRunning) return;

    _startTime = DateTime.now();
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _isRunning = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _finishWorkout() async {
    _stopTimer();

    final now = DateTime.now();

    final logData = {
      "exerciseId": exercise["id"],
      "sets": exercise["sets"] ?? 1,
      "reps": exercise["reps"] ?? 10,
      "durationMinutes": (_seconds / 60).ceil(),
      "dateExecuted": now.toIso8601String().split('T').first,
      "timeExecuted": now.toIso8601String(),
    };

    final api = ref.read(apiServiceProvider);
    final success = await api.saveExerciseLog(logData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("운동 기록이 저장되었습니다!")),
      );
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("운동 저장 실패하였습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = exercise["name"] ?? "운동";

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      /// -------------------------------
      /// 🔥 내용 전체를 정가운데 배치
      /// -------------------------------
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            mainAxisSize: MainAxisSize.min,     // 화면 전체 차지 ❌ → 진짜 가운데 정렬됨
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              /// 🔥 운동 이미지 (픽토그램)
              SizedBox(
                height: 120,
                child: Image.asset(
                  'assets/images/squat.png', // 원하는 PNG로 교체 가능
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 운동 이름
              Text(
                name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// 🔥 세트 & 횟수
              Text(
                "세트: ${exercise["sets"] ?? '-'}   |   횟수: ${exercise["reps"] ?? '-'}",
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),

              const SizedBox(height: 35),

              /// 🔥 타이머
              Text(
                _formatTime(_seconds),
                style: const TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              /// 🔥 운동 시작 버튼
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("운동 시작", style: TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(height: 16),

              /// 🔥 운동 완료 버튼
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _finishWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("운동 완료", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }
}




