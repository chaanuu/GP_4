import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // SVG 사용 시 필요

// 1. StatefulWidget으로 변경
class SignInScreen extends StatefulWidget {
  static const routeName = '/signIn';
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // 인스턴스 초기화 (StatefulWidget의 State 내부에서 관리)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // GoogleSignIn() 생성자에 const 키워드를 사용하지 않습니다.
  late final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 2. Google 로그인 처리 함수 구현
  Future<void> _signInWithGoogle() async {
    // 로딩 상태 표시 등 UI 처리를 이전에 추가할 수 있습니다.

    try {
      // 1) Google 인증 흐름 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // 사용자가 취소했을 경우

      // 2) Google 계정 인증 정보 (토큰) 획득
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3) Firebase가 이해할 수 있는 자격 증명(Credential) 생성
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4) Firebase에 로그인하여 인증 완료
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 로그인 성공! 메인 화면으로 이동
        if (mounted) {
          // 화면 전환 시 애니메이션 없이 (혹은 원하는 애니메이션으로) 메인 화면으로 대체
          // '/'(메인) 경로가 반드시 main.dart에 정의되어 있어야 합니다.
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } catch (e) {
      debugPrint("Google 로그인 오류: $e");
      // 로그인 실패 시 사용자에게 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google 로그인에 실패했습니다. Firebase 설정을 확인해 주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(flex: 2),
              const Text(
                '앱 이름',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              const Text(
                '계정 만들기',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '이 앱에 가입하려면 이메일을 입력하세요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'email@domain.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    // BorderSide(color: Colors.grey[300]!)는 Non-Nullable 경고를 피하기 위해 제거했습니다.
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: 이메일/비밀번호 로그인 또는 회원가입 로직 구현
                  Navigator.pushReplacementNamed(context, '/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('계속', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('또는', style: TextStyle(color: Colors.grey[600])),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              // Google 로그인 버튼에 로직 연결
              _buildSocialButton(
                text: 'Google 계정으로 계속하기',
                // iconPath: 'assets/icons/google.svg',
                onPressed: _signInWithGoogle, // Google 로그인 함수 연결
              ),
              const SizedBox(height: 12),
              _buildSocialButton(
                text: 'Apple 계정으로 계속하기',
                // iconPath: 'assets/icons/apple.svg',
                onPressed: () {
                  // TODO: Apple 로그인 로직 구현
                },
              ),
              const Spacer(flex: 1),
              Text(
                '계속을 클릭하면 당사의 서비스 이용 약관 및 개인정보 처리방침에 동의하는 것으로 간주합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  // Social Button UI를 위한 함수
  Widget _buildSocialButton({required String text, required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        // BorderSide는 const가 될 수 없으므로 const 키워드를 사용하지 않습니다.
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SvgPicture.asset(iconPath, height: 20), // SVG 아이콘을 사용하려면 flutter_svg 패키지 필요
          // const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.black, fontSize: 16)),
        ],
      ),
    );
  }
}