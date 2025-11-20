import 'package:flutter_riverpod/flutter_riverpod.dart';

// 현재 선택된 탭의 인덱스를 관리합니다.
// -1: 홈 화면 (MainScreen)
// 0: 식단, 1: 활동, 3: 운동, 4: 눈바디
final navIndexProvider = StateProvider<int>((ref) => -1);