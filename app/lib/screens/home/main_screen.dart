    import 'package:flutter/material.dart';

    // 분리한 위젯들을 import 합니다.
    import 'package:app/widgets/image_card.dart';
    import 'package:app/widgets/calorie_card.dart';

    class MainScreen extends StatelessWidget {
      const MainScreen({super.key});

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'App Name',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.black),
                onPressed: () {Navigator.pushNamed(context, '/personal_info');
                  },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.black),
                onPressed: () {Navigator.pushNamed(context, '/preferences');
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
                    imagePath: 'assets/images/pears.jpg', // TODO: assets 폴더에 이미지 추가
                    onTap: () {
                      // 식습관 분석 페이지로 이동
                      Navigator.pushNamed(context, '/food_diary');
                    },
                  ),
                  const SizedBox(height: 16),
                  ImageCard(
                    title: '활동량',
                    imagePath: 'assets/images/track.jpg', // TODO: assets 폴더에 이미지 추가
                    onTap: () {
                      // 활동량 분석 페이지로 이동
                      // AppShell의 탭으로 이동하고 싶다면 아래처럼 할 수도 있습니다.
                      // DefaultTabController.of(context)?.animateTo(1); // 이 경우 DefaultTabController 필요
                      // 또는 Navigator.of(context).popUntil((route) => route.isFirst); // AppShell 초기화 후 이동
                      // 여기서는 새로운 페이지로 push하는 것이 더 간단합니다.
                      Navigator.pushNamed(context, '/activity_analysis');
                    },
                  ),
                  const SizedBox(height: 16),
                  CalorieCard(
                    calories: 459,
                    goalText: '목표까지',
                    onTap: () {
                      // 활동량 분석 페이지로 이동 (칼로리 관련 정보이므로)
                      Navigator.pushNamed(context, '/activity_analysis');
                    },
                  ),
                  const SizedBox(height: 16),
                  ImageCard(
                    title: '추천 운동',
                    imagePath: 'assets/images/weights.jpg', // TODO: assets 폴더에 이미지 추가
                    onTap: () {
                      // 오늘의 프로그램 페이지로 이동
                      Navigator.pushNamed(context, '/workout_program');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }