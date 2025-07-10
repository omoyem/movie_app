import 'package:flutter/material.dart';

class CurvedTopContainer extends StatelessWidget {
  final double height;
  final Color color;
  final Widget? child;

  const CurvedTopContainer({
    super.key,
    this.height = 200,
    this.color = Colors.blue,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Curved top background
        CustomPaint(
          painter: _UpwardCurvePainter(color),
          size: Size(MediaQuery.of(context).size.width, height),
        ),

        // Foreground content inside the container
        SizedBox(
          height: height,
          width: double.infinity,
          child: Center(child: child),
        ),
      ],
    );
  }
}

class _UpwardCurvePainter extends CustomPainter {
  final Color color;

  _UpwardCurvePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height); // Start from bottom-left
    path.lineTo(0, size.height * 0.2); // Go up a bit

    // Draw an upward concave curve
    path.quadraticBezierTo(
      size.width / 2, 0, // control point (curve dip)
      size.width, size.height * 0.2, // right dip edge
    );

    path.lineTo(size.width, size.height); // down to bottom-right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
