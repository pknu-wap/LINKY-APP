import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/widgets/public_popup_menu_button.dart';

class TripleFolderBottomSheet extends StatefulWidget {
  final String contentTitle, url;

  const TripleFolderBottomSheet({
    super.key,
    required this.contentTitle,
    required this.url,
  });

  @override
  State<TripleFolderBottomSheet> createState() =>
      _TripleFolderBottomSheetState();
}

class _TripleFolderBottomSheetState extends State<TripleFolderBottomSheet> {
  // 처음에는 화면 아래(1000px)에 숨겨둡니다.
  double _top1 = 1000;
  double _top2 = 1000;
  double _top3 = 1000;

  @override
  void initState() {
    super.initState();
    // 위젯이 그려진 직후에 순차적으로 위치(top) 값을 올려줍니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _top1 = 0);

      Future.delayed(const Duration(milliseconds: 70), () {
        if (mounted) setState(() => _top2 = 38); // 70px 아래 배치
      });

      Future.delayed(const Duration(milliseconds: 110), () {
        if (mounted) setState(() => _top3 = 92); // 140px 아래 배치
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    // 시트 전체의 높이 지정 (폴더 높이 + 겹치는 여백 고려)
    double sheetHeight = screenSize.height - 100;

    return SizedBox(
      height: sheetHeight,
      width: screenSize.width,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 첫 번째 폴더 (맨 뒤)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: _top1,
            child: Transform.translate(
              offset: const Offset(27, 0),
              child: ContentDetailSheet(
                title: widget.contentTitle,
                urlLink: widget.url,
                showContent: false,
                subWidth: 80,
                color: Color(0xffeaeaea),
              ),
            ),
          ),
          // 두 번째 폴더 (중간)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: _top2,
            child: Transform.translate(
              offset: const Offset(16, 0),
              child: ContentDetailSheet(
                title: widget.contentTitle,
                urlLink: widget.url,
                showContent: false,
                subWidth: 33,
                color: Color(0xffC8C8C8),
              ),
            ),
          ),
          // 세 번째 폴더 (맨 앞)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: _top3,
            child: ContentDetailSheet(
              title: widget.contentTitle,
              urlLink: widget.url,
              showContent: true,
              subWidth: 0,
              color: Color(0xff3fd966),
            ),
          ),
        ],
      ),
    );
  }
}

class ContentDetailSheet extends StatelessWidget {
  final Color color;
  final int subWidth;
  final bool showContent;
  final String title, urlLink;

  const ContentDetailSheet({
    super.key,
    required this.color,
    required this.subWidth,
    required this.showContent,
    required this.title,
    required this.urlLink,
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double folderWidth = screenSize.width - 28 - subWidth;
    double folderHeight = screenSize.height - 260;

    return Material(
      color: Colors.transparent, // InkWell 에러 방지용 투명 Material
      child: SizedBox(
        width: folderWidth,
        height: folderHeight,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(folderWidth, folderHeight),
              painter: FolderShapePainter(backColor: color),
            ),
            if (showContent)
              Padding(
                padding: const EdgeInsets.only(top: 78, left: 26, right: 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '제목',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                decoration: TextDecoration.none,
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(width: 20),
                            Text(
                              title,
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                decoration: TextDecoration.none,
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),

                        PopupButton(
                          onActionDone: () => print('삭제 버튼 클릭됨'),
                          context: context,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1, color: Colors.black),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'URL',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                decoration: TextDecoration.none,
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(width: 20),
                            Text(
                              urlLink,
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                decoration: TextDecoration.none,
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),

                        InkWell(
                          onTap: () => print('이동 버튼 클릭'),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 70,
                            height: 39,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                '이동',
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(thickness: 1, color: Colors.black),
                    const SizedBox(height: 10),
                    Text(
                      '요약',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FolderShapePainter extends CustomPainter {
  const FolderShapePainter({required this.backColor});

  final Color backColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backColor
      ..style = PaintingStyle.fill;

    final path = Path();

    final double radius = 25.0;
    final double tabWidth = size.width * 0.45;
    final double tabHeight = 40.0;

    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    path.lineTo(tabWidth - radius, 0);
    path.quadraticBezierTo(
      tabWidth,
      0,
      tabWidth + size.width * 0.13,
      radius + tabHeight / 1.5,
    );

    path.lineTo(size.width - radius, radius + tabHeight / 1.5);

    path.quadraticBezierTo(
      size.width,
      radius + tabHeight / 1.5,
      size.width,
      tabHeight + radius * 1.5,
    );

    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );

    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
