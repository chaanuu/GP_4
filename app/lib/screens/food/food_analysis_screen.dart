import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // <--- 추가 필요

// FoodAnalysisScreen을 StatefulWidget으로 변경
class FoodAnalysisScreen extends StatefulWidget {
  final XFile image; // 카메라로 찍은 이미지를 이전 화면에서 전달받음
  const FoodAnalysisScreen({super.key, required this.image});

  @override
  State<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {

  bool _isLoading = true;
  String? _errorMessage;

  // 분석 결과를 담을 초기 데이터 맵
  Map<String, String> _nutritionData = {
    '음식': '분석 중...',
    '섭취량': '0g',
    '섭취 칼로리': '0kcal',
    '탄수화물': '0g',
    '단백질': '0g',
    '지방': '0g',
  };

  @override
  void initState() {
    super.initState();
    _analyzeFood(widget.image); // 이미지 분석 시작
  }

  // --- 서버 통신 및 데이터 저장 로직 ---
  Future<void> _analyzeFood(XFile image) async {
    // 1. 최종 서버 API 엔드포인트 설정 (제공해주신 정보 반영)
    const url = 'http://jyb1018.iptime.org:3000/food/img_anlysis';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // 2. 이미지 파일 추가 (필드 이름 'image'로 가정)
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // 🔑 가장 흔한 이름으로 가정하여 시도
          image.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // 3. JSON 응답을 파싱하여 상태 업데이트
        setState(() {
          // 서버 응답 키 (food_name, calories 등)가 통일되었다고 가정
          _nutritionData = {
            '음식': jsonResponse['food_name']?.toString() ?? '분석 실패',
            '섭취량': '${jsonResponse['serving_size']?.toString() ?? '0'}g',
            '섭취 칼로리': '${jsonResponse['calories']?.toString() ?? '0'}kcal',
            '탄수화물': '${jsonResponse['carbs']?.toString() ?? '0'}g',
            '단백질': '${jsonResponse['protein']?.toString() ?? '0'}g',
            '지방': '${jsonResponse['fat']?.toString() ?? '0'}g',
          };
          _isLoading = false;
        });

        // 4. 분석 결과를 SharedPreferences에 저장
        await _saveFoodLog(image.path, jsonResponse);

      } else {
        // 서버 에러 처리 (200이 아닌 경우)
        setState(() {
          _errorMessage = '서버 통신 오류: ${response.statusCode}\n서버 응답: ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      // 네트워크 또는 기타 에러 처리
      setState(() {
        _errorMessage = '데이터를 불러오는 중 오류가 발생했습니다: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // SharedPreferences에 로그 저장
  Future<void> _saveFoodLog(String imagePath, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedLogs = prefs.getStringList('food_logs') ?? [];

    final now = DateTime.now();
    final dateStr = '${now.month}/${now.day}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // ⚠️ 식사 유형은 임시로 '점심'으로 가정. 실제는 UI에서 선택해야 함.
    const mealType = '점심';

    final newLog =
        '$imagePath|'
        '${data['food_name']?.toString() ?? '알 수 없음'}|'
        '${data['serving_size']?.toString() ?? '0'}g|'
        '${data['calories']?.toString() ?? '0'}kcal|'
        '$mealType|'
        '$dateStr $timeStr';

    savedLogs.add(newLog);
    await prefs.setStringList('food_logs', savedLogs);
  }
  // --- UI 구성 ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        title: const Text('음식 분석', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 캡처한 이미지를 표시
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(
                File(widget.image.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300,
              ),
            ),
            const SizedBox(height: 24),

            // --- 분석 결과 표시 영역 (로딩/에러 처리 포함) ---
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('음식 이미지 분석 중...', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    '⚠️ 분석 오류: $_errorMessage',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
            // 데이터 로드 성공 시 영양 정보 표시
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNutritionInfo('음식', _nutritionData['음식']!),
                  _buildNutritionInfo('섭취량', _nutritionData['섭취량']!),
                  _buildNutritionInfo('섭취 칼로리', _nutritionData['섭취 칼로리']!),
                  const Divider(height: 40),
                  _buildNutritionInfo('탄수화물', _nutritionData['탄수화물']!),
                  _buildNutritionInfo('단백질', _nutritionData['단백질']!),
                  _buildNutritionInfo('지방', _nutritionData['지방']!),
                ],
              ),
            // -----------------------------
          ],
        ),
      ),
    );
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
}