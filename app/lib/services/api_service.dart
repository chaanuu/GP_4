import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_program.dart';

class ApiService {
  // Docker 실행 시 외부 포트 8000번 사용
  static const String _baseUrl = 'http://jyb1018.iptime.org:3000';
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  Future<int?> createProgram(Map<String, dynamic> programData) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId(); // ⭐ 여기서 userId 가져오기

      if (userId == null) {
        print("User ID is NULL — 로그인 상태를 확인하세요.");
        return null;
      }

      // **반드시 userId 추가**
      programData["userId"] = userId;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/program'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(programData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body)['programId'];
      }
      return null;
    } catch (e) {
      print("Program create error: $e");
      return null;
    }
  }

  Future<List<dynamic>> getProgramList() async {
    final userId = await _getUserId();
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/program/user/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>?> getProgramDetail(int programId) async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/api/program/$programId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("프로그램 상세 오류: $e");
    }
    return null;
  }

  Future<bool> deleteProgram(int programId) async {
    try {
      final token = await _getToken();

      final res = await http.delete(
        Uri.parse('$_baseUrl/api/program/$programId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return res.statusCode == 204;
    } catch (e) {
      print("프로그램 삭제 오류: $e");
      return false;
    }
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

  Future<bool> saveExerciseLog(Map<String, dynamic> logData) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      if (userId == null) return false;

      logData["userId"] = userId;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/exercise/log'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(logData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("운동 기록 저장 에러: $e");
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

  // 운동 목록 불러오기 (정적 + 유저 운동 모두)
  Future<List<Map<String, dynamic>>> getAllExercises() async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      // 1) 정적 운동
      final staticRes = await http.get(
        Uri.parse('$_baseUrl/api/exercise/static'),
        headers: headers,
      );

      // 2) 유저가 만든 운동
      final userRes = await http.get(
        Uri.parse('$_baseUrl/api/exercise/user/$userId'),
        headers: headers,
      );

      if (staticRes.statusCode == 200 && userRes.statusCode == 200) {
        final List<dynamic> staticList = jsonDecode(staticRes.body);
        final List<dynamic> userList = jsonDecode(userRes.body);

        // 두 목록 병합
        return [...staticList, ...userList];
      }

      return [];
    } catch (e) {
      print('운동 목록 로드 에러: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getExerciseByCode(String code) async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/api/exercise/code/$code'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("QR 운동 조회 에러: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getWeeklyMuscleTiredness() async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();
      if (userId == null) return null;

      final now = DateTime.now();
      final endDate = now.toIso8601String().split('T').first;
      final startDate =
          now.subtract(const Duration(days: 6)).toIso8601String().split('T').first;

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/exercise/log/user/$userId/muscles/summary?startDate=$startDate&endDate=$endDate'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print(
            '근육 피로도 응답 코드: ${response.statusCode}, body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('근육 피로도 불러오기 에러: $e');
      return null;
    }
  }


}

