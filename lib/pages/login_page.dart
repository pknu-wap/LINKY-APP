import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool keepLogin = false;
  final dio = Dio(
    BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 5),
  ),
  );
  final storage = const FlutterSecureStorage();

Future<void> handleKakaoLogin() async {
  try {
    debugPrint('1. 카카오 로그인 버튼 클릭');

    final installed = await isKakaoTalkInstalled();
    debugPrint('2. 카카오톡 설치 여부: $installed');

    if (!installed) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카카오톡이 설치되어 있지 않습니다.')),
      );
      return;
    }

    final kakaoToken = await UserApi.instance.loginWithKakaoTalk();
    debugPrint('3. 카카오 로그인 성공');

    //await sendKakaoTokenToBackend(kakaoToken.accessToken); //테스트 진행시에는 이 코드 주석 처리하고 진행
    debugPrint('4. 백엔드 전송 성공');

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
    debugPrint('5. 메인 이동');
  } catch (error) {
    debugPrint('카카오 로그인/백엔드 전송 실패: $error');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('카카오 로그인 실패: $error')),
    );
  }
}

Future<void> sendKakaoTokenToBackend(String kakaoAccessToken) async {
  try {
    debugPrint('백엔드 요청 시작');

    final response = await dio.post(
      'http://172.20.10.2:8081/auth/kakao',
      data: {
        'accessToken': kakaoAccessToken,
      },
    );

    final responseData = response.data;

    // ApiResponse로 감싸져 있으면 data 안에 token이 있음
    final token = responseData['data']?['token'] ?? responseData['token'];

    if (token == null) {
      throw Exception('백엔드 응답에 token이 없습니다: $responseData');
    }

    await storage.write(key: 'accessToken', value: token);
  } on DioException catch (e) {
    debugPrint('백엔드 요청 실패');
    debugPrint('상태 코드: ${e.response?.statusCode}');
    debugPrint('응답 데이터: ${e.response?.data}');
    debugPrint('에러 메시지: ${e.message}');
    rethrow;
  } catch (e){
    debugPrint('백엔드 응답 처리 실패: $e');
    rethrow;
  }
}

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0XFF2CD456),
        body: Column(
          children: [
            Container(height: topInset, color: Colors.white),
            
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 54,
                    child: Header(),
                  ),
                  
                  Expanded(
                    flex: 46,
                    child: ActionArea(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget Header() {
    return Stack(
      children: [
        ClipPath(
          clipper: WhiteCircle(),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
        ),
        ClipPath(
          clipper: WhiteCircle(),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: Center(
              child: Image.asset(
                'assets/images/linky_logo.png',
                width: 180,
                height: 180,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget ActionArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '시작하기 위해 로그인하기',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          socialButton(
            label: '카카오로 계속하기',
            onPressed: handleKakaoLogin,
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget socialButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/kakao_logo.png', width: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class WhiteCircle extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}