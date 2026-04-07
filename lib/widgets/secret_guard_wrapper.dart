import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SecretGuardWrapper extends StatefulWidget {
  final Widget child;
  const SecretGuardWrapper({super.key, required this.child});

  @override
  State<SecretGuardWrapper> createState() => _SecretGuardWrapperState();
}

class _SecretGuardWrapperState extends State<SecretGuardWrapper>
    with WidgetsBindingObserver {
  bool _isLocked = true; // 처음 진입 시 잠금 상태

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 라이프사이클 감지 시작
    _tryUnlock(); // 초기 인증 시도
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 감지 종료
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 화면에서 사라질 때 (홈 버튼, 다른 앱 전환 등)
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      setState(() => _isLocked = true);
    }
  }

  Future<void> _tryUnlock() async {
    bool authenticated = await AuthService.authenticate();
    if (authenticated) {
      setState(() => _isLocked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child, // 실제 앱 콘텐츠

        if (_isLocked) // 잠금 상태일 때만 덮어씌움
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // 배경 블러 처리
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, color: Colors.white, size: 100),
                    const SizedBox(height: 30),
                    const Text(
                      "시크릿 모드 보호 중",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _tryUnlock,
                      child: const Text("인증하고 열기"),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
