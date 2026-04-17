import 'package:flutter/material.dart';

class RoundedRightTriangle extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const RoundedRightTriangle({
    super.key,
    this.width = 60,
    this.height = 60,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _RoundedTrianglePainter(color: color),
      ),
    );
  }
}

class _RoundedTrianglePainter extends CustomPainter {
  final Color color;

  _RoundedTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path = Path();

    // 1. 왼쪽 위에서 시작 (약간 아래에서 시작)
    path.moveTo(0, 0);

    // 2. 왼쪽 아래(직각 부분)로 선을 긋고 굴리기
    path.lineTo(0, size.height);

    // 3. 오른쪽 아래로 선을 긋고 굴리기
    path.lineTo(size.width, size.height);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
