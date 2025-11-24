import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // 파일 저장을 위해 추가
import 'package:shared_preferences/shared_preferences.dart'; // 경로 저장을 위해 추가
// File 사용을 위해 추가
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가

// Provider import
import 'providers/nav_provider.dart';

// 화면 import
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
import 'screens/workout/program_builder_screen.dart';
import 'screens/workout/save_program_screen.dart';
import 'screens/workout/program_detail_screen.dart';
import 'screens/body_log/compare_result_screen.dart';
// ✅ 누락되었던 import 추가
import 'screens/home/personal_info.dart';
import 'screens/home/preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
        fontFamily: 'Pretendard',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/': (context) => const AppShell(),
        '/food_diary': (context) => const FoodDiaryScreen(),
        // ⚠️ 이 경로는 이제 사용되지 않지만, 다른 곳에서 호출될까봐 유지합니다.
        '/activity_analysis': (context) => const ActivityAnalysisScreen(),
        '/workout_program': (context) => const WorkoutProgramScreen(),
        '/workout_reps': (context) => const WorkoutRepsScreen(),
        '/muscle_condition': (context) => const MuscleConditionScreen(),
        '/single_exercise_list': (context) => const SingleExerciseListScreen(),
        '/qr_scanner': (context) => const QrScannerScreen(),
        '/exercise_setup': (context) => const ExerciseSetupScreen(),
        '/program_builder': (context) => const ProgramBuilderScreen(),
        '/save_program': (context) => const SaveProgramScreen(),
        '/program_detail': (context) => const ProgramDetailScreen(),
        '/compare_result': (context) => const CompareResultScreen(),
        '/personal_info': (context) => const PersonalInfoScreen(),
        '/preferences': (context) => const PreferencesScreen(),
      },
    );
  }
}

// AppShell을 ConsumerStatefulWidget으로 유지 (뒤로가기 기능 필수!)
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const List<Widget> _tabScreens = <Widget>[
    FoodDiaryScreen(),
    ActivityAnalysisScreen(),
    SizedBox.shrink(),
    WorkoutHubScreen(),
    BodyLogScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) return;
    // setState가 아닌 ref를 사용하여 상태 변경
    ref.read(navIndexProvider.notifier).state = index;
  }

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

  Future<void> _pickImage(ImageSource source, String type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      if (type == 'food') {
        print('Food image path: ${image.path}');
        if (mounted) {
          // ✅ 수정된 로직: FoodAnalysisScreen에 XFile image 객체를 직접 전달
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodAnalysisScreen(image: image),
            ),
          );
        }
      } else if (type == 'body') {
        // 눈바디 사진 저장 로직 유지
        await _saveBodyImage(image);
        print('Body image saved: ${image.path}');

        // 저장 후 눈바디 탭(인덱스 4)으로 이동
        ref.read(navIndexProvider.notifier).state = 4;
      }
    }
  }

  // 이미지를 로컬 저장소에 저장하고 경로를 SharedPref에 기록하는 함수
  Future<void> _saveBodyImage(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String savedPath = '${directory.path}/$fileName';

    // 1. 파일 저장
    await image.saveTo(savedPath);

    // 2. 경로 및 날짜 정보 저장 (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    List<String> savedImages = prefs.getStringList('body_images') ?? [];

    // "경로|날짜 시간" 형식으로 저장
    String dateStr = DateFormat('yyyy년 MM월 dd일 HH:mm').format(DateTime.now());
    savedImages.add('$savedPath|$dateStr');

    await prefs.setStringList('body_images', savedImages);
  }

  @override
  Widget build(BuildContext context) {
    // Provider의 값을 구독하여 현재 인덱스를 가져옵니다.
    final selectedIndex = ref.watch(navIndexProvider);

    // PopScope 유지 (뒤로가기 시 홈으로 이동)
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (selectedIndex != -1) {
          ref.read(navIndexProvider.notifier).state = -1;
        }
      },
      child: Scaffold(
        body: Center(
          child: selectedIndex == -1
              ? const MainScreen()
              : _tabScreens.elementAt(selectedIndex),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onCameraTapped,
          backgroundColor: Colors.black,
          elevation: 2.0,
          shape: const CircleBorder(),
          child: const Icon(Icons.camera_alt, color: Colors.white),
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
                _buildNavItem(Icons.restaurant, 0, selectedIndex),
                _buildNavItem(Icons.directions_run, 1, selectedIndex),
                const SizedBox(width: 40),
                _buildNavItem(Icons.fitness_center, 3, selectedIndex),
                _buildNavItem(Icons.accessibility_new, 4, selectedIndex),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, int currentIndex) {
    final bool isSelected = currentIndex == index;
    return Expanded(
      child: IconButton(
        icon: Icon(icon),
        color: isSelected ? Colors.black : Colors.grey,
        onPressed: () => _onItemTapped(index),
      ),
    );
  }
}