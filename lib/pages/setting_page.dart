import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/pages/category_setting_page.dart';
import 'package:std/pages/introduce_page.dart';
import 'package:std/pages/private_setting_page.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/snackbar.dart';
import 'package:std/widgets/public_appbar.dart';
import 'package:std/widgets/public_messagebox.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
    });
  }

  Future<void> _onResetConfirm() async {
    try {
      await context.read<AppState>().resetAllData();

      if (!mounted) return;

      showCustomSnackBar(
        context,
        message: '데이터가 초기화되었습니다.',
        isError: false,
      );
    } catch (e) {
      if (!mounted) return;

      showCustomSnackBar(
        context,
        message: '초기화에 실패했습니다.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackGrey,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppBarDesign(
                    appbarText: 'Setting',
                    appbarIcon: Icons.settings_outlined,
                  ),
                ),

                const SizedBox(height: 25),

                SettingMenu(
                  icon: Icons.reorder,
                  text: '카테고리 설정',
                  onTap: () => settingAnimation(context, CategorySettingPage()),
                ),

                SettingMenu(
                  icon: Icons.account_circle_outlined,
                  text: '나만보기 설정',
                  onTap: () => settingAnimation(context, PrivateSettingPage()),
                ),

                SettingMenu(
                  icon: Icons.info_outline_rounded,
                  text: 'LINKY 소개',
                  onTap: () => settingAnimation(context, IntroducePage()),
                ),

                SettingMenu(
                  icon: Icons.info_outline_rounded,
                  text: '앱 버전',
                  needMove: false,
                  text2: 'v$_appVersion',
                  onTap: () {},
                ),

                Divider(
                  height: 1,
                  color: AppColors.outlineGrey.withValues(alpha: 0.3),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (dialogContext) {
                          return DialogPopup(
                            title: '데이터를 초기화하시겠습니까?',
                            boxType: BoxType.warning,
                            onConfirm: () {
                              _onResetConfirm();
                              print('초기화 완료');
                              return true;
                            },
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
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void settingAnimation(BuildContext context, Widget moveTo) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => moveTo,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

class SettingMenu extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool needMove;
  final String text2;

  const SettingMenu({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.needMove = true,
    this.text2 = '',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Divider(
            height: 1,
            color: AppColors.outlineGrey.withValues(alpha: 0.3),
          ),
          Container(
            color: AppColors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: AppColors.textGrey,
                        size: 35,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        text,
                        style: GoogleFonts.inter(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  if (needMove)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textGrey,
                    ),
                  if (!needMove)
                    Text(
                      text2,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.textGrey,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
