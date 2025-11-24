import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// API Key Getters 및 URL 함수 (이전과 동일)
String? get GOOGLE_VISION_API_KEY => dotenv.env['GOOGLE_VISION_API_KEY'];
String? get USDA_API_KEY => dotenv.env['USDA_API_KEY'];

String getVisionApiUrl() {
  final key = GOOGLE_VISION_API_KEY ?? '';
  return 'https://vision.googleapis.com/v1/images:annotate?key=$key';
}


class FoodAnalysisScreen extends StatefulWidget {
  final XFile image;
  const FoodAnalysisScreen({super.key, required this.image});

  @override
  State<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {
  final TextEditingController _foodNameController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  bool _showRetryUI = false;

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

  @override
  void dispose() {
    _foodNameController.dispose();
    super.dispose();
  }

  // USDA API를 호출하여 영양 정보를 가져오는 함수 (이전과 동일)
  Future<Map<String, String>?> _getUsdaNutritionInfo(String foodName) async {
    final usdaKey = USDA_API_KEY;
    if (usdaKey == null || usdaKey.isEmpty) {
      print("USDA API 키가 설정되지 않았습니다.");
      return null;
    }

    final searchUrl = Uri.parse(
        "https://api.nal.usda.gov/fdc/v1/foods/search?api_key=$usdaKey&query=$foodName&dataType=SR%20Legacy"
    );

    try {
      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode != 200) {
        throw Exception('USDA 검색 API 통신 오류: ${searchResponse.statusCode}');
      }

      final searchResults = jsonDecode(searchResponse.body);

      if (searchResults['foods'] == null || searchResults['foods'].isEmpty) {
        return null;
      }

      final fdcId = searchResults['foods'][0]['fdcId'];

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
              value = value / 4.184;
              unit = 'kcal';
            } else if (unit.toUpperCase() != 'KCAL') {
              continue;
            }
          }
          nutritionData[name] = "${value.toStringAsFixed(1)} ${unit}";
        }
      }

      nutritionData['food_name_usda'] = foodDetails['description'] ?? foodName;

      return nutritionData;

    } catch (e) {
      print("USDA API 요청 중 예외 발생: $e");
      return null;
    }
  }

  // --- Google Vision API를 사용한 분석 및 데이터 로직 (초기 진입) ---
  Future<void> _analyzeFoodWithVision(XFile image) async {
    final visionKey = GOOGLE_VISION_API_KEY;

    if (visionKey == null || visionKey.isEmpty) {
      setState(() {
        _errorMessage = '⚠️ Google Vision API 키를 설정해야 합니다.';
        _isLoading = false;
        _showRetryUI = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showRetryUI = false; // 초기 분석 시에는 재시도 UI를 숨김
      _nutritionData['음식'] = 'Google Vision API로 분석 중...';
    });

    try {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);

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

      final visionResponse = await http.post(
        Uri.parse(getVisionApiUrl()),
        headers: {"Content-Type": "application/json"},
        body: visionRequestBody,
      );

      if (visionResponse.statusCode != 200) {
        throw Exception('Vision API 통신 오류: ${visionResponse.body}');
      }

      final visionJson = jsonDecode(visionResponse.body);

      String predictedFood = '알 수 없는 음식';
      var responses = visionJson['responses'];

      if (responses != null && responses.isNotEmpty) {
        var webEntities = responses[0]['webDetection']?['webEntities'];
        if (webEntities != null && webEntities.isNotEmpty) {
          predictedFood = webEntities[0]['description']?.toString() ?? '알 수 없는 음식';
        }

        if (predictedFood == '알 수 없는 음식') {
          var labels = responses[0]['labelAnnotations'];
          if (labels != null && labels.isNotEmpty) {
            predictedFood = labels[0]['description']?.toString() ?? '알 수 없는 음식';
          }
        }
      }

      // 추출된 음식 이름으로 영양 정보 분석을 시작합니다.
      await _performAnalysis(predictedFood);

    } catch (e) {
      setState(() {
        _errorMessage = '이미지 인식 중 오류 발생: ${e.toString()}';
        _isLoading = false;
        _showRetryUI = true; // 실패 시 사용자 입력 UI 표시
      });
    }
  }

  // --- 영양 정보 분석 및 저장 로직 (Vision 결과 또는 사용자 입력으로 실행됨) ---
  Future<void> _performAnalysis(String foodName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showRetryUI = false;
      _nutritionData['음식'] = '$foodName (USDA 검색 중...)';
    });

    try {
      // 1. USDA 정보 가져오기 시도 (원본 이름)
      Map<String, String>? rawNutrition = await _getUsdaNutritionInfo(foodName);

      // 2. USDA 정보 가져오기 시도 (단어 분리 후 재시도)
      if (rawNutrition == null) {
        final words = foodName.split(' ');
        if (words.length > 1) {
          final lastWord = words.last;
          rawNutrition = await _getUsdaNutritionInfo(lastWord);
        }
      }

      if (rawNutrition == null) {
        // USDA 데이터베이스에서 정보를 찾지 못한 경우
        throw Exception('USDA 데이터베이스에서 영양 정보를 찾을 수 없습니다.');
      }

      // 3. USDA 결과 파싱 및 UI 업데이트
      final Map<String, dynamic> finalData = {};
      finalData['food_name'] = rawNutrition['food_name_usda'] ?? foodName;
      finalData['serving_size'] = 100.0;
      finalData['calories'] = _extractValue(rawNutrition['Energy']);
      finalData['carbs'] = _extractValue(rawNutrition['Carbohydrate, by difference']);
      finalData['protein'] = _extractValue(rawNutrition['Protein']);
      finalData['fat'] = _extractValue(rawNutrition['Total lipid (fat)']);

      // 4. UI 및 SharedPreferences 업데이트
      setState(() {
        final foodNameDisplay = finalData['food_name']?.toString() ?? '분석 실패';

        _nutritionData = {
          '음식': foodNameDisplay,
          '섭취량': '${finalData['serving_size']?.toStringAsFixed(0) ?? '0'}g', // 소수점 제거
          '섭취 칼로리': '${finalData['calories']?.toStringAsFixed(1) ?? '0'}kcal',
          '탄수화물': '${finalData['carbs']?.toStringAsFixed(1) ?? '0'}g',
          '단백질': '${finalData['protein']?.toStringAsFixed(1) ?? '0'}g',
          '지방': '${finalData['fat']?.toStringAsFixed(1) ?? '0'}g',
        };
        _isLoading = false;
        _showRetryUI = false; // 성공했으므로 숨김
      });

      // 5. 분석 결과를 SharedPreferences에 저장
      await _saveFoodLog(widget.image.path, finalData);

    } catch (e) {
      // USDA 검색 실패 또는 기타 에러 처리
      setState(() {
        _errorMessage = '분석 오류: ${e.toString()}';
        _isLoading = false;
        _showRetryUI = true; // 실패 시 사용자 입력 UI 표시
      });
    }
  }

  void _retryAnalysis() {
    final manualFoodName = _foodNameController.text.trim();
    if (manualFoodName.isNotEmpty) {
      _performAnalysis(manualFoodName);
    } else {
      setState(() {
        _errorMessage = '음식 이름을 입력해 주세요.';
      });
    }
  }

  // --- 헬퍼 함수: 문자열에서 숫자 값만 추출 (이전과 동일) ---
  double _extractValue(String? valueStr) {
    if (valueStr == null) return 0.0;
    try {
      return double.tryParse(valueStr.split(' ')[0]) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // SharedPreferences에 로그 저장 (이전과 동일)
  Future<void> _saveFoodLog(String imagePath, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedLogs = prefs.getStringList('food_logs') ?? [];

    final now = DateTime.now();
    final dateStr = '${now.month}/${now.day}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    const mealType = '점심';

    final newLog =
        '$imagePath|'
        '${data['food_name']?.toString() ?? '알 수 없음'}|'
        '${data['serving_size']?.toStringAsFixed(0) ?? '0'}g|'
        '${data['calories']?.toStringAsFixed(1) ?? '0'}kcal|'
        '${data['carbs']?.toStringAsFixed(1) ?? '0'}g|'
        '${data['protein']?.toStringAsFixed(1) ?? '0'}g|'
        '${data['fat']?.toStringAsFixed(1) ?? '0'}g|'
        '$mealType|'
        '$dateStr $timeStr';

    savedLogs.add(newLog);
    await prefs.setStringList('food_logs', savedLogs);
  }

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
            // ----------------------------------------------------
            // ✅ 수정: 에러 메시지와 재시도 UI 표시
            // ----------------------------------------------------
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Text(
                        '⚠️ $_errorMessage',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (_showRetryUI)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              '음식 이름을 직접 입력해 주세요:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _foodNameController,
                              decoration: InputDecoration(
                                hintText: '예: 닭가슴살 샐러드',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _foodNameController.clear,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _retryAnalysis,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('영양 정보 다시 검색', style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              )
            // ----------------------------------------------------
            else
            // 데이터 로드 성공 시 영양 정보 표시 (이전과 동일)
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