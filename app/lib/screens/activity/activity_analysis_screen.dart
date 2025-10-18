import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // 차트 라이브러리
import 'package:shared_preferences/shared_preferences.dart';

class ActivityAnalysisScreen extends StatefulWidget {
  const ActivityAnalysisScreen({super.key});

  @override
  State<ActivityAnalysisScreen> createState() => _ActivityAnalysisScreenState();
}

class _ActivityAnalysisScreenState extends State<ActivityAnalysisScreen> {
  int _steps = 0;
  int _calories = 0;

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  // SharedPreferences에서 저장된 걸음 수 데이터를 불러오는 함수
  Future<void> _loadActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 'total_steps' 키로 저장된 값을 불러옵니다. 값이 없으면 0을 기본값으로 사용합니다.
      _steps = prefs.getInt('total_steps') ?? 0;
      // TODO: 불러온 걸음 수와 사용자 정보(키, 몸무게)를 이용해 METS 칼로리 계산
      // 예시: _calories = calculateCalories(_steps, userWeight, userHeight);
      _calories = (_steps * 0.04).toInt(); // 임시 계산
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('활동량 분석', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.directions_run, size: 80),
            const SizedBox(height: 16),
            const Text(
              '활동량이 늘었습니다!\n잘 하고 있어요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildStatCard('걸음 수', '$_steps 걸음', '전일 대비 +17%')), // _steps 변수 사용
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('소비한 칼로리', '$_calories kcal', '전일 대비 +8%')), // _calories 변수 사용
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '주간 활동량 분석',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: LineChart(
                LineChartData(
                  // TODO: 실제 주간 데이터를 기반으로 차트 그리기
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(change, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}