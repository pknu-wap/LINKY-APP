import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/constants.dart';

class IntroducePage extends StatefulWidget {
  const IntroducePage({super.key});

  @override
  State<IntroducePage> createState() => _IntroducePageState();
}

class _IntroducePageState extends State<IntroducePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const tb = 'readme_setup/ktb.png';
    const mj = 'readme_setup/gmj.png';
    const jy = 'readme_setup/ajy.png';
    const jw = 'readme_setup/yjw.png';
    const sy = 'readme_setup/ssy.png';
    const dy = 'readme_setup/ldy.png';
    const hs = 'readme_setup/jhs.png';

    return Scaffold(
      backgroundColor: AppColors.mainBackGrey,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
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
                        'LINKY 소개',
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
                          print('눌림');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Divider(color: AppColors.outlineGrey, height: 1.5),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      const SizedBox(height: 70, width: double.infinity),
                      Text(
                        'LINKY 소개',
                        style: GoogleFonts.inter(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        '세상의 모든 링크를 한 곳에 모으다.\n스마트한 링크 관리, LINKY.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          color: AppColors.bottNavTextGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // 만든 이 소개
                      IntroduceWidget(
                        screenSize: screenSize,
                        who: '김태범',
                        imageLoc: tb,
                        color: AppColors.mainBlue,
                      ),
                      const SizedBox(height: 20),
                      IntroduceWidget(
                        screenSize: screenSize,
                        who: '구민준',
                        imageLoc: mj,
                        color: AppColors.mainBlue,
                      ),
                      const SizedBox(height: 20),
                      IntroduceWidget(
                        screenSize: screenSize,
                        who: '안지예',
                        imageLoc: jy,
                        color: AppColors.mainBlue,
                      ),
                      const SizedBox(height: 20),
                      IntroduceWidget(
                        screenSize: screenSize,
                        who: '윤재원',
                        imageLoc: jw,
                        color: AppColors.mainBlue,
                      ),
                      const SizedBox(height: 20),
                      IntroduceWidget(
                        screenSize: screenSize,
                        who: '송시연',
                        imageLoc: sy,
                        color: AppColors.mainYellow,
                      ),
                      const SizedBox(height: 20),
                      IntroduceWidget(
                        screenSize: screenSize,
                        who: '이대연',
                        imageLoc: dy,
                        color: AppColors.mainYellow,
                      ),
                      const SizedBox(height: 20),
                      IntroduceWidget(
                        screenSize: screenSize,
                        who: '조희승',
                        imageLoc: hs,
                        color: AppColors.mainRed,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IntroduceWidget extends StatelessWidget {
  const IntroduceWidget({
    super.key,
    required this.screenSize,
    required this.who,
    required this.imageLoc,
    required this.color,
  });

  final Size screenSize;
  final String who;
  final String imageLoc;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenSize.width * 0.9,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              who,
              style: GoogleFonts.inter(
                fontSize: 21,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              clipBehavior: Clip.hardEdge,
              height: 80,
              width: 80,
              child: Image.asset(
                imageLoc,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
