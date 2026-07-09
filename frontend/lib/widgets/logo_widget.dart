import 'package:flutter/material.dart';

class AitbaarLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AitbaarLogo({
    super.key,
    this.size = 100.0,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: ShieldPainter(),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            'Aitbaar AI',
            style: TextStyle(
              color: const Color(0xFF2D4A3E),
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontFamily: 'Poppins', // Note: Make sure Poppins is added to pubspec.yaml
            ),
          ),
          SizedBox(height: size * 0.05),
          Text(
            'Detect Scams. Stay Safe.',
            style: TextStyle(
              color: const Color(0xFF5C7A6B),
              fontSize: size * 0.12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ],
    );
  }
}

class ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Gradient setup
    final Rect rect = Rect.fromLTWH(0, 0, width, height);
    final Gradient gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF8EB69B),
        Color(0xFF2E7D32),
      ],
    );

    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Shield Path
    final Path path = Path();
    path.moveTo(width * 0.1, height * 0.1); // Top left
    path.lineTo(width * 0.5, height * 0.05); // Top center dip (optional, classic shield)
    path.lineTo(width * 0.9, height * 0.1); // Top right
    
    // Right side curve towards bottom center
    path.quadraticBezierTo(
        width * 0.9, height * 0.65, width * 0.5, height * 0.95);
        
    // Left side curve towards top left
    path.quadraticBezierTo(
        width * 0.1, height * 0.65, width * 0.1, height * 0.1);
    path.close();

    canvas.drawPath(path, paint);

    // Draw the "A" inside the shield
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: 'A',
        style: TextStyle(
          color: Colors.white,
          fontSize: height * 0.55,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final Offset textOffset = Offset(
      (width - textPainter.width) / 2,
      (height - textPainter.height) / 2.2, // Slightly offset towards top to center visually
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
