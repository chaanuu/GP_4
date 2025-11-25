import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 백그라운드 서비스 초기화 함수
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
      autoStart: true,
    ),
  );
  service.startService();
}

// iOS 백그라운드 설정
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// 서비스가 시작될 때 호출되는 메인 함수
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // 걸음 수 스트림 초기화
  late Stream<StepCount> stepCountStream;
  late StreamSubscription<StepCount> stepCountSubscription;

  stepCountStream = Pedometer.stepCountStream;
  stepCountSubscription = stepCountStream.listen(_onStepCount);

  print("백그라운드 걸음 수 감지를 시작합니다.");

  // 서비스가 활성화되어 있는 동안 계속 실행
  Timer.periodic(const Duration(seconds: 30), (timer) {
    print("Background service is running...");
  });
}

// 걸음 수가 감지될 때마다 호출되는 함수
void _onStepCount(StepCount event) async {
  print("걸음 수 감지: ${event.steps}");
  final prefs = await SharedPreferences.getInstance();
  // 'total_steps'라는 키로 걸음 수를 저장합니다.
  await prefs.setInt('total_steps', event.steps);
}