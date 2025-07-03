import 'package:flutter/material.dart';

class ContainerWithSharpEdgesAndCurvedSides extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  ContainerWithSharpEdgesAndCurvedSides({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: ShapePainter(color: color),
    );
  }
}

class ShapePainter extends CustomPainter {
  final Color color;

  ShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;
    Path path = Path();

    // Draw the sharp edges
    path.lineTo(20, 0);
    path.lineTo(size.width - 20, 0);
    path.lineTo(size.width, 20);
    path.lineTo(size.width, size.height - 20);
    path.lineTo(size.width - 20, size.height);
    path.lineTo(20, size.height);
    path.lineTo(0, size.height - 20);
    path.lineTo(0, 20);
    path.lineTo(20, 0);

    // Draw the curved sides
    path.moveTo(20, 0);
    path.arcToPoint(Offset(0, 20), radius: Radius.circular(20));

    path.moveTo(size.width - 20, 0);
    path.arcToPoint(
      Offset(size.width, 20),
      radius: Radius.circular(20),
      clockwise: false,
    );

    path.moveTo(size.width, size.height - 20);
    path.arcToPoint(
      Offset(size.width - 20, size.height),
      radius: Radius.circular(20),
      clockwise: false,
    );

    path.moveTo(20, size.height);
    path.arcToPoint(
      Offset(0, size.height - 20),
      radius: Radius.circular(20),
      clockwise: false,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
