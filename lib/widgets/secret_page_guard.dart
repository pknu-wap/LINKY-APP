import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/services/auth_service.dart';
import 'package:std/widgets/public_messagebox.dart';
import 'package:std/constants.dart';

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
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return DialogPopup(
            title: '잘못된 비밀번호입니다',
            boxType: BoxType.alert,
            onConfirm: () {},
            confirmText: '확인',
          );
        },
      );
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
              color: AppColors.black.withValues(alpha: 0.1),
              child: Center(
                child: Container(
                  width: 362,
                  height: 186,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(color: AppColors.black, width: 1),
                    color: AppColors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 25),
                      const Text(
                        "비밀번호 입력",
                        style: TextStyle(
                          color: AppColors.black,
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
                      const SizedBox(height: 13),
                      InkWell(
                        onTap: () => _tryUnlock(myController.text),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(19.5),
                            border: Border.all(
                              color: AppColors.outlineGrey,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            '확인',
                            style: GoogleFonts.inter(color: AppColors.mainRed),
                          ),
                        ),
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
