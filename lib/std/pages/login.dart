import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool keepLogin = false;

  void handleKakaoLogin() {
    Navigator.pushReplacementNamed(context, '/main');
  }

  void handleKakaoSignUp() {
    print("카카오 회원가입 시도");
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
            label: '카카오로 로그인하기',
            onPressed: handleKakaoLogin,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            '계정이 없으신가요?',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          socialButton(
            label: '카카오로 회원가입하기',
            onPressed: handleKakaoSignUp,
          ),
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

  Widget _buildKeepLoginOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 0.7,
          child: Checkbox(
            value: keepLogin,
            onChanged: (value) => setState(() => keepLogin = value ?? false),
            fillColor: WidgetStateProperty.all(Colors.white),
            checkColor: const Color(0xFF2CD456),
            side: const BorderSide(color: Colors.white, width: 1.5),  
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        Text(
          '로그인 유지하기',
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        ),
      ],
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