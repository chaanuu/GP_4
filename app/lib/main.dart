import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'screens/auth/sign_in_screen.dart';
import 'screens/home/main_screen.dart';
import 'screens/activity/activity_analysis_screen.dart';
import 'screens/food/food_diary_screen.dart';
import 'screens/food/food_analysis_screen.dart';
import 'screens/workout/workout_hub_screen.dart';
import 'screens/workout/workout_program_screen.dart';
import 'screens/workout/workout_reps_screen.dart';
import 'screens/workout/muscle_condition_screen.dart';
import 'screens/workout/single_exercise_list_screen.dart';
import 'screens/workout/qr_scanner_screen.dart';
import 'screens/body_log/body_log_screen.dart';
import 'screens/workout/exercise_setup_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/workout/program_builder_screen.dart';
import 'screens/workout/save_program_screen.dart';
import 'screens/workout/program_detail_screen.dart';
import 'screens/home/personal_info.dart';
import 'screens/home/preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard', // TODO: Pretendard 폰트 추가 후 적용
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/signin', // 앱 시작 시 로그인 화면부터
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/': (context) => const AppShell(), // 로그인 성공 후 AppShell로 이동
        '/food_diary': (context) => const FoodDiaryScreen(),
        '/food_analysis': (context) => const FoodAnalysisScreen(),
        '/workout_program': (context) => const WorkoutProgramScreen(),
        '/workout_reps': (context) => const WorkoutRepsScreen(),
        '/muscle_condition': (context) => const MuscleConditionScreen(),
        '/single_exercise_list': (context) => const SingleExerciseListScreen(),
        '/qr_scanner': (context) => const QrScannerScreen(),
        '/exercise_setup': (context) => const ExerciseSetupScreen(),
        '/workout_program': (context) => const WorkoutProgramScreen(),
        '/program_builder': (context) => const ProgramBuilderScreen(),
        '/save_program': (context) => const SaveProgramScreen(),
        '/program_detail': (context) => const ProgramDetailScreen(),
        '/personal_info': (context) => const PersonalInfoScreen(),
        '/preferences': (context) => const PreferencesScreen(),
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // -1은 초기 상태 (MainScreen)를 나타냅니다. 0부터는 탭 인덱스를 의미
  int _selectedIndex = -1;

  // 하단 네비게이션 바 아이콘 순서에 맞게 페이지를 매핑
  static const List<Widget> _tabScreens = <Widget>[
    FoodDiaryScreen(),        // Index 0: '식사' (restaurant icon)
    ActivityAnalysisScreen(), // Index 1: '활동' (run icon)
    SizedBox.shrink(),        // Index 2: 카메라 버튼 (FAB) - 이 인덱스는 건너뜀
    WorkoutHubScreen(),       // Index 3: '운동' (weight icon)
    BodyLogScreen(),          // Index 4: '눈바디' (person icon)
  ];

  // 탭 아이템 클릭 시 호출
  void _onItemTapped(int index) {
    if (index == 2) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  // 카메라 아이콘 클릭 시 동작
  void _onCameraTapped() {
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
                  _pickImage(ImageSource.camera, 'food');
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('눈바디 사진 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, 'body');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 이미지 피커 로직
  Future<void> _pickImage(ImageSource source, String type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      if (type == 'food') {
        // TODO: 찍은 음식 사진을 백엔드로 전송하고 분석 페이지로 이동
        print('Food image path: ${image.path}');
        Navigator.pushNamed(context, '/food_analysis' /*, arguments: image */);
      } else if (type == 'body') {
        // TODO: 찍은 눈바디 사진을 로컬에 저장
        print('Body image path: ${image.path}');
        // local_storage_service.saveImage(image);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // _selectedIndex가 -1이면 MainScreen을, 아니면 선택된 탭 화면을 보여줌
        child: _selectedIndex == -1
            ? const MainScreen()
            : _tabScreens.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCameraTapped,
        backgroundColor: Colors.black,
        child: const Icon(Icons.camera_alt, color: Colors.white),
        elevation: 2.0,
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // '식사' 탭
              _buildNavItem(Icons.restaurant, 0),
              // '활동' 탭
              _buildNavItem(Icons.directions_run, 1),
              // FAB 공간
              const SizedBox(width: 40),
              // '운동' 탭
              _buildNavItem(Icons.fitness_center, 3),
              // '눈바디' 탭
              _buildNavItem(Icons.accessibility_new, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    // _selectedIndex와 현재 탭의 index가 정확히 일치할 때만 선택된 것으로 처리
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: IconButton(
        icon: Icon(icon),
        color: isSelected ? Colors.black : Colors.grey,
        onPressed: () => _onItemTapped(index),
      ),
    );
  }
}