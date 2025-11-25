import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/nav_provider.dart';
import '../../widgets/image_card.dart';
import '../../widgets/calorie_card.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _remainingCalories = 0; // 기초대사량 - 활동량

  @override
  void initState() {
    super.initState();
    _loadAndCalculateCalories();
  }

  // 기초대사량 계산 및 활동량 반영 로직
  Future<void> _loadAndCalculateCalories() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. 신체 정보 불러오기 (없으면 기본값 사용)
    final height = prefs.getDouble('user_height') ?? 175.0;
    final weight = prefs.getDouble('user_weight') ?? 70.0;
    final age = prefs.getInt('user_age') ?? 25;
    final gender = prefs.getString('user_gender') ?? 'male';

    // 2. 기초대사량(BMR) 계산 (해리스-베네딕트 공식)
    // 남자: 88.362 + (13.397 × 체중kg) + (4.799 × 키cm) - (5.677 × 나이)
    // 여자: 447.593 + (9.247 × 체중kg) + (3.098 × 키cm) - (4.330 × 나이)
    double bmr;
    if (gender == 'male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    // 3. 오늘 활동 칼로리 불러오기 (ActivityAnalysisScreen에서 저장한 값)
    final activityCalories = prefs.getInt('today_activity_calories') ?? 0;

    // 4. 기초대사량 - 활동량 계산
    final result = bmr - activityCalories;

    if (mounted) {
      setState(() {
        _remainingCalories = result.toInt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MealFit',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              // 내 정보 화면으로 이동. 돌아올 때(.then) 데이터를 다시 로드해서 칼로리 갱신
              Navigator.pushNamed(context, '/personal_info')
                  .then((_) => _loadAndCalculateCalories());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/preferences');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ImageCard(
                title: '최근 식사',
                imagePath: 'assets/images/pears.jpg',
                onTap: () {
                  ref.read(navIndexProvider.notifier).state = 0;
                },
              ),
              const SizedBox(height: 16),
              ImageCard(
                title: '활동량',
                imagePath: 'assets/images/track.jpg',
                onTap: () {
                  ref.read(navIndexProvider.notifier).state = 1;
                },
              ),
              const SizedBox(height: 16),

              // 계산된 '기초대사량 - 활동량' 표시, 추후 섭취 칼로리 추가 필요
              CalorieCard(
                calories: _remainingCalories,
                onTap: () {
                  // 필요 시 탭 이동 로직 추가 (여기서는 이동 없음)
                },
                goalText: "",
              ),

              const SizedBox(height: 16),
              ImageCard(
                title: '추천 운동',
                imagePath: 'assets/images/weights.jpg',
                onTap: () {
                  ref.read(navIndexProvider.notifier).state = 3;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}