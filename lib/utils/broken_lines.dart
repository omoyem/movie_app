import 'package:flutter/material.dart';

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double dashWidth = 6; // Length of each dash
    const double gapWidth = 4; // Length of gap between dashes
    double startX = 0;

    // Draw top dashed line
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0), // Start point
        Offset(startX + dashWidth, 0), // End point
        paint,
      );
      startX +=
          dashWidth + gapWidth; // Move the start to the next dash position
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
