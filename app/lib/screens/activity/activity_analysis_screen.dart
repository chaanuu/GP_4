import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../providers/nav_provider.dart';

class ActivityAnalysisScreen extends ConsumerStatefulWidget {
  const ActivityAnalysisScreen({super.key});

  @override
  ConsumerState<ActivityAnalysisScreen> createState() => _ActivityAnalysisScreenState();
}

class _ActivityAnalysisScreenState extends ConsumerState<ActivityAnalysisScreen> {
  int _todaySteps = 0;
  double _calories = 0.0;
  double _altitude = 0.0; // 현재 고도
  String _locationMessage = "위치 정보 수신 중...";

  // 로컬 저장소에서 불러올 사용자 몸무게 (기본값 70kg)
  double _userWeight = 70.0;

  // 주간 데이터 (더미 데이터, 추후 DB 연동 시 수정)
  final List<Map<String, dynamic>> _weeklyData = [
    {'day': '월', 'steps': 0, 'calories': 0},
    {'day': '화', 'steps': 0, 'calories': 0},
    {'day': '수', 'steps': 0, 'calories': 0},
    {'day': '목', 'steps': 0, 'calories': 0},
    {'day': '금', 'steps': 0, 'calories': 0},
    {'day': '토', 'steps': 0, 'calories': 0},
    {'day': '일', 'steps': 0, 'calories': 0},
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startLocationTracking(); // 위치 및 고도 추적 시작
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ 1. 저장된 몸무게 불러오기
    _userWeight = prefs.getDouble('user_weight') ?? 70.0;

    int totalSensorSteps = prefs.getInt('total_steps') ?? 0;
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String lastSavedDate = prefs.getString('last_saved_date') ?? todayDate;

    // 날짜가 바뀌었으면 어제 기록 저장 및 기준점 리셋
    if (todayDate != lastSavedDate) {
      await _saveYesterdayRecord(prefs, lastSavedDate, totalSensorSteps);
      await prefs.setInt('steps_anchor', totalSensorSteps);
      await prefs.setString('last_saved_date', todayDate);
    }

    int anchorSteps = prefs.getInt('steps_anchor') ?? 0;

    // 재부팅 등으로 센서값이 초기화된 경우 처리
    if (totalSensorSteps < anchorSteps) {
      anchorSteps = 0;
      await prefs.setInt('steps_anchor', 0);
    }

    setState(() {
      _todaySteps = totalSensorSteps - anchorSteps;
      _calculateCalories();
    });
  }

  Future<void> _saveYesterdayRecord(SharedPreferences prefs, String date, int totalSensorSteps) async {
    int anchorSteps = prefs.getInt('steps_anchor') ?? 0;
    int pastDailySteps = totalSensorSteps - anchorSteps;

    List<String> history = prefs.getStringList('activity_history') ?? [];
    Map<String, dynamic> newRecord = {'date': date, 'steps': pastDailySteps};

    history.add(jsonEncode(newRecord));
    await prefs.setStringList('activity_history', history);
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _locationMessage = "위치 서비스가 꺼져 있습니다.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // 실시간 위치(고도) 추적
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _altitude = position.altitude; // 고도 업데이트
          _calculateCalories(); // 고도 변화 반영하여 칼로리 재계산
        });
      }
    });
  }

  // ✅ 실제 몸무게와 고도를 반영한 정밀 칼로리 계산
  void _calculateCalories() async {
    // 1. 기본 걷기 칼로리 (METs 약식: 0.0005 * 몸무게 * 걸음수)
    double baseCalories = _todaySteps * 0.0005 * _userWeight;

    // 2. 고도 보정 (오르막길 가중치: 고도 1m당 추가 소모량, 몸무게 비례)
    double altitudeBonus = 0;
    if (_altitude > 0) {
      altitudeBonus = _altitude * 0.05 * (_userWeight / 70.0);
    }

    final totalCalories = baseCalories + altitudeBonus;

    setState(() {
      _calories = totalCalories;
    });

    // ✅ 계산된 활동 칼로리를 저장 (메인 화면에서 불러다 씀)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('today_activity_calories', totalCalories.toInt());
  }

  @override
  Widget build(BuildContext context) {
    String activityMessage;
    if (_todaySteps < 5000) {
      activityMessage = '조금만 더 힘내세요!\n가벼운 산책 어떠신가요?';
    } else {
      activityMessage = '활동량이 늘었습니다!\n정말 잘 하고 있어요!';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // 홈 화면으로 이동
            ref.read(navIndexProvider.notifier).state = -1;
          },
        ),
        title: const Text('활동량 분석', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.directions_run, size: 80, color: Colors.black),
            const SizedBox(height: 16),
            Text(
              activityMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: _buildStatCard('걸음 수', '$_todaySteps걸음')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('소비한 칼로리', '${_calories.toInt()}kcal')),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              '주간 활동량 분석',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < _weeklyData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _weeklyData[index]['day'],
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 10000,

                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueAccent,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          int index = barSpot.x.toInt();
                          int steps = _weeklyData[index]['steps'];
                          int calories = _weeklyData[index]['calories'];
                          return LineTooltipItem(
                            '$steps걸음\n$calories kcal',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      spots: _weeklyData.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), (e.value['steps'] as int).toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
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
        ],
      ),
    );
  }
}