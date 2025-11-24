import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/nav_provider.dart';
import 'food_analysis_screen.dart';

// ConsumerStatefulWidget으로 변경
class FoodDiaryScreen extends ConsumerStatefulWidget {
  const FoodDiaryScreen({super.key});

  @override
  ConsumerState<FoodDiaryScreen> createState() => _FoodDiaryScreenState();
}

// ConsumerState로 변경
class _FoodDiaryScreenState extends ConsumerState<FoodDiaryScreen> {

  List<Map<String, dynamic>> _foodLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoodLogs();
  }

  // SharedPreferences에서 음식 기록 불러오기 (원본 인덱스 저장 로직 추가)
  Future<void> _loadFoodLogs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedData = prefs.getStringList('food_logs') ?? [];

    // 임시 데이터 (디자인 확인용)
    final List<Map<String, dynamic>> assetLogs = [
      {'imageUrl': 'assets/images/pears.jpg', 'name': '설탕 절인 토마토', 'portion': '100.0g', 'calories': 73, 'mealType': '간식', 'date': '9/19', 'isAsset': true},
      {'imageUrl': 'assets/images/pizza.jpg', 'name': '피자', 'portion': '90.0g', 'calories': 237, 'mealType': '저녁', 'date': '9/19', 'isAsset': true},
    ];

    // 저장된 데이터 파싱
    List<Map<String, dynamic>> parsedLogs = savedData.asMap().entries.map((entry) {
      int originalIndex = entry.key; // 원본 인덱스
      String item = entry.value;

      final parts = item.split('|');

      return {
        'imageUrl': parts[0],
        'name': parts.length > 1 ? parts[1] : '이름 없음',
        'portion': parts.length > 2 ? parts[2] : 'N/A',
        // double로 파싱 후 int로 반올림하여 칼로리 오류 수정
        'calories': parts.length > 3
            ? (double.tryParse(parts[3].replaceAll('kcal', '')) ?? 0.0).round()
            : 0,
        'mealType': parts.length > 4 ? parts[4] : '기타',
        'date': parts.length > 5 ? parts[5].split(' ')[0] : '날짜 없음',
        'isAsset': false,
        'originalIndex': originalIndex, // 삭제를 위해 원본 인덱스 저장
      };
    }).toList();

    setState(() {
      // 최신 로그를 위에 표시하기 위해 reversed 사용
      _foodLogs = [...parsedLogs.reversed, ...assetLogs];
      _isLoading = false;
    });
  }

  // 추가: 음식 기록 삭제 함수
  Future<void> _deleteFoodLog(int originalIndex, bool isAsset) async {
    if (isAsset) {
      // 임시 데이터는 SharedPreferences를 건드릴 필요가 없습니다.
      print('Asset log cannot be permanently deleted from SharedPreferences.');
      // UI에서만 제거하고 싶다면 여기서 setState를 통해 _foodLogs를 수정해야 하지만,
      // 여기서는 영구 기록 삭제에 초점을 맞추고 임시 데이터는 삭제를 허용하지 않습니다.
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> savedData = prefs.getStringList('food_logs') ?? [];

    if (originalIndex >= 0 && originalIndex < savedData.length) {
      // SharedPreferences에 저장된 목록에서 해당 인덱스의 항목을 제거
      savedData.removeAt(originalIndex);
      await prefs.setStringList('food_logs', savedData);

      // 삭제 후 로그 목록을 새로고침하여 UI 업데이트
      await _loadFoodLogs();
    }
  }
  // ----------------------------------------------------

  void _onAddTapped() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('음식 사진 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodAnalysisScreen(image: image),
        ),
      ).then((_) {
        // 분석 화면에서 돌아왔을 때, 로그 목록을 새로고침합니다.
        _loadFoodLogs();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            ref.read(navIndexProvider.notifier).state = -1;
          },
        ),
        title: const Text('식습관 분석', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _onAddTapped,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _foodLogs.isEmpty
          ? const Center(child: Text('아직 기록된 식단이 없습니다.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        itemCount: _foodLogs.length,
        itemBuilder: (context, index) {
          final log = _foodLogs[index];
          final isAsset = log['isAsset'] == true;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: isAsset
                      ? Image.asset(
                    log['imageUrl'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: _errorBuilder,
                  )
                      : Image.file(
                    File(log['imageUrl']),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: _errorBuilder,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${log['mealType']} - ${log['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(log['portion'], style: TextStyle(color: Colors.grey[600])),
                      Text('${log['calories']}kcal', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                // ----------------------------------------------------
                // ✅ 수정: 날짜와 삭제 버튼을 포함하는 Row 추가
                // ----------------------------------------------------
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(log['date'], style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 8),
                    if (!isAsset) // 실제 데이터에만 삭제 버튼 표시
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                        onPressed: () {
                          // _deleteFoodLog 호출 시 원본 인덱스와 isAsset 플래그 전달
                          _deleteFoodLog(
                              log['originalIndex']!,
                              log['isAsset'] ?? false
                          );
                        },
                        // 버튼 영역 최소화
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                // ----------------------------------------------------
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[300],
      child: const Icon(Icons.fastfood, color: Colors.grey),
    );
  }
}