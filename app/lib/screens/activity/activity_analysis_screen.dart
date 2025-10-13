import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // 차트 라이브러리

class ActivityAnalysisScreen extends StatelessWidget {
  const ActivityAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 백그라운드 서비스에서 걸음 수, 칼로리 데이터 가져오기
    final int steps = 8795;
    final int calories = 1380;

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
                Expanded(child: _buildStatCard('걸음 수', '$steps걸음', '전일 대비 +17%')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('소비한 칼로리', '${calories}kcal', '전일 대비 +8%')),
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
              // TODO: 실제 주간 데이터를 기반으로 차트 그리기
              child: LineChart(
                LineChartData(
                  // 차트 디자인 및 데이터 설정
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