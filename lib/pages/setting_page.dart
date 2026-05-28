import 'package:flutter/material.dart';
import 'package:std/constants.dart';
import 'package:std/widgets/public_appbar.dart';
import 'package:std/widgets/public_messagebox.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  InputDecoration inputBox(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.outlineGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.outlineGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.mainGreen),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackGrey,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  AppBarDesign(
                    appbarText: 'Setting',
                    appbarIcon: Icons.settings_outlined,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: const [
                      Icon(
                        Icons.account_circle,
                        color: AppColors.mainGreen,
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "나만 보기 페이지 비밀 번호 설정",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: true,
                    decoration: inputBox("비밀번호를 입력해주세요."),
                  ),

                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return DialogPopup(
                            title: '데이터 초기화 하시겠어요?',
                            boxType: BoxType.warning,
                            onConfirm: () => print('데이터 초기화 완료'),
                            confirmText: '초기화',
                          );
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Center(
                        child: Text(
                          "데이터 초기화",
                          style: TextStyle(
                            color: AppColors.mainRed,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
