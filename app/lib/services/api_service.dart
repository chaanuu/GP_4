import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_program.dart';

class ApiService {
  // Docker 실행 시 외부 포트 8000번 사용
  static const String _baseUrl = 'http://jyb1018.iptime.org:3000';
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  // 운동 프로그램은 앱 내부에서만 관리 (가짜 DB)
  // 백엔드에는 '프로그램' 자체를 저장하는 API가 없으므로 앱 내부에 저장합니다.
  final List<WorkoutProgram> _fakeDatabase = [];

  // ------------------------------------------------------------------------
  // 운동 프로그램 (Local - 앱 내부 관리)
  // ------------------------------------------------------------------------

  Future<List<WorkoutProgram>> getPrograms() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _fakeDatabase;
  }

  Future<WorkoutProgram> createProgram(WorkoutProgram program) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _fakeDatabase.add(program);
    return program;
  }

  // ------------------------------------------------------------------------
  // 인증 (Auth) - 경로: /auth/...
  // ------------------------------------------------------------------------

  Future<bool> login(String email, String password) async {
    try {
      // 경로: app.js에서 app.use('/auth', authRouter)
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 토큰 파싱 로직
        final tokenData = data['token'];
        String? accessToken;

        if (tokenData is Map) {
          accessToken = tokenData['accessToken'];
        } else if (tokenData is String) {
          accessToken = tokenData;
        }

        if (accessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, accessToken);

          final userId = _getUserIdFromToken(accessToken);
          if (userId != null) {
            await prefs.setInt(_userIdKey, userId);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      print('로그인 에러: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('회원가입 에러: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    try {
      await http.post(Uri.parse('$_baseUrl/auth/logout'));
    } catch (_) {}
  }

  // ------------------------------------------------------------------------
  // 사용자 (User) - 경로: /api/user/...
  // ------------------------------------------------------------------------

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();
      if (userId == null) return null;

      // 경로: app.js에서 app.use('/api', router) -> router.use('/user', userRouter)
      final response = await http.get(
        Uri.parse('$_baseUrl/api/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('유저 정보 로드 에러: $e');
    }
    return null;
  }

  Future<bool> updateUserInfo(
      String name, {
        double? height,
        double? weight,
        int? age,
        String? gender,
        String? password,
      }) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();
      if (userId == null) return false;

      final Map<String, dynamic> body = {
        'name': name,
        'height': height,
        'weight': weight,
        'age': age,
        'gender': gender,
      };

      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/api/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('유저 정보 수정 에러: $e');
      return false;
    }
  }

  // ------------------------------------------------------------------------
  // 4️음식 & 운동 기록 - 경로: /api/food, /api/exercise/log
  // ------------------------------------------------------------------------

  Future<Map<String, dynamic>?> analyzeFood(String imagePath) async {
    try {
      final token = await _getToken();
      // 경로: Food.js
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/food/img_anlysis'));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('음식 분석 에러: $e');
    }
    return null;
  }

  // 운동 수행 기록 저장
  Future<bool> saveExerciseLog(WorkoutExercise exercise, DateTime date) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();
      if (userId == null) return false;

      final body = {
        'userId': userId,
        // TODO: 현재는 임시 ID(1)를 보냅니다. 나중에 운동 이름으로 ID를 찾는 로직이 필요
        'exerciseId': 1,
        'reps': exercise.reps,
        'sets': exercise.sets,
        'dateExecuted': date.toIso8601String(),
        'durationMinutes': 0, // 필요시 추가
        'caloriesBurned': 0,  // 필요시 추가
      };

      // 경로: app.js -> /api/exercise/log
      final response = await http.post(
        Uri.parse('$_baseUrl/api/exercise/log'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('운동 기록 저장 에러: $e');
      return false;
    }
  }

  // ------------------------------------------------------------------------
  // 유틸리티
  // ------------------------------------------------------------------------

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  int? _getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(resp);

      if (payloadMap is Map<String, dynamic> && payloadMap.containsKey('userId')) {
        return payloadMap['userId'];
      }
    } catch (e) {
      print('토큰 디코딩 에러: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> comparePhysique(String beforePath, String afterPath) async {
    try {
      final token = await _getToken();

      //백엔드 라우터 경로 확인 필요
      // (PhysiqueChange.js 라우터가 app.js에 '/api/physique'로 연결되었다고 가정)
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/physique/compare'));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // 파일 2개를 첨부합니다. 필드명('before', 'after')은 백엔드 multer 설정과 같아야 합니다.
      request.files.add(await http.MultipartFile.fromPath('before', beforePath));
      request.files.add(await http.MultipartFile.fromPath('after', afterPath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // 성공 시 분석 결과 반환 (예: { "waist": -2.0, "thigh": +0.5, ... })
        return jsonDecode(response.body);
      } else {
        print('눈바디 분석 실패: ${response.body}');
        return null;
      }
    } catch (e) {
      print('눈바디 분석 에러: $e');
      return null;
    }
  }
}