import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/nav_provider.dart';

class ActivityAnalysisScreen extends ConsumerStatefulWidget {
  const ActivityAnalysisScreen({super.key});

  @override
  ConsumerState<ActivityAnalysisScreen> createState() => _ActivityAnalysisScreenState();
}

class _ActivityAnalysisScreenState extends ConsumerState<ActivityAnalysisScreen> {
  // 오늘 걸음 수 & 칼로리
  int _todaySteps = 0;
  double _calories = 0.0;

  // 고도 / 위치 관련
  double _altitude = 0.0;
  double _elevationGain = 0.0; // 오늘 누적 상승 고도(m)
  double _distance = 0.0; // 오늘 이동 거리(m)
  String _locationMessage = '위치 정보 수신 중...';

  // 사용자 몸무게 (kcal 계산용) – 없으면 70kg 가정
  double _userWeight = 70.0;

  // 주간 데이터 (월~일)
  final List<Map<String, dynamic>> _weeklyData = [
    {'day': '월', 'steps': 0, 'calories': 0.0},
    {'day': '화', 'steps': 0, 'calories': 0.0},
    {'day': '수', 'steps': 0, 'calories': 0.0},
    {'day': '목', 'steps': 0, 'calories': 0.0},
    {'day': '금', 'steps': 0, 'calories': 0.0},
    {'day': '토', 'steps': 0, 'calories': 0.0},
    {'day': '일', 'steps': 0, 'calories': 0.0},
  ];

  // 센서 / 스트림 관련
  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<Position>? _positionSub;
  Position? _lastPosition;

  // 하루 기준 anchor
  DateTime _anchorDate = DateTime.now();

  static const _prefStepsAnchor = 'steps_anchor';
  static const _prefStepsDate = 'steps_date';
  static const _prefHistory = 'activity_history'; // List<String(json)]

  bool _isTrackingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadUserWeight();
    _loadWeeklyHistory();
    _initPedometer();
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUserWeight() async {
    final prefs = await SharedPreferences.getInstance();
    // PersonalInfo 에서 저장한 값이 있으면 사용
    _userWeight = prefs.getDouble('user_weight') ?? 70.0;
    if (mounted) setState(() {});
  }

