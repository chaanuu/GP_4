import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 추가
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // File 사용을 위해 추가
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

  // SharedPreferences에서 음식 기록 불러오기
  Future<void> _loadFoodLogs() async {
    final prefs = await SharedPreferences.getInstance();
    // 'food_logs' 키를 사용합니다.
    List<String> savedData = prefs.getStringList('food_logs') ?? [];

    // 임시 데이터 (디자인 확인용)
    final List<Map<String, dynamic>> assetLogs = [
        {'imageUrl': 'assets/images/pears.jpg', 'name': '설탕 절인 토마토', 'portion': '100.0g', 'calories': 73, 'mealType': '간식', 'date': '9/19', 'isAsset': true},
        {'imageUrl': 'assets/images/pizza.jpg', 'name': '피자', 'portion': '90.0g', 'calories': 237, 'mealType': '저녁', 'date': '9/19', 'isAsset': true},
    ];

    // 저장된 데이터 파싱
    List<Map<String, dynamic>> parsedLogs = savedData.map((item) {
      // 저장 형식: "경로|음식명|양|칼로리|식사유형|날짜 시간"
      final parts = item.split('|');

      // 데이터가 6개 미만일 경우 기본값 설정으로 오류 방지
      return {
        'imageUrl': parts[0],
        'name': parts.length > 1 ? parts[1] : '이름 없음',
        'portion': parts.length > 2 ? parts[2] : 'N/A',
        'calories': parts.length > 3
            ? (double.tryParse(parts[3].replaceAll('kcal', '')) ?? 0.0).round()
            : 0,
        'mealType': parts.length > 4 ? parts[4] : '기타',
        // 날짜만 분리 (예: "9/20 18:30" -> "9/20")
        'date': parts.length > 5 ? parts[5].split(' ')[0] : '날짜 없음',
        'isAsset': false, // SharedPreferences에 저장된 것은 파일 경로
      };
    }).toList();

    setState(() {
      // SharedPreferences에 저장된 로그 + 임시 Asset 로그를 합칩니다.
      _foodLogs = [...parsedLogs.reversed, ...assetLogs];
      // 최신 로그를 위에 표시하고 싶다면 .reversed를 제거하고 parsedLogs만 사용하세요.
      _isLoading = false;
    });
  }

  void _onAddTapped() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
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

  // ✅ 추가: 이미지 선택 및 FoodAnalysisScreen으로 이동
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null && mounted) {
      // FoodAnalysisScreen으로 XFile 객체 전달
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
  Widget build(BuildContext context) { // WidgetRef 제거
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // ConsumerStatefulWidget 내에서 Riverpod 사용 시 ref.read 사용
            ref.read(navIndexProvider.notifier).state = -1;
          },
        ),
        title: const Text('식습관 분석', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,

        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _onAddTapped, // 위에서 정의한 함수 연결
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
                    File(log['imageUrl']), // 저장된 파일 경로 사용
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
                      // '아침 - 계란 샌드위치' 형식
                      Text('${log['mealType']} - ${log['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(log['portion'], style: TextStyle(color: Colors.grey[600])),
                      // 칼로리가 int로 저장되었을 경우 다시 문자열로 포맷팅
                      Text('${log['calories']}kcal', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text(log['date'], style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        },
      ),
    );
  }

  // 에러 발생 시 공통적으로 사용할 errorBuilder 위젯
  Widget _errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[300],
      child: const Icon(Icons.fastfood, color: Colors.grey),
    );
  }
}