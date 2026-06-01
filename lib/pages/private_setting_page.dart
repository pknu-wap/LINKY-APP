import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:std/constants.dart';
import 'package:std/main.dart';
import 'package:std/services/auth_service.dart';
import 'package:std/snackbar.dart';
import 'package:std/widgets/public_appbar.dart';
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
        borderSide: const BorderSide(color: AppColors.outlineGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.outlineGrey),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.outlineGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.mainGreen),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                AppBarDesign(
                  appbarText: '나만보기 설정',
                  appbarIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 25),
                const Row(
                  children: [
                    Icon(
                      Icons.account_circle,
                      color: AppColors.mainGreen,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "잠금 방식 설정",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
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
                          height: 54,
                          decoration: BoxDecoration(
                            color: (_localLockWith == LockWith.customPw)
                                ? AppColors.mainGreen
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.lightGrey),
                          ),
                          child: Center(
                            child: Text(
                              'custom_pw',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: (_localLockWith == LockWith.customPw)
                                    ? AppColors.white
                                    : AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (customPw != null &&
                              lockWith == LockWith.customPw) {
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
                          height: 54,
                          decoration: BoxDecoration(
                            color: (_localLockWith == LockWith.localAuth)
                                ? AppColors.mainGreen
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.lightGrey),
                          ),
                          child: Center(
                            child: Text(
                              'local_auth',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: (_localLockWith == LockWith.localAuth)
                                    ? AppColors.white
                                    : AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_localLockWith == LockWith.customPw)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: pwController,
                          enabled: _isPwEnabled,
                          obscureText: true,
                          decoration: inputBox(
                            "비밀번호를 입력해주세요.",
                            fillColor: _isPwEnabled
                                ? AppColors.white
                                : AppColors.outlineGrey.withValues(alpha: 0.5),
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
                              await prefs.setString('lock_method', 'customPw');

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
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.lightGrey),
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
              ],
            ),
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