  /// SharedPreferences 에 저장된 최근 일주일 기록을 읽어서 _weeklyData 에 반영
  Future<void> _loadWeeklyHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_prefHistory) ?? [];

    // 초기화
    for (final item in _weeklyData) {
      item['steps'] = 0;
      item['calories'] = 0.0;
    }

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));

    for (final encoded in history) {
      try {
        final Map<String, dynamic> rec = jsonDecode(encoded);
        final DateTime date = DateTime.parse(rec['date'] as String);
        if (date.isBefore(weekAgo) || date.isAfter(now)) continue;

        final int steps = rec['steps'] as int? ?? 0;
        final double kcal = _estimateCalories(steps);

        // 요일 index (월=1 ... 일=7) → 0~6
        final weekdayIndex = (date.weekday + 6) % 7;
        _weeklyData[weekdayIndex]['steps'] += steps;
        _weeklyData[weekdayIndex]['calories'] += kcal;
      } catch (_) {
        // 깨진 데이터는 무시
      }
    }

    if (mounted) setState(() {});
  }

  /// pedometer 스트림 초기화
  void _initPedometer() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    _anchorDate = DateTime(now.year, now.month, now.day);

    // 날짜 저장이 안 돼 있으면 오늘 날짜와 현재 센서값을 anchor로 저장
    prefs.getString(_prefStepsDate);

    _stepSub = Pedometer.stepCountStream.listen(
          (event) => _onStepCount(event),
      onError: (error) => debugPrint('StepCount error: $error'),
      cancelOnError: false,
    );
  }

  Future<void> _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final int sensorSteps = event.steps;
    final now = DateTime.now();
    final String todayStr = DateFormat('yyyy-MM-dd').format(now);

    String? savedDate = prefs.getString(_prefStepsDate);
    int anchor = prefs.getInt(_prefStepsAnchor) ?? sensorSteps;

    // 첫 실행이거나 저장된 날짜가 없으면
    if (savedDate == null) {
      savedDate = todayStr;
      anchor = sensorSteps;
      await prefs.setString(_prefStepsDate, todayStr);
      await prefs.setInt(_prefStepsAnchor, anchor);
    }

    // 날짜가 바뀐 경우 → 어제 기록 저장 후 anchor 초기화
    if (savedDate != todayStr) {
      final int yesterdaySteps = sensorSteps - anchor;
      if (yesterdaySteps >= 0) {
        await _saveDailyRecord(savedDate, yesterdaySteps);
      }
      // 오늘 기준 anchor 재설정
      anchor = sensorSteps;
      await prefs.setString(_prefStepsDate, todayStr);
      await prefs.setInt(_prefStepsAnchor, anchor);
      savedDate = todayStr;
    }

    // 센서 값이 anchor보다 작으면(재부팅 등) anchor 재설정
    if (sensorSteps < anchor) {
      anchor = sensorSteps;
      await prefs.setInt(_prefStepsAnchor, anchor);
    }

    final int todaySteps = sensorSteps - anchor;

    if (mounted) {
      setState(() {
        _todaySteps = todaySteps < 0 ? 0 : todaySteps;
        _calories = _estimateCalories(_todaySteps);
      });
    }
  }

  /// 하루 기록을 history 에 추가
  Future<void> _saveDailyRecord(String dateStr, int steps) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_prefHistory) ?? [];
    history.add(jsonEncode({'date': dateStr, 'steps': steps}));
    await prefs.setStringList(_prefHistory, history);
    await _loadWeeklyHistory();
  }

  double _estimateCalories(int steps) {
    // 대략적인 추정치: 1걸음당 0.04kcal (70kg 기준)
    final base = steps * 0.04;
    return base * (_userWeight / 70.0);
  }

  // 위치 추적 시작
  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() => _locationMessage = '위치 서비스가 꺼져 있습니다.');
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() => _locationMessage = '위치 권한이 영구적으로 거부되었습니다.');
      }
      return;
    }

    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // 5m 이상 이동 시 이벤트 발생
      ),
    ).listen((position) {
      _onPositionUpdate(position);
    });

    if (mounted) {
      setState(() {
        _isTrackingLocation = true;
        _locationMessage = '위치 추적 중...';
      });
    }
  }

  void _onPositionUpdate(Position position) {
    if (_lastPosition != null) {
      final double delta = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // 너무 큰 값(잘못된 GPS)을 필터링
      if (delta < 1000) {
        _distance += delta;
      }

      final double altDiff = position.altitude - _lastPosition!.altitude;
      if (altDiff > 0) {
        _elevationGain += altDiff;
      }
    }

    _lastPosition = position;
    _altitude = position.altitude;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _stopLocationTracking() async {
    await _positionSub?.cancel();
    _positionSub = null;
    if (mounted) {
      setState(() {
        _isTrackingLocation = false;
        _locationMessage = '위치 추적 중지됨';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final String todayLabel = DateFormat('M월 d일 (E)', 'ko_KR').format(today);

    String activityMessage;
    if (_todaySteps > 10000) {
      activityMessage = '대단해요! 오늘 목표를 훌쩍 넘었어요 💪';
    } else if (_todaySteps > 7000) {
      activityMessage = '꽤 많이 걸었어요! 조금만 더 걸어볼까요?';
    } else if (_todaySteps > 3000) {
      activityMessage = '나쁘지 않아요. 산책 한 번 더 어떤가요?';
    } else {
      activityMessage = '오늘은 조금 움직임이 적어요. 가벼운 산책 어떠세요?';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '활동 분석',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            ref.read(navIndexProvider.notifier).state = -1;
          },
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                todayLabel,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                activityMessage,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: _buildStatCard('걸음 수', '$_todaySteps 보')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('소비 칼로리', '${_calories.toInt()} kcal')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('이동 거리', '${(_distance / 1000).toStringAsFixed(2)} km')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('상승 고도', '${_elevationGain.toStringAsFixed(0)} m')),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                _locationMessage,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '현재 고도: ${_altitude.toStringAsFixed(1)} m',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isTrackingLocation ? null : _startLocationTracking,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('위치 추적 시작'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isTrackingLocation ? _stopLocationTracking : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('위치 추적 중지'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

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
                          reservedSize: 28,
                          interval: 1,   // ⭐ 요일을 0,1,2,3,4,5,6 하나씩만 찍게 함
                          getTitlesWidget: (value, meta) {
                            const List<String> weekDays = [
                              '월', '화', '수', '목', '금', '토', '일'
                            ];

                            int index = value.toInt();
                            if (index < 0 || index >= weekDays.length) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                weekDays[index],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _weeklyData.asMap().entries.map((e) {
                          final x = e.key.toDouble();
                          final y = (e.value['steps'] as int).toDouble();
                          return FlSpot(x, y);
                        }).toList(),
                        isCurved: true,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blue.withOpacity(0.3),
                              Colors.blue.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
