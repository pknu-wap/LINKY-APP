import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/main.dart';
import 'package:std/services/auth_service.dart';
import 'package:std/snackbar.dart';
import 'package:std/constants.dart';

class SecretGuardWrapper extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  const SecretGuardWrapper({
    super.key,
    required this.child,
    this.isSelected = false,
  });

  @override
  State<SecretGuardWrapper> createState() => _SecretGuardWrapperState();
}

class _SecretGuardWrapperState extends State<SecretGuardWrapper>
    with WidgetsBindingObserver {
  bool _isLocked = true;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 라이프사이클 감지 시작

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryUnlock();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 감지 종료
    pwController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SecretGuardWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isSelected != widget.isSelected) {
      _isAuthenticating = false;
    }

    if (!oldWidget.isSelected && widget.isSelected) {
      setState(() {
        _isLocked = true;
        pwController.clear();
      });

      if (lockWith == LockWith.localAuth) {
        _tryUnlock();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      setState(() => _isLocked = true);
    } else if (state == AppLifecycleState.resumed) {
      if (widget.isSelected &&
          _isLocked &&
          lockWith == LockWith.localAuth &&
          !_isAuthenticating) {
        _tryUnlock();
      }
    }
  }

  Future<void> _tryUnlock() async {
    if (_isAuthenticating || !_isLocked || !widget.isSelected) return;

    _isAuthenticating = true;
    bool authenticated = false;
    try {
      if (lockWith == LockWith.customPw) {
        authenticated = PwAuthService.authenticate(pwController.text);
      } else if (lockWith == LockWith.localAuth) {
        bool isAvailable = await LocalAuthService.checkAvailable();
        if (!mounted || !widget.isSelected) return;

        if (isAvailable) {
          authenticated = await LocalAuthService.authenticate();
        } else {
          showCustomSnackBar(
            context,
            message: '기기에 등록된 보안 설정이 없습니다.',
            isError: true,
          );
        }
      }

      if (!mounted || !widget.isSelected) return;

      if (authenticated) {
        setState(() {
          _isLocked = false;
        });
      } else {
        if (lockWith == LockWith.customPw) {
          showCustomSnackBar(context, message: '잘못된 비밀번호입니다', isError: true);
        }
      }
    } catch (e) {
      showCustomSnackBar(context, message: '에러 발생: $e', isError: true);
    }
  }

  final pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          widget.child, // 실제 앱 콘텐츠

          if (_isLocked && lockWith == LockWith.customPw)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                          width: screenSize.width * 0.9,
                          height: 44,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              textSelectionTheme: TextSelectionThemeData(
                                cursorColor: AppColors.mainGreen,
                                selectionColor: AppColors.mainGreen.withValues(
                                  alpha: 0.3,
                                ),
                                selectionHandleColor: AppColors.mainGreen,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                              ),
                              child: TextField(
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                obscureText: true,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.outlineGrey,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.outlineGrey,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.mainGreen,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                style: TextStyle(fontSize: 16),
                                controller: pwController,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        InkWell(
                          onTap: () {
                            _isAuthenticating = false;
                            _tryUnlock();
                          },
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
                              style: GoogleFonts.inter(
                                color: AppColors.mainRed,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_isLocked && lockWith == LockWith.localAuth)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: const Color.from(
                  alpha: 1,
                  red: 0,
                  green: 0,
                  blue: 0,
                ).withValues(alpha: 0.1),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _isAuthenticating = false;
                      _tryUnlock();
                    },
                    child: Container(
                      width: screenSize.width * 0.3,
                      height: screenSize.width * 0.3,
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineGrey),
                      ),
                      child: Center(
                        child: const Icon(
                          Icons.lock_outline,
                          color: AppColors.bottNavTextGrey,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_isLocked && lockWith == null)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: AppColors.black.withValues(alpha: 0.1),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 100,
                        color: AppColors.bottNavTextGrey,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '설정에서 잠금방식을\n먼저 설정해주세요!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  //     child: Container(
                  //       width: screenSize.width * 0.65,
                  //       height: 260,
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(40),
                  //         border: Border.all(
                  //           color: AppColors.outlineGrey,
                  //           width: 1,
                  //         ),
                  //         color: AppColors.white,
                  //       ),
                  //       child: Center(
                  //         child: Column(
                  //           mainAxisSize: MainAxisSize.min,
                  //           children: [
                  //             Icon(
                  //               Icons.lock_outline_rounded,
                  //               color: AppColors.textGrey,
                  //               size: 80,
                  //             ),
                  //             SizedBox(height: 10),
                  //             Text(
                  //               '잠금방식 설정 필요',
                  //               style: GoogleFonts.inter(fontSize: 23),
                  //             ),
                  //             Text(
                  //               '설정에서 잠금방식을 선택해주세요',
                  //               style: GoogleFonts.inter(fontSize: 13.5),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
