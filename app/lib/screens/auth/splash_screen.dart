import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // 1초 정도 로딩 표시
    await Future.delayed(const Duration(milliseconds: 700));

    if (token != null) {
      // 자동 로그인 → 메인 화면 이동
      Navigator.pushReplacementNamed(context, '/');
    } else {
      // 토큰 없음 → 로그인 화면 이동
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
