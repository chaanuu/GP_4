import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod import

// 분리한 위젯들을 import 합니다.
// (경로가 다르다면 프로젝트 구조에 맞춰 수정해주세요. 보통은 상대 경로를 추천합니다.)
import '../../widgets/image_card.dart';
import '../../widgets/qr_card.dart';
import '../../providers/nav_provider.dart'; // 네비게이션 상태 관리 provider

class WorkoutHubScreen extends ConsumerWidget {
  const WorkoutHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        // 뒤로가기 버튼 커스텀: 팝(Pop) 대신 탭 인덱스를 -1(홈)로 변경
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            ref.read(navIndexProvider.notifier).state = -1;
          },
        ),
        title: const Text(
          '운동 보조',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ImageCard(
              title: '오늘의\n프로그램',
              imagePath: 'assets/images/program.jpg',
              onTap: () {
                // 라우트 이름을 사용하여 이동
                Navigator.pushNamed(context, '/workout_program');
              },
            ),
            const SizedBox(height: 16),
            ImageCard(
              title: '단일 운동',
              imagePath: 'assets/images/single_workout.jpg',
              onTap: () {
                Navigator.pushNamed(context, '/single_exercise_list');
              },
            ),
            const SizedBox(height: 16),
            QrCard(
              onTap: () {
                Navigator.pushNamed(context, '/qr_scanner');
              },
            ),
            const SizedBox(height: 16),
            ImageCard(
              title: '부위별\n상태',
              imagePath: 'assets/images/body_part.jpg',
              onTap: () {
                Navigator.pushNamed(context, '/muscle_condition');
              },
            ),
          ],
        ),
      ),
    );
  }
}