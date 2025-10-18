/*import 'dart:convert'; // json 처리를 위해 import
import 'package:http/http.dart' as http; // http 패키지 import
import '../models/workout_program.dart';

class ApiService {
  // TODO: 나중에 실제 서버 주소로 변경하세요.
  final String _baseUrl = 'https://your-api-server.com';

  // [GET] 모든 운동 프로그램을 서버에서 가져오는 함수
  Future<List<WorkoutProgram>> getPrograms() async {
    // --- 나중에 이 부분을 실제 HTTP 요청으로 교체 ---
    // final response = await http.get(Uri.parse('$_baseUrl/programs'));
    // if (response.statusCode == 200) {
    //   final List<dynamic> data = jsonDecode(response.body);
    //   return data.map((json) => WorkoutProgram.fromJson(json)).toList();
    // } else {
    //   throw Exception('프로그램을 불러오는데 실패했습니다.');
    // }
    // ---------------------------------------------

    // 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));
    print("ApiService: 서버에서 프로그램 목록을 가져옵니다 (시뮬레이션).");
    return []; // 처음에는 비어있는 리스트를 반환
  }

  // [POST] 새로운 운동 프로그램을 서버에 저장하는 함수
  Future<WorkoutProgram> createProgram(WorkoutProgram program) async {
    // --- 나중에 이 부분을 실제 HTTP 요청으로 교체 ---
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/programs'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(program.toJson()),
    // );
    // if (response.statusCode == 201) {
    //   return WorkoutProgram.fromJson(jsonDecode(response.body));
    // } else {
    //   throw Exception('프로그램을 저장하는데 실패했습니다.');
    // }
    // ---------------------------------------------

    // 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));
    print("ApiService: 새 프로그램을 서버에 저장합니다 (시뮬레이션).");
    return program;
  }
}
*/

//임시 가짜 데이터베이스

import '../models/workout_program.dart';

class ApiService {
  // ✅ 1. 가짜 데이터베이스 역할을 할 리스트를 클래스 내부에 생성합니다.
  final List<WorkoutProgram> _fakeDatabase = [];

  // TODO: 나중에 실제 서버 주소로 변경하세요.
  final String _baseUrl = 'https://your-api-server.com';

  // [GET] 모든 운동 프로그램을 서버에서 가져오는 함수
  Future<List<WorkoutProgram>> getPrograms() async {
    // --- 나중에 이 부분을 실제 HTTP 요청으로 교체 ---

    // 지금은 1초 후 가짜 데이터베이스의 내용을 반환합니다.
    await Future.delayed(const Duration(seconds: 1));
    print("ApiService: 서버에서 프로그램 목록을 가져옵니다 (현재 ${_fakeDatabase.length}개).");
    // ✅ 2. 비어있는 리스트 대신, _fakeDatabase를 반환합니다.
    return _fakeDatabase;
  }

  // [POST] 새로운 운동 프로그램을 서버에 저장하는 함수
  Future<WorkoutProgram> createProgram(WorkoutProgram program) async {
    // --- 나중에 이 부분을 실제 HTTP 요청으로 교체 ---

    // 지금은 받은 프로그램을 가짜 데이터베이스에 추가하고 다시 반환합니다.
    await Future.delayed(const Duration(milliseconds: 500));
    print("ApiService: 새 프로그램을 서버에 저장합니다.");
    // ✅ 3. _fakeDatabase 리스트에 새로운 프로그램을 추가합니다.
    _fakeDatabase.add(program);
    return program;
  }
}