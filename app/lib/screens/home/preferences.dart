import 'package:flutter/material.dart';

class PreferencesScreen extends StatelessWidget {
  // const 생성자는 main.dart의 라우트 정의를 만족시킵니다.
  const PreferencesScreen({super.key});

  void _handleLogout(BuildContext context) {
    // TODO: 1. Riverpod, Provider, GetX 등을 사용하여 사용자 인증 상태 초기화
    // TODO: 2. 토큰 및 사용자 정보 삭제 (SharedPreferences/Secure Storage)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('로그아웃 되었습니다.')),
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/signin',
          (route) => false,
    );
    // TODO: 로그인 화면으로 이동 (예시: Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings', // 설정 -> Settings
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // 뒤로가기 버튼 색상
      ),
      body: ListView(
        children: <Widget>[

          // 알림 설정 스위치 예시
          SwitchListTile(
            title: const Text('Receive Push Notifications'), // 푸시 알림 수신
            value: true, // TODO: 실제 상태 값(SharedPreferences)을 로드하여 사용
            onChanged: (bool value) {
              // 상태 변경 로직
            },
            secondary: const Icon(Icons.notifications_outlined),
          ),
          const Divider(),

          // 앱 정보 항목
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About App'), // 앱 정보
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showLicensePage(
                  context: context,
                  applicationName: 'MealFit',
                  applicationVersion: '1.0.0'
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}
