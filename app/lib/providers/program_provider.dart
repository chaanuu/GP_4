import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_program.dart';
import '../services/api_service.dart';

// 현재 만들고 있는 프로그램의 상태를 정의
class ProgramBuilderState {
  final List<WorkoutExercise> exercises;
  ProgramBuilderState({this.exercises = const []});
}

// 상태를 관리하고 업데이트하는 Notifier
class ProgramBuilderNotifier extends StateNotifier<ProgramBuilderState> {
  ProgramBuilderNotifier() : super(ProgramBuilderState());

  // 리스트에 운동 추가
  void addExercise(WorkoutExercise exercise) {
    state = ProgramBuilderState(exercises: [...state.exercises, exercise]);
  }

  // 프로그램 생성이 완료되면 리스트 비우기
  void clear() {
    state = ProgramBuilderState();
  }
}

// 앱의 어디에서든 접근할 수 있도록 provider를 전역으로 생성
final programBuilderProvider = StateNotifierProvider<ProgramBuilderNotifier, ProgramBuilderState>(
      (ref) => ProgramBuilderNotifier(),
);

// ApiService 인스턴스를 제공하는 Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// 서버에서 프로그램 목록을 가져오는 FutureProvider
final programsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  //  우리가 ApiService에 만든 서버용 메서드
  return await api.getProgramList();
});