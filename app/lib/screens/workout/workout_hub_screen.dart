import 'package:flutter/material.dart';

// 분리한 위젯들을 import 합니다.
import 'package:app/widgets/image_card.dart';
import 'package:app/widgets/qr_card.dart';

// 네비게이션 할 페이지들을 import 합니다.
import './workout_program_screen.dart';
import './muscle_condition_screen.dart';
import './single_exercise_list_screen.dart'; // 이전에 만든 빈 페이지
import './qr_scanner_screen.dart'; // 이전에 만든 빈 페이지

class WorkoutHubScreen extends StatelessWidget {
  const WorkoutHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 보조', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 홈 탭이므로 뒤로가기 버튼 제거
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ImageCard(
              title: '오늘의\n프로그램',
              imagePath: 'assets/images/program.png', // 이미지 경로
              onTap: () {
                Navigator.pushNamed(context, '/workout_program');
              },

            ),
            const SizedBox(height: 16),
            ImageCard(
              title: '단일 운동',
              imagePath: 'assets/images/single_workout.png', // 이미지 경로
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
              imagePath: 'assets/images/body_part.png', // 이미지 경로
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
// 이 파일 하단에 있던 QrCard 클래스 정의는 삭제되었습니다.