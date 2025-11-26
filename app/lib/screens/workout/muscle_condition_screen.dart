import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/program_provider.dart';

class MuscleConditionScreen extends ConsumerStatefulWidget {
  const MuscleConditionScreen({super.key});

  @override
  ConsumerState<MuscleConditionScreen> createState() =>
      _MuscleConditionScreenState();
}

class _MuscleConditionScreenState
    extends ConsumerState<MuscleConditionScreen> {
  bool _loading = true;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadMuscleData();
  }

  Future<void> _loadMuscleData() async {
    final api = ref.read(apiServiceProvider);
    final result = await api.getWeeklyMuscleTiredness();

    if (!mounted) return;

    setState(() {
      _summary = result;
      _loading = false;
    });
  }

  // 근육 상태 텍스트
  String _getStatusText(int score) {
    if (score >= 80) return '과부하 상태입니다. 충분한 휴식이 필요해요.';
    if (score >= 50) return '적당한 운동량입니다. 가벼운 스트레칭을 병행하세요.';
    if (score > 0) return '운동량이 조금 부족해요. 가볍게 단련해보세요.';
    return '최근 일주일 동안 기록이 없습니다.';
  }

  // 팝업 표시
  void _showMusclePopup(String label) {
    final muscles = _summary?['muscles'] ?? [];

    final muscle = muscles.firstWhere(
          (m) => m['label'] == label,
      orElse: () => null,
    );

    if (muscle == null) return;

    final int score = (muscle['tiredness'] ?? 0) is int
        ? muscle['tiredness']
        : (muscle['tiredness'] as num).toInt();

    final status = _getStatusText(score);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          '피로도: $score점\n$status',
          style: const TextStyle(fontSize: 15, height: 1.6),
        ),
        actions: [
          TextButton(
            child: const Text("확인"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // 투명 터치 영역
  Widget _hotZone({
    required double left,
    required double top,
    required double width,
    required double height,
    required String label,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => _showMusclePopup(label),
        child: Container(
          width: width,
          height: height,
          color: Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '부위별 상태',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
          ? const Center(child: Text("최근 일주일 운동 기록이 없습니다."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/muscles.png',
                    width: 260,
                    fit: BoxFit.contain,
                  ),

                  // 가슴
                  _hotZone(
                    left: 95,
                    top: 65,
                    width: 70,
                    height: 60,
                    label: '가슴',
                  ),

                  // 등
                  _hotZone(
                    left: 95,
                    top: 140,
                    width: 70,
                    height: 70,
                    label: '등',
                  ),

                  // 어깨
                  _hotZone(
                    left: 80,
                    top: 40,
                    width: 100,
                    height: 30,
                    label: '어깨',
                  ),

                  // 팔 (좌)
                  _hotZone(
                    left: 45,
                    top: 70,
                    width: 40,
                    height: 120,
                    label: '팔',
                  ),

                  // 팔 (우)
                  _hotZone(
                    left: 165,
                    top: 70,
                    width: 40,
                    height: 120,
                    label: '팔',
                  ),

                  // 하체
                  _hotZone(
                    left: 100,
                    top: 220,
                    width: 60,
                    height: 120,
                    label: '하체',
                  ),

                  // 코어
                  _hotZone(
                    left: 100,
                    top: 120,
                    width: 60,
                    height: 60,
                    label: '코어',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '근육별 피로도',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            _buildMuscleList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleList() {
    final List<dynamic> muscles = _summary?['muscles'] ?? [];

    return Column(
      children: muscles.map((m) {
        final String label = m['label'];
        final int score = (m['tiredness'] ?? 0) is int
            ? m['tiredness']
            : (m['tiredness'] as num).toInt();

        final String status = _getStatusText(score);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 + 수치
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('$score점',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 6),

              LinearProgressIndicator(
                value: (score / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                minHeight: 8,
              ),
              const SizedBox(height: 6),

              Text(status, style: const TextStyle(fontSize: 14, height: 1.4)),
            ],
          ),
        );
      }).toList(),
    );
  }
}


