import 'package:flutter/material.dart';

class FolderShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xff3fd966) // 💡 첨부해주신 이미지와 비슷한 밝은 초록색
      ..style = PaintingStyle.fill;

    final path = Path();

    // 디자인 수치 설정
    final double radius = 24.0; // 전체적인 둥글기
    final double tabWidth = size.width * 0.45; // 탭의 너비 (전체의 45%)
    final double tabHeight = 40.0; // 탭의 높이

    // 1. 탭 왼쪽 상단에서 시작
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // 2. 탭 상단 선 ~ 탭 오른쪽 상단 곡선
    path.lineTo(tabWidth - radius, 0);
    path.quadraticBezierTo(tabWidth, 0, tabWidth, radius);

    // 3. 탭 오른쪽 선 ~ 메인 카드와 만나는 안쪽(오목한) 곡선
    path.lineTo(tabWidth, tabHeight - radius);
    path.quadraticBezierTo(tabWidth, tabHeight, tabWidth + radius, tabHeight);

    // 4. 메인 카드 상단 선 ~ 메인 카드 오른쪽 상단 곡선
    path.lineTo(size.width - radius, tabHeight);
    path.quadraticBezierTo(
      size.width,
      tabHeight,
      size.width,
      tabHeight + radius,
    );

    // 5. 메인 카드 오른쪽 선 ~ 우측 하단 곡선
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );

    // 6. 메인 카드 하단 선 ~ 좌측 하단 곡선
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // 7. 다시 시작점(탭 왼쪽)으로 연결
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
