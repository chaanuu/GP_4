import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
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
  Map<String, String> _nutritionData = {}; // UI 표시용 파싱된 데이터
  final List<String> _mealTypes = ['아침', '점심', '저녁', '간식'];
  bool _isLoading = true;

  // ⭐ 100g당 기준 영양소 값 (재계산을 위한 베이스)
  double _baseCaloriesPer100g = 0.0;
  double _baseCarbsPer100g = 0.0;
  double _baseProteinPer100g = 0.0;
  double _baseFatPer100g = 0.0;

  // 컨트롤러 정의
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(); // ⭐ 추가: 섭취량 컨트롤러

  @override
  void initState() {
    super.initState();
    _loadAndParseLog();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _amountController.dispose(); // ⭐ 추가: 컨트롤러 정리
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
      '섭취량': parts[2], // ex: 100g
      '섭취 칼로리': parts[3], // ex: 300kcal
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

      // ⭐ 현재 저장된 섭취량과 영양소 값 추출
      final amountString = parsedData['섭취량']!.replaceAll(RegExp(r'[a-zA-Z]'), '').trim(); // 숫자만 추출 (g 제거)
      final amount = double.tryParse(amountString) ?? 0.0;

      final currentCalories = double.tryParse(parsedData['섭취 칼로리']!.replaceAll(RegExp(r'[a-zA-Z]'), '').trim()) ?? 0.0;
      final currentCarbs = double.tryParse(parsedData['탄수화물']!.replaceAll(RegExp(r'[a-zA-Z]'), '').trim()) ?? 0.0;
      final currentProtein = double.tryParse(parsedData['단백질']!.replaceAll(RegExp(r'[a-zA-Z]'), '').trim()) ?? 0.0;
      final currentFat = double.tryParse(parsedData['지방']!.replaceAll(RegExp(r'[a-zA-Z]'), '').trim()) ?? 0.0;

      // ⭐ 100g당 기준 영양소 값 계산 (재계산의 기준이 됨)
      final ratio = amount > 0 ? 100 / amount : 0.0;

      _baseCaloriesPer100g = currentCalories * ratio;
      _baseCarbsPer100g = currentCarbs * ratio;
      _baseProteinPer100g = currentProtein * ratio;
      _baseFatPer100g = currentFat * ratio;

      setState(() {
        _nutritionData = parsedData;
        _currentFoodName = parsedData['음식'] ?? '';
        _currentMealType = parsedData['mealType'] ?? _mealTypes.first;
        _foodNameController.text = _currentFoodName;
        _amountController.text = amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 1); // ⭐ 컨트롤러에 초기값 설정
        _isLoading = false;
      });
    } else {
      // ...
      setState(() {
        _nutritionData = _parseLogEntry(logEntry);
        _isLoading = false;
      });
    }
  }

  // ⭐ 섭취량 변경 시 영양소 재계산 함수
  void _recalculateNutrition(String amountString) {
    // 숫자만 추출
    final amountText = amountString.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final newAmount = double.tryParse(amountText) ?? 0.0;

    if (newAmount < 0) return; // 음수 입력 방지

    if (newAmount == 0) {
      // 0g 입력 시 모든 영양소를 0으로 표시
      setState(() {
        _nutritionData['섭취량'] = '0g';
        _nutritionData['섭취 칼로리'] = '0.0kcal';
        _nutritionData['탄수화물'] = '0.0g';
        _nutritionData['단백질'] = '0.0g';
        _nutritionData['지방'] = '0.0g';
      });
      return;
    }

    final ratio = newAmount / 100;

    // 100g 기준값에 새 비율을 곱하여 재계산
    final newCalories = _baseCaloriesPer100g * ratio;
    final newCarbs = _baseCarbsPer100g * ratio;
    final newProtein = _baseProteinPer100g * ratio;
    final newFat = _baseFatPer100g * ratio;

    setState(() {
      // UI 표시용 Map 업데이트 (소수점 첫째 자리까지 표시)
      _nutritionData['섭취량'] = '${newAmount.toStringAsFixed(0)}g';
      _nutritionData['섭취 칼로리'] = '${newCalories.toStringAsFixed(1)}kcal';
      _nutritionData['탄수화물'] = '${newCarbs.toStringAsFixed(1)}g';
      _nutritionData['단백질'] = '${newProtein.toStringAsFixed(1)}g';
      _nutritionData['지방'] = '${newFat.toStringAsFixed(1)}g';
    });
  }

  // ⭐ 영양 정보를 재분석하는 함수 (클래스 멤버 함수로 유지)
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

    if (!File(imagePath).existsSync()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('원본 이미지 파일을 찾을 수 없습니다.')),
        );
      }
      return;
    }


    try {
      // FoodAnalysisScreen으로 XFile과 초기 음식 이름 전달
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
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


  // 수정 완료 및 SharedPreferences 업데이트 함수
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

    // ⭐ 재계산된 값 추출 (UI 표시용 Map에서)
    // 이 값들이 새로운 로그 항목에 저장됩니다.
    final newAmountString = _nutritionData['섭취량']!;
    final newCaloriesString = _nutritionData['섭취 칼로리']!;
    final newCarbsString = _nutritionData['탄수화물']!;
    final newProteinString = _nutritionData['단백질']!;
    final newFatString = _nutritionData['지방']!;


    // 2. 현재 상태 업데이트
    _currentFoodName = updatedFoodName;

    // 3. 기존 로그 문자열 분리
    final originalLog = _savedLogs[_originalIndex];
    final parts = originalLog.split('|');

    // 4. 새로운 값으로 업데이트
    parts[1] = _currentFoodName;              // 음식 이름 (인덱스 1)
    parts[2] = newAmountString;               // 섭취량 (인덱스 2)
    parts[3] = newCaloriesString;             // 섭취 칼로리 (인덱스 3)
    parts[4] = newCarbsString;                // 탄수화물 (인덱스 4)
    parts[5] = newProteinString;              // 단백질 (인덱스 5)
    parts[6] = newFatString;                  // 지방 (인덱스 6)
    parts[7] = _currentMealType;             // 식사 유형 (인덱스 7)

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

            // ⭐ 수정 가능한 섭취량 필드 추가
            const Text('섭취량 (g)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true), // 소수점 입력 허용
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                suffixText: 'g', // 단위 표시
              ),
              onChanged: _recalculateNutrition, // ⭐ 값이 바뀔 때마다 영양소 재계산
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

            _buildNutritionInfo('섭취량', _nutritionData['섭취량']!), // ⭐ 실시간 업데이트
            _buildNutritionInfo('섭취 칼로리', _nutritionData['섭취 칼로리']!), // ⭐ 실시간 업데이트
            const Divider(height: 40),
            _buildNutritionInfo('탄수화물', _nutritionData['탄수화물']!), // ⭐ 실시간 업데이트
            _buildNutritionInfo('단백질', _nutritionData['단백질']!), // ⭐ 실시간 업데이트
            _buildNutritionInfo('지방', _nutritionData['지방']!), // ⭐ 실시간 업데이트

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