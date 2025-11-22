import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _storageKey = 'user_personal_info'; // SharedPreferences에 사용할 키

// 1. 개인 정보를 담는 모델 (Data Model)
class PersonalInfo {
  final double height;
  final double weight;
  final int age;
  final String gender;

  PersonalInfo({
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
  });

  // 복사 및 JSON 변환 메서드 (기존 내용 유지)
  PersonalInfo copyWith({double? height, double? weight, int? age, String? gender}) {
    return PersonalInfo(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toJson() => {
    'height': height, 'weight': weight, 'age': age, 'gender': gender,
  };

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      height: (json['height'] as num? ?? 0.0).toDouble(),
      weight: (json['weight'] as num? ?? 0.0).toDouble(),
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? 'Male',
    );
  }
}

// 2. 상태를 관리하고 업데이트하는 Notifier
class PersonalInfoNotifier extends Notifier<PersonalInfo> {
  // 초기 상태 설정 및 비동기 로드 시작
  @override
  PersonalInfo build() {
    _loadInfo(); // ⭐️ 비동기 로드 함수 호출
    return PersonalInfo(
      height: 0.0,
      weight: 0.0,
      age: 0,
      gender: 'Male',
    );
  }

  // 1. 데이터 로드 (SharedPreferences에서 읽기)
  Future<void> _loadInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      state = PersonalInfo.fromJson(jsonMap); // 상태 업데이트
    }
  }

  // 2. 데이터 저장 (SharedPreferences에 쓰기)
  Future<void> _saveInfo(PersonalInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(info.toJson());
    await prefs.setString(_storageKey, jsonString);
  }

// 개인 정보를 업데이트하는 메서드
  void updateInfo({
    required double height,
    required double weight,
    required int age,
    required String gender,
  }) {
    state = state.copyWith(
      height: height,
      weight: weight,
      age: age,
      gender: gender,
    );
    _saveInfo(state); // ⭐️ 영구 저장 함수 호출 ⭐️
  }
}

// 위젯들이 접근할 수 있는 Provider
final personalInfoProvider = NotifierProvider<PersonalInfoNotifier, PersonalInfo>(
  PersonalInfoNotifier.new,
);