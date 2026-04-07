import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:std/services/auth_service_with_password.dart';

class SecretGuardWrapperPw extends StatefulWidget {
  final Widget child;
  const SecretGuardWrapperPw({super.key, required this.child});

  @override
  State<SecretGuardWrapperPw> createState() => _SecretGuardWrapperState();
}

class _SecretGuardWrapperState extends State<SecretGuardWrapperPw>
    with WidgetsBindingObserver {
  bool _isLocked = true; // 처음 진입 시 잠금 상태

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 라이프사이클 감지 시작
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

  Future<void> _tryUnlock(String inputPassword) async {
    // bool authenticated = await AuthService.authenticate();
    bool authenticated = AuthWithPW.authenticate(inputPassword);
    if (authenticated) {
      setState(() => _isLocked = false);
    } else {
      print('Password did not matched');
    }
  }

  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child, // 실제 앱 콘텐츠

        if (_isLocked) // 잠금 상태일 때만 덮어씌움
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 배경 블러 처리
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
              child: Center(
                child: Container(
                  width: 362,
                  height: 186,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(color: Colors.black, width: 1),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 25),
                      const Text(
                        "비밀번호 입력",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 21),
                      SizedBox(
                        width: 293,
                        height: 44,
                        child: TextField(
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          obscureText: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(fontSize: 16),
                          controller: myController,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _tryUnlock(myController.text),
                        child: const Text("확인"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
