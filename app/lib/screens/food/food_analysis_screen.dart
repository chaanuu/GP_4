import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// ----------------------------------------------------
// ✅ 1. API Key Getters 및 URL 함수로 수정
// ----------------------------------------------------
String? get GOOGLE_VISION_API_KEY => dotenv.env['GOOGLE_VISION_API_KEY'];

// final USDA_API_KEY = dotenv.env['USDA_API_KEY'];
String? get USDA_API_KEY => dotenv.env['USDA_API_KEY'];

String getVisionApiUrl() {
  final key = GOOGLE_VISION_API_KEY ?? '';
  return 'https://vision.googleapis.com/v1/images:annotate?key=$key';
}
// ----------------------------------------------------


class FoodAnalysisScreen extends StatefulWidget {
  final XFile image;
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
    _analyzeFoodWithVision(widget.image);
  }

  Future<Map<String, String>?> _getUsdaNutritionInfo(String foodName) async {
    final usdaKey = USDA_API_KEY;
    if (usdaKey == null || usdaKey.isEmpty) {
      print("USDA API 키가 설정되지 않았습니다.");
      return null;
    }

    // 1단계: 음식 검색 (fdcId 찾기)
    // ✅ 수정: usdaKey 변수 사용 (널 체크 완료)
    final searchUrl = Uri.parse(
        "https://api.nal.usda.gov/fdc/v1/foods/search?api_key=$usdaKey&query=$foodName&dataType=SR%20Legacy"
    );

    try {
      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode != 200) {
        throw Exception('USDA 검색 API 통신 오류: ${searchResponse.statusCode}');
      }

      final searchResults = jsonDecode(searchResponse.body);

      // 검색 결과가 없으면 종료
      if (searchResults['foods'] == null || searchResults['foods'].isEmpty) {
        return null;
      }

      final fdcId = searchResults['foods'][0]['fdcId'];

      // 2단계: 상세 영양 정보 조회
      // ✅ 수정: usdaKey 변수 사용 (널 체크 완료)
      final detailsUrl = Uri.parse(
          "https://api.nal.usda.gov/fdc/v1/food/$fdcId?api_key=$usdaKey"
      );

      final detailsResponse = await http.get(detailsUrl);

      if (detailsResponse.statusCode != 200) {
        throw Exception('USDA 상세 API 통신 오류: ${detailsResponse.statusCode}');
      }

      final foodDetails = jsonDecode(detailsResponse.body);

      Map<String, String> nutritionData = {};
      final nutrients = foodDetails['foodNutrients'] ?? [];

      const targetNutrients = [
        'Energy', 'Protein', 'Total lipid (fat)', 'Carbohydrate, by difference'
      ];

      for (var nutrient in nutrients) {
        String name = nutrient['nutrient']['name'];
        double value = (nutrient['amount'] ?? 0.0).toDouble();
        String unit = nutrient['nutrient']['unitName'] ?? 'g';

        if (targetNutrients.contains(name)) {
          if (name == 'Energy') {
            if (unit.toUpperCase() == 'KJ') {
              // 1 kcal ≈ 4.184 kJ 이므로, kJ를 kcal로 변환
              value = value / 4.184;
              unit = 'kcal'; // 단위를 kcal로 변경

            } else if (unit.toUpperCase() != 'KCAL') {
              // kJ나 kcal이 아닌 다른 이상한 단위인 경우 로깅하고 건너뜁니다.
              print('경고: Energy 단위가 $unit 입니다. (예상: kcal 또는 kJ)');
              continue;
            }
          }
          // Python 코드와 동일하게 저장 (예: "100.0 kcal")
          nutritionData[name] = "${value.toStringAsFixed(1)} ${unit}";
        }
      }

      // USDA API가 반환하는 음식 이름도 포함
      nutritionData['food_name_usda'] = foodDetails['description'] ?? foodName;

      return nutritionData;

    } catch (e) {
      print("USDA API 요청 중 예외 발생: $e");
      return null;
    }
  }

  // --- Google Vision API를 사용한 분석 및 데이터 로직 ---
  Future<void> _analyzeFoodWithVision(XFile image) async {
    final visionKey = GOOGLE_VISION_API_KEY;

    // 1. Vision API 키 누락 확인
    if (visionKey == null || visionKey.isEmpty) {
      setState(() {
        _errorMessage = '⚠️ Google Vision API 키를 설정해야 합니다.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _nutritionData['음식'] = 'Google Vision API로 분석 중...';
    });

    try {
      // 이미지 파일을 base64로 인코딩
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Vision API 요청 본문 (라벨 및 웹 검색 사용)
      final visionRequestBody = jsonEncode({
        "requests": [
          {
            "image": {"content": base64Image},
            "features": [
              {"type": "LABEL_DETECTION", "maxResults": 3},
              {"type": "WEB_DETECTION", "maxResults": 3},
            ]
          }
        ]
      });

      // 2. Google Vision API 호출
      // ✅ 수정: getVisionApiUrl() 함수를 사용하여 URL 가져오기
      final visionResponse = await http.post(
        Uri.parse(getVisionApiUrl()),
        headers: {"Content-Type": "application/json"},
        body: visionRequestBody,
      );

      if (visionResponse.statusCode != 200) {
        throw Exception('Vision API 통신 오류: ${visionResponse.body}');
      }

      final visionJson = jsonDecode(visionResponse.body);

      // 3. Vision API 응답에서 가장 가능성 높은 음식 이름 추출
      String predictedFood = '알 수 없는 음식';
      var responses = visionJson['responses'];

      if (responses != null && responses.isNotEmpty) {
        // 웹 감지에서 가장 적합한 엔티티를 찾습니다 (일반적으로 가장 정확)
        var webEntities = responses[0]['webDetection']?['webEntities'];
        if (webEntities != null && webEntities.isNotEmpty) {
          // 가장 높은 점수를 가진 엔티티의 설명(description)을 사용
          predictedFood = webEntities[0]['description']?.toString() ?? '알 수 없는 음식';
        }

        // 웹 감지가 없을 경우 라벨 감지를 확인합니다.
        if (predictedFood == '알 수 없는 음식') {
          var labels = responses[0]['labelAnnotations'];
          if (labels != null && labels.isNotEmpty) {
            // 첫 번째 라벨을 사용
            predictedFood = labels[0]['description']?.toString() ?? '알 수 없는 음식';
          }
        }
      }

      // 4. 추출된 음식 이름으로 임시 영양 정보 가져오기
      Map<String, String>? rawNutrition = await _getUsdaNutritionInfo(predictedFood);

      if (rawNutrition == null) {
        final words = predictedFood.split(' ');
        if (words.length > 1) {
          final lastWord = words.last;
          rawNutrition = await _getUsdaNutritionInfo(lastWord);
        }
      }

      if (rawNutrition == null) {
        throw Exception('USDA 데이터베이스에서 영양 정보를 찾을 수 없습니다.');
      }

      // 4. USDA 결과 파싱 및 UI 업데이트를 위한 최종 맵 구성
      // Python의 ORDER MAPPING 로직과 유사하게 파싱합니다.
      final Map<String, dynamic> finalData = {};

      finalData['food_name'] = rawNutrition['food_name_usda'] ?? predictedFood;
      finalData['serving_size'] = 100.0; // USDA 기본값(100g)으로 가정

      // 영양소 값 추출
      finalData['calories'] = _extractValue(rawNutrition['Energy']);
      finalData['carbs'] = _extractValue(rawNutrition['Carbohydrate, by difference']);
      finalData['protein'] = _extractValue(rawNutrition['Protein']);
      finalData['fat'] = _extractValue(rawNutrition['Total lipid (fat)']);

      // 5. UI 및 SharedPreferences 업데이트
      setState(() {
        final foodNameDisplay = finalData['food_name']?.toString() ?? '분석 실패';

        _nutritionData = {
          '음식': foodNameDisplay,
          '섭취량': '${finalData['serving_size']?.toString() ?? '0'}g',
          '섭취 칼로리': '${finalData['calories']?.toString() ?? '0'}kcal',
          '탄수화물': '${finalData['carbs']?.toString() ?? '0'}g',
          '단백질': '${finalData['protein']?.toString() ?? '0'}g',
          '지방': '${finalData['fat']?.toString() ?? '0'}g',
        };
        _isLoading = false;
      });

      // 6. 분석 결과를 SharedPreferences에 저장
      await _saveFoodLog(image.path, finalData);

    } catch (e) {
      // 네트워크 또는 기타 에러 처리
      setState(() {
        _errorMessage = '분석 중 오류 발생: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // --- 헬퍼 함수: 문자열에서 숫자 값만 추출 ---
  double _extractValue(String? valueStr) {
    if (valueStr == null) return 0.0;
    try {
      // "100.0 kcal"에서 "100.0"만 추출하여 double로 변환
      return double.tryParse(valueStr.split(' ')[0]) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }


  // SharedPreferences에 로그 저장 (기존과 동일)
  Future<void> _saveFoodLog(String imagePath, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedLogs = prefs.getStringList('food_logs') ?? [];

    final now = DateTime.now();
    final dateStr = '${now.month}/${now.day}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // ⚠️ 식사 유형은 임시로 '점심'으로 가정. 실제는 UI에서 선택해야 함.
    const mealType = '점심';

    // data 맵에서 직접 값 추출 (getDummyNutrition 구조와 일치)
    final newLog =
        '$imagePath|'
        '${data['food_name']?.toString() ?? '알 수 없음'}|'
        '${data['serving_size']?.toString() ?? '0'}g|'
        '${data['calories']?.toString() ?? '0'}kcal|' // 칼로리만 kcal 붙여서 저장
        '$mealType|'
        '$dateStr $timeStr';

    savedLogs.add(newLog);
    await prefs.setStringList('food_logs', savedLogs);
  }

  // (나머지 build 및 _buildNutritionInfo 함수는 이전과 동일)
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