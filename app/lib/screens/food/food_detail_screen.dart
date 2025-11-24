import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // ⭐ 추가: XFile 사용을 위해 필요
import 'food_analysis_screen.dart';

// StatefulWidget으로 변경
class FoodDetailScreen extends StatefulWidget {
  final String logEntry;
  const FoodDetailScreen({super.key, required this.logEntry});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  // 상태 변수 정의
  String _currentFoodName = '';
  String _currentMealType = '';
  int _originalIndex = -1;
  List<String> _savedLogs = [];
  Map<String, String> _nutritionData = {};
  final List<String> _mealTypes = ['아침', '점심', '저녁', '간식'];
  bool _isLoading = true;

  final TextEditingController _foodNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAndParseLog();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    super.dispose();
  }

  // 로그 문자열을 파싱하여 화면에 표시할 Map 형태로 변환 (식사 유형 포함)
  Map<String, String> _parseLogEntry(String log) {
    final parts = log.split('|');

    if (parts.length < 9) {
      return {
        'imagePath': parts.length > 0 ? parts[0] : '',
        '음식': '로그 파싱 오류: 데이터 부족',
        '섭취량': 'N/A',
        '섭취 칼로리': 'N/A',
        '탄수화물': 'N/A',
        '단백질': 'N/A',
        '지방': 'N/A',
        'mealType': '기타',
        '기록 시간': 'N/A',
      };
    }

    return {
      'imagePath': parts[0],
      '음식': parts[1],
      '섭취량': parts[2],
      '섭취 칼로리': parts[3],
      '탄수화물': parts[4],
      '단백질': parts[5],
      '지방': parts[6],
      'mealType': parts[7],
      '기록 시간': parts[8],
    };
  }

  // 로그 로드 및 파싱 함수
  Future<void> _loadAndParseLog() async {
    final prefs = await SharedPreferences.getInstance();
    _savedLogs = prefs.getStringList('food_logs') ?? [];

    final logEntry = widget.logEntry;

    final index = _savedLogs.indexOf(logEntry);

    if (index != -1) {
      _originalIndex = index;
      final parsedData = _parseLogEntry(logEntry);

      setState(() {
        _nutritionData = parsedData;
        _currentFoodName = parsedData['음식'] ?? '';
        _currentMealType = parsedData['mealType'] ?? _mealTypes.first;
        _foodNameController.text = _currentFoodName;
        _isLoading = false;
      });
    } else {
      setState(() {
        _nutritionData = _parseLogEntry(logEntry);
        _isLoading = false;
      });
    }
  }

  // ⭐ 재분석 로직 (클래스 멤버 함수로 분리)
  Future<void> _reanalyzeFood() async {
    final imagePath = _nutritionData['imagePath'];
    final foodName = _foodNameController.text.trim();

    if (imagePath == null || imagePath.isEmpty || foodName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 또는 음식 이름 정보가 필요합니다.')),
        );
      }
      return;
    }

    // 이미지 파일 존재 여부 재확인
    if (!File(imagePath).existsSync()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('원본 이미지 파일을 찾을 수 없습니다.')),
        );
      }
      return;
    }


    // FoodAnalysisScreen으로 이동하여 재분석 시작
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          // FoodAnalysisScreen으로 XFile과 초기 음식 이름 전달
          builder: (context) => FoodAnalysisScreen(
            image: XFile(imagePath),
            initialFoodName: foodName,
          ),
        ),
      );

      // 재분석 후 돌아왔을 때, 현재 Detail 화면은 닫고 Diary 화면으로 돌아감
      if (mounted) {
        Navigator.pop(context, true);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('재분석을 시작할 수 없습니다: ${e.toString()}')),
        );
      }
    }
  }


  // 수정 완료 및 SharedPreferences 업데이트 함수 (순수 수정만 담당)
  Future<void> _updateFoodLog() async {
    // 1. 유효성 검사
    final updatedFoodName = _foodNameController.text.trim();
    if (_originalIndex == -1 || updatedFoodName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정할 수 없습니다. (데이터 오류 또는 이름 누락)')),
        );
      }
      return;
    }

    // 2. 현재 상태 업데이트
    _currentFoodName = updatedFoodName;

    // 3. 기존 로그 문자열 분리
    final originalLog = _savedLogs[_originalIndex];
    final parts = originalLog.split('|');

    // 4. 새로운 값으로 업데이트 (이름: parts[1], 식사 유형: parts[7])
    parts[1] = _currentFoodName;
    parts[7] = _currentMealType;

    // 5. 새로운 로그 문자열 생성
    final newLog = parts.join('|');

    // 6. SharedPreferences에 업데이트
    _savedLogs[_originalIndex] = newLog;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('food_logs', _savedLogs);

    // 7. 이전 화면으로 돌아가기 (수정 사항 반영을 위해 true 리턴)
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget _buildNutritionInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('기록 상세', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 1),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final imagePath = _nutritionData['imagePath']!;
    final displayTitle = _currentFoodName.isEmpty ? '알 수 없는 음식' : _currentFoodName;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.of(context).pop(false)),
        title: Text(displayTitle, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 표시
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: imagePath.isNotEmpty && File(imagePath).existsSync()
                  ? Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300,
              )
                  : Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Text('이미지 파일을 찾을 수 없습니다.'),
              ),
            ),
            const SizedBox(height: 24),

            // 수정 가능한 음식 이름 필드
            const Text('음식 이름', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
            const SizedBox(height: 24),

            // 수정 가능한 식사 유형 드롭다운
            const Text('식사 시간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _currentMealType,
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _currentMealType = newValue;
                      });
                    }
                  },
                  items: _mealTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 기록 시간 및 영양 정보 표시 (수정 불가)
            _buildNutritionInfo('기록 시간', _nutritionData['기록 시간']!),
            const Divider(height: 40),

            _buildNutritionInfo('섭취량', _nutritionData['섭취량']!),
            _buildNutritionInfo('섭취 칼로리', _nutritionData['섭취 칼로리']!),
            const Divider(height: 40),
            _buildNutritionInfo('탄수화물', _nutritionData['탄수화물']!),
            _buildNutritionInfo('단백질', _nutritionData['단백질']!),
            _buildNutritionInfo('지방', _nutritionData['지방']!),

            const SizedBox(height: 32),

            // 수정 완료 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateFoodLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('수정 완료', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),

            const SizedBox(height: 16),

            // 재분석 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _reanalyzeFood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('수정된 이름으로 영양 정보 재분석', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}