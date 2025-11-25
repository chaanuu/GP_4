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
  final String? initialFoodName;
  const FoodAnalysisScreen({super.key, required this.image, this.initialFoodName});

  @override
  State<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {
  final TextEditingController _foodNameController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  bool _showRetryUI = false;

  List<String> _suggestedFoodNames = [];
  String? _selectedFoodName;

  Map<String, String> _nutritionData = {
    '음식': '분석 중...',
    '섭취량': '0g',
    '섭취 칼로리': '0kcal',
    '탄수화물': '0g',
    '단백질': '0g',
    '지방': '0g',
  };

  final List<String> _mealTypes = ['아침', '점심', '저녁', '간식'];

  String _selectedMealType = '점심';

  Map<String, dynamic>? _finalAnalysisResult;

  @override
  void initState() {
    super.initState();
    if (widget.initialFoodName != null && widget.initialFoodName!.isNotEmpty) {
      // initialFoodName이 전달되면 Vision API 건너뛰고 바로 USDA 분석 시작
      _performAnalysis(widget.initialFoodName!);
    } else {
      // 아니면 기존처럼 Vision API로 분석 시작
      _analyzeFoodWithVision(widget.image);
    }
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
      List<String> candidates = ['apple_pie', 'baby_back_ribs', 'baklava', 'beef_carpaccio', 'beef_tartare', 'beet_salad', 'beignets', 'bibimbap', 'bread_pudding', 'breakfast_burrito', 'bruschetta', 'caesar_salad', 'cannoli', 'caprese_salad', 'carrot_cake', 'ceviche', 'cheesecake', 'cheese_plate', 'chicken_curry', 'chicken_quesadilla', 'chicken_wings', 'chocolate_cake', 'chocolate_mousse', 'churros', 'clam_chowder', 'club_sandwich', 'crab_cakes', 'creme_brulee', 'croque_madame', 'cup_cakes', 'deviled_eggs', 'donuts', 'dumplings', 'edamame', 'eggs_benedict', 'escargots', 'falafel', 'filet_mignon', 'fish_and_chips', 'foie_gras', 'french_fries', 'french_onion_soup', 'french_toast', 'fried_calamari', 'fried_rice', 'frozen_yogurt', 'garlic_bread', 'gnocchi', 'greek_salad', 'grilled_cheese_sandwich', 'grilled_salmon', 'guacamole', 'gyoza', 'hamburger', 'hot_and_sour_soup', 'hot_dog', 'huevos_rancheros', 'hummus', 'ice_cream', 'lasagna', 'lobster_bisque', 'lobster_roll_sandwich', 'macaroni_and_cheese', 'macarons', 'miso_soup', 'mussels', 'nachos', 'omelette', 'onion_rings', 'oysters', 'pad_thai', 'paella', 'pancakes', 'panna_cotta', 'peking_duck', 'pho', 'pizza', 'pork_chop', 'poutine', 'prime_rib', 'pulled_pork_sandwich', 'ramen', 'ravioli', 'red_velvet_cake', 'risotto', 'samosa', 'sashimi', 'scallops', 'seaweed_salad', 'shrimp_and_grits', 'spaghetti_bolognese', 'spaghetti_carbonara', 'spring_rolls', 'steak', 'strawberry_shortcake', 'sushi', 'tacos', 'takoyaki', 'tiramisu', 'tuna_tartare', 'waffles'];

      candidates = candidates.toSet().toList();


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

      setState(() {
        _suggestedFoodNames = candidates;
        _selectedFoodName = candidates.isNotEmpty ? candidates.first : null;
      });



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

        _finalAnalysisResult = finalData;

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
  Future<void> _saveFoodLog(String imagePath, Map<String, dynamic> data, String mealType) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedLogs = prefs.getStringList('food_logs') ?? [];

    final now = DateTime.now();
    final dateStr = '${now.month}/${now.day}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

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
                              '검색된 후보 중 정확한 음식 이름을 선택하거나 직접 입력해 주세요:', // 텍스트 수정
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            // ⭐ 1. 드롭다운 버튼 (Vision 후보 목록 사용)
                            if (_suggestedFoodNames.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedFoodName,
                                    hint: const Text('음식 후보 선택'),
                                    isExpanded: true,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedFoodName = newValue;
                                        // 드롭다운에서 선택 시, 직접 입력 필드와 동기화
                                        _foodNameController.text = newValue ?? '';
                                      });
                                    },
                                    items: _suggestedFoodNames.map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16), // 드롭다운과 텍스트 필드 사이 간격

                            // ⭐ 2. 직접 입력 필드 (선택하거나 직접 입력)
                            TextField(
                              controller: _foodNameController,
                              // 드롭다운이 있을 경우 힌트 텍스트 수정
                              decoration: InputDecoration(
                                hintText: _suggestedFoodNames.isNotEmpty ? '직접 입력 (선택지가 없을 경우)' : '예: Chocolate Cookie',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _foodNameController.clear();
                                    setState(() {
                                      // 입력 필드를 지우면 선택된 항목도 해제
                                      _selectedFoodName = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ⭐ 3. 재시도 버튼 수정: 선택된/입력된 이름 사용
                            ElevatedButton(
                              onPressed: () {
                                final finalSelection = _foodNameController.text.trim();

                                // 입력 필드에 값이 있으면 그것을 사용하고, 아니면 드롭다운 선택 값을 사용
                                if (finalSelection.isNotEmpty) {
                                  _performAnalysis(finalSelection);
                                } else if (_selectedFoodName != null) {
                                  _performAnalysis(_selectedFoodName!);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('음식 이름을 선택하거나 입력해 주세요.')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('선택/입력된 이름으로 다시 검색', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                  // ⭐ 식사 유형 선택 드롭다운 추가
                  const Text('식사 시간 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMealType,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_downward),
                        onChanged: (String? newValue) {
                          setState(() {
                            // _selectedMealType 상태 변수는 _FoodAnalysisScreenState에 정의되어 있다고 가정
                            _selectedMealType = newValue!;
                          });
                        },
                        items: _mealTypes.map<DropdownMenuItem<String>>((String value) {
                          // _mealTypes 리스트는 _FoodAnalysisScreenState에 정의되어 있다고 가정
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildNutritionInfo('음식', _nutritionData['음식']!),
                  _buildNutritionInfo('섭취량', _nutritionData['섭취량']!),
                  _buildNutritionInfo('섭취 칼로리', _nutritionData['섭취 칼로리']!),
                  const Divider(height: 40),
                  _buildNutritionInfo('탄수화물', _nutritionData['탄수화물']!),
                  _buildNutritionInfo('단백질', _nutritionData['단백질']!),
                  _buildNutritionInfo('지방', _nutritionData['지방']!),

                  // 기록 저장하기 버튼 추가
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_finalAnalysisResult != null && widget.image != null) {
                          // _saveFoodLog 함수는 _selectedMealType을 인수로 받도록 수정되어야 합니다.
                          await _saveFoodLog(
                            widget.image!.path,
                            _finalAnalysisResult!,
                            _selectedMealType,
                          );
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('기록 저장하기', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
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