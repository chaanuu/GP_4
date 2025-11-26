import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';   // ⭐ 추가됨 (중요)

import 'providers/nav_provider.dart';

// 화면 import
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/splash_screen.dart';

import 'screens/home/main_screen.dart';
import 'screens/home/personal_info.dart';
import 'screens/home/preferences.dart';

import 'screens/activity/activity_analysis_screen.dart';
import 'screens/food/food_diary_screen.dart';
import 'screens/food/food_analysis_screen.dart';

import 'screens/workout/workout_hub_screen.dart';
import 'screens/workout/workout_program_screen.dart';
import 'screens/workout/workout_reps_screen.dart';
import 'screens/workout/muscle_condition_screen.dart';
import 'screens/workout/single_exercise_list_screen.dart';
import 'screens/workout/qr_scanner_screen.dart';
import 'screens/workout/exercise_setup_screen.dart';
import 'screens/workout/program_builder_screen.dart';
import 'screens/workout/save_program_screen.dart';
import 'screens/workout/program_detail_screen.dart';
import 'screens/workout/exercise_setup_program.dart';

import 'screens/body_log/body_log_screen.dart';
import 'screens/body_log/compare_result_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  한국어 날짜/요일 표시를 위해 필수 (에러 해결)
  await initializeDateFormatting('ko_KR', null);

  // 환경 변수 로드 (.env)
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealFit',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),

        '/': (context) => const AppShell(),
        '/food_diary': (context) => const FoodDiaryScreen(),
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
        '/exercise_setup_program': (context) => ExerciseSetupProgramScreen(),
        '/workout_hub' : (context) => WorkoutHubScreen(),
        '/muscle_status': (context) => const MuscleConditionScreen(),

      },
    );
  }
}

// =====================
// 앱 전체 탭 구조
// =====================
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
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodAnalysisScreen(image: image),
            ),
          );
        }
      } else if (type == 'body') {
        await _saveBodyImage(image);
        ref.read(navIndexProvider.notifier).state = 4;
      }
    }
  }

  Future<void> _saveBodyImage(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String savedPath = '${directory.path}/$fileName';

    await image.saveTo(savedPath);

    final prefs = await SharedPreferences.getInstance();
    List<String> savedImages = prefs.getStringList('body_images') ?? [];

    String dateStr =
    DateFormat('yyyy년 MM월 dd일 HH:mm', 'ko_KR').format(DateTime.now());
    savedImages.add('$savedPath|$dateStr');

    await prefs.setStringList('body_images', savedImages);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navIndexProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop && selectedIndex != -1) {
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
