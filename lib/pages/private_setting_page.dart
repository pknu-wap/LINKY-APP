import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:std/constants.dart';
import 'package:std/main.dart';
import 'package:std/services/auth_service.dart';
import 'package:std/snackbar.dart';
import 'package:std/widgets/public_messagebox.dart';

class PrivateSettingPage extends StatefulWidget {
  const PrivateSettingPage({super.key});

  @override
  State<PrivateSettingPage> createState() => _PrivateSettingPageState();
}

class _PrivateSettingPageState extends State<PrivateSettingPage> {
  final pwController = TextEditingController();
  final pwCheckController = TextEditingController();
  bool _isPwEnabled = true;
  late LockWith? _localLockWith;
  bool pwChecked = false;
  bool localAuthChecked = false;

  @override
  void initState() {
    super.initState();
    _localLockWith = lockWith;
    if (customPw != null) {
      pwController.text = customPw!;
      _isPwEnabled = false;
    }
  }

  InputDecoration inputBox(String hint, {Color? fillColor}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
      filled: true,
      fillColor: fillColor ?? AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.transparent),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.transparent),
      ),
    );
  }

  @override
  void dispose() {
    pwController.dispose();
    pwCheckController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackGrey,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        '나만보기 설정',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, 2),
                      child: GestureDetector(
                        child: SizedBox(
                          width: 45,
                          height: 45,
                          child: Center(
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.textGrey,
                              size: 40,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Divider(color: AppColors.outlineGrey, height: 1.5),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.mainGreen.withValues(alpha: 0.2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.mainGreen,
                              size: 22,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "잠금 방식 설정",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          '나만보기 기능 잠금 방식을을 선택해주세요.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        if (lockWith == LockWith.localAuth) {
                          localAuthChecked =
                              await LocalAuthService.authenticate();
                          if (localAuthChecked) {
                            localAuthChecked = false;
                            setState(() {
                              _localLockWith = LockWith.customPw;
                            });
                            showCustomSnackBar(
                              context,
                              message: '잠금방식이 변경되었습니다',
                            );
                            if (customPw != null) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              lockWith = LockWith.customPw;
                              await prefs.setString(
                                'lock_method',
                                'customPw',
                              );
                              showCustomSnackBar(
                                context,
                                message: '잠금방식이 변경되었습니다',
                              );
                            }
                          }
                        } else {
                          setState(() {
                            _localLockWith = LockWith.customPw;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 62,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textGrey.withValues(
                                alpha: 0.4,
                              ),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: (_localLockWith == LockWith.customPw)
                                  ? Offset(0, 4)
                                  : Offset(0, 2),
                            ),
                          ],
                          color: (_localLockWith == LockWith.customPw)
                              ? AppColors.mainGreen.withValues(alpha: 0.7)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: (_localLockWith == LockWith.customPw)
                                ? AppColors.transparent
                                : AppColors.lightGrey,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    color: (_localLockWith == LockWith.customPw)
                                        ? AppColors.white
                                        : AppColors.textGrey,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    '비밀번호',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          (_localLockWith == LockWith.customPw)
                                          ? AppColors.white
                                          : AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.white,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_localLockWith == LockWith.customPw)
                      const SizedBox(height: 13),
                    if (_localLockWith == LockWith.customPw)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(19),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.textGrey.withValues(
                                      alpha: 0.2,
                                    ),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: pwController,
                                enabled: _isPwEnabled,
                                obscureText: true,
                                enableSuggestions: false,
                                decoration: inputBox(
                                  "비밀번호를 입력해주세요.",
                                  fillColor: _isPwEnabled
                                      ? AppColors.white
                                      : AppColors.outlineGrey.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              if (_isPwEnabled) {
                                if (pwController.text.isEmpty) {
                                  showCustomSnackBar(
                                    context,
                                    message: "비밀번호를 입력해주세요.",
                                    isError: true,
                                  );
                                } else {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  customPw = pwController.text;
                                  await prefs.setString('custom_pw', customPw!);

                                  lockWith = LockWith.customPw;
                                  await prefs.setString(
                                    'lock_method',
                                    'customPw',
                                  );

                                  setState(() {
                                    _isPwEnabled = false;
                                    FocusScope.of(context).unfocus();
                                  });
                                  if (mounted) {
                                    showCustomSnackBar(
                                      context,
                                      message: "비밀번호가 설정되었습니다.",
                                    );
                                  }
                                }
                              } else {
                                await checkCurrentPassword(context);
                                if (pwChecked) {
                                  setState(() {
                                    pwChecked = false;
                                    _isPwEnabled = true;
                                  });
                                }
                              }
                            },
                            child: Container(
                              height: 54,
                              width: 90,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.textGrey.withValues(
                                      alpha: 0.2,
                                    ),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                // border: Border.all(color: AppColors.lightGrey),
                              ),
                              child: Center(
                                child: Text(
                                  _isPwEnabled ? '설정' : '수정',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () async {
                        if (customPw != null && lockWith == LockWith.customPw) {
                          if (_isPwEnabled == true) {
                            changeLockMethodtoLocalAuth(false);
                          } else {
                            await checkCurrentPassword(context);
                            if (pwChecked) {
                              pwChecked = false;
                              changeLockMethodtoLocalAuth(false);
                            }
                          }
                        } else {
                          changeLockMethodtoLocalAuth(true);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 62,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textGrey.withValues(
                                alpha: 0.4,
                              ),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: (_localLockWith == LockWith.localAuth)
                                  ? Offset(0, 4)
                                  : Offset(0, 2),
                            ),
                          ],
                          color: (_localLockWith == LockWith.localAuth)
                              ? AppColors.mainGreen.withValues(alpha: 0.7)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: (_localLockWith == LockWith.localAuth)
                                ? AppColors.transparent
                                : AppColors.lightGrey,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.fingerprint,
                                    color:
                                        (_localLockWith == LockWith.localAuth)
                                        ? AppColors.white
                                        : AppColors.textGrey,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    '생체인식',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      color:
                                          (_localLockWith == LockWith.localAuth)
                                          ? AppColors.white
                                          : AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.white,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeLockMethodtoLocalAuth(bool isFirst) async {
    final isAvailable = await LocalAuthService.checkAvailable();
    if (isAvailable) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _localLockWith = LockWith.localAuth;
        lockWith = LockWith.localAuth;
      });
      await prefs.setString(
        'lock_method',
        'localAuth',
      );
      showCustomSnackBar(
        context,
        message: isFirst ? '잠금방식이 설정되었습니다' : '잠금방식이 변경되었습니다',
      );
    } else {
      showCustomSnackBar(
        context,
        message: '기기에 보안방식이 설정되어 있지 않습니다.',
        isError: true,
      );
    }
  }

  Future<void> checkCurrentPassword(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return DialogPopup(
          title: '기존 비밀번호 확인',
          height: 160,
          content: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: AppColors.mainGreen,
                selectionColor: AppColors.mainGreen.withValues(
                  alpha: 0.3,
                ),
                selectionHandleColor: AppColors.mainGreen,
              ),
            ),
            child: TextField(
              controller: pwCheckController,
              obscureText: true,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.only(
                  bottom: 1,
                ),
                hintText: "기존 비밀번호를 입력해주세요",
                focusedBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ),
          ),
          onConfirm: () {
            if (pwCheckController.text == customPw) {
              pwCheckController.clear();
              pwChecked = true;
              return true;
            } else {
              showCustomSnackBar(
                context,
                message: "올바르지 않은 비밀번호입니다.",
                isError: true,
              );
              pwCheckController.clear();
              return false;
            }
          },
          confirmText: '확인',
          boxType: BoxType.warning,
        );
      },
    );
    pwCheckController.clear();
  }
}
